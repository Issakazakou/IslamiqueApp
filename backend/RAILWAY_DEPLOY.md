# IslamiqueApp Backend — Déploiement Railway

Ce backend PHP est déployé sur Railway et expose une API REST pour l'app Flutter.

## Variables d'environnement Railway à configurer

| Variable              | Description                                      | Exemple                          |
|-----------------------|--------------------------------------------------|----------------------------------|
| `PORT`                | Géré automatiquement par Railway                 | (ne pas modifier)                |
| `QUIZ_STORAGE_DIR`    | Dossier de stockage (sessions, users, tokens)    | `/app/storage`                   |
| `QUIZ_CORS_ORIGIN`    | Origines autorisées (CORS)                       | `*`                              |
| `QUIZ_RATE_LIMIT`     | Nb de sessions/heure/IP (0 = illimité)           | `120`                            |
| `QUIZ_AUTH_RATE_LIMIT`| Nb de tentatives auth/heure/IP                   | `30`                             |
| `QUIZ_ADMIN_PASSWORD` | Mot de passe du panneau admin (vide = désactivé) | `motdepasse_secret`              |
| `QUIZ_DB_DSN`         | (Optionnel) DSN PDO si base SQL externe          | (laisser vide = fichier JSON)    |

## Déploiement rapide

1. Pousser ce dossier `backend/` sur GitHub
2. Créer un projet Railway → "Deploy from GitHub repo"
3. Sélectionner le dossier `backend/` comme racine
4. Ajouter les variables d'environnement ci-dessus
5. Railway génère une URL publique HTTPS (ex: `https://islamiqueapp-backend-xxx.up.railway.app`)
6. Dans Flutter : `flutter build apk --dart-define=API_BASE_URL=https://ton-url.up.railway.app`

## Persistance des données (IMPORTANT)

Railway efface le système de fichiers à chaque redéploiement.  
**Solution** : Utiliser un Volume Railway pour persister `/app/storage` :
- Dans Railway > ton service > "Volumes" → Monter `/app/storage`
- Cela préserve les comptes utilisateurs, sessions et certificats entre les déploiements.
