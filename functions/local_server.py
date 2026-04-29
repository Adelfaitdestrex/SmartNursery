"""
Serveur Flask local pour la reconnaissance faciale SmartNursery
Utilise la bibliothèque face_recognition et Firebase

Pour démarrer:
    pip install -r requirements.txt
    python local_server.py
"""

import os
import sys
from pathlib import Path
import json
import tempfile
import io

import face_recognition
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
from PIL import Image
import requests

# Import Firebase
import firebase_admin
from firebase_admin import credentials, firestore, storage

# Configuration
app = Flask(__name__)
CORS(app)
PORT = 5000

# Variables globales
db = None
storage_bucket = None
FACE_TOLERANCE = 0.6  # Seuil de similarité (0-1, plus bas = plus strict)

# ============================================================================
# INITIALISATION FIREBASE
# ============================================================================
def init_firebase():
    """Initialise Firebase Admin"""
    global db, storage_bucket
    
    try:
        # Cherche le fichier de credentials
        cred_paths = [
            'temp_service_account.json',
            Path.home() / '.config/smartnursery/service_account.json',
            os.getenv('FIREBASE_CREDENTIALS_PATH', '')
        ]
        
        cred_file = None
        for path in cred_paths:
            if path and os.path.exists(path):
                cred_file = path
                break
        
        if not cred_file:
            print("⚠️  ATTENTION: Fichier de credentials Firebase non trouvé!")
            print(f"   Cherché dans:")
            for path in cred_paths:
                if path:
                    print(f"     - {path}")
            print("\n   ➡️  Placez votre fichier service_account.json dans le dossier functions/")
            print("   ➡️  Ou définissez FIREBASE_CREDENTIALS_PATH")
            return False
        
        if not firebase_admin.get_app():
            creds = credentials.Certificate(str(cred_file))
            firebase_admin.initialize_app(creds, {
                'storageBucket': 'smartnursery-b46102cf.appspot.com'
            })
        
        db = firestore.client()
        storage_bucket = storage.bucket()
        print("✅ Firebase initialisé avec succès!")
        return True
        
    except Exception as e:
        print(f"❌ Erreur Firebase: {e}")
        return False


# ============================================================================
# FONCTIONS DE RECONNAISSANCE FACIALE
# ============================================================================

def load_image_from_url(url: str) -> np.ndarray:
    """Télécharge et charge une image depuis une URL"""
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        img = Image.open(io.BytesIO(response.content))
        if img.mode != 'RGB':
            img = img.convert('RGB')
        return np.array(img)
    except Exception as e:
        raise ValueError(f"Erreur chargement image: {e}")


def get_face_encodings(image: np.ndarray) -> list:
    """Extrait les encodages des visages d'une image"""
    try:
        encodings = face_recognition.face_encodings(image)
        if not encodings:
            raise ValueError("Aucun visage détecté dans l'image")
        return encodings
    except Exception as e:
        raise ValueError(f"Erreur extraction visage: {e}")


def get_registered_faces_from_firestore() -> dict:
    """Récupère tous les visages enregistrés depuis Firebase"""
    try:
        faces_data = {}
        
        # Récupère tous les utilisateurs (parents/éducateurs)
        users = db.collection('users').stream()
        
        for user_doc in users:
            user_id = user_doc.id
            user_data = user_doc.to_dict() or {}
            role = (user_data.get('role', '') or '').lower()
            
            # Vérifie si c'est une personne autorisée
            is_authorized = role in ['parent', 'admin', 'educateur', 'educator']
            if not is_authorized or not user_data.get('hasFaceData'):
                continue
            
            try:
                # Liste les visages dans Storage
                face_refs = storage_bucket.list_blobs(
                    prefix=f'faces/parents/{user_id}/'
                )
                
                user_faces = []
                user_name = user_data.get('name', user_data.get('email', f'Utilisateur {user_id}'))
                
                for blob in face_refs:
                    try:
                        # Charge l'image depuis Storage
                        img_data = blob.download_as_bytes()
                        img = Image.open(io.BytesIO(img_data))
                        if img.mode != 'RGB':
                            img = img.convert('RGB')
                        img_array = np.array(img)
                        
                        # Extrait les encodages
                        encodings = get_face_encodings(img_array)
                        user_faces.extend(encodings)
                        
                    except Exception as e:
                        print(f"⚠️  Erreur traitement {blob.name}: {e}")
                        continue
                
                if user_faces:
                    faces_data[user_id] = {
                        'name': user_name,
                        'role': role,
                        'encodings': user_faces
                    }
                    print(f"✅ Chargé {len(user_faces)} encodages pour {user_name}")
                    
            except Exception as e:
                print(f"⚠️  Erreur récupération visages pour {user_id}: {e}")
                continue
        
        if not faces_data:
            print("⚠️  Aucun visage enregistré trouvé")
        
        return faces_data
        
    except Exception as e:
        print(f"❌ Erreur récupération visages Firebase: {e}")
        return {}


