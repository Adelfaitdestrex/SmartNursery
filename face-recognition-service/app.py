import os
import io

from flask import Flask, request, jsonify
from flask_cors import CORS
from PIL import Image
import numpy as np
import requests
import face_recognition
import firebase_admin
from firebase_admin import firestore, storage

app = Flask(__name__)
CORS(app)

FACE_TOLERANCE = float(os.getenv("FACE_TOLERANCE", "0.6"))
STORAGE_BUCKET = os.getenv("FIREBASE_STORAGE_BUCKET", "")

try:
    firebase_admin.get_app()
except ValueError:
    if STORAGE_BUCKET:
        firebase_admin.initialize_app(options={"storageBucket": STORAGE_BUCKET})
    else:
        firebase_admin.initialize_app()

db = firestore.client()


def load_image_from_url(url: str) -> np.ndarray:
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    img = Image.open(io.BytesIO(response.content))
    if img.mode != "RGB":
        img = img.convert("RGB")
    return np.array(img)


def get_face_encodings(image: np.ndarray) -> list:
    return face_recognition.face_encodings(image)


def get_registered_faces_from_firestore() -> dict:
    faces_data = {}

    users = db.collection("users").stream()
    bucket = storage.bucket()

    for user_doc in users:
        user_id = user_doc.id
        user_data = user_doc.to_dict() or {}
        role = (user_data.get("role", "") or "").lower()

        is_authorized = role in ["parent", "admin", "educateur", "educator"]
        if not is_authorized or not user_data.get("hasFaceData"):
            continue

        try:
            face_refs = bucket.list_blobs(prefix=f"faces/parents/{user_id}/")
            user_faces = []
            user_name = user_data.get("name") or user_data.get("email") or f"Utilisateur {user_id}"

            for blob in face_refs:
                try:
                    img_data = blob.download_as_bytes()
                    img = Image.open(io.BytesIO(img_data))
                    if img.mode != "RGB":
                        img = img.convert("RGB")
                    img_array = np.array(img)
                    encodings = get_face_encodings(img_array)
                    user_faces.extend(encodings)
                except Exception:
                    continue

            if user_faces:
                faces_data[user_id] = {
                    "name": user_name,
                    "role": role,
                    "encodings": user_faces,
                }
        except Exception:
            continue

    return faces_data


def compare_face(unknown_encoding: np.ndarray, registered_faces: dict) -> tuple:
    best_distance = float("inf")
    matched_user_id = None
    matched_user_data = None

    for user_id, user_data in registered_faces.items():
        distances = face_recognition.face_distance(
            user_data["encodings"],
            unknown_encoding,
        )
        min_distance = np.min(distances)
        if min_distance < best_distance:
            best_distance = min_distance
            matched_user_id = user_id
            matched_user_data = user_data

    if best_distance < FACE_TOLERANCE:
        return True, matched_user_id, matched_user_data, float(best_distance)

    return False, None, None, float(best_distance)


@app.get("/health")
def health():
    return jsonify({
        "status": "ok",
        "firebase_initialized": db is not None,
        "message": "Face recognition service actif",
    })


@app.post("/recognize")
def recognize_face():
    data = request.get_json(silent=True) or {}
    image_url = data.get("imageUrl") or data.get("image_url")

    if not image_url:
        return jsonify({"recognized": False, "message": "imageUrl manquante"}), 400

    try:
        image = load_image_from_url(image_url)
        unknown_encodings = get_face_encodings(image)

        if not unknown_encodings:
            return jsonify({"recognized": False, "message": "Aucun visage detecte"}), 200

        registered_faces = get_registered_faces_from_firestore()
        if not registered_faces:
            return jsonify({"recognized": False, "message": "Aucun visage enregistre"}), 200

        matched, user_id, user_data, distance = compare_face(
            unknown_encodings[0],
            registered_faces,
        )

        if matched:
            return jsonify({
                "recognized": True,
                "personId": user_id,
                "personName": user_data.get("name", "Personne autorisee"),
                "role": user_data.get("role", ""),
                "confidence": max(0.0, 1.0 - distance),
                "message": f"Visage reconnu: {user_data.get('name', 'Personne autorisee')}",
                "result": "Autorise",
            })

        return jsonify({
            "recognized": False,
            "message": "Visage non reconnu - Aucune correspondance",
        })

    except Exception as exc:
        return jsonify({"recognized": False, "message": f"Erreur: {exc}"}), 500


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8080"))
    app.run(host="0.0.0.0", port=port)
