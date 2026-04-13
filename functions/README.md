# 🚀 Firebase Cloud Functions - SmartNursery

Envoie des emails OTP pour la réinitialisation de mot de passe.

## 📋 Prérequis

- Firebase CLI installé: `npm install -g firebase-tools`
- Compte Gmail pour envoyer les emails
- Projet Firebase configuré dans `firebase.json`

## 🔧 Installation

### 1. Installer les dépendances

```bash
cd functions
npm install
```

### 2. Configurer les variables d'environnement

#### Option A: Avec Firebase CLI (Recommandé)

```bash
# 1. Créer un App Password Gmail
# Aller à: https://myaccount.google.com/apppasswords
# - Sélectionner Mail + Custom (Cloud Function)
# - Générer un mot de passe

# 2. Configurer les variables
firebase functions:config:set \
  gmail.user="your-email@gmail.com" \
  gmail.password="your-app-password"

# 3. Vérifier la configuration
firebase functions:config:get
```

#### Option B: Avec .env.local (Dev local)

```bash
# Créer functions/.env.local
echo "GMAIL_USER=your-email@gmail.com"
echo "GMAIL_PASSWORD=your-app-password"
```

## 🚀 Déploiement

### Déployer les fonctions

```bash
firebase deploy --only functions
```

### Voir les logs

```bash
firebase functions:log
```

### Exécuter localement (Emulator)

```bash
firebase emulators:start --only functions
# Les logs s'affichent dans le terminal
```

## ✅ Tester la fonction

### Test 1: Vérifier que la fonction est accessible

```bash
curl https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/testEmail
```

### Test 2: Envoyer un OTP

```bash
curl -X POST \
  https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/sendOTP \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "otp": "123456",
    "subject": "Test Code",
    "body": "This is a test"
  }'
```

## 🔐 Configuration Gmail

### Créer une App Password

1. Aller à https://myaccount.google.com/apppasswords
2. Sélectionner **Mail**
3. Sélectionner **Custom (Cloud Function)**
4. Générer un mot de passe
5. Copier le mot de passe généré

### Configuration Firebase

```bash
firebase functions:config:set \
  gmail.user="your-email@gmail.com" \
  gmail.password="your-16-char-password"

firebase deploy --only functions
```

## 📍 URL de la fonction

Après le déploiement, vous verrez:

```
✔  functions[sendOTP(us-central1)]: https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/sendOTP
```

Copier cette URL dans `lib/services/email_service.dart`:

```dart
static const String _emailEndpoint =
  'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/sendOTP';
```

## 🐛 Troubleshooting

### "Email configuration missing"

```bash
firebase functions:config:set gmail.user="..." gmail.password="..."
firebase deploy --only functions
```

### "CORS error"

Les CORS sont activés par défaut. Si vous avez encore des erreurs, vérifier la configuration du navigateur.

### "Invalid email"

- Vérifier le format de l'email
- S'assurer que l'adresse est valide

### Fonction ne s'appelle pas

```bash
# Vérifier les logs
firebase functions:log

# Redéployer
firebase deploy --only functions
```

## 📊 Monitoring

### Firebase Console

1. Aller à: https://console.firebase.google.com
2. Cloud Functions → sendOTP
3. Voir les Executions et Logs

### Terminal

```bash
firebase functions:log --lines 50
```

## 💾 Fichiers importants

- `index.js` - Implémentation des Cloud Functions
- `package.json` - Dépendances Node.js
- `.gitignore` - Fichiers à ignorer (node_modules, .env)

## 📚 Documentation

- [Firebase Cloud Functions](https://firebase.google.com/docs/functions)
- [Nodemailer](https://nodemailer.com/)
- [Gmail App Passwords](https://support.google.com/accounts/answer/185833)

## 🔒 Sécurité

⚠️ **IMPORTANT:**

- NE PAS commiter `.env` ou `package.json` avec les vrais mots de passe
- Utiliser `firebase functions:config:set` pour les secrets
- Valider les emails côté backend
- Rate limiter les requêtes

---

**Questions?** Voir `SECURITY_GUIDE.md` ou `INSTALLATION_GUIDE.md` dans le repo principal.
