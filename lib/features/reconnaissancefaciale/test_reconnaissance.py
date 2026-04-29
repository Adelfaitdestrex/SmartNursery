from flask import Flask, jsonify, request
import face_recognition
import numpy as np
from PIL import Image


app = Flask(__name__)

# Exemple : visage enregistré (à remplacer par une base de données)
known_encodings = []
known_names = []


def load_known_face(image_path: str, person_name: str) -> None:
    try:
        image = face_recognition.load_image_file(image_path)
        encodings = face_recognition.face_encodings(image)
        if not encodings:
            print(f"Aucun visage trouvé dans {image_path}")
            return

        known_encodings.append(encodings[0])
        known_names.append(person_name)
    except FileNotFoundError:
        print(f"Image de référence introuvable: {image_path}")


load_known_face("person1.jpg", "Parent 1")


@app.route("/recognize", methods=["POST"])
def recognize():
    if "image" not in request.files:
        return jsonify({"error": "No image"}), 400

    file = request.files["image"]
    img = Image.open(file.stream).convert("RGB")
    img = np.array(img)

    face_encodings = face_recognition.face_encodings(img)

    if len(face_encodings) == 0:
        return jsonify({"result": "Aucun visage détecté"})

    face_encoding = face_encodings[0]
    matches = face_recognition.compare_faces(known_encodings, face_encoding)

    if True in matches:
        index = matches.index(True)
        name = known_names[index]
        return jsonify({"result": "Autorisé", "name": name})

    return jsonify({"result": "Refusé"})


if __name__ == "__main__":
    app.run(debug=True)