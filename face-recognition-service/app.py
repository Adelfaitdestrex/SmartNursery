import os
import io
from datetime import datetime

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
bucket = storage.bucket()


def load_image_from_url(url: str) -> np.ndarray:
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    img = Image.open(io.BytesIO(response.content))
    if img.mode != "RGB":
        img = img.convert("RGB")
    return np.array(img)


def get_face_encodings(image: np.ndarray) -> list:
    return face_recognition.face_encodings(image)


# ==========================================
# MODE LENT : Charge images depuis Storage
# ==========================================
def get_registered_faces_from_storage() -> dict:
    """Charge les images depuis Firebase Storage (LENT mais fiable)"""
    faces_data = {}
    users = db.collection("users").stream()

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
            user_name = user_data.get("name") or user_data.get("email") or f"User {user_id}"

            for blob in face_refs:
                try:
                    img_data = blob.download_as_bytes()
                    img = Image.open(io.BytesIO(img_data))
                    if img.mode != "RGB":
                        img = img.convert("RGB")
                    img_array = np.array(img)
                    encodings = get_face_encodings(img_array)
                    user_faces.extend(encodings)
                except Exception as e:
                    print(f"⚠️ Erreur lecture blob {blob.name}: {e}")
                    continue

            if user_faces:
                faces_data[user_id] = {
                    "name": user_name,
                    "role": role,
                    "encodings": user_faces,
                }
        except Exception as e:
            print(f"⚠️ Erreur chargement faces {user_id}: {e}")
            continue

    return faces_data


# ==========================================
# MODE RAPIDE : Charge encodings depuis Firestore
# ==========================================
def get_registered_faces_from_firestore() -> dict:
    """Charge les encodings depuis Firestore (RAPIDE)"""
    faces_data = {}
    users = db.collection("users").stream()

    for user_doc in users:
        user_id = user_doc.id
        user_data = user_doc.to_dict() or {}
        
        # Vérifie si l'utilisateur a des encodings
        if not user_data.get("hasFaceData") or "faceEncodings" not in user_data:
            continue

        role = (user_data.get("role", "") or "").lower()
        is_authorized = role in ["parent", "admin", "educateur", "educator"]
        
        if not is_authorized:
            continue

        try:
            user_name = user_data.get("name") or user_data.get("email") or f"User {user_id}"
            
            # Récupère les encodings (peut être liste simple ou liste de listes)
            encodings_data = user_data.get("faceEncodings", [])
            
            # Normalise en liste d'encodings
            if encodings_data:
                # Si c'est une liste simple de 128 chiffres
                if isinstance(encodings_data[0], (int, float)):
                    encodings = [np.array(encodings_data)]
                # Si c'est une liste de listes
                else:
                    encodings = [np.array(enc) for enc in encodings_data]
                
                faces_data[user_id] = {
                    "name": user_name,
                    "role": role,
                    "encodings": encodings,
                }
        except Exception as e:
            print(f"⚠️ Erreur parsing encodings {user_id}: {e}")
            continue

    return faces_data


def compare_face(unknown_encoding: np.ndarray, registered_faces: dict) -> tuple:
    """Compare un visage avec tous les visages enregistrés"""
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


# ==========================================
# ENDPOINTS
# ==========================================

@app.get("/health")
def health():
    return jsonify({
        "status": "ok",
        "firebase_initialized": db is not None,
        "message": "Face recognition service actif",
    })


@app.post("/recognize")
def recognize_face():
    """
    🐢 MODE LENT : Charge les images depuis Storage (fallback fiable)
    """
    data = request.get_json(silent=True) or {}
    image_url = data.get("imageUrl") or data.get("image_url")

    if not image_url:
        return jsonify({"recognized": False, "message": "imageUrl manquante"}), 400

    try:
        print("[RECOGNIZE SLOW] === DÉBUT (mode Storage) ===")
        
        image = load_image_from_url(image_url)
        unknown_encodings = get_face_encodings(image)

        if not unknown_encodings:
            return jsonify({"recognized": False, "message": "Aucun visage détecté"}), 200

        registered_faces = get_registered_faces_from_storage()
        
        if not registered_faces:
            print("[RECOGNIZE SLOW] ⚠️ Aucune image dans Storage, utiliser /recognize_pro")
            return jsonify({
                "recognized": False,
                "message": "Aucun visage enregistré dans Storage"
            }), 200

        matched, user_id, user_data, distance = compare_face(
            unknown_encodings[0],
            registered_faces,
        )

        if matched:
            print(f"[RECOGNIZE SLOW] ✅ Match: {user_data.get('name')}")
            return jsonify({
                "recognized": True,
                "personId": user_id,
                "personName": user_data.get("name", "Personne autorisée"),
                "role": user_data.get("role", ""),
                "confidence": max(0.0, 1.0 - distance),
                "message": f"Visage reconnu: {user_data.get('name')}",
                "mode": "storage",
            })

        return jsonify({
            "recognized": False,
            "message": "Visage non reconnu",
        })

    except Exception as exc:
        print(f"[RECOGNIZE SLOW] ❌ Erreur: {exc}")
        return jsonify({"recognized": False, "message": f"Erreur: {exc}"}), 500


