# 🔐 Guide de Sécurité Firebase - SmartNursery

## ⚠️ IMPORTANT : Fichiers Sensibles Ne Doivent JAMAIS Être Comittés

### Fichiers à ne jamais commiter:

```
❌ DANGEREUSES (contiennent des clés API):
- android/app/google-services.json
- ios/Runner/GoogleService-Info.plist
- lib/firebase_options.dart
- SETUP_EMAIL.js (contient clés d'environnement)
- .env, .env.local

✅ REMPLACÉ PAR DES TEMPLATES:
- android/app/google-services.json.template
```

---

## 🚀 Configuration pour les nouveaux développeurs

### 1️⃣ Récupérer les fichiers Firebase

#### Pour Android:

```bash
# Via Firebase Console:
# 1. Aller à Project Settings → Your Apps → Android
# 2. Télécharger google-services.json
# 3. Placer dans: android/app/google-services.json

# Via FlutterFire CLI (recommandé):
curl -sL https://firebase.google.com/download/admin | bash
flutterfire configure
```

#### Pour iOS:

```bash
# Via Firebase Console:
# 1. Aller à Project Settings → Your Apps → iOS
# 2. Télécharger GoogleService-Info.plist
# 3. Placer dans: ios/Runner/GoogleService-Info.plist
```

### 2️⃣ Configuration des emails (SETUP_EMAIL.js)

```bash
# 1. Copier le template
cp SETUP_EMAIL.js.template functions/index.js

# 2. Configurer les variables d'environnement:
firebase functions:config:set \
  gmail.user="your-email@gmail.com" \
  gmail.password="your-app-password"

# 3. Ne jamais commiter SETUP_EMAIL.js avec des vraies clés!
```

### 3️⃣ Mettre à jour lib/firebase_options.dart

```bash
# Générer automatiquement:
flutterfire configure --platforms=android,ios,web

# Ce fichier sera généré automatiquement et ignoré par .gitignore
```

---

## 🔒 Sécurité Firebase - Best Practices

### ✅ À FAIRE:

1. **Utiliser Cloud Firestore Security Rules**

   ```firebase
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Seulement les utilisateurs authentifiés peuvent créer
       match /users/{userId} {
         allow read, write: if request.auth.uid == userId;
       }
     }
   }
   ```

2. **Restreindre les API Keys**
   - Firebase Console → API Restrictions
   - Limiter par Android Package
   - Limiter par iOS Bundle ID
   - Limiter par domaines Web

3. **Activer Authentication**
   - Mettre en place les Security Rules
   - Valider les emails
   - Implémenter 2FA

4. **Audit des clés**
   - Vérifier l'historique de publication
   - Rotationner les clés régulièrement
   - Surveiller les utilisations anormales

### ❌ À ÉVITER:

1. **Commiter des fichiers sensibles**
   - ❌ `google-services.json`
   - ❌ `GoogleService-Info.plist`
   - ❌ `SETUP_EMAIL.js` avec clés réelles
   - ❌ `.env` avec tokens

2. **Utiliser des clés en dur dans le code**

   ```dart
   // ❌ MAUVAIS
   const String apiKey = "AIzaSy...";

   // ✅ BON
   // Récupérer depuis firebase_options.dart généré
   ```

3. **Exposer trop d'infos en logs**

   ```dart
   // ❌ MAUVAIS
   print('User UID: ${user.uid}, Token: ${user.idToken}');

   // ✅ BON
   if (kDebugMode) {
     debugPrint('User authenticated');
   }
   ```

---

## 🔑 Types de clés Firebase et leur sécurité

### API Key (dans google-services.json)

- **Risque:** Moyen (limitées par package/domaine)
- **Rotation:** Annuelle recommandée
- **Commiter:** ❌ NON

### Service Account Key

- **Risque:** CRITIQUE (accès administrateur)
- **Stockage:** Variables d'environnement seulement
- **Commiter:** ❌ JAMAIS

### Web API Key

- **Risque:** Moyen (limitées par domaine)
- **Stockage:** Code cliente OK (validé par Security Rules)
- **Commiter:** ❌ NON (si possible)

### ID Token / Refresh Token

- **Risque:** Critique (authentification utilisateur)
- **Stockage:** Secure Storage seulement
- **Commiter:** ❌ JAMAIS

---

## 🛠️ Configuration Git Locale (optionnel)

Pour plus de sécurité, vous pouvez aussi faire :

```bash
# Ignorer les fichiers localement sans les commiter
git config core.hooksPath .git/hooks

# Ou créer un hook pour prévenir les commits accidentels:
# .git/hooks/pre-commit
#!/bin/bash
if git diff --cached --name-only | grep -E "(google-services|GoogleService|.env|SETUP_EMAIL)" > /dev/null
then
  echo "❌ Tentative de committer un fichier sensible!"
  exit 1
fi
```

---

## 📋 Checklist de Sécurité

- [ ] Fichiers sensibles dans `.gitignore`
- [ ] Templates créés pour les clés (`.template`)
- [ ] `google-services.json` retiré du Git
- [ ] `SETUP_EMAIL.js` retiré du Git
- [ ] Security Rules configurées dans Firestore
- [ ] API Keys restreintes dans Firebase Console
- [ ] Pas de secrets en dur dans le code
- [ ] Variables d'environnement utilisées pour Cloud Functions
- [ ] Logs ne contiennent pas de données sensibles
- [ ] Développeurs informés des bonnes pratiques

---

## 🚨 Si une clé a été accidentellement commitée

### Actions immédiates:

```bash
# 1. Régénérer les clés dans Firebase Console
# Revenir à Project Settings → API Keys → Régénérer la clé

# 2. Supprimer du Git history
git filter-branch --tree-filter 'rm -f android/app/google-services.json' HEAD

# ou utiliser BFG Repo-Cleaner pour gros repos:
bfg --delete-files google-services.json

# 3. Force push (attention: affecte tous les développeurs)
git push origin --force-with-lease

# 4. Notifier l'équipe
```

---

## 🔍 Audit Automatisé

Vous pouvez utiliser des outils pour éviter les leaks:

```bash
# Installer git-secrets
brew install git-secrets  # ou apt-get install git-secrets

# Configurer
git secrets --install
git secrets --register-aws

# Custom pattern Firebase
git secrets --add 'AIzaSy[a-zA-Z0-9_-]*'

# Tester sur repo existant
git secrets --scan-history
```

---

## 📚 Ressources utiles

- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/service-cloud-firestore-security)
- [FlutterFire Configuration](https://firebase.flutter.dev/docs/overview/)
- [Google Cloud Documentation](https://cloud.google.com/docs)
- [OWASP - Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)

---

**Questions ou problèmes de sécurité?** Contactez l'administrateur du projet immédiatement.
