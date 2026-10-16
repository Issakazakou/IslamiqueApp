<?php
declare(strict_types=1);
// Construit une base SQLite de test (mêmes tables que SQL Server) à partir de data/questions.json.
//   php tests/make_sqlite.php /chemin/quiz.sqlite
if (!extension_loaded('pdo_sqlite')) {
    fwrite(STDERR, "pdo_sqlite indisponible\n");
    exit(2);
}
$file = $argv[1] ?? '';
if ($file === '') {
    fwrite(STDERR, "usage: php tests/make_sqlite.php FICHIER.sqlite\n");
    exit(1);
}
if (is_file($file)) {
    unlink($file);
}
$pdo = new PDO('sqlite:' . $file, null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$pdo->exec('CREATE TABLE questions (id INTEGER PRIMARY KEY, categorie TEXT NOT NULL, niveau TEXT NOT NULL, enonce TEXT NOT NULL)');
$pdo->exec('CREATE TABLE choix (id INTEGER PRIMARY KEY AUTOINCREMENT, question_id INTEGER NOT NULL REFERENCES questions(id), choix TEXT NOT NULL, est_correct INTEGER NOT NULL DEFAULT 0)');

$data = json_decode((string) file_get_contents(__DIR__ . '/../data/questions.json'), true, 512, JSON_THROW_ON_ERROR);
$q = $pdo->prepare('INSERT INTO questions (id, categorie, niveau, enonce) VALUES (?, ?, ?, ?)');
$c = $pdo->prepare('INSERT INTO choix (question_id, choix, est_correct) VALUES (?, ?, ?)');
$pdo->beginTransaction();
foreach ($data as $categorie => $questions) {
    foreach ($questions as $row) {
        $q->execute([$row['id'], $categorie, $row['niveau'], $row['question']]);
        foreach ($row['options'] as $i => $texte) {
            $c->execute([$row['id'], $texte, $i === $row['bonneReponse'] ? 1 : 0]);
        }
    }
}
$pdo->commit();
echo "Base créée : $file\n";
