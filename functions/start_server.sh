#!/bin/bash

echo ""
echo "=============================================================="
echo "  Serveur de Reconnaissance Faciale - SmartNursery"
echo "=============================================================="
echo ""

# Vérifie si Python est installé
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 n'est pas installé"
    echo "Installez Python 3.9+ depuis https://www.python.org/"
    exit 1
fi

echo "[1/3] Installation des dépendances..."
python3 -m pip install --upgrade pip >/dev/null 2>&1
python3 -m pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo "ERROR: Installation des dépendances échouée"
    exit 1
fi

echo "[2/3] Vérification du fichier de credentials Firebase..."
if [ ! -f "temp_service_account.json" ]; then
    echo ""
    echo "WARNING: temp_service_account.json non trouvé!"
    echo "Téléchargez votre fichier de credentials Firebase:"
    echo "1. Allez sur https://console.firebase.google.com"
    echo "2. Projet SmartNursery > Settings > Service Accounts"
    echo "3. Cliquez 'Generate New Private Key'"
    echo "4. Placez le fichier dans: functions/temp_service_account.json"
    echo ""
    echo "Le serveur démarrera sans Firebase pour les tests."
    echo ""
fi

echo "[3/3] Démarrage du serveur..."
echo ""
echo "✓ Serveur actif sur: http://localhost:5000"
echo "✓ Appuyez sur Ctrl+C pour arrêter"
echo ""

python3 local_server.py