def compare_face(unknown_encoding: np.ndarray, registered_faces: dict, tolerance: float = FACE_TOLERANCE) -> tuple:
    """
    Compare un visage avec les visages enregistrés
    Retourne (True/False, user_id, user_data)
    """
    best_distance = float('inf')
    matched_user_id = None
    matched_user_data = None
    
    for user_id, user_data in registered_faces.items():
        # Calcule les distances avec tous les encodages de l'utilisateur
        distances = face_recognition.face_distance(
            user_data['encodings'],
            unknown_encoding
        )
        
        # Trouve la meilleure correspondance
        min_distance = np.min(distances)
        
        if min_distance < best_distance:
            best_distance = min_distance
            matched_user_id = user_id
            matched_user_data = user_data
    
    # Vérifie si c'est un match valide
    if best_distance < tolerance:
        return True, matched_user_id, matched_user_data
    
    return False, None, None


# ============================================================================
# ROUTES FLASK
# ============================================================================

@app.route('/health', methods=['GET'])
def health():
    """Vérifie que le serveur est actif"""
    return jsonify({
        'status': 'ok',
        'firebase_initialized': db is not None,
        'message': 'Serveur de reconnaissance faciale actif'
    })


@app.route('/recognize', methods=['POST', 'OPTIONS'])
def recognize_face():
    """
    Endpoint principal de reconnaissance faciale
    
    POST body:
        {
            "imageUrl": "https://...",
            "image_url": "https://..." (accepté aussi)
        }
    
    Réponse:
        {
            "recognized": true/false,
            "personId": "user_id",
            "personName": "Nom du parent",
            "role": "parent",
            "confidence": 0.95,
            "message": "..."
        }
    """
    if request.method == 'OPTIONS':
        return '', 204
    
    if not db:
        return jsonify({
            'recognized': False,
            'message': '❌ Firebase non initialisé'
        }), 500
    
    try:
        # Récupère l'URL de l'image
        data = request.get_json() or {}
        image_url = data.get('imageUrl') or data.get('image_url')
        
        if not image_url:
            return jsonify({
                'recognized': False,
                'message': 'imageUrl manquante'
            }), 400
        
        print(f"\n🔍 Reconnaissance de visage demandée...")
        print(f"   Image: {image_url[:80]}...")
        
        # Charge l'image
        unknown_image = load_image_from_url(image_url)
        
        # Extrait les encodages du visage inconnu
        unknown_encodings = get_face_encodings(unknown_image)
        unknown_encoding = unknown_encodings[0]
        print(f"✅ Visage détecté dans l'image")
        
        # Récupère les visages enregistrés
        registered_faces = get_registered_faces_from_firestore()
        
        if not registered_faces:
            return jsonify({
                'recognized': False,
                'message': 'Aucun visage enregistré dans la base de données'
            }), 200
        
        print(f"📊 Comparaison avec {len(registered_faces)} utilisateurs...")
        
        # Compare le visage
        is_match, matched_id, matched_data = compare_face(unknown_encoding, registered_faces)
        
        if is_match:
            print(f"✅ VISAGE RECONNU: {matched_data['name']} (score excellent)")
            return jsonify({
                'recognized': True,
                'personId': matched_id,
                'parentId': matched_id,  # Alias pour compatibilité
                'childId': matched_id,   # Alias pour compatibilité
                'personName': matched_data['name'],
                'name': matched_data['name'],
                'role': matched_data['role'],
                'message': f'Visage reconnu: {matched_data["name"]}',
                'result': 'Autorisé'
            }), 200
        
        print(f"❌ Visage non reconnu - aucune correspondance")
        return jsonify({
            'recognized': False,
            'message': 'Visage non reconnu - Aucune correspondance trouvée'
        }), 200
        
    except ValueError as e:
        print(f"⚠️  Erreur validation: {e}")
        return jsonify({
            'recognized': False,
            'message': str(e)
        }), 400
    except Exception as e:
        print(f"❌ Erreur serveur: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'recognized': False,
            'message': f'Erreur serveur: {str(e)}'
        }), 500


