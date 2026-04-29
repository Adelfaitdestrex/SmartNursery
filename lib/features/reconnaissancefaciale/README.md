# Système de Reconnaissance Faciale SmartNursery

## 📋 Vue d'ensemble

Le système de reconnaissance faciale SmartNursery permet d'identifier les enfants via leur visage. Le flux complet inclut :

1. **Écran d'entrée** (`recherche.dart`) - Vérification d'identité
2. **Écran de capture** (`recherche_en_cours.dart`) - Capture via caméra
3. **Écran de résultat** - Succès ou échec de la reconnaissance
4. **Backend** - Reconnaissance faciale avec Flask (Python) ou Cloud Functions (Node.js)
5. **Stockage** - Firebase Storage (images) et Firestore (métadonnées)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App (Client)                      │
├─────────────────────────────────────────────────────────────┤
│  RechercheFacePage  →  IdentificationScreen  →  Result Page │
└──────────────────────────────┬──────────────────────────────┘
                               │
                    FaceRecognitionService
                               │
                ┌──────────────┴──────────────┐
                │                             │
        ┌───────▼────────┐         ┌─────────▼──────┐
        │  Firebase Store│         │ Local Python  │
        │ (Production)   │         │   Server (Dev) │
        └────────────────┘         └────────────────┘
```

## 🔧 Configuration

### Mode Développement (Serveur Python local)

Dans `lib/services/face_recognition_service.dart` :

```dart
static const bool _useLocalServer = bool.fromEnvironment(
   'SMARTNURSERY_USE_LOCAL_FACE_SERVER',
   defaultValue: true,
);
```

**Démarrer le serveur Python :**

```bash
cd functions
python local_server.py
```

Si vous testez sur un téléphone physique, lancez Flutter avec une URL adaptée :

```bash
flutter run --dart-define=SMARTNURSERY_FACE_SERVER_URL=http://192.168.1.100:5000/recognize
```

### Mode Production (Cloud Functions Firebase)

Dans `lib/services/face_recognition_service.dart` :

```dart
static const bool _useLocalServer = false;  // Utilise la Cloud Function Firebase
```

Pour forcer Cloud Functions pendant un test local :

```bash
flutter run --dart-define=SMARTNURSERY_USE_LOCAL_FACE_SERVER=false
```

**Déployer la Cloud Function :**

```bash
cd functions
npm install
firebase deploy --only functions:recognizeFace
```

## 📱 Flux Utilisateur

### 1. Écran d'entrée (`recherche.dart`)

- Affiche les instructions de vérification d'identité
- Bouton "Commencer" lance la capture
- Bouton "Annuler" pour quitter

### 2. Écran de capture (`recherche_en_cours.dart`)

- Affiche le flux caméra en temps réel
- Cercle de guidage pour positionner le visage
- Vérification des conditions (luminosité, distance)
- Bouton "Continuer" envoie la photo pour analyse
- Bouton "Annuler" revient en arrière

### 3. Écran de résultat - Succès (`reconnaissance_faciale.dart`)

- Affiche le nom de l'enfant reconnu
- Badge de vérification réussie
- Photo en miniature de l'enfant
- Bouton "Continuer" pour confirmer l'arrivée
- Bouton "Annuler" pour recommencer

### 4. Écran de résultat - Échec (`visage_non_reconnue.dart`)

- Message d'erreur explicite
- Conseils pour réessayer (meilleure lumière, enlever accessoires)
- Bouton "Réessayer" relance la capture
- Bouton "Annuler" revient en arrière

## 🖼️ Gestion des Images

### Upload d'image

1. Capture via caméra → fichier temporaire
2. Upload dans Firebase Storage → `temp_faces/{timestamp}.jpg`
3. Récupération de l'URL publique
4. Envoi de l'URL au backend
5. Suppression du fichier temporaire

### Stockage des visages enregistrés

- **Chemin Firebase Storage** : `faces/{childId}/{timestamp}.jpg`
- **Métadonnées Firestore** :
  ```
  children/{childId}
  - name: string
  - hasFaceData: boolean
  - lastFaceRegisteredAt: timestamp
  ```

## 🔐 Sécurité

- Images temporaires supprimées après traitement
- Authentification Firebase requise pour enregistrer des visages
- Cloud Functions protégées par Firebase Security Rules
- Pas de stockage d'images permanentes côté client

## 🚀 Déploiement

### Prérequis

- Firebase CLI : `npm install -g firebase-cli`
- Dépendances Python : `pip install face-recognition pillow requests firebase-admin`
- Dépendances Node.js : `cd functions && npm install`

### Étapes

1. **Configuration Firebase**

   ```bash
   firebase init
   firebase use --add smartnursery
   ```

2. **Déploiement Cloud Functions**

   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```

3. **Mise à jour des URLs dans le code Flutter**
   - Si mode production, vérifier les URLs des Cloud Functions

4. **Déploiement Flutter**
   ```bash
   flutter pub get
   flutter run
   ```

## 🐛 Troubleshooting

### Erreur: "Aucune caméra disponible"

- Vérifier les permissions Android/iOS
- Sur Android: `android/app/src/main/AndroidManifest.xml`
  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  ```

### Erreur: "Visage non reconnu" constant

- Vérifier que les visages sont enregistrés dans Firestore
- S'assurer que les images sont stockées dans `faces/{childId}/`
- Tester avec une lumière adéquate

### Erreur: Cloud Function non accessible

- Vérifier que la Cloud Function est déployée: `firebase deploy --only functions`
- Vérifier l'URL dans `face_recognition_service.dart`
- Vérifier les Cloud Function Logs

### Serveur Python local ne répond pas

- S'assurer que Flask est lancé: `python test_reconnaissance.py`
- Vérifier le port: 5000
- Sur émulateur Android, utiliser `10.0.2.2:5000` (pas `localhost`)

## 📦 Dépendances

### Flutter (pubspec.yaml)

```yaml
camera: ^0.10.0
firebase_storage: ^11.0.0
cloud_firestore: ^14.0.0
http: ^1.1.0
```

### Python (requirements.txt)

```
face-recognition==1.3.5
flask==2.3.0
pillow==10.0.0
firebase-admin==6.0.0
numpy==1.24.0
```

### Node.js (functions/package.json)

```json
{
  "firebase-admin": "^12.0.0",
  "firebase-functions": "^4.5.0",
  "cors": "^2.8.5"
}
```

## 📝 TODO / Améliorations futures

- [ ] Améliorer la précision de la reconnaissance (augmenter le seuil de confiance)
- [ ] Ajouter un mode d'enregistrement des nouveaux visages
- [ ] Implémenter la reconnaissance multi-visages
- [ ] Ajouter des logs d'audit
- [ ] Créer une API pour gérer les visages (admin)
- [ ] Implémenter le retry automatique avec délai
- [ ] Ajouter des webhooks pour notifier après reconnaissance
- [ ] Performance optimization: cache des encodages de visage

## 📞 Support

Pour toute question ou problème:

1. Vérifier les logs Cloud Functions
2. Vérifier les logs Flutter
3. Tester avec des images de test connues
4. Consulter la documentation Firebase
