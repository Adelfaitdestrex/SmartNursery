# 🌳 Serveur de Reconnaissance Faciale - SmartNursery

Ce serveur Flask local fournit une reconnaissance faciale en temps réel pour l'application SmartNursery. Il utilise la bibliothèque `face_recognition` et Firebase pour comparer les visages capturés avec les visages enregistrés des parents/éducateurs.

## 📋 Prérequis

- **Python 3.9+** installé et accessible en ligne de commande
- **pip** (gestionnaire de paquets Python)
- **Firebase**: Un fichier de credentials (`temp_service_account.json`)
- **Connexion Internet** pour accéder à Firebase Storage

## 🚀 Installation Rapide

### 1. Sur Windows (PowerShell)

```bash
cd functions
.\start_server.bat
```

**Ou manuellement:**

```powershell
cd functions
python -m pip install -r requirements.txt
python local_server.py
```

### 2. Sur macOS/Linux

```bash
cd functions
chmod +x start_server.sh
./start_server.sh
```

**Ou manuellement:**

```bash
cd functions
python3 -m pip install -r requirements.txt
python3 local_server.py
```

## 🔐 Configuration Firebase

Pour que le serveur puisse accéder à vos visages enregistrés dans Firebase:

### 1. Obtenir les credentials Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Sélectionnez votre projet **SmartNursery**
3. Allez dans **⚙️ Settings > Service Accounts**
4. Cliquez **"Generate New Private Key"**
5. Un fichier JSON se télécharge

### 2. Placer le fichier dans le dossier functions

Copiez le fichier téléchargé et renommez-le en:

```
SmartNursery/functions/temp_service_account.json
```

**Après cela, redémarrez le serveur pour que Firebase soit initialisé.**

## 📡 Endpoints Disponibles

### GET `/health`

Vérifie que le serveur est actif

**Réponse:**

```json
{
  "status": "ok",
  "firebase_initialized": true,
  "message": "Serveur de reconnaissance faciale actif"
}
```

### GET `/faces/list`

Liste tous les visages enregistrés dans Firebase

**Réponse:**

```json
{
  "count": 3,
  "faces": {
    "user_id_1": {
      "name": "Jean Dupont",
      "role": "parent",
      "encodings_count": 2
    }
  }
}
```

### POST `/recognize`

Reconnait un visage à partir d'une URL d'image

**Body:**

```json
{
  "imageUrl": "https://storage.googleapis.com/..."
}
```

**Réponse (visage reconnu):**

```json
{
  "recognized": true,
  "personId": "user_id_1",
  "personName": "Jean Dupont",
  "role": "parent",
  "message": "Visage reconnu: Jean Dupont",
  "result": "Autorisé"
}
```

**Réponse (visage non reconnu):**

```json
{
  "recognized": false,
  "message": "Visage non reconnu - Aucune correspondance trouvée"
}
```

## 🎯 Configuration de l'App Flutter

L'app Flutter est déjà configurée pour utiliser ce serveur!

Dans `lib/services/face_recognition_service.dart`:

- **`_useLocalServer = true`** ✅ (Configuré pour le serveur local)
- **URL**: `http://10.0.2.2:5000/recognize` (adresse spéciale pour émulateur Android)

### Test sur Émulateur Android

Assurez-vous que:

1. L'émulateur Android est en cours d'exécution
2. Le serveur Flask tourne sur votre machine hôte
3. Le serveur est accessible via `http://10.0.2.2:5000`

### Test sur Appareil Physique Android

Il faut obtenir l'adresse IP de votre machine:

**Windows (PowerShell):**

```powershell
ipconfig
# Cherchez "Adresse IPv4" (ex: 192.168.1.100)
```

**macOS/Linux:**

```bash
ifconfig
# Cherchez "inet" (ex: 192.168.1.100)
```

Puis modifiez `lib/services/face_recognition_service.dart`:

