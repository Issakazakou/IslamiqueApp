# IslamiqueApp — Frontend Flutter

Application de quiz islamique multiplateforme (Android, iOS, Web et desktop).

## Développement local

Depuis le dossier `frontend` :

```bash
flutter pub get
flutter run
```

Le backend PHP doit être démarré séparément depuis `backend` :

```bash
php -S 0.0.0.0:8000 -t public public/index.php
```

## Configuration de l'API

L'URL est résolue dans cet ordre :

1. l'URL personnalisée enregistrée dans les réglages de l'application ;
2. la variable de compilation `API_BASE_URL` ;
3. une URL locale adaptée à la plateforme.

Exemples :

```bash
# API de production ou de staging
flutter run --dart-define=API_BASE_URL=https://api.exemple.com
flutter build web --dart-define=API_BASE_URL=https://api.exemple.com

# Téléphone physique sur le réseau local
# Saisir l'URL du PC dans Réglages, par exemple :
# http://192.168.1.20:8000
```

Les adresses locales par défaut sont `http://127.0.0.1:8000` sur desktop et
`http://10.0.2.2:8000` sur l'émulateur Android. En Web, l'application utilise
l'origine courante, ce qui permet de placer l'API derrière le même domaine.

## Vérifications

```bash
flutter analyze
flutter test
```

## Architecture principale

- `lib/main.dart` : démarrage et écran d'accueil ;
- `lib/services/quiz_service.dart` : communication avec l'API ;
- `lib/config/api_config.dart` : résolution et test de l'URL backend ;
- `lib/stage_progress_manager.dart` : progression locale ;
- `lib/theme/` : tokens et thèmes clair/sombre ;
- `../backend/` : API PHP et données des questions.
