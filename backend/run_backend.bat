@echo off
title Serveur Backend PHP - Quiz Islamique
chcp 65001 >nul
cls
echo ========================================================
echo         SERVEUR BACKEND PHP - QUIZ ISLAMIQUE
echo ========================================================
echo.

set PHP_BIN=php
rem --- Base de données SQL Server (optionnel) : décommentez et adaptez ---
rem set QUIZ_DB_DSN=sqlsrv:Server=localhost\SQLEXPRESS;Database=quiz;TrustServerCertificate=1
rem set QUIZ_DB_USER=quiz_app
rem set QUIZ_DB_PASS=un_mot_de_passe_fort

where php >nul 2>nul
if %errorlevel% neq 0 (
    if exist "C:\xampp\php\php.exe" (
        set "PHP_BIN=C:\xampp\php\php.exe"
    ) else if exist "C:\wamp64\bin\php" (
        set "PHP_BIN=C:\wamp64\bin\php"
    ) else (
        echo [ERREUR] PHP n'a pas ete trouve dans le PATH ni dans C:\xampp\php\php.exe.
        echo Veuillez installer PHP ou XAMPP pour demarrer le backend.
        pause
        exit /b 1
    )
)

echo PHP utilise : %PHP_BIN%
echo.
echo Adresses d'acces :
echo   - Navigateur / PC local   : http://localhost:8000/api/health
echo   - Emulateur Android       : http://localhost:8000/api/health
echo   - Telephone physique       : utiliser une des IP ci-dessous (meme reseau)
echo.
echo   IP locales detectees sur ce PC :
powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } | ForEach-Object { '       http://' + $_.IPAddress + ':8000/api/health' }"
echo.
echo   ^>^> Copiez l'IP correspondant a votre reseau, puis saisissez
echo      http://localhost:8000 dans les Reglages de l'application.
echo.
echo ========================================================
echo  Serveur en cours d'execution... Appuyez sur Ctrl+C pour arreter.
echo ========================================================
echo.

cd /d "%~dp0"
"%PHP_BIN%" -S 0.0.0.0:8000 -t public public/index.php
pause