```dart
// Remplacez:
static const String _localServerUrl = 'http://10.0.2.2:5000/recognize';

// Par (avec votre IP):
static const String _localServerUrl = 'http://192.168.1.100:5000/recognize';
```

## 🔧 Troubleshooting

### ❌ "Aucun visage détecté dans l'image"

Le serveur ne peut pas détecter de visage. Assurez-vous que:

- L'image contient un visage clair et visible
- La résolution de l'image est suffisante (au moins 480x480)
- L'éclairage est bon

### ❌ "Firebase non initialisé"

Vous n'avez pas placé le fichier `temp_service_account.json`:

1. Téléchargez-le depuis Firebase Console (voir section Configuration)
2. Placez-le dans `functions/`
3. Redémarrez le serveur

### ❌ "Aucun visage enregistré dans la base de données"

Vérifiez que:

1. Au moins un parent/éducateur a des visages enregistrés dans l'app
2. Leurs rôles sont: `parent`, `admin`, `educateur`, ou `educator`
3. Ils ont le champ `hasFaceData: true` dans Firestore

### ❌ "Erreur: Connection refused"

Le serveur n'est pas lancé:

```bash
cd functions
python local_server.py  # Windows
# ou
python3 local_server.py  # macOS/Linux
```

### ❌ "ModuleNotFoundError: No module named 'face_recognition'"

Les dépendances ne sont pas installées:

```bash
python -m pip install -r requirements.txt
```

### ❌ "Port 5000 déjà en utilisation"

Un autre processus utilise le port 5000:

```powershell
# Windows:
netstat -ano | findstr :5000
taskkill /PID {PID} /F

# macOS/Linux:
lsof -i :5000
kill -9 {PID}
```

## 📊 Logs et Debugging

Le serveur affiche des logs détaillés. Exemple:

```
🔍 Reconnaissance de visage demandée...
   Image: https://storage.googleapis.com/...
✅ Visage détecté dans l'image
📊 Comparaison avec 3 utilisateurs...
✅ Chargé 2 encodages pour Jean Dupont
✅ Chargé 1 encodages pour Marie Dupont
✅ VISAGE RECONNU: Jean Dupont (score excellent)
```

## 🔒 Sécurité

### ⚠️ IMPORTANT: Ne partagez pas `temp_service_account.json`

Ce fichier contient des credentials Firebase. **Ne le commitez jamais** dans Git:

```gitignore
# Ajoutez à .gitignore:
temp_service_account.json
```

## 📈 Optimisations Possibles

### Augmenter la sensibilité

Modifiez `FACE_TOLERANCE` dans `local_server.py` (ligne ~20):

```python
FACE_TOLERANCE = 0.6  # Plus bas = plus strict (0.4-0.5)
# ou
FACE_TOLERANCE = 0.8  # Plus permissif (0.8-1.0)
```

### Cache les visages enregistrés

Pour améliorer la performance, les visages pourraient être mis en cache après le premier chargement (TODO).

### Supportez d'autres formats d'image

Le serveur supporte déjà JPEG, PNG. Vous pouvez ajouter WebP, TIFF, etc. dans `load_image_from_url()`.

## 🔗 Liens Utiles

- [Firebase Console](https://console.firebase.google.com)
- [face_recognition Documentation](https://github.com/ageitgey/face_recognition)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [SmartNursery GitHub](https://github.com/...)

## 📝 Notes Futures

- [ ] Déployer la reconnaissance faciale sur Google Cloud Functions (production)
- [ ] Implémenter un cache des visages encodés pour améliorer les performances
- [ ] Ajouter un endpoint pour entraîner le modèle avec plus de données
- [ ] Supporter plusieurs visages par parent dans la comparaison
- [ ] Ajouter des logs détaillés en JSON pour l'analytics

---

**Créé pour SmartNursery** 🌳 - Gestion intelligent de la garde d'enfants
