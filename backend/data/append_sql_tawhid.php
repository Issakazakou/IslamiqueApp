<?php
declare(strict_types=1);

$sqlFile = __DIR__ . '/../sql/sqlserver_toutes_categories.sql';
$questionsFile = __DIR__ . '/questions.json';

$data = json_decode(file_get_contents($questionsFile), true);

$content = file_get_contents($sqlFile);
if (str_contains($content, 'tawhid_fondements')) {
    echo "Tawhid déjà présent dans le fichier SQL.\n";
    exit(0);
}

$commitPos = strrpos($content, 'COMMIT TRANSACTION;');
if ($commitPos === false) {
    fwrite(STDERR, "COMMIT TRANSACTION non trouvé.\n");
    exit(1);
}

$tawhidCats = ['tawhid_fondements', 'tawhid_adoration', 'tawhid_preservation'];
$sqlInsertQuestions = "\n-- ======== QUIZ TAWHID (KITÂB AT-TAWHÎD) : 100 QUESTIONS ========\n\nINSERT INTO dbo.questions (id, categorie, niveau, enonce) VALUES\n";
$sqlInsertChoix = "\nINSERT INTO dbo.choix (question_id, choix, est_correct) VALUES\n";

$qRows = [];
$cRows = [];

foreach ($tawhidCats as $cat) {
    if (!isset($data[$cat])) continue;
    foreach ($data[$cat] as $q) {
        $id = (int)$q['id'];
        $catSql = "N'" . addslashes($cat) . "'";
        $nivSql = "N'" . addslashes($q['niveau']) . "'";
        $enonceSql = "N'" . str_replace("'", "''", $q['question']) . "'";
        $qRows[] = "    ($id, $catSql, $nivSql, $enonceSql)";

        foreach ($q['options'] as $idx => $opt) {
            $optSql = "N'" . str_replace("'", "''", $opt) . "'";
            $isCorrect = ($idx === $q['bonneReponse']) ? 1 : 0;
            $cRows[] = "    ($id, $optSql, $isCorrect)";
        }
    }
}

$sqlInsertQuestions .= implode(",\n", $qRows) . ";\n";
$sqlInsertChoix .= implode(",\n", $cRows) . ";\n\n";

$newContent = substr($content, 0, $commitPos) . $sqlInsertQuestions . $sqlInsertChoix . substr($content, $commitPos);
file_put_contents($sqlFile, $newContent);
echo "SQL Server mis à jour avec les 100 questions de Tawhid.\n";
