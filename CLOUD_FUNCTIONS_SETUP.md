# 📧 Guide Complet: Déployer Cloud Functions pour les Emails OTP

## Aperçu

Ce guide vous permet de mettre en place l'envoi réel d'emails OTP via Firebase Cloud Functions.

---

## 📋 Prérequis

- ✅ Firebase CLI installée: `npm install -g firebase-tools`
- ✅ Compte Gmail (pour envoyer les emails)
- ✅ Projet Firebase créé dans [Firebase Console](https://console.firebase.google.com)
- ✅ Authentifi avec Firebase: `firebase login`

---

## 🚀 Installation Rapide (5 minutes)

### Option A: Script automatisé (Recommandé)

#### Sur Mac/Linux:

```bash
chmod +x deploy-functions.sh
./deploy-functions.sh
```

#### Sur Windows (PowerShell):

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\deploy-functions.ps1
```

Le script va:

1. ✅ Installer les dépendances
2. ✅ Vous demander votre email Gmail et App Password
3. ✅ Configurer les variables Firebase
4. ✅ Déployer les Cloud Functions
5. ✅ Afficher l'URL de la fonction

### Option B: Déploiement manuel

#### 1. Préparer les dépendances

```bash
cd functions
npm install
cd ..
```

#### 2. Créer un App Password Gmail

**Étapes:**

1. Aller à https://myaccount.google.com/apppasswords
2. Si demandé, vérifier votre identité (SMS/Email)
3. Sélectionner:
   - Application: **Mail**
   - Appareil: **Custom (type the name)**
   - Écrire: "Cloud Function"
4. Cliquer **Générer**
5. Copier le mot de passe généré (16 caractères)

**Exemple d'App Password:** `abcd efgh ijkl mnop`

#### 3. Configurer Firebase

```bash
# Remplacer par vos vraies données
firebase functions:config:set \
  gmail.user="your-email@gmail.com" \
  gmail.password="your-16-char-app-password"

# Vérifier la configuration
firebase functions:config:get
```

#### 4. Déployer

```bash
firebase deploy --only functions
```

Vous verrez la sortie:

```
✔  functions[sendOTP(us-central1)]: ...
https://us-central1-smart-nursery-7a6f6.cloudfunctions.net/sendOTP
```

---

## 🔗 Configurer l'URL dans Flutter

Après le déploiement, copier l'URL et mettre à jour `email_service.dart`:

```dart
// lib/services/email_service.dart

class EmailService {
  static const String _emailEndpoint =
    'https://us-central1-smart-nursery-7a6f6.cloudfunctions.net/sendOTP';
    // ↑ REMPLACER PAR VOTRE URL
```

---

## ✅ Tester l'envoi d'email

### Test 1: Depuis le terminal

```bash
curl -X POST \
  https://us-central1-smart-nursery-7a6f6.cloudfunctions.net/sendOTP \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your-email@example.com",
    "otp": "123456"
  }'
```

Réponse réussie:

```json
{
  "success": true,
  "message": "Email envoyé avec succès",
  "email": "your-email@example.com"
}
```

### Test 2: Depuis votre app Flutter

1. Ouvrir l'app
2. Aller à Reset Password
3. Entrer votre email
4. Vérifier que l'email est reçu ✅

---

## 🐛 Troubleshooting

### Problème: "Email configuration missing"

**Causes:**

- Pas configuré `gmail.user` / `gmail.password`
- Cloud Function non redéployée après config

**Solution:**

```bash
firebase functions:config:set gmail.user="..." gmail.password="..."
firebase deploy --only functions
```

### Problème: "Authentication failed"

**Causes:**

- App Password incorrect
- Compte Gmail sans 2FA (requis pour App Password)

**Solution:**

```bash
# Réactiver 2FA
# https://myaccount.google.com/security

# Générer un nouveau App Password
# https://myaccount.google.com/apppasswords

# Reconfigurer
firebase functions:config:set gmail.password="NEW_PASSWORD"
firebase deploy --only functions
```

### Problème: "Invalid email"

**Cause:** Format d'email invalide

**Solution:** Vérifier le format `user@domain.com`

### Problème: Email n'est pas reçu

**Vérifications:**

1. ✅ Est-ce qu'un email est dans les SPAM/Promotions?
2. ✅ Vérifier les logs: `firebase functions:log`
3. ✅ Tester avec une autre adresse email
4. ✅ Vérifier la configuration Gmail

**Logs:**

```bash
# Voir les dernière 50 lignes
firebase functions:log --lines 50

# Voir les erreurs
firebase functions:log | grep ERROR
```

---

## 🔒 Sécurité

### ✅ À FAIRE:

1. **Ne pas mettre les secrets dans le code:**

   ```dart
   // ❌ MAUVAIS
   final password = "AIzaSy...";

   // ✅ BON
   // Utiliser firebase functions:config:set
   ```

2. **Ne pas commiter le mot de passe:**
   - `functions/.env` est dans `.gitignore`
   - Les variables sont sauvegardées dans Firebase (sécurisées)

3. **Rate limiting:**
   - Limiter à 5 tentatives par email
   - OTP valide 15 minutes seulement

### ⚠️ À ÉVITER:

- ❌ Commit le mot de passe Gmail en dur
- ❌ Partager l'App Password
- ❌ Utiliser votre vrai mot de passe (utiliser App Password)
- ❌ Stocker OTP en clair

---

## 📊 Monitoring

### Firebase Console

1. Aller à: https://console.firebase.google.com/project/YOUR_PROJECT/functions
2. Cliquer sur `sendOTP`
3. Voir:
   - Invocations
   - Errors
   - Logs

### Terminal

```bash
# Logs en temps réel
firebase functions:log -f

# Erreurs seulement
firebase functions:log | grep ERROR

# Historique (50 dernières lignes)
firebase functions:log --lines 50
```

---

## 🧪 Développement local

### Émulateur Firebase

```bash
cd functions

# Démarrer l'émulateur
firebase emulators:start --only functions

# La fonction sera accessible à:
# http://localhost:5001/smart-nursery-7a6f6/us-central1/sendOTP
```

Puis mettre à jour `email_service.dart`:

```dart
static const String _emailEndpoint =
  'http://localhost:5001/smart-nursery-7a6f6/us-central1/sendOTP';
```

---

## 📁 Structure des fichiers

```
functions/
├── index.js              ← Cloud Function (sendOTP + testEmail)
├── package.json          ← Dépendances Node.js
├── .gitignore            ← Ignore node_modules
├── README.md             ← Doc détaillée
└── node_modules/         ← Installé avec npm install

SmartNursery/
└── lib/services/
    └── email_service.dart ← Appel la Cloud Function
```

---

## 📚 Ressources

- [Firebase Cloud Functions Docs](https://firebase.google.com/docs/functions)
- [Nodemailer](https://nodemailer.com/)
- [Gmail App Passwords](https://support.google.com/accounts/answer/185833)
- [Firebase Security](https://firebase.google.com/docs/rules)

---

## 🎉 Prochaines étapes

Après le déploiement réussi:

1. ✅ Mettre à jour l'URL dans `email_service.dart`
2. ✅ Tester l'envoi d'email depuis l'app
3. ✅ Implémenter le rate limiting
4. ✅ Ajouter la vérification OTP en Firestore
5. ✅ Monitorer les logs Firebase

---

**Besoin d'aide?** Voir `functions/README.md` ou `SECURITY_GUIDE.md`
