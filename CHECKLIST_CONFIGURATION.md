# ✅ Checklist de Configuration - Reconnaissance Faciale

Utilisez cette checklist pour vérifier que tout est correctement configuré.

## Installation de Base

- [ ] **Python 3.9+** installé

  ```bash
  python --version  # Doit afficher Python 3.9+
  ```

- [ ] **Dépendances Python** installées

  ```bash
  cd SmartNursery/functions
  pip install -r requirements.txt
  ```

- [ ] **Serveur Flask peut démarrer**
  ```bash
  python local_server.py
  # Doit afficher: ▶️  Démarrage serveur Flask sur http://localhost:5000
  ```

## Configuration Firebase

- [ ] **Fichier `temp_service_account.json` obtenu**
  - [ ] Allez sur https://console.firebase.google.com
  - [ ] Settings > Service Accounts > Generate New Private Key
  - [ ] Fichier téléchargé avec succès

- [ ] **Fichier placé au bon endroit**

  ```
  SmartNursery/
  └── functions/
      └── temp_service_account.json  ✅ ICI
  ```

- [ ] **Serveur detects Firebase au démarrage**

  ```bash
  python local_server.py
  # Doit afficher: ✅ Firebase initialisé avec succès!
  ```

- [ ] **Fichier est dans .gitignore** (pour sécurité)
  ```bash
  grep "service_account" ../.gitignore
  # Doit retourner une ligne
  ```

## Configuration App Flutter

- [ ] **Code Dart correctement configuré**
  - Ouvrez: `lib/services/face_recognition_service.dart`
  - Ligne 33 doit être: `static const bool _useLocalServer = false;`

  ✅ Vérifiez:

  ```bash
  grep "_useLocalServer" lib/services/face_recognition_service.dart
  # Doit afficher: static const bool _useLocalServer = false;
  ```

## Données Firebase

- [ ] **Au moins 1 parent/éducateur enregistré**

  ```
  Firestore → users → {user_id}
  - name: "Nom du parent"
  - role: "parent" (ou "admin", "educateur")
  ```

- [ ] **Au moins 1 visage enregistré**

  ```
  Storage → faces/parents/{parent_id}/ → image.jpg
  ```

  ✅ Vérifiez via: `GET http://localhost:5000/faces/list`

## Tests Manuels

- [ ] **Serveur répond aux requêtes**

  ```bash
  curl http://localhost:5000/health
  # Doit afficher: {"status": "ok", "firebase_initialized": true}
  ```

- [ ] **Visages sont listés**

  ```bash
  curl http://localhost:5000/faces/list
  # Doit afficher: {"count": N, "faces": {...}}
  ```

- [ ] **Image test obtient réponse**
  ```bash
  curl -X POST http://localhost:5000/recognize \
    -H "Content-Type: application/json" \
    -d '{"imageUrl": "https://..."}'
  # Doit retourner JSON avec "recognized" ou "message"
  ```

## Test App Flutter

- [ ] **App Flutter peut se connecter au serveur**
  - [ ] Serveur local tourne: `python local_server.py`
  - [ ] App en mode développement
  - [ ] Émulateur Android/iOS en cours d'exécution
- [ ] **Test d'Identification fonctionne**
  1. Ouvrez l'app
  2. Identification → prendre une photo
  3. L'app affiche soit:
     - ✅ "Enfant reconnu: [Nom]" → SUCCÈS!
     - ❌ "Visage non reconnu" → Continuer au dépannage

- [ ] **Logs serveur sont informatifs**
  ```
  🔍 Reconnaissance de visage demandée...
  ✅ Visage détecté
  📊 Comparaison avec N utilisateurs...
  ✅ VISAGE RECONNU: [Nom]  ← C'est ce qu'on veut voir
  ```

## Dépannage

Si quelque chose ne fonctionne pas:

- [ ] **"Port 5000 en utilisation"**
  - Fermez l'autre application ou changez le port
- [ ] **"Firebase non initialisé"**
  - Placez `temp_service_account.json` dans `functions/`
  - Redémarrez le serveur
- [ ] **"Aucun visage enregistré"**
  - Enregistrez des visages via l'app Flutter
  - Vérifiez Storage: `faces/parents/{id}/`
- [ ] **"Visage non reconnu"**
  - Augmentez `FACE_TOLERANCE` dans `local_server.py` (0.6 → 0.7)
  - Enregistrez plus de photos d'angles différents
- [ ] **"Erreur d'image"**
  - L'image doit contenir un visage clair
  - Résolution minimum: 480x480 pixels
  - Bonne lumière requise

## En Cas de Problème

Consultez ces fichiers dans cet ordre:

1. **Démarrage rapide**: `DEMARRAGE_RAPIDE.md`
2. **Résolution du problème**: `RESOLUTION_RECONNAISSANCE_FACIALE.md`
3. **Documentation complète**: `functions/FACE_RECOGNITION_SERVER.md`

---

## Notes pour les Développeurs

### Structure des Dossiers

```
SmartNursery/
├── lib/services/
│   └── face_recognition_service.dart      ← Client Flutter
├── functions/
│   ├── local_server.py                    ← Serveur Flask
│   ├── requirements.txt                   ← Dépendances Python
│   ├── start_server.bat                   ← Démarrage Windows
│   ├── start_server.sh                    ← Démarrage Unix
│   └── temp_service_account.json          ← Firebase credentials (à ajouter)
└── DEMARRAGE_RAPIDE.md                    ← Ce fichier
```

### Architecture

```
Flutter App (prend photo)
    ↓
Firebase Storage (upload URL)
    ↓
Serveur Flask (détecte + compare)
    ↓
Retour résultat (reconnu/non-reconnu)
```

### Variables d'Environnement (Optionnel)

```bash
export FIREBASE_CREDENTIALS_PATH="/chemin/vers/service_account.json"
python local_server.py
```

---

**Généré pour SmartNursery** 🌳  
Dernière mise à jour: 2024