@app.post("/recognize_pro")
def recognize_pro():
    """
    🚀 MODE RAPIDE : Utilise les encodings Firestore (recommandé)
    """
    data = request.get_json(silent=True) or {}
    image_url = data.get("imageUrl") or data.get("image_url")

    if not image_url:
        return jsonify({"recognized": False, "message": "imageUrl manquante"}), 400

    try:
        print("[RECOGNIZE PRO] === DÉBUT (mode Firestore) ===")
        
        image = load_image_from_url(image_url)
        unknown_encodings = get_face_encodings(image)

        if not unknown_encodings:
            return jsonify({"recognized": False, "message": "Aucun visage détecté"}), 200

        registered_faces = get_registered_faces_from_firestore()
        
        if not registered_faces:
            print("[RECOGNIZE PRO] ⚠️ Aucun encoding dans Firestore")
            return jsonify({
                "recognized": False,
                "message": "Aucun encodage enregistré"
            }), 200

        matched, user_id, user_data, distance = compare_face(
            unknown_encodings[0],
            registered_faces,
        )

        if matched:
            print(f"[RECOGNIZE PRO] ✅ Match: {user_data.get('name')} (distance={distance:.4f})")
            return jsonify({
                "recognized": True,
                "personId": user_id,
                "personName": user_data.get("name", "Personne autorisée"),
                "role": user_data.get("role", ""),
                "confidence": max(0.0, 1.0 - distance),
                "distance": distance,
                "message": f"✅ Visage reconnu: {user_data.get('name')}",
                "mode": "firestore",
            })

        return jsonify({
            "recognized": False,
            "message": "❌ Visage non reconnu",
        })

    except Exception as exc:
        print(f"[RECOGNIZE PRO] ❌ Erreur: {exc}")
        import traceback
        traceback.print_exc()
        return jsonify({"recognized": False, "message": f"Erreur: {exc}"}), 500


@app.post("/register_parent_face")
def register_parent_face():
    """
    📸 Enregistre un visage en DOUBLE :
    1. Encodings dans Firestore (rapide)
    2. Image dans Storage (fallback)
    """
    data = request.get_json(silent=True) or {}
    image_url = data.get("imageUrl") or data.get("image_url")
    parent_id = data.get("parentId") or data.get("parent_id")

    if not image_url or not parent_id:
        return jsonify({
            "success": False,
            "message": "imageUrl et parentId requis"
        }), 400

    try:
        print(f"[REGISTER] 📸 Enregistrement pour {parent_id}")
        
        # 1. Charge l'image
        response = requests.get(image_url, timeout=10)
        response.raise_for_status()
        img_bytes = response.content
        
        img = Image.open(io.BytesIO(img_bytes))
        if img.mode != "RGB":
            img = img.convert("RGB")
        img_array = np.array(img)
        
        # 2. Calcule l'encoding
        encodings = get_face_encodings(img_array)
        if not encodings:
            return jsonify({
                "success": False,
                "message": "Aucun visage détecté"
            }), 200

        encoding_list = encodings[0].tolist()
        
        # 3. Sauvegarde dans Firestore (rapide)
        user_ref = db.collection("users").document(parent_id)
        user_ref.set({
            "faceEncodings": encoding_list,
            "hasFaceData": True,
            "lastFaceRegisteredAt": firestore.SERVER_TIMESTAMP,
        }, merge=True)
        
        print(f"[REGISTER] ✅ Encodings sauvegardés dans Firestore")
        
        # 4. Upload image dans Storage (fallback)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        blob_path = f"faces/parents/{parent_id}/{timestamp}.jpg"
        blob = bucket.blob(blob_path)
        
        # Convertit en JPEG si nécessaire
        img_io = io.BytesIO()
        img.save(img_io, format='JPEG', quality=95)
        img_io.seek(0)
        
        blob.upload_from_file(img_io, content_type='image/jpeg')
        print(f"[REGISTER] ✅ Image uploadée: {blob_path}")

        return jsonify({
            "success": True,
            "message": "Visage enregistré (Firestore + Storage)",
            "encoding": encoding_list[:5],  # Juste un aperçu
            "storagePath": blob_path,
        }), 200

    except Exception as exc:
        print(f"[REGISTER] ❌ Erreur: {exc}")
        import traceback
        traceback.print_exc()
        return jsonify({
            "success": False,
            "message": f"Erreur: {str(exc)}"
        }), 500


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8080"))
    app.run(host="0.0.0.0", port=port, debug=True)