# 🚨 URGENT: Nettoyage du Dépôt Git

## Situation Actuelle

Votre dépôt Git contient des fichiers sensibles dans l'historique:

❌ **Fichiers sensibles exposés:**

- `lib/services/firebase/firebase_options.dart` (Clés API Firebase)
- `android/app/google-services.json` (Clé API Firebase)
- `SETUP_EMAIL.js` (Possibles secrets d'environnement)

Ces fichiers sont accessibles à quiconque ayant accès au repo, même s'ils sont maintenant ignorés par `.gitignore`.

---

## 🔧 Solution: Nettoyer l'historique Git

### Option 1: Avec BFG Repo-Cleaner (Recommandé - Plus facile)

**BFG est plus simple et plus rapide que `git filter-branch`.**

#### Installation:

```bash
# macOS
brew install bfg

# Linux
apt-get install bfg  # ou get via leur site

# Windows
choco install bfg
# ou télécharger: https://rtyley.github.io/bfg-repo-cleaner/
```

#### Utilisation:

```bash
# 1. Créer une copie de secours
cp -r .git .git.backup

# 2. Supprimer tous fichiers sensibles de l'historique
bfg --delete-files firebase_options.dart
bfg --delete-files google-services.json
bfg --delete-files SETUP_EMAIL.js

# 3. Nettoyer les refs
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 4. Force push (ATTENTION: cela rewrite l'historique)
git push origin --force-with-lease

# 5. Notifier tous les développeurs de re-cloner
```

### Option 2: Avec `git filter-branch` (Plus contrôle)

```bash
# 1. Supprimer firebase_options.dart
git filter-branch --tree-filter 'rm -f lib/services/firebase/firebase_options.dart' HEAD

# 2. Supprimer google-services.json
git filter-branch --tree-filter 'rm -f android/app/google-services.json' HEAD

# 3. Supprimer SETUP_EMAIL.js
git filter-branch --tree-filter 'rm -f SETUP_EMAIL.js' HEAD

# 4. Force push
git push origin --force
```

### Option 3: Créer une nouvelle branche clean (Plus compliqué)

```bash
# 1. Créer une branche orpheline (sans historique)
git checkout --orphan clean-branch

# 2. Ajouter tous les fichiers sauf les sensibles
git add .
git reset HEAD lib/services/firebase/firebase_options.dart
git reset HEAD android/app/google-services.json
git reset HEAD SETUP_EMAIL.js

# 3. Committer
git commit -m "Initial clean commit without sensitive files"

# 4. Supprimer l'ancienne branche et renommer
git branch -D main
git branch -m main

# 5. Force push
git push origin main --force
```

---

## ✅ Après le nettoyage

### Pour l'équipe:

```bash
# Tous les développeurs doivent faire:
rm -rf smartnursery
git clone https://github.com/YOUR_REPO/smartnursery.git

# Puis réconfigurer Firebase:
flutterfire configure
```

### Vérifier le nettoyage:

```bash
# Vérifier que les fichiers ne sont plus dans l'historique
git log --all --full-history -- lib/services/firebase/firebase_options.dart
# Devrait returner aucun résultat

# Ou scanner le dépôt avec git-secrets
git secrets --scan-history
```

---

## 🛡️ Prévention Future

### 1. Ajouter Git Hooks pour éviter les commits accidentels

Créer `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Prévenir les commits accidentels de fichiers sensibles

FORBIDDEN_FILES=(
  "lib/services/firebase/firebase_options.dart"
  "android/app/google-services.json"
  "GoogleService-Info.plist"
  ".env"
  ".env.local"
)

for file in "${FORBIDDEN_FILES[@]}"; do
  if git diff --cached --name-only | grep -E "$file" > /dev/null 2>&1; then
    echo "❌ ERREUR: Tentative de committer un fichier sensible: $file"
    echo "   Ce fichier est ignoré par .gitignore"
    exit 1
  fi
done

exit 0
```

Installation:

```bash
# Rendre exécutable
chmod +x .git/hooks/pre-commit

# (Optional) Utiliser git-secrets
brew install git-secrets
git secrets --install
git secrets --register-aws
git secrets --add 'AIzaSy[a-zA-Z0-9_-]*'
```

### 2. Configuration GitHub/GitLab

**GitHub:**

- Settings → Security → Secret scanning
- Ajouter des règles customisées pour Firebase keys

**GitLab:**

- Settings → Audit events
- Activer Secret Detection

### 3. Pre-commit Framework

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets

  - repo: local
    hooks:
      - id: check-sensitive-files
        name: Check for sensitive files
        entry: bash -c 'for file in lib/services/firebase/firebase_options.dart android/app/google-services.json; do test -f "$file" && exit 1; done'
        language: system
```

---

## 📊 Status du Repo Actuellement

### ✅ Fait:

- `.gitignore` mis à jour avec les fichiers sensibles
- Templates créés (`.template`)
- Documentation de sécurité ajoutée

### ⚠️ À faire d'urgence:

1. **Nettoyer l'historique Git** pour supprimer les fichiers sensibles
2. Régénérer les clés Firebase (optionnel mais recommandé)
3. Mettre en place les git hooks
4. Notifier l'équipe

### 🔄 Futur:

- Implémenter les git hooks
- Ajouter detect-secrets à CI/CD
- Scanner régulier du dépôt

---

## 🚨 Si les clés ont été compromises

### Actions immédiates:

```bash
# 1. Dans Firebase Console:
# Project Settings → API Keys → Régénérer la clé

# 2. Invalider les tokens utilisateur
firebase auth:export --user-uids > users.json

# 3. Monitorer les activités suspectes
# Firestore → Metrics & Monitoring
```

---

## 📚 Ressources

- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
- [Git Filter-Branch](https://git-scm.com/docs/git-filter-branch)
- [Detect-Secrets](https://github.com/Yelp/detect-secrets)
- [OWASP - Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)

---

## Questions?

Pour plus d'informations sur la sécurité, voir:

- `SECURITY_GUIDE.md`
- `INSTALLATION_GUIDE.md`

**IMPORTANT: Effectuer ce nettoyage dès que possible!**
