<?php
declare(strict_types=1);
// Tests unitaires sans dépendance :  php backend/tests/run.php
require __DIR__ . '/../src/Http.php';
require __DIR__ . '/../src/QuestionRepository.php';
require __DIR__ . '/../src/DatabaseQuestionLoader.php';
require __DIR__ . '/../src/QuizSession.php';
require __DIR__ . '/../src/UserStore.php';
require __DIR__ . '/../src/AdminPanel.php';

$failed = 0;
function check(string $name, bool $ok): void
{
    global $failed;
    echo ($ok ? "  OK   " : "  FAIL ") . $name . PHP_EOL;
    if (!$ok) { $failed++; }
}
function throwsStatus(callable $fn, int $status): bool
{
    try { $fn(); } catch (SessionException $e) { return $e->status === $status; }
    return false;
}

echo "QuestionRepository\n";
$repo = QuestionRepository::fromJsonFile(__DIR__ . '/../data/questions.json');
$expected = ['coran_mediter' => 10, 'coran_tajwid' => 100, 'coran_culture' => 25, 'hadith' => 25, 'fiqh' => 25, 'sira' => 25];
foreach ($expected as $cat => $perLevel) {
    $all = $repo->all($cat);
    check("$cat : " . ($perLevel * 3) . " questions", count($all) === $perLevel * 3);
    foreach (array_keys(QuestionRepository::LEVELS) as $lvl) {
        $n = count($repo->pick($cat, $lvl, 0, false));
        check("$cat / $lvl : $perLevel questions", $n === $perLevel);
    }
    $ids = array_column($all, 'id');
    check("$cat : ids uniques", count($ids) === count(array_unique($ids)));
    $validAnswers = true;
    foreach ($all as $q) {
        $validAnswers = $validAnswers && is_int($q['bonneReponse'])
            && $q['bonneReponse'] >= 0 && $q['bonneReponse'] < count($q['options'])
            && count($q['options']) === count(array_unique($q['options']));
    }
    check("$cat : bonneReponse valide, choix distincts", $validAnswers);
}
$withSources = true;
foreach ($repo->all('coran_mediter') as $q) {
    $withSources = $withSources && is_string($q['explication'] ?? null) && $q['explication'] !== ''
        && is_string($q['source'] ?? null) && $q['source'] !== '';
}
check('coran_mediter : explication et source sur chaque question', $withSources);
$cats = $repo->categories();
check('catégories Coran rattachées au parent « coran »',
    count(array_filter($cats, static fn(array $c): bool => $c['parent'] === 'coran')) === 3);
$debutant = array_column($repo->pick('coran_culture', 'debutant', 0, false), 'id');
$avance   = array_column($repo->pick('coran_culture', 'avance', 0, false), 'id');
check('niveaux disjoints', array_intersect($debutant, $avance) === []);
check('limit respecté', count($repo->pick('coran_culture', null, 7, true)) === 7);

echo "QuizSession\n";
$dir = sys_get_temp_dir() . '/quiz_test_' . bin2hex(random_bytes(4));
$s = new QuizSession($dir);
$id = $s->create('coran_culture', [1, 2, 3]);
check('id de session = 32 hex', (bool) preg_match('/^[a-f0-9]{32}$/', $id));
check('mauvaise catégorie -> 410', throwsStatus(fn() => $s->mutate($id, 'hadith', fn(array &$d) => 1), 410));
check('session inconnue -> 410', throwsStatus(fn() => $s->mutate(str_repeat('a', 32), 'coran_culture', fn(array &$d) => 1), 410));
check('id mal formé -> 401', throwsStatus(fn() => $s->mutate('../../etc/passwd', 'coran_culture', fn(array &$d) => 1), 401));
$s->mutate($id, 'coran_culture', function (array &$d) { $d['checked']['1'] = 2; });
$seen = $s->mutate($id, 'coran_culture', fn(array &$d) => $d['checked']['1'] ?? null);
check('mutation persistée', $seen === 2);
check('limite de débit : sous la limite', $s->rateLimited('1.2.3.4', 3) === false);
$s->rateLimited('1.2.3.4', 3); $s->rateLimited('1.2.3.4', 3);
check('limite de débit : dépassée à la 4e', $s->rateLimited('1.2.3.4', 3) === true);
check('limite de débit : autre IP non bloquée', $s->rateLimited('5.6.7.8', 3) === false);
check('limite 0 = illimité', $s->rateLimited('9.9.9.9', 0) === false);

