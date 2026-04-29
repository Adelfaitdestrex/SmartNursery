"""Cloud Function pour la reconnaissance faciale avec Firebase"""
import functions_framework
import face_recognition
import numpy as np
from PIL import Image
import io
import requests
from firebase_admin import initialize_app, credentials, storage, firestore
import json
from typing import Dict, Any, List, Tuple

# Initialiser Firebase (les credentials sont automatiquement fournis)
try:
    initialize_app()
except Exception:
    pass  # App déjà initialisée

db = firestore.client()


def load_image_from_url(url: str) -> np.ndarray:
    """Télécharge et charge une image à partir d'une URL"""
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        img = Image.open(io.BytesIO(response.content))
        if img.mode != 'RGB':
            img = img.convert('RGB')
        return np.array(img)
    except Exception as e:
        raise ValueError(f"Erreur lors du chargement de l'image: {e}")


def get_face_encodings(image: np.ndarray) -> List[np.ndarray]:
    """Extrait les encodages des visages d'une image"""
    try:
        return face_recognition.face_encodings(image)
    except Exception as e:
        raise ValueError(f"Erreur lors du traitement de l'image: {e}")


def get_registered_faces() -> Dict[str, List[np.ndarray]]:
    """Récupère tous les visages enregistrés depuis Firestore et Storage"""
    try:
        children = db.collection('children').stream()
        faces_data = {}

        for child_doc in children:
            child_id = child_doc.id
            child_data = child_doc.to_dict()

            if not child_data or 'name' not in child_data:
                continue

            try:
                # Récupère les URLs des visages stockés
                bucket = storage.bucket()
                blobs = bucket.list_blobs(prefix=f'faces/{child_id}/')
                
                child_faces = []
                for blob in blobs:
                    try:
                        face_url = blob.public_url
                        img = load_image_from_url(face_url)
                        encodings = get_face_encodings(img)
                        child_faces.extend(encodings)
                    except Exception as e:
                        print(f"Erreur traitement visage {blob.name}: {e}")
                        continue

                if child_faces:
                    faces_data[child_id] = {
                        'name': child_data.get('name', 'Unknown'),
                        'encodings': child_faces,
                    }
            except Exception as e:
                print(f"Erreur pour l'enfant {child_id}: {e}")
                continue

        return faces_data
    except Exception as e:
        raise ValueError(f"Erreur lors de la récupération des visages: {e}")


def compare_faces(
    unknown_encoding: np.ndarray,
    known_faces: Dict[str, Any],
    tolerance: float = 0.6,
) -> Tuple[bool, str]:
    """Compare un visage avec les visages enregistrés"""
    best_distance = float('inf')
    matched_child_id = None

    for child_id, child_data in known_faces.items():
        distances = face_recognition.face_distance(
            child_data['encodings'],
            unknown_encoding,
        )
        min_distance = np.min(distances)

        if min_distance < best_distance:
            best_distance = min_distance
            matched_child_id = child_id

    # Si la meilleure distance est en dessous du seuil, c'est un match
    if best_distance < tolerance:
        return True, matched_child_id

    return False, None


@functions_framework.http
def recognize_face(request):
    """HTTP Cloud Function pour la reconnaissance faciale"""
    # Active CORS
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
        }
        return ('', 204, headers)

    try:
        # Parse la requête JSON
        data = request.get_json() if request.is_json else {}

        if not data or 'imageUrl' not in data:
            return (
                json.dumps({
                    'recognized': False,
                    'message': 'imageUrl manquante',
                }),
                400,
                {'Content-Type': 'application/json',
                 'Access-Control-Allow-Origin': '*'},
            )

        image_url = data.get('imageUrl', '')

        # Charge l'image depuis l'URL
        image = load_image_from_url(image_url)

        # Extrait les encodages du visage inconnu
        unknown_encodings = get_face_encodings(image)

        if not unknown_encodings:
            return (
                json.dumps({
                    'recognized': False,
                    'message': 'Aucun visage détecté dans l\'image',
                }),
                200,
                {'Content-Type': 'application/json',
                 'Access-Control-Allow-Origin': '*'},
            )

        # Récupère les visages enregistrés
        registered_faces = get_registered_faces()

        if not registered_faces:
            return (
                json.dumps({
                    'recognized': False,
                    'message': 'Aucun visage enregistré dans la base de données',
                }),
                200,
                {'Content-Type': 'application/json',
                 'Access-Control-Allow-Origin': '*'},
            )

        # Compare avec le premier visage détecté
        unknown_encoding = unknown_encodings[0]
        is_match, matched_child_id = compare_faces(unknown_encoding, registered_faces)

        if is_match:
            return (
                json.dumps({
                    'recognized': True,
                    'childId': matched_child_id,
                    'message': f'Visage reconnu: {registered_faces[matched_child_id]["name"]}',
                }),
                200,
                {'Content-Type': 'application/json',
                 'Access-Control-Allow-Origin': '*'},
            )

        return (
            json.dumps({
                'recognized': False,
                'message': 'Visage non reconnu - Aucune correspondance trouvée',
            }),
            200,
            {'Content-Type': 'application/json',
             'Access-Control-Allow-Origin': '*'},
        )

    except ValueError as ve:
        return (
            json.dumps({
                'recognized': False,
                'message': str(ve),
            }),
            400,
            {'Content-Type': 'application/json',
             'Access-Control-Allow-Origin': '*'},
        )
    except Exception as e:
        print(f"Erreur non gérée: {e}")
        return (
            json.dumps({
                'recognized': False,
                'message': f'Erreur serveur: {str(e)}',
            }),
            500,
            {'Content-Type': 'application/json',
             'Access-Control-Allow-Origin': '*'},
        )
