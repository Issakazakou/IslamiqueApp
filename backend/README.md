# Quiz Islamique – Backend PHP

PHP 8.1+, sans dépendances. Données : `data/questions.json`.

## Structure
```
public/index.php          Routeur (point d'entrée)
src/Http.php              Réponses JSON, CORS, erreurs
src/QuestionRepository.php  Lecture des questions, niveaux
src/QuizSession.php       Sessions de quiz (anti-triche) + limite de débit
src/UserStore.php         Comptes, jetons de connexion, progression synchronisée
src/DatabaseQuestionLoader.php  Lecture des questions depuis une base (SQL Server ou tout PDO)
sql/sqlserver_toutes_categories.sql  Tables + 300 questions / 1200 choix (T-SQL)
data/questions.json       Questions (champ `niveau` explicite)
storage/                  Sessions générées à l'exécution (dossier inscriptible, ignoré par git)
tests/                    run.php (unitaires) et integration.sh (HTTP)
```

## Lancer
```bash
php -S 0.0.0.0:8000 -t public public/index.php
```
Émulateur Android : `http://10.0.2.2:8000`

## API
| Méthode | Route | Description |
|---|---|---|
| GET | `/api/health` | Disponibilité |
| GET | `/api/categories` | Catégories, niveaux, nombre de questions |
| GET | `/api/questions/{categorie}` | Questions **sans** la bonne réponse + `session` |
| POST | `/api/quiz/{categorie}/check` | Vérifie **une** réponse (`{"session":"…","id":1,"choice":2}`), `choice=-1` = temps écoulé |
| POST | `/api/quiz/{categorie}/submit` | Correction complète (`{"session":"…","answers":{…}}`) |
| POST | `/api/auth/register` | Crée un compte (`{"name","email","password"}`, mot de passe ≥ 8 caractères) → `{token, user}` |
| POST | `/api/auth/login` | Connexion (`{"email","password"}`) → `{token, user}` |
| POST | `/api/auth/logout` | Révoque le jeton (en-tête `Authorization: Bearer <jeton>`) |
| GET | `/api/me` | Utilisateur connecté |
| GET | `/api/progress` | Progression du compte : `{progress: [{cat, lvl, stage, stars, score, total}], stats, certificates}` |
| PUT | `/api/progress` | Envoie `{progress, stats}` : fusionne avec le compte (on garde le meilleur résultat) et renvoie `{progress, stats, certificates}` |
| GET | `/api/profile` | Profil : `{user, stats, certificates, stagesPlayed}` |
| PUT | `/api/profile` | Change le nom (`{"name"}`) |
| GET | `/api/certificates/{code}` | **Public** : vérifie un certificat → `{valid, name, title, date}` ou 404 |

### Langues (français, anglais, arabe)
Le français est la langue d'origine (`data/questions.json`). Les traductions sont dans `data/translations.json` (`{"en": {"<id>": {question, options, explication, source}}, "ar": {…}}`) ; **les choix doivent rester dans le même ordre que le français**. Ajoute `?lang=en|ar` à `/api/questions/{categorie}` (et `"lang"` dans le corps de `/check` et `/submit`, ce que fait l'application). Une question sans traduction reste en français.
Traductions fournies pour `coran_mediter` et `coran_tajwid` (60 questions) : les autres catégories sont encore en français et se complètent depuis le panneau d'administration.

### Panneau d'administration
- Adresse : `/admin` (utilisateur `admin`, mot de passe = variable `QUIZ_ADMIN_PASSWORD`). **Désactivé tant que cette variable est vide.** HTTPS obligatoire en production.
- Permet d'ajouter, modifier et supprimer des questions avec leurs explications, sources et traductions EN/AR.
- Écrit dans `data/questions.json` et `data/translations.json` : le dossier `data` doit être inscriptible par PHP.
- Indisponible avec une base de données (`QUIZ_DB_DSN`) : les questions se modifient alors dans la base.

### Explications et sources
Une question peut avoir les champs optionnels `explication` et `source` (voir `coran_mediter` dans `data/questions.json`). Ils ne sont **jamais** envoyés avec les questions : le serveur ne les révèle qu'avec la réponse (`/check`, `/submit`). Les tables SQL ne les contiennent pas encore : avec `QUIZ_DB_DSN`, il n'y a pas d'explications.

