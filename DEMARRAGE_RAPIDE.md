# 🚀 DÉMARRAGE RAPIDE - Reconnaissance Faciale SmartNursery

## ⏱️ 5 Minutes pour Faire Fonctionner

### Étape 1: Démarrer le Serveur (1 min)

**Windows:**

```bash
cd SmartNursery\functions
start_server.bat
```

**macOS/Linux:**

```bash
cd SmartNursery/functions
./start_server.sh
```

✅ Le serveur tourne sur **http://localhost:5000**

---

### Étape 2: Configurer Firebase (2 min)

**Important**: Sans cela, le serveur ne peut pas accéder à vos données!

1. **Allez ici**: https://console.firebase.google.com/project/smartnursery-b46102cf/settings/serviceaccounts/adminsdk

2. **Cliquez**: "Generate New Private Key" (bouton bleu)

3. **Copiez le fichier** dans:

   ```
   SmartNursery/functions/temp_service_account.json
   ```

4. **Redémarrez le serveur** (Ctrl+C puis relancez)

✅ Vous verrez: `✅ Firebase initialisé avec succès!`

---

### Étape 3: Enregistrer des Visages (1 min)

1. **Lancez l'app Flutter**
2. **Profil** → Parents/Éducateurs
3. **"Ajouter un visage"** et prenez une photo
4. **Répétez** pour 2-3 parents

✅ Les visages sont stockés automatiquement

---

### Étape 4: Tester l'Identification (1 min)

1. **Identification** (écran caméra)
2. **Positionnez votre visage** dans le cercle
3. **"Continuer"** → La photo est prise
4. **Attendez** 3-5 secondes
5. **Résultat**: ✅ Parent reconnu ou ❌ Visage non reconnu

---

## 🎯 C'est Tout!

Si ça marche, vous verrez:

```
✅ VISAGE RECONNU: Jean Dupont
```

Si ça ne marche pas, regardez [RESOLUTION_RECONNAISSANCE_FACIALE.md](../RESOLUTION_RECONNAISSANCE_FACIALE.md) section "Dépannage"

---

## 💡 Conseils Utiles

### Les Logs du Serveur vous Aident

Quand vous testez, regardez la console du serveur (l'autre fenêtre):

```
🔍 Reconnaissance de visage demandée...
✅ Visage détecté dans l'image
📊 Comparaison avec 3 utilisateurs...
✅ VISAGE RECONNU: Jean Dupont
```

### Si le Visage n'est Pas Reconnu

- ✅ Bonne lumière
- ✅ Visage centré et clair
- ✅ Plusieurs photos enregistrées d'angles différents
- ✅ Distance: 30-50 cm

### Port 5000 Occupé?

```bash
# Windows PowerShell:
Get-Process -Id (Get-NetTCPConnection -LocalPort 5000).OwningProcess | Stop-Process -Force

# macOS/Linux:
kill -9 $(lsof -t -i:5000)
```

---

## 📚 Documentation Complète

- **[FACE_RECOGNITION_SERVER.md](./functions/FACE_RECOGNITION_SERVER.md)** - Configuration avancée
- **[RESOLUTION_RECONNAISSANCE_FACIALE.md](./RESOLUTION_RECONNAISSANCE_FACIALE.md)** - Problèmes et solutions

---

## 🆘 Besoin d'Aide?

Le serveur affiche des messages d'erreur clairs. Exemple:

```
⚠️  ATTENTION: Fichier de credentials Firebase non trouvé!
   Cherché dans:
     - temp_service_account.json
```

→ Cela signifie que vous devez placer votre fichier Firebase JSON (voir Étape 2).

---

**Créé pour SmartNursery** 🌳 - Gestion intelligente de la garde d'enfants
