# Quiz Islamique – Backend PHP

PHP 8.1+, sans dépendances. Données : `data/questions.json`.

## Structure
```
public/index.php          Routeur (point d'entrée)
src/Http.php              Réponses JSON, CORS, erreurs
src/QuestionRepository.php  Lecture des questions, niveaux
data/questions.json       Questions
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
| GET | `/api/questions/{categorie}` | Questions (sans la bonne réponse) |
| POST | `/api/quiz/{categorie}/submit` | Correction |

**Catégories** : `coran`, `hadith`, `fiqh`, `sira`
**Niveaux** : `debutant`, `intermediaire`, `avance` (un tiers des questions chacun, selon l'ordre du fichier)

**Paramètres de `/api/questions/{categorie}`**

| Paramètre | Exemple | Effet |
|---|---|---|
| `level` | `debutant` | Filtre par niveau |
| `limit` | `10` | Nombre max de questions |
| `random` | `1` | Ordre aléatoire |
| `answers` | `1` | Inclut `bonneReponse` |

## Exemples
```bash
curl "http://localhost:8000/api/questions/coran?level=debutant&limit=10&random=1"

curl -X POST http://localhost:8000/api/quiz/coran/submit \
  -H "Content-Type: application/json" \
  -d '{"answers": {"1": 1, "2": 3}}'
```

Réponse de la correction :
```json
{ "category": "coran", "total": 2, "score": 2, "percentage": 100,
  "results": [ { "id": 1, "choice": 1, "correct": true, "bonneReponse": 1 } ] }
```

## Erreurs
Format : `{ "error": "message" }` — codes `404` (route/catégorie), `422` (paramètre invalide), `400` (JSON invalide), `500` (serveur).

## Déploiement Apache
DocumentRoot sur `public/` — le `.htaccess` redirige vers `index.php`.