echo "Traductions\n";
$trRepo = QuestionRepository::fromJsonFile(__DIR__ . '/../data/questions.json');
$trRepo->loadTranslationsFile(__DIR__ . '/../data/translations.json');
$trFile = json_decode((string) file_get_contents(__DIR__ . '/../data/translations.json'), true);
$byIdAll = [];
foreach (array_keys($expected) as $cat) {
    foreach ($trRepo->all($cat) as $q) {
        $byIdAll[(int) $q['id']] = $q;
    }
}
foreach (['en', 'ar'] as $lang) {
    $valid = true;
    foreach ($trFile[$lang] ?? [] as $id => $t) {
        $q = $byIdAll[(int) $id] ?? null;
        $valid = $valid && $q !== null && count($t['options'] ?? []) === count($q['options'])
            && count(array_unique($t['options'])) === count($t['options']) && ($t['question'] ?? '') !== '';
    }
    check("traductions $lang : questions connues, 4 choix distincts", $valid && count($trFile[$lang] ?? []) > 0);
}
$q301 = $byIdAll[301];
$en301 = $trRepo->localize($q301, 'en');
check('localize : question traduite', $en301['question'] !== $q301['question']);
check('localize : même bonne réponse (index conservé)', $en301['bonneReponse'] === $q301['bonneReponse']);
check('localize : explication traduite', $en301['explication'] !== $q301['explication']);
check('localize : français inchangé', $trRepo->localize($q301, 'fr') === $q301);
check('localize : sans traduction -> français', $trRepo->localize($byIdAll[1], 'ar') === $byIdAll[1]);
check('normalizeLang', QuestionRepository::normalizeLang('EN-us') === 'en'
    && QuestionRepository::normalizeLang('xx') === 'fr' && QuestionRepository::normalizeLang(null) === 'fr');

echo "AdminPanel (validation)\n";
$form = [
    'categorie' => 'sira', 'niveau' => 'debutant', 'question' => ' Qui fut le premier calife ? ',
    'options' => ['Abu Bakr', 'Omar', 'Othman', 'Ali'], 'bonne' => '0',
    'explication' => '', 'source' => '',
    'en' => ['question' => '', 'options' => ['', '', '', ''], 'explication' => '', 'source' => ''],
    'ar' => ['question' => '', 'options' => ['', '', '', ''], 'explication' => '', 'source' => ''],
];
$ok = AdminPanel::parseForm($form, 999);
check('formulaire valide', $ok['question']['id'] === 999 && $ok['question']['question'] === 'Qui fut le premier calife ?');
check('formulaire : pas de champ explication vide', !isset($ok['question']['explication']) && $ok['translations']['en'] === null);
$rejects = static function (array $changes) use ($form): bool {
    try { AdminPanel::parseForm(array_replace_recursive($form, $changes), 1); } catch (InvalidArgumentException) { return true; }
    return false;
};
check('formulaire : catégorie inconnue refusée', $rejects(['categorie' => 'nimporte']));
check('formulaire : choix en double refusés', $rejects(['options' => ['A', 'A', 'B', 'C']]));
check('formulaire : choix vide refusé', $rejects(['options' => ['A', '', 'B', 'C']]));
check('formulaire : bonne réponse hors limites refusée', $rejects(['bonne' => '4']));
check('formulaire : traduction incomplète refusée', $rejects(['en' => ['question' => 'Who?']]));
$withTr = AdminPanel::parseForm(array_replace_recursive($form, ['en' => [
    'question' => 'Who was the first caliph?', 'options' => ['Abu Bakr', 'Umar', 'Uthman', 'Ali'],
]]), 5);
check('formulaire : traduction complète acceptée', $withTr['translations']['en']['options'][1] === 'Umar');

