@echo off
title Serveur Backend PHP - Quiz Islamique
chcp 65001 >nul
cls

echo ============================================================
echo        BACKEND PHP - QUIZ ISLAMIQUE
echo ============================================================
echo.

:: ─── Arreter l'ancien serveur sur port 8000 (sans quitter si erreur) ───────
echo Nettoyage du port 8000...
for /f "tokens=5" %%p in ('netstat -ano 2^>nul ^| findstr /C:":8000"') do (
    taskkill /PID %%p /F >nul 2>&1
)
ping -n 2 127.0.0.1 >nul

:: ─── Detecter PHP ──────────────────────────────────────────────────────────
set PHP_BIN=
if exist "C:\xampp\php\php.exe" set "PHP_BIN=C:\xampp\php\php.exe"
if exist "C:\wamp64\bin\php\php.exe" set "PHP_BIN=C:\wamp64\bin\php\php.exe"

if "%PHP_BIN%"=="" (
    where php >nul 2>nul
    if %errorlevel%==0 set "PHP_BIN=php"
)

if "%PHP_BIN%"=="" (
    echo.
    echo  [ERREUR] PHP introuvable !
    echo  Installez XAMPP sur C:\xampp
    echo.
    pause
    exit /b 1
)

echo  PHP trouve : %PHP_BIN%
echo.

:: ─── Detecter l'IP Wi-Fi (methode simple sans goto) ────────────────────────
set WIFI_IP=Inconnue
for /f "skip=1 tokens=1" %%a in (
    'powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.*'} | Select-Object -First 1 -ExpandProperty IPAddress"'
) do set WIFI_IP=%%a

:: ─── Affichage des adresses ─────────────────────────────────────────────────
echo  ADRESSES POUR FLUTTER :
echo.
echo  [PC / Web]           http://127.0.0.1:8000
echo  [Emulateur Android]  http://10.0.2.2:8000
echo  [Telephone Wi-Fi]    http://%WIFI_IP%:8000
echo.
echo  Test : http://127.0.0.1:8000/api/health
echo.
echo  >> Pour tester sur PC mettre : http://127.0.0.1:8000
echo.
echo ============================================================
echo  Serveur en cours... NE FERMEZ PAS cette fenetre !
echo  Appuyez sur Ctrl+C pour arreter le serveur.
echo ============================================================
echo.

:: ─── Lancer le serveur ──────────────────────────────────────────────────────
cd /d "%~dp0"
"%PHP_BIN%" -S 0.0.0.0:8000 -t public public/index.php

:: ─── Si le serveur s'arrete ─────────────────────────────────────────────────
echo.
echo  Serveur arrete.
echo  Appuyez sur une touche pour fermer...
pause >nul
