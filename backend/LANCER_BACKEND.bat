@echo off
chcp 65001 >nul
title IslamiqueApp — Serveur Backend PHP

:: ─── Arrêter tout ancien serveur sur le port 8000 ─────────────────────────
echo [1/3] Arrêt de l'ancien serveur si existant...
for /f "tokens=5" %%p in ('netstat -ano 2^>nul ^| findstr ":8000 "') do (
    taskkill /PID %%p /F >nul 2>&1
)
timeout /t 1 >nul

:: ─── Vérifier PHP ─────────────────────────────────────────────────────────
if not exist "C:\xampp\php\php.exe" (
    echo ERREUR : PHP introuvable dans C:\xampp\php\php.exe
    pause & exit /b 1
)

:: ─── Récupérer l'IP Wi-Fi actuelle ────────────────────────────────────────
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4"') do (
    set RAW_IP=%%a
    goto :got_ip
)
:got_ip
set IP=%RAW_IP: =%

:: ─── Lancer le serveur ────────────────────────────────────────────────────
echo [2/3] Démarrage...
echo.
echo ══════════════════════════════════════════════════════
echo   ✅  ISLAMIQUE APP — BACKEND PHP
echo ══════════════════════════════════════════════════════
echo.
echo   Adresses pour Flutter :
echo.
echo   - Emulateur Android  : http://10.0.2.2:8000
echo   - Telephone Wi-Fi    : http://%IP%:8000
echo   - PC / Web           : http://127.0.0.1:8000
echo.
echo   Sante    : http://127.0.0.1:8000/api/health
echo   Categ.   : http://127.0.0.1:8000/api/categories
echo.
echo   ⚠️  Ne fermez pas cette fenetre !
echo ══════════════════════════════════════════════════════
echo.

C:\xampp\php\php.exe -S 0.0.0.0:8000 -t "%~dp0public"

echo.
echo Serveur arrêté. Appuyez sur une touche...
pause >nul
