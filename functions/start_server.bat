@echo off
REM Script de démarrage du serveur de reconnaissance faciale
REM Pour Windows PowerShell

echo.
echo ==============================================================
echo  Serveur de Reconnaissance Faciale - SmartNursery
echo ==============================================================
echo.

REM Vérifie si Python est installé
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python n'est pas installie ou pas dans PATH
    echo Installez Python 3.9+ depuis https://www.python.org/
    pause
    exit /b 1
)

echo [1/3] Installation des dépendances...
python -m pip install --upgrade pip >nul 2>&1
python -m pip install -r requirements.txt

if errorlevel 1 (
    echo ERROR: Installation des dépendances échouée
    pause
    exit /b 1
)

echo [2/3] Vérification du fichier de credentials Firebase...
if not exist "temp_service_account.json" (
    echo.
    echo WARNING: temp_service_account.json non trouvé!
    echo Téléchargez votre fichier de credentials Firebase:
    echo 1. Allez sur https://console.firebase.google.com
    echo 2. Projet SmartNursery ^> Settings ^> Service Accounts
    echo 3. Cliquez "Generate New Private Key"
    echo 4. Placez le fichier dans: functions/temp_service_account.json
    echo.
    echo Le serveur démarrera sans Firebase pour les tests.
    echo.
)

echo [3/3] Démarrage du serveur...
echo.
echo ✓ Serveur actif sur: http://localhost:5000
echo ✓ Appuyez sur Ctrl+C pour arrêter
echo.

python local_server.py

pause