### Profil, statistiques et certificats
- **Statistiques** (quiz terminés, précision, série de jours, badges) : fusionnées avec celles du compte (totaux = valeur la plus haute, série = celle du dernier jour joué, badges réunis).
- **Certificats** : le serveur les délivre lui-même d'après la progression enregistrée (toutes les étapes d'une catégorie avec au moins 1 étoile ; le groupe Coran quand ses 3 sous-catégories sont terminées). La date est celle du serveur, le code (`XXXX-XXXX-XXXX`) est fabriqué avec une clé secrète `storage/secret.key` (**à sauvegarder** : elle est créée au premier usage). Un certificat n'est délivré qu'une fois.
- Vérification publique : `GET /api/certificates/{code}`.

### Comptes utilisateurs
- Stockage en fichiers JSON dans `storage/users`, `storage/tokens`, `storage/progress` (le dossier `storage` doit être inscriptible et **non accessible depuis le web**).
- Mots de passe hachés avec `password_hash` ; seul le hash du jeton est stocké ; jeton valable 90 jours.
- Inscription et connexion limitées par IP (défaut 30 tentatives/heure, `QUIZ_AUTH_RATE_LIMIT`, `0` = illimité).
- **En production : HTTPS obligatoire** (les mots de passe et les jetons transitent par l'API).

### Anti-triche
- Chaque chargement de questions crée une **session** (`session` dans la réponse) à renvoyer à `/check` et `/submit`.
- Une question ne peut être vérifiée qu'**une seule fois** par session : renvoyer le même choix redonne la même réponse, un autre choix → `409`. On ne peut donc pas tester les 4 options pour deviner.
- `/submit` conserve le choix déjà vérifié ; les ids hors session sont refusés (`422`).
- Nombre de sessions limité **par IP** (défaut 120/heure, `429` au-delà). Derrière un reverse proxy, `REMOTE_ADDR` est l'IP du proxy : adaptez la limite ou ajoutez la gestion de `X-Forwarded-For`.
- Limite : un joueur motivé peut encore apprendre les réponses en répondant à chaque question (c'est inhérent à un quiz avec correction) ; la limite de débit ralentit le moissonnage automatisé.

### Réglages (variables d'environnement)
| Variable | Défaut | Rôle |
|---|---|---|
| `QUIZ_DB_DSN` | *(vide)* | Base de données des questions. Vide = fichier `data/questions.json`. Ex. `sqlsrv:Server=localhost\SQLEXPRESS;Database=quiz;TrustServerCertificate=1` |
| `QUIZ_DB_USER` / `QUIZ_DB_PASS` | *(vides)* | Identifiants SQL (omettre pour l'authentification Windows) |
| `QUIZ_DB_SCHEMA` | `dbo` | Schéma des tables (`''` = aucun préfixe) |
| `QUIZ_STORAGE_DIR` | `backend/storage` | Dossier des sessions (doit être inscriptible par PHP) |
| `QUIZ_RATE_LIMIT` | `120` | Sessions / heure / IP (`0` = illimité) |
| `QUIZ_ADMIN_PASSWORD` | *(vide)* | Active le panneau `/admin` (utilisateur `admin`) |
| `QUIZ_AUTH_RATE_LIMIT` | `30` | Inscriptions + connexions / heure / IP (`0` = illimité) |
| `QUIZ_CORS_ORIGIN` | `*` | Origine autorisée pour une app web |
| `QUIZ_ALLOW_ANSWERS` | *(vide)* | `1` = autorise `?answers=1` (debug local uniquement) |

**Catégories** : `coran_mediter`, `coran_tajwid`, `coran_culture` (regroupées sous « Coran » dans l'application, champ `parent` de `/api/categories`), `hadith`, `fiqh`, `sira`
**Niveaux** : `debutant`, `intermediaire`, `avance` (champ `niveau` de chaque question dans `data/questions.json` ; 25 questions par niveau pour `coran_culture`, `hadith`, `fiqh`, `sira` ; 10 par niveau pour `coran_mediter` et `coran_tajwid`)

**Paramètres de `/api/questions/{categorie}`**

| Paramètre | Exemple | Effet |
|---|---|---|
| `level` | `debutant` | Filtre par niveau |
| `limit` | `10` | Nombre max de questions |
| `random` | `1` | Ordre aléatoire |
| `answers` | `1` | Inclut `bonneReponse` — **ignoré** sauf si `QUIZ_ALLOW_ANSWERS=1` (debug) |

## Exemples
```bash
curl "http://localhost:8000/api/questions/coran?level=debutant&limit=10&random=1"   # -> { "session": "…", "questions": [...] }

curl -X POST http://localhost:8000/api/quiz/coran/submit \
  -H "Content-Type: application/json" \
  -d '{"session": "LA_SESSION_REÇUE", "answers": {"1": 1, "2": 3}}'
```

Réponse de la correction :
```json
{ "category": "coran", "total": 2, "score": 2, "percentage": 100,
  "results": [ { "id": 1, "choice": 1, "correct": true, "bonneReponse": 1 } ] }
```

## Erreurs
Format : `{ "error": "message" }` — codes `404` (route/catégorie), `422` (paramètre invalide), `400` (JSON invalide), `401` (session mal formée), `409` (question déjà vérifiée avec un autre choix), `410` (session inconnue ou expirée, 6 h), `429` (trop de quiz), `500` (serveur).

## Tests
```bash
php tests/run.php          # unitaires : données, niveaux, sessions, limite de débit
bash tests/integration.sh  # HTTP : lance un serveur temporaire et teste toutes les routes
```

## Déploiement Apache
DocumentRoot sur `public/` — le `.htaccess` redirige vers `index.php`.
Le dossier `storage/` doit être inscriptible par l'utilisateur PHP (`chown www-data storage`).

## Déploiement HTTPS (obligatoire en production)
L'application mobile de **production** refuse le HTTP en clair (Android release, iOS).
Placez le backend derrière HTTPS.

**Caddy** (certificat Let's Encrypt automatique) :
```caddyfile
quiz.mondomaine.com {
    root * /var/www/IslamiqueApp/backend/public
    php_fastcgi unix//run/php/php8.3-fpm.sock
    file_server
    header Strict-Transport-Security "max-age=31536000"
}
```

**Apache** : `sudo certbot --apache -d quiz.mondomaine.com`, puis redirigez le port 80 vers 443.

Compiler l'application avec l'URL de production :
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://quiz.mondomaine.com
```
En développement (sans `API_BASE_URL`), l'app vise `127.0.0.1:8000` (`10.0.2.2:8000` sur l'émulateur
Android). Un téléphone physique saisit l'IP du PC dans les réglages du serveur.

## Base de données SQL Server (optionnel)
Par défaut les questions viennent de `data/questions.json`. Pour les lire dans SQL Server :

1. **Créer la base** puis exécuter `sql/sqlserver_toutes_categories.sql` (SSMS ou `sqlcmd -S SERVEUR -d quiz -i sql/sqlserver_toutes_categories.sql`).
   Tables : `questions(id, categorie, niveau, enonce)` et `choix(id, question_id, choix, est_correct)`.
   La bonne réponse est le choix dont `est_correct = 1` ; **l'ordre d'affichage des choix suit `choix.id`**
   (insérez-les dans l'ordre voulu). Un index unique interdit deux bonnes réponses sur une même question.
2. **Installer le pilote PHP** : *Microsoft Drivers for PHP for SQL Server* (`php_pdo_sqlsrv`, version et
   « thread safety » identiques à votre PHP) + *ODBC Driver 18 for SQL Server*, puis `extension=pdo_sqlsrv`
   dans `php.ini`.
3. **Définir les variables** avant de lancer PHP (dans `run_backend.bat` : `set QUIZ_DB_DSN=...`) :
```bat
set QUIZ_DB_DSN=sqlsrv:Server=localhost\SQLEXPRESS;Database=quiz;TrustServerCertificate=1
rem Authentification SQL (sinon authentification Windows) :
rem set QUIZ_DB_USER=quiz_app
rem set QUIZ_DB_PASS=un_mot_de_passe_fort
```
Les questions sont lues à chaque requête de chargement ; une donnée invalide (moins de 2 choix, 0 ou 2 bonnes
réponses) renvoie une erreur 500 et le détail est écrit dans le journal PHP (`error_log`).
Utilisez un compte SQL en **lecture seule** pour l'application.

Test sans SQL Server : `SOURCE=sqlite bash tests/integration.sh` rejoue les tests HTTP avec les questions
lues dans une base SQLite (mêmes tables, même code de chargement).