echo "UserStore\n";
$u = new UserStore($dir . '_users');
$thrown = static function (callable $fn, int $status): bool {
    try { $fn(); } catch (AuthException $e) { return $e->status === $status; }
    return false;
};
$acc = $u->register('  Ali@Example.com ', 'motdepasse1', 'Ali');
check('inscription : e-mail normalisé', $acc['email'] === 'ali@example.com');
check('inscription : doublon -> 409', $thrown(fn() => $u->register('ali@example.com', 'autrepasse1', 'Ali'), 409));
check('inscription : mot de passe trop court -> 422', $thrown(fn() => $u->register('b@example.com', 'court', 'B'), 422));
check('inscription : e-mail invalide -> 422', $thrown(fn() => $u->register('pas-un-email', 'motdepasse1', 'B'), 422));
check('connexion : bon mot de passe', $u->login('ALI@example.com', 'motdepasse1')['id'] === $acc['id']);
check('connexion : mauvais mot de passe -> 401', $thrown(fn() => $u->login('ali@example.com', 'faux-mot-de-passe'), 401));
check('connexion : compte inconnu -> 401', $thrown(fn() => $u->login('zz@example.com', 'motdepasse1'), 401));
$tok = $u->createToken($acc);
check('jeton = 64 hex', (bool) preg_match('/^[a-f0-9]{64}$/', $tok));
check('jeton valide -> utilisateur', $u->authenticate($tok)['id'] === $acc['id']);
check('jeton absent -> 401', $thrown(fn() => $u->authenticate(null), 401));
check('jeton inconnu -> 401', $thrown(fn() => $u->authenticate(str_repeat('a', 64)), 401));
$u->revokeToken($tok);
check('jeton révoqué -> 401', $thrown(fn() => $u->authenticate($tok), 401));
$e1 = ['cat' => 'sira', 'lvl' => 'debutant', 'stage' => 1, 'stars' => 2, 'score' => 4, 'total' => 5];
$m1 = $u->mergeProgress($acc['id'], [$e1]);
check('progression enregistrée', count($m1) === 1 && $m1[0]['stars'] === 2);
$m2 = $u->mergeProgress($acc['id'], [array_merge($e1, ['stars' => 1, 'score' => 3])]);
check('progression : on garde le meilleur résultat', $m2[0]['stars'] === 2 && $m2[0]['score'] === 4);
$m3 = $u->mergeProgress($acc['id'], [array_merge($e1, ['stars' => 3, 'score' => 5])]);
check('progression : amélioration prise en compte', $m3[0]['stars'] === 3 && $m3[0]['score'] === 5);
check('progression relue', $u->progress($acc['id'])[0]['stars'] === 3);
check('limite de débit auth', $u->rateLimited('1.1.1.1', 2) === false && $u->rateLimited('1.1.1.1', 2) === false && $u->rateLimited('1.1.1.1', 2) === true);

echo "Profil : statistiques, certificats\n";
$s1 = $u->mergeStats($acc['id'], [
    'quizDone' => 3, 'questions' => 15, 'correct' => 10, 'streak' => 2, 'bestStreak' => 4,
    'lastPlay' => '2026-10-10', 'badges' => ['a'], 'categories' => ['sira' => ['done' => 3, 'correct' => 10, 'total' => 15]],
]);
check('statistiques enregistrées', $s1['quizDone'] === 3 && $s1['badges'] === ['a']);
$s2 = $u->mergeStats($acc['id'], [
    'quizDone' => 1, 'questions' => 5, 'correct' => 5, 'streak' => 5, 'bestStreak' => 5,
    'lastPlay' => '2026-10-12', 'badges' => ['b'], 'categories' => ['sira' => ['done' => 1, 'correct' => 5, 'total' => 5]],
]);
check('statistiques : totaux = maximum', $s2['quizDone'] === 3 && $s2['questions'] === 15 && $s2['categories']['sira']['done'] === 3);
check('statistiques : série du dernier jour joué', $s2['lastPlay'] === '2026-10-12' && $s2['streak'] === 5 && $s2['bestStreak'] === 5);
check('statistiques : badges réunis', $s2['badges'] === ['a', 'b']);
check('statistiques relues', $u->stats($acc['id'])['quizDone'] === 3);

$defs   = [['id' => 'sira', 'title' => 'Sira', 'leaves' => ['sira']]];
$levels = ['debutant', 'intermediaire', 'avance'];
$all = [];
foreach ($levels as $lv) {
    for ($st = 1; $st <= 5; $st++) {
        $all[] = ['cat' => 'sira', 'lvl' => $lv, 'stage' => $st, 'stars' => 1, 'score' => 3, 'total' => 5];
    }
}
$u->mergeProgress($acc['id'], array_slice($all, 0, 14));
check('certificat : pas délivré s\'il manque une étape', $u->issueCertificates($acc['id'], 'Ali', $defs, $levels) === []);
$u->mergeProgress($acc['id'], [$all[14]]);
$certs = $u->issueCertificates($acc['id'], 'Ali', $defs, $levels);
check('certificat : délivré quand tout est réussi', count($certs) === 1 && $certs[0]['cat'] === 'sira');
check('certificat : code au format XXXX-XXXX-XXXX', (bool) preg_match('/^[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}$/', $certs[0]['code']));
check('certificat : date fixée par le serveur', $certs[0]['date'] === gmdate('Y-m-d'));
$again = $u->issueCertificates($acc['id'], 'Ali', $defs, $levels);
check('certificat : jamais redélivré (même code)', $again[0]['code'] === $certs[0]['code']);
$v = $u->verifyCertificate(strtolower(str_replace('-', '', $certs[0]['code'])));
check('certificat : vérification publique', $v !== null && $v['name'] === 'Ali' && $v['title'] === 'Sira');
check('certificat : code inconnu', $u->verifyCertificate('AAAA-BBBB-CCCC') === null && $u->verifyCertificate('xx') === null);
check('profil : changement de nom', $u->updateName($acc, ' Ali B. ')['name'] === 'Ali B.');
check('profil : nom vide refusé', $thrown(fn() => $u->updateName($acc, '  '), 422));

