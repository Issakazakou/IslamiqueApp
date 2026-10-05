<?php
declare(strict_types=1);

require __DIR__ . '/../src/Http.php';
require __DIR__ . '/../src/QuestionRepository.php';

Http::cors();

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
if ($method === 'OPTIONS') {
    http_response_code(204);
    exit;
}

try {
    $repo = new QuestionRepository(__DIR__ . '/../data/questions.json');
} catch (Throwable $e) {
    Http::error('Erreur serveur : données indisponibles.', 500);
}

$path = Http::path();

/** Retire la bonne réponse avant envoi au client. */
$hideAnswer = static function (array $q): array {
    unset($q['bonneReponse']);
    return $q;
};

// GET /api/health
if ($method === 'GET' && $path === '/api/health') {
    Http::json(['status' => 'ok']);
}

// GET /api/categories
if ($method === 'GET' && $path === '/api/categories') {
    Http::json($repo->categories());
}

// GET /api/questions/{categorie}?level=debutant&limit=10&random=1&answers=0
if ($method === 'GET' && preg_match('#^/api/questions/([a-z]+)$#', $path, $m)) {
    $category = $m[1];
    if (!$repo->hasCategory($category)) {
        Http::error('Catégorie inconnue.', 404);
    }
    $level = $_GET['level'] ?? null;
    if ($level !== null && !QuestionRepository::isValidLevel((string) $level)) {
        Http::error('Niveau invalide : debutant, intermediaire ou avance.', 422);
    }
    $limit   = max(0, min(200, (int) ($_GET['limit'] ?? 0)));
    $random  = filter_var($_GET['random'] ?? false, FILTER_VALIDATE_BOOLEAN);
    $answers = filter_var($_GET['answers'] ?? false, FILTER_VALIDATE_BOOLEAN);

    $questions = $repo->pick($category, $level, $limit, $random);
    if (!$answers) {
        $questions = array_map($hideAnswer, $questions);
    }
    Http::json([
        'category'  => $category,
        'level'     => $level,
        'count'     => count($questions),
        'questions' => $questions,
    ]);
}

// POST /api/quiz/{categorie}/submit   { "answers": { "1": 1, "2": 3 } }
if ($method === 'POST' && preg_match('#^/api/quiz/([a-z]+)/submit$#', $path, $m)) {
    $category = $m[1];
    if (!$repo->hasCategory($category)) {
        Http::error('Catégorie inconnue.', 404);
    }
    $answers = Http::body()['answers'] ?? null;
    if (!is_array($answers) || $answers === []) {
        Http::error('Champ "answers" requis : { "idQuestion": indexChoix }.', 422);
    }

    $byId    = $repo->indexById($category);
    $results = [];
    $score   = 0;

    foreach ($answers as $id => $choice) {
        $id = (int) $id;
        if (!isset($byId[$id]) || !is_int($choice)) {
            Http::error("Réponse invalide pour la question $id.", 422);
        }
        $correct = $choice === (int) $byId[$id]['bonneReponse'];
        $score  += $correct ? 1 : 0;
        $results[] = [
            'id'           => $id,
            'choice'       => $choice,
            'correct'      => $correct,
            'bonneReponse' => (int) $byId[$id]['bonneReponse'],
        ];
    }

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
