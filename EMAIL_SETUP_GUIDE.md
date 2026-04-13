# Configuration de l'envoi d'emails - SmartNursery

## 📧 Vue d'ensemble

Le système de réinitialisation de mot de passe de SmartNursery peut envoyer des OTP par email. Trois approches sont possibles :

---

## Option 1️⃣ : Firebase Cloud Functions (Recommandé)

### ✅ Avantages :

- Sécurisé (pas d'exposition de credentials)
- Intégré à Firebase
- Scalable

### 📋 Étapes :

1. **Créer le dossier functions** :

```bash
firebase init functions
cd functions
npm install nodemailer
```

2. **Ajouter la Cloud Function** (copier le contenu de `SETUP_EMAIL.js`)

3. **Configurer les variables d'environnement** :

```bash
# Avec Gmail App Password
firebase functions:config:set gmail.user="votre-email@gmail.com"
firebase functions:config:set gmail.password="votre-app-password"

# Ou avec SendGrid
firebase functions:config:set sendgrid.key="votre-clé-sendgrid"
```

4. **Déployer** :

```bash
firebase deploy --only functions:sendOTP
```

5. **Mettre à jour email_service.dart** :

```dart
static const String _emailEndpoint = 'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/sendOTP';
```

---

## Option 2️⃣ : Service d'email externe (SendGrid, Mailgun, etc.)

### ✅ Avantages :

- Facile à configurer
- Haute délivrabilité
- Analytics intégrées

### 📋 Exemple avec SendGrid :

1. **Créer un compte SendGrid** (gratuit 100 emails/jour)

2. **Créer une API Key** dans https://app.sendgrid.com/settings/api_keys

3. **Créer votre propre endpoint backend** qui utilise l'API SendGrid

4. **Mettre à jour email_service.dart** :

```dart
static const String _emailEndpoint = 'https://votre-backend.com/api/send-otp';
```

---

## Option 3️⃣ : Gmail avec Nodemailer (Simple mais moins sécurisé)

### ⚠️ Limitation :

- Ne pas utiliser votre mot de passe Gmail direct
- Utiliser App Passwords

### 📋 Étapes :

1. **Activer les App Passwords** :
   - https://myaccount.google.com/apppasswords
   - Générer un mot de passe pour "Mail"

2. **Créer la Cloud Function** avec Nodemailer (voir `SETUP_EMAIL.js`)

---

## 🔧 Test local

Pour tester sans Cloud Function :

```dart
// Dans email_service.dart, mode développement
static Future<bool> sendOtpEmail({...}) async {
  // Remplacer par une implementation mock
  debugPrint('OTP envoyé: $otp');
  return true;
}
```

---

## 📝 Flux complet actuel

1. ✅ Utilisateur saisit email → **reset_password_screen.dart**
2. ✅ Génération OTP (6 chiffres)
3. ⏳ **Appel EmailService.sendOtpEmail()**
4. 🚀 Envoi via Cloud Function/Backend
5. ✅ Affichage dialog "Email envoyé"
6. ✅ Navigation vers écran OTP
7. ✅ Saisie OTP et vérification
8. ✅ Navigation vers changement mot de passe
9. ✅ Mise à jour Firebase Auth

---

## 🐛 Troubleshooting

| Problème                 | Solution                                  |
| ------------------------ | ----------------------------------------- |
| "URL_BACKEND_URL" erreur | Remplacer l'URL dans `email_service.dart` |
| Email n'arrive pas       | Vérifier le dossier Spam/Promotion        |
| Erreur 403/401           | Vérifier les clés API / permissions       |
| Timeout                  | Vérifier la connexion internet            |

---

## 🔐 Sécurité - Points importants

✅ **À faire** :

- Valider l'email côté backend
- Limiter les tentatives (rate limiting)
- Expirer les OTP après 15 minutes
- Stocker les OTP chiffrés en Firestore

❌ **À éviter** :

- Exposer vos clés API
- Envoyer des mots de passe en clair
- Générer des OTP faibles

---

## 📚 Ressources utiles

- [Firebase Cloud Functions → https://firebase.google.com/docs/functions
- [Nodemailer → https://nodemailer.com/
- [SendGrid → https://sendgrid.com/
- [Firebase Security → https://firebase.google.com/docs/rules

---

**Questions ?** Consultez la documentation Firebase officielle ou contactez le support.