echo "DatabaseQuestionLoader (SQLite en mémoire, mêmes tables que SQL Server)\n";
if (!extension_loaded('pdo_sqlite')) {
    echo "  SKIP pdo_sqlite non installé\n";
} else {
    $json = json_decode((string) file_get_contents(__DIR__ . '/../data/questions.json'), true);
    $sqlite = sys_get_temp_dir() . '/quiz_loader_' . bin2hex(random_bytes(4)) . '.sqlite';
    exec('php ' . escapeshellarg(__DIR__ . '/make_sqlite.php') . ' ' . escapeshellarg($sqlite), $o, $rc);
    check('base de test créée', $rc === 0);
    $pdo = new PDO('sqlite:' . $sqlite);
    $loaded = DatabaseQuestionLoader::load($pdo, '');
    check('mêmes catégories que le JSON, dans le même ordre', array_keys($loaded) === array_keys($json));
    $same = true;
    foreach ($json as $cat => $qs) {
        foreach ($qs as $i => $q) {
            $l = $loaded[$cat][$i] ?? null;
            $same = $same && $l !== null && $l['id'] === $q['id'] && $l['question'] === $q['question']
                && $l['options'] === $q['options'] && $l['niveau'] === $q['niveau']
                && $l['bonneReponse'] === $q['bonneReponse'];
        }
        $same = $same && count($loaded[$cat]) === count($qs);
    }
    check('630 questions identiques au JSON (texte, ordre des choix, niveau, bonne réponse)', $same);
    $dbRepo = new QuestionRepository($loaded);
    check('niveaux via la base : 25 questions', count($dbRepo->pick('coran_culture', 'debutant', 0, false)) === 25);
    check('indexById via la base', ($dbRepo->indexById('sira')[226]['bonneReponse'] ?? null) === 2);

    // données invalides -> erreur claire
    $pdo->exec('UPDATE choix SET est_correct = 1 WHERE question_id = 1');
    $err = '';
    try { DatabaseQuestionLoader::load($pdo, ''); } catch (RuntimeException $e) { $err = $e->getMessage(); }
    check('2 bonnes réponses -> erreur explicite', str_contains($err, 'Question 1') && str_contains($err, 'exactement 1'));
    // rétablit la question 1 (une seule bonne réponse) avant de tester la question 2
    $pdo->exec('UPDATE choix SET est_correct = 0 WHERE question_id = 1');
    $pdo->exec('UPDATE choix SET est_correct = 1 WHERE id = (SELECT MIN(id) FROM choix WHERE question_id = 1)');
    $pdo->exec('UPDATE choix SET est_correct = 0 WHERE question_id = 2');
    try { DatabaseQuestionLoader::load($pdo, ''); $err = ''; } catch (RuntimeException $e) { $err = $e->getMessage(); }
    check('0 bonne réponse -> erreur explicite', str_contains($err, 'Question 2'));
    $pdo->exec('DELETE FROM choix WHERE question_id = 3 AND id NOT IN (SELECT MIN(id) FROM choix WHERE question_id = 3)');
    try { DatabaseQuestionLoader::load($pdo, ''); $err = ''; } catch (RuntimeException $e) { $err = $e->getMessage(); }
    check('moins de 2 choix -> erreur explicite', $err !== '');
    $thrown = false;
    try { DatabaseQuestionLoader::load($pdo, 'dbo; DROP TABLE x'); } catch (InvalidArgumentException $e) { $thrown = true; }
    check('nom de schéma invalide refusé (injection)', $thrown);
    @unlink($sqlite);
}

// nettoyage
foreach (glob($dir . '/*/*.json') ?: [] as $f) { unlink($f); }
foreach (glob($dir . '/*') ?: [] as $d) { @rmdir($d); }
@rmdir($dir);

echo $failed === 0 ? "\nTous les tests passent.\n" : "\n$failed test(s) en échec.\n";
exit($failed === 0 ? 0 : 1);