@app.route('/faces/list', methods=['GET'])
def list_registered_faces():
    """Liste tous les visages enregistrés"""
    try:
        faces = get_registered_faces_from_firestore()
        return jsonify({
            'count': len(faces),
            'faces': {
                user_id: {
                    'name': data['name'],
                    'role': data['role'],
                    'encodings_count': len(data['encodings'])
                }
                for user_id, data in faces.items()
            }
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/', methods=['GET'])
def index():
    """Page d'accueil avec infos"""
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>SmartNursery - Serveur de Reconnaissance Faciale</title>
        <style>
            body { font-family: Arial; margin: 40px; }
            h1 { color: #2F5D00; }
            .endpoint { background: #f0f0f0; padding: 10px; margin: 10px 0; border-radius: 5px; }
            code { background: #ddd; padding: 2px 5px; }
        </style>
    </head>
    <body>
        <h1>🌳 SmartNursery - Serveur de Reconnaissance Faciale</h1>
        <p>Serveur local pour la reconnaissance faciale avec Firebase</p>
        
        <h2>Endpoints disponibles:</h2>
        <div class="endpoint">
            <strong>GET /health</strong><br>
            Vérifie que le serveur est actif
        </div>
        <div class="endpoint">
            <strong>GET /faces/list</strong><br>
            Liste tous les visages enregistrés
        </div>
        <div class="endpoint">
            <strong>POST /recognize</strong><br>
            Reconnait un visage<br>
            Body: <code>{"imageUrl": "https://..."}</code>
        </div>
        
        <h2>Configuration:</h2>
        <ul>
            <li>Port: 5000</li>
            <li>Firebase: ''' + ('✅ Initialisé' if db else '❌ Non initialisé') + '''</li>
            <li>Tolérance: ''' + str(FACE_TOLERANCE) + '''</li>
        </ul>
    </body>
    </html>
    '''


# ============================================================================
# MAIN
# ============================================================================

if __name__ == '__main__':
    print("""
╔════════════════════════════════════════════════════════════════╗
║   🌳 SmartNursery - Serveur de Reconnaissance Faciale        ║
╚════════════════════════════════════════════════════════════════╝
    """)
    
    # Initialise Firebase
    if not init_firebase():
        print("\n⚠️  IMPORTANT: Vous devez configurer Firebase pour fonctionner")
        print("   Téléchargez votre fichier service_account.json depuis Firebase Console")
        print("   et placez-le dans: functions/temp_service_account.json\n")
        # Continue même sans Firebase pour tester
    
    print(f"\n▶️  Démarrage serveur Flask sur http://localhost:{PORT}")
    print(f"▶️  Appuyez sur Ctrl+C pour arrêter\n")
    
    try:
        app.run(
            host='0.0.0.0',
            port=PORT,
            debug=True,
            use_reloader=True
        )
    except KeyboardInterrupt:
        print("\n\n▶️  Serveur arrêté par l'utilisateur")
    except Exception as e:
        print(f"\n❌ Erreur démarrage: {e}")
        sys.exit(1)
