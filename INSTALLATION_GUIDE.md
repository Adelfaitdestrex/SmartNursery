# 🚀 Installation et Configuration de SmartNursery

## ⚠️ IMPORTANT: Données Sensibles

Ce projet utilise des fichiers sensibles (clés Firebase, secrets) qui **NE DOIVENT PAS** être commitées dans Git.

### Fichiers à configurer localement:

1. `android/app/google-services.json` - Clé Firebase Android
2. `SETUP_EMAIL.js` - Configuration email avec variables d'environnement
3. `.env.local` - Variables d'environnement (ne pas commiter)

---

## 🔧 Installation Initiale

### 1. Cloner le projet

```bash
git clone https://github.com/YOUR_REPO/smartnursery.git
cd smartnursery
```

### 2️⃣ Configurer Firebase (Android)

```bash
# Récupérer le fichier google-services.json depuis Firebase Console
# Project Settings → Your Apps → Android → Download google-services.json

# Place it in:
cp ~/Downloads/google-services.json android/app/

# Vérifier le fichier est ignoré par Git:
git check-ignore -v android/app/google-services.json
# Should return: android/app/google-services.json
```

Si vous n'avez pas le fichier, générez-le avec FlutterFire:

```bash
# Installer FlutterFire
brew install flutterfire  # ou via pub

# Configurer
flutterfire configure --platforms=android,ios,web
```

### 3️⃣ Configurer les variables d'environnement

```bash
# Copier le template
cp .env.template .env.local

# Éditer .env.local avec vos données
nano .env.local

# Ajouter au .gitignore (déjà fait)
```

### 4️⃣ Installer les dépendances Flutter

```bash
flutter pub get
flutter pub upgrade
```

### 5️⃣ Générer les fichiers (si besoin)

```bash
# Générer firebase_options.dart
flutterfire configure

# Générer le code généré
flutter pub run build_runner build
```

### 6️⃣ Lancer l'application

```bash
# Android
flutter run

# iOS
flutter run -d ios
# ou
cd ios && pod install && cd ..
flutter run -d ios
```

---

## 📧 Configuration des Emails

### Option 1: Gmail + Nodemailer

1. **Créer App Password**
   - Aller à https://myaccount.google.com/apppasswords
   - Sélectionner Mail + Custom (Cloud Function)
   - Générer un mot de passe

2. **Configurer la Cloud Function**

   ```bash
   cd functions
   npm install nodemailer

   # Configurer les variables
   firebase functions:config:set \
     gmail.user="your-email@gmail.com" \
     gmail.password="your-app-password"

   # Déployer
   firebase deploy --only functions:sendOTP
   ```

3. **Tester** :
   ```bash
   # Copier l'URL de la fonction depuis le déploiement
   # Et la mettre dans lib/services/email_service.dart
   ```

### Option 2: SendGrid (Recommandé)

1. **Créer un compte SendGrid**
   - https://sendgrid.com/free (100 emails/jour gratuit)

2. **Créer une API Key**
   - Settings → API Keys → Create API Key

3. **Configurer**

   ```bash
   firebase functions:config:set \
     sendgrid.key="your-sendgrid-api-key"
   ```

4. **Mettre à jour SETUP_EMAIL.js** - Décommenter la section SendGrid

---

## 🏗️ Structure du Projet

```
smartnursery/
├── lib/
│   ├── main.dart                    # Point d'entrée
│   ├── firebase_options.dart        # ⚠️ GÉNÉRÉ (ignoré)
│   ├── features/
│   │   ├── auth/                    # Authentification
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── reset_password_screen.dart
│   │   │   │   ├── otp_verification_screen.dart
│   │   │   │   └── password_change_screen.dart
│   │   └── ...                      # Autres features
│   └── services/
│       ├── auth_service.dart
│       ├── firebase_service.dart
│       └── email_service.dart       # Envoi des emails
│
├── android/
│   └── app/
│       ├── google-services.json     # ⚠️ SENSIBLE (ignoré)
│       └── google-services.json.template
│
├── ios/
│   ├── Runner/
│   │   └── GoogleService-Info.plist # ⚠️ SENSIBLE (ignoré)
│   └── Runner.xcodeproj/
│
├── firebase.json                     # Config Firebase (publique OK)
├── pubspec.yaml                      # Dépendances
├── .gitignore                        # Fichiers à ignorer
├── .env.template                     # Template variables d'env
├── SECURITY_GUIDE.md                 # Guide de sécurité
├── SETUP_EMAIL.js                    # ⚠️ Ne pas commiter avec clés
├── EMAIL_SETUP_GUIDE.md              # Guide configuration email
└── README.md                         # Ce fichier
```

---

## 🔐 Points de Sécurité

### ✅ Avant de démarrer:

- [ ] `android/app/google-services.json` est configuré et ignoré par Git
- [ ] `.env.local` est créé et ignoré par Git
- [ ] Variables d'environnement sont configurées pour Firebase Cloud Functions
- [ ] Aucune clé API n'est exposée dans le code source
- [ ] Security Rules sont configurées dans Firestore

### 📚 Rose plus d'informations:

Voir [SECURITY_GUIDE.md](./SECURITY_GUIDE.md)

---

## 🐛 Dépannage

### "google-services.json not found"

```bash
# Télécharger depuis Firebase Console ou générer avec flutterfire
flutterfire configure --platforms=android
```

### "Error: FirebaseApp not initialized"

```bash
# Vérifier que google-services.json existe et est valide
file android/app/google-services.json

# Sinon, régénérer:
flutterfire configure
```

### L'email n'est pas envoyé

```bash
# 1. Vérifier que Cloud Functions est déployée
firebase list

# 2. Vérifier les logs
firebase functions:log

# 3. Vérifier que EMAIL_USER et EMAIL_PASSWORD sont configurés
firebase functions:config:get
```

### Port occupé lors du run

```bash
# Tuer le processus sur le port 8080
lsof -i :8080
kill -9 <PID>
```

---

## 📞 Support

Pour toute question sur la sécurité, contactez l'administrateur du projet.

**⚠️ RÈGLE IMPORTANTE: Ne jamais commiter de data sensitive!**
