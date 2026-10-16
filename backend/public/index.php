<?php
declare(strict_types=1);

require __DIR__ . '/../src/Http.php';
require __DIR__ . '/../src/QuestionRepository.php';
require __DIR__ . '/../src/DatabaseQuestionLoader.php';
require __DIR__ . '/../src/QuizSession.php';
require __DIR__ . '/../src/UserStore.php';
require __DIR__ . '/../src/AdminPanel.php';

Http::cors();

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
if ($method === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Panneau d'administration (/admin) : géré avant le chargement des questions.
//   QUIZ_ADMIN_PASSWORD  mot de passe de l'administrateur (utilisateur : admin). Vide = panneau désactivé.
$earlyPath = Http::path();
if ($earlyPath === '/admin' || str_starts_with($earlyPath, '/admin/')) {
    $dbMode = getenv('QUIZ_DB_DSN') !== false && getenv('QUIZ_DB_DSN') !== '';
    (new AdminPanel(
        __DIR__ . '/../data',
        getenv('QUIZ_ADMIN_PASSWORD') !== false ? (string) getenv('QUIZ_ADMIN_PASSWORD') : '',
        $dbMode
    ))->handle($method, $earlyPath);
}

// Source des questions :
//   - QUIZ_DB_DSN défini  -> base de données (ex. SQL Server : sqlsrv:Server=localhost;Database=quiz)
//   - sinon               -> data/questions.json
try {
    $dsn = getenv('QUIZ_DB_DSN');
    if ($dsn !== false && $dsn !== '') {
        $pdo = new PDO(
            $dsn,
            getenv('QUIZ_DB_USER') !== false ? getenv('QUIZ_DB_USER') : null,
            getenv('QUIZ_DB_PASS') !== false ? getenv('QUIZ_DB_PASS') : null,
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
        );
        $schema = getenv('QUIZ_DB_SCHEMA') !== false ? (string) getenv('QUIZ_DB_SCHEMA') : 'dbo';
        $repo = new QuestionRepository(DatabaseQuestionLoader::load($pdo, $schema));
    } else {
        $repo = QuestionRepository::fromJsonFile(__DIR__ . '/../data/questions.json');
    }
    $repo->loadTranslationsFile(__DIR__ . '/../data/translations.json');
} catch (Throwable $e) {
    error_log('[quiz] source de questions indisponible : ' . $e->getMessage());
    Http::error('Erreur serveur : données indisponibles.', 500);
}

// Réglages (variables d'environnement) :
//   QUIZ_DB_DSN / QUIZ_DB_USER / QUIZ_DB_PASS / QUIZ_DB_SCHEMA : base de données (voir ci-dessus)
//   QUIZ_STORAGE_DIR   dossier des sessions        (défaut : backend/storage)
//   QUIZ_RATE_LIMIT    sessions / heure / IP        (défaut : 120, 0 = illimité)
//   QUIZ_ALLOW_ANSWERS 1 = autorise ?answers=1      (debug local uniquement)
$sessions  = new QuizSession(getenv('QUIZ_STORAGE_DIR') ?: __DIR__ . '/../storage');
$rateLimit = (int) (getenv('QUIZ_RATE_LIMIT') !== false ? getenv('QUIZ_RATE_LIMIT') : 120);

$users     = new UserStore(getenv('QUIZ_STORAGE_DIR') ?: __DIR__ . '/../storage');
$authLimit = (int) (getenv('QUIZ_AUTH_RATE_LIMIT') !== false ? getenv('QUIZ_AUTH_RATE_LIMIT') : 30);

$path = Http::path();

/** Retire la bonne réponse avant envoi au client. */
$hideAnswer = static function (array $q): array {
    unset($q['bonneReponse'], $q['explication'], $q['source']);
    return $q;
};

/** Exécute [$fn] en convertissant les erreurs de session en réponse HTTP. */
$guard = static function (callable $fn) {
    try {
        return $fn();
    } catch (SessionException $e) {
        Http::error($e->getMessage(), $e->status);
    }
};


/** Convertit les erreurs de comptes en réponse HTTP. */
$authGuard = static function (callable $fn) {
    try {
        return $fn();
    } catch (AuthException $e) {
        Http::error($e->getMessage(), $e->status);
    }
};

// POST /api/auth/register   { "email": "…", "password": "…", "name": "…" }
// POST /api/auth/login      { "email": "…", "password": "…" }
// -> { "token": "…", "user": { "id", "email", "name" } }
if ($method === 'POST' && ($path === '/api/auth/register' || $path === '/api/auth/login')) {
    $body = Http::body();
    $email = $body['email'] ?? null;
    $password = $body['password'] ?? null;
    if (!is_string($email) || !is_string($password)) {
        Http::error('Champs "email" et "password" (texte) requis.', 422);
    }
    $out = $authGuard(static function () use ($users, $authLimit, $path, $body, $email, $password) {
        if ($users->rateLimited($_SERVER['REMOTE_ADDR'] ?? 'unknown', $authLimit)) {
            Http::error('Trop de tentatives. Réessayez plus tard.', 429);
        }
        if ($path === '/api/auth/register') {
            $name = $body['name'] ?? '';
            $user = $users->register($email, $password, is_string($name) ? $name : '');
        } else {
            $user = $users->login($email, $password);
        }
        return ['token' => $users->createToken($user), 'user' => $user];
    });
    Http::json($out, $path === '/api/auth/register' ? 201 : 200);
}

// POST /api/auth/logout   (Authorization: Bearer <jeton>)
if ($method === 'POST' && $path === '/api/auth/logout') {
    $users->revokeToken(Http::bearerToken());
    Http::json(['ok' => true]);
}

// GET /api/me   (Authorization: Bearer <jeton>)
if ($method === 'GET' && $path === '/api/me') {
    $user = $authGuard(static fn() => $users->authenticate(Http::bearerToken()));
    Http::json(['user' => $user]);
}

// ---- Profil : progression, statistiques et certificats synchronisés avec le compte ----

/** Catégories (et groupes) donnant droit à un certificat. */
$certDefs = static function () use ($repo): array {
    $groupTitles = ['coran' => 'Coran'];
    $defs = [];
    $groups = [];
    foreach ($repo->categories() as $c) {
        $defs[] = ['id' => $c['id'], 'title' => $c['title'], 'leaves' => [$c['id']]];
        if (is_string($c['parent'] ?? null)) {
            $groups[$c['parent']][] = $c['id'];
        }
    }
    foreach ($groups as $parent => $children) {
        $defs[] = ['id' => $parent, 'title' => $groupTitles[$parent] ?? ucfirst($parent), 'leaves' => $children];
    }
    return $defs;
};
$levelIds = array_keys(QuestionRepository::LEVELS);

/** Valide les statistiques envoyées par l'application (null = non envoyées). */
$cleanStats = static function (mixed $raw) use ($repo): ?array {
    if ($raw === null) {
        return null;
    }
    if (!is_array($raw)) {
        Http::error('Champ "stats" invalide.', 422);
    }
    $out = [];
    foreach (['quizDone', 'questions', 'correct', 'streak', 'bestStreak'] as $k) {
        $v = $raw[$k] ?? 0;
        if (!is_int($v) || $v < 0 || $v > 10000000) {
            Http::error("Statistique \"$k\" invalide.", 422);
        }
        $out[$k] = $v;
    }
    $lastPlay = $raw['lastPlay'] ?? null;
    if ($lastPlay !== null && (!is_string($lastPlay) || !preg_match('/^\d{4}-\d{2}-\d{2}$/', $lastPlay))) {
        Http::error('Statistique "lastPlay" invalide.', 422);
    }
    $out['lastPlay'] = $lastPlay;
    $badges = $raw['badges'] ?? [];
    if (!is_array($badges) || count($badges) > 100) {
        Http::error('Statistique "badges" invalide.', 422);
    }
    foreach ($badges as $badge) {
        if (!is_string($badge) || $badge === '' || strlen($badge) > 40) {
            Http::error('Statistique "badges" invalide.', 422);
        }
    }
    $out['badges'] = array_values($badges);
    $cats = $raw['categories'] ?? [];
    if (!is_array($cats)) {
        Http::error('Statistique "categories" invalide.', 422);
    }
    $out['categories'] = [];
    foreach ($cats as $id => $v) {
        if (!is_string($id) || !$repo->hasCategory($id) || !is_array($v)) {
            continue; // catégorie inconnue : ignorée
        }
        foreach (['done', 'correct', 'total'] as $f) {
            $n = $v[$f] ?? 0;
            if (!is_int($n) || $n < 0 || $n > 10000000) {
                Http::error('Statistique "categories" invalide.', 422);
            }
            $out['categories'][$id][$f] = $n;
        }
    }
    return $out;
};

// GET /api/progress   -> { "progress": [...], "stats": {...}, "certificates": [...] }
// PUT /api/progress   { "progress": [ … ], "stats": { … } }  fusionne (garde le meilleur) puis renvoie le résultat
if ($path === '/api/progress' && ($method === 'GET' || $method === 'PUT')) {
    $user = $authGuard(static fn() => $users->authenticate(Http::bearerToken()));
    if ($method === 'GET') {
        Http::json($authGuard(static fn() => [
            'progress'     => $users->progress($user['id']),
            'stats'        => $users->stats($user['id']),
            'certificates' => $users->issueCertificates($user['id'], $user['name'], $certDefs(), $levelIds),
        ]));
    }
    $body = Http::body();
    $list = $body['progress'] ?? null;
    if (!is_array($list)) {
        Http::error('Champ "progress" (liste) requis.', 422);
    }
    $clean = [];
    foreach ($list as $e) {
        if (!is_array($e)) {
            Http::error('Entrée de progression invalide.', 422);
        }
        $cat = $e['cat'] ?? null; $lvl = $e['lvl'] ?? null;
        $stage = $e['stage'] ?? null; $stars = $e['stars'] ?? null;
        $score = $e['score'] ?? null; $total = $e['total'] ?? null;
        if (!is_string($cat) || !$repo->hasCategory($cat)
            || !is_string($lvl) || !QuestionRepository::isValidLevel($lvl)
            || !is_int($stage) || $stage < 1 || $stage > 5
            || !is_int($stars) || $stars < 0 || $stars > 3
            || !is_int($score) || $score < 0 || $score > 1000
            || !is_int($total) || $total < 0 || $total > 1000 || $score > $total) {
            Http::error('Entrée de progression invalide.', 422);
        }
        $clean[] = ['cat' => $cat, 'lvl' => $lvl, 'stage' => $stage, 'stars' => $stars, 'score' => $score, 'total' => $total];
    }
    $stats = $cleanStats($body['stats'] ?? null);
    Http::json($authGuard(static fn() => [
        'progress'     => $users->mergeProgress($user['id'], $clean),
        'stats'        => $stats === null ? $users->stats($user['id']) : $users->mergeStats($user['id'], $stats),
        // Les certificats sont délivrés par le serveur, d'après la progression enregistrée.
        'certificates' => $users->issueCertificates($user['id'], $user['name'], $certDefs(), $levelIds),
    ]));
}

// GET /api/profile   -> { "user": {...}, "stats": {...}, "certificates": [...], "stagesPlayed": n }
// PUT /api/profile   { "name": "…" }  -> { "user": {...} }
if ($path === '/api/profile' && ($method === 'GET' || $method === 'PUT')) {
    $user = $authGuard(static fn() => $users->authenticate(Http::bearerToken()));
    if ($method === 'PUT') {
        $name = Http::body()['name'] ?? null;
        if (!is_string($name)) {
            Http::error('Champ "name" (texte) requis.', 422);
        }
        Http::json(['user' => $authGuard(static fn() => $users->updateName($user, $name))]);
    }
    Http::json($authGuard(static fn() => [
        'user'         => $user,
        'stats'        => $users->stats($user['id']),
        'certificates' => $users->issueCertificates($user['id'], $user['name'], $certDefs(), $levelIds),
        'stagesPlayed' => count($users->progress($user['id'])),
    ]));
}

// GET /api/certificates/{code}   (public) -> { "valid": true, "name", "title", "date" } ou 404
if ($method === 'GET' && preg_match('#^/api/certificates/([A-Za-z0-9-]{1,30})$#', $path, $m)) {
    if ($users->rateLimited($_SERVER['REMOTE_ADDR'] ?? 'unknown', max(0, $authLimit) * 10)) {
        Http::error('Trop de tentatives. Réessayez plus tard.', 429);
    }
    $cert = $authGuard(static fn() => $users->verifyCertificate($m[1]));
    if ($cert === null) {
        Http::error('Certificat introuvable.', 404);
    }
    Http::json(['valid' => true, 'name' => $cert['name'], 'title' => $cert['title'], 'date' => $cert['date']]);
}

// GET /api/health
if ($method === 'GET' && $path === '/api/health') {
    Http::json(['status' => 'ok']);
}

// GET /api/categories
if ($method === 'GET' && $path === '/api/categories') {
    Http::json($repo->categories());
}

// GET /api/questions/{categorie}?level=debutant&limit=10&random=1
// Crée une session de quiz : la réponse contient `session` (à renvoyer à /check et /submit).
if ($method === 'GET' && preg_match('#^/api/questions/([a-z_]+)$#', $path, $m)) {
    $category = $m[1];
    if (!$repo->hasCategory($category)) {
        Http::error('Catégorie inconnue.', 404);
    }
    $level = $_GET['level'] ?? null;
    if ($level !== null && !QuestionRepository::isValidLevel((string) $level)) {
        Http::error('Niveau invalide : debutant, intermediaire ou avance.', 422);
    }
    $limit  = max(0, min(200, (int) ($_GET['limit'] ?? 0)));
    $random = filter_var($_GET['random'] ?? false, FILTER_VALIDATE_BOOLEAN);
    // Les bonnes réponses ne sont JAMAIS envoyées avant que le joueur ait répondu.
    // `answers=1` n'est honoré que si QUIZ_ALLOW_ANSWERS=1 (debug local uniquement).
    $allowAnswers = getenv('QUIZ_ALLOW_ANSWERS') === '1';
    $answers = $allowAnswers && filter_var($_GET['answers'] ?? false, FILTER_VALIDATE_BOOLEAN);

    $lang      = QuestionRepository::normalizeLang($_GET['lang'] ?? null);
    $questions = array_map(
        static fn(array $q): array => $repo->localize($q, $lang),
        $repo->pick($category, $level, $limit, $random)
    );

    $session = $guard(static function () use ($sessions, $rateLimit, $category, $questions) {
        if ($sessions->rateLimited($_SERVER['REMOTE_ADDR'] ?? 'unknown', $rateLimit)) {
            Http::error('Trop de quiz lancés. Réessayez plus tard.', 429);
        }
        return $sessions->create($category, array_map(static fn(array $q): int => (int) $q['id'], $questions));
    });

    if (!$answers) {
        $questions = array_map($hideAnswer, $questions);
    }
    Http::json([
        'category'  => $category,
        'level'     => $level,
        'count'     => count($questions),
        'session'   => $session,
        'questions' => $questions,
    ]);
}

// POST /api/quiz/{categorie}/check   { "session": "...", "id": 1, "choice": 2 }
// Vérifie UNE réponse et révèle la bonne réponse de CETTE question (choice = -1 : temps écoulé).
// Une question ne se vérifie qu'une fois par session (même choix = même réponse, idempotent).
if ($method === 'POST' && preg_match('#^/api/quiz/([a-z_]+)/check$#', $path, $m)) {
    $category = $m[1];
    if (!$repo->hasCategory($category)) {
        Http::error('Catégorie inconnue.', 404);
    }
    $body    = Http::body();
    $session = $body['session'] ?? null;
    $id      = $body['id'] ?? null;
    $choice  = $body['choice'] ?? null;
    if (!is_string($session) || !is_int($id) || !is_int($choice)) {
        Http::error('Champs "session" (texte), "id" et "choice" (entiers) requis.', 422);
    }
    $lang = QuestionRepository::normalizeLang($body['lang'] ?? ($_GET['lang'] ?? null));
    $byId = array_map(
        static fn(array $q): array => $repo->localize($q, $lang),
        $repo->indexById($category)
    );
    if (!isset($byId[$id])) {
        Http::error("Question inconnue : $id.", 422);
    }
    if ($choice < -1 || $choice >= count($byId[$id]['options'] ?? [])) {
        Http::error('Choix hors limites.', 422);
    }
    $right = (int) $byId[$id]['bonneReponse'];

    $effective = $guard(static function () use ($sessions, $session, $category, $id, $choice) {
        return $sessions->mutate($session, $category, static function (array &$data) use ($id, $choice): int {
            if (!in_array($id, $data['ids'], true)) {
                Http::error('Cette question ne fait pas partie de votre quiz.', 422);
            }
            if (array_key_exists((string) $id, $data['checked'])) {
                $previous = (int) $data['checked'][(string) $id];
                if ($previous !== $choice) {
                    Http::error('Question déjà vérifiée avec un autre choix.', 409);
                }
                return $previous;
            }
            $data['checked'][(string) $id] = $choice;
            return $choice;
        });
    });

    Http::json([
        'id'           => $id,
        'choice'       => $effective,
        'correct'      => $effective === $right,
        'bonneReponse' => $right,
        // Explication et source : révélées avec la réponse, jamais avant.
        'explication'  => $byId[$id]['explication'] ?? null,
        'source'       => $byId[$id]['source'] ?? null,
    ]);
}

// POST /api/quiz/{categorie}/submit   { "session": "...", "answers": { "1": 1, "2": 3 } }
// Les questions déjà vérifiées gardent le choix enregistré (le client ne peut pas le changer).
if ($method === 'POST' && preg_match('#^/api/quiz/([a-z_]+)/submit$#', $path, $m)) {
    $category = $m[1];
    if (!$repo->hasCategory($category)) {
        Http::error('Catégorie inconnue.', 404);
    }
    $body    = Http::body();
    $session = $body['session'] ?? null;
    $answers = $body['answers'] ?? null;
    if (!is_string($session)) {
        Http::error('Champ "session" requis.', 422);
    }
    if (!is_array($answers) || $answers === []) {
        Http::error('Champ "answers" requis : { "idQuestion": indexChoix }.', 422);
    }

    $lang = QuestionRepository::normalizeLang($body['lang'] ?? ($_GET['lang'] ?? null));
    $byId = array_map(
        static fn(array $q): array => $repo->localize($q, $lang),
        $repo->indexById($category)
    );
    foreach ($answers as $id => $choice) {
        $id = (int) $id;
        if (!isset($byId[$id]) || !is_int($choice)
            || $choice < -1 || $choice >= count($byId[$id]['options'] ?? [])) {
            Http::error("Réponse invalide pour la question $id.", 422);
        }
    }

    $results = $guard(static function () use ($sessions, $session, $category, $answers, $byId) {
        return $sessions->mutate($session, $category, static function (array &$data) use ($answers, $byId): array {
            $out = [];
            foreach ($answers as $id => $choice) {
                $id = (int) $id;
                if (!in_array($id, $data['ids'], true)) {
                    Http::error("La question $id ne fait pas partie de votre quiz.", 422);
                }
                if (array_key_exists((string) $id, $data['checked'])) {
                    $choice = (int) $data['checked'][(string) $id];
                } else {
                    $data['checked'][(string) $id] = $choice;
                }
                $right = (int) $byId[$id]['bonneReponse'];
                $out[] = [
                    'id'           => $id,
                    'choice'       => $choice,
                    'correct'      => $choice === $right,
                    'bonneReponse' => $right,
                    'explication'  => $byId[$id]['explication'] ?? null,
                    'source'       => $byId[$id]['source'] ?? null,
                ];
            }
            return $out;
        });
    });

    $score = count(array_filter($results, static fn(array $r): bool => $r['correct']));
    $total = count($results);
    Http::json([
        'category'   => $category,
        'total'      => $total,
        'score'      => $score,
        'percentage' => $total > 0 ? round($score / $total * 100, 1) : 0,
        'results'    => $results,
    ]);
}

Http::error('Route introuvable.', 404);
