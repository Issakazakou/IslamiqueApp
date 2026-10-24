<?php
declare(strict_types=1);

/**
 * Script d'intégration des 100 questions de Kitâb At-Tawhîd dans questions.json
 * et des traductions dans translations.json.
 */

$rawFile = __DIR__ . '/raw_tawhid_100.json';
$questionsFile = __DIR__ . '/questions.json';
$translationsFile = __DIR__ . '/translations.json';

if (!file_exists($rawFile)) {
    fwrite(STDERR, "Fichier raw_tawhid_100.json introuvable.\n");
    exit(1);
}

$rawData = json_decode(file_get_contents($rawFile), true);
if (!$rawData || !isset($rawData['levels'])) {
    fwrite(STDERR, "Format raw_tawhid_100.json invalide.\n");
    exit(1);
}

// Aplatir les 100 questions par ID d'origine (1 à 100)
$flatQuestions = [];
foreach ($rawData['levels'] as $lvl) {
    foreach ($lvl['questions'] as $q) {
        $flatQuestions[(int)$q['id']] = $q;
    }
}

if (count($flatQuestions) !== 100) {
    fwrite(STDERR, "Attendu 100 questions, trouvé " . count($flatQuestions) . "\n");
    exit(1);
}

// Fonction pour mélanger les options de manière déterministe
function shuffleOptions(array $q): array {
    $correctAnswer = $q['correct_answer'] ?? $q['options'][$q['correct_option_index']];
    $pairs = [];
    foreach ($q['options'] as $idx => $opt) {
        $pairs[] = [
            'text' => $opt,
            'is_correct' => ($opt === $correctAnswer || $idx === $q['correct_option_index']),
        ];
    }

    $seed = 2000 + (int)$q['id'];
    mt_srand($seed);
    for ($i = count($pairs) - 1; $i > 0; $i--) {
        $j = mt_rand(0, $i);
        $tmp = $pairs[$i];
        $pairs[$i] = $pairs[$j];
        $pairs[$j] = $tmp;
    }
    mt_srand();

    $shuffled = [];
    $correctIndex = 0;
    foreach ($pairs as $newIdx => $p) {
        $shuffled[] = $p['text'];
        if ($p['is_correct']) {
            $correctIndex = $newIdx;
        }
    }

    return [$shuffled, $correctIndex];
}

// Définition des 3 catégories Tawhid
// 1) tawhid_fondements (40 questions : Q1-Q40)
//    debutant: Q1-Q14 (14)
//    intermediaire: Q15-Q27 (13)
//    avance: Q28-Q40 (13)
$fondementsList = [];
$currentId = 1001;

for ($id = 1; $id <= 40; $id++) {
    $rawQ = $flatQuestions[$id];
    [$opts, $correctIdx] = shuffleOptions($rawQ);
    
    $level = 'debutant';
    if ($id >= 15 && $id <= 27) {
        $level = 'intermediaire';
    } elseif ($id >= 28) {
        $level = 'avance';
    }

    $fondementsList[] = [
        'id'           => $currentId++,
        'question'     => $rawQ['question'],
        'options'      => $opts,
        'niveau'       => $level,
        'bonneReponse' => $correctIdx,
        'explication'  => $rawQ['explanation'],
        'source'       => $rawQ['references'],
    ];
}

// 2) tawhid_adoration (30 questions : Q51-Q60, Q61-Q70, Q91-Q100)
//    debutant: Q51-Q60 (10)
//    intermediaire: Q61-Q70 (10)
//    avance: Q91-Q100 (10)
$adorationList = [];
// debutant Q51-Q60
for ($id = 51; $id <= 60; $id++) {
    $rawQ = $flatQuestions[$id];
    [$opts, $correctIdx] = shuffleOptions($rawQ);
    $adorationList[] = [
        'id'           => $currentId++,
        'question'     => $rawQ['question'],
        'options'      => $opts,
        'niveau'       => 'debutant',
        'bonneReponse' => $correctIdx,
        'explication'  => $rawQ['explanation'],
        'source'       => $rawQ['references'],
    ];
}
// intermediaire Q61-Q70
for ($id = 61; $id <= 70; $id++) {
    $rawQ = $flatQuestions[$id];
    [$opts, $correctIdx] = shuffleOptions($rawQ);
    $adorationList[] = [
        'id'           => $currentId++,
        'question'     => $rawQ['question'],
        'options'      => $opts,
        'niveau'       => 'intermediaire',
        'bonneReponse' => $correctIdx,
        'explication'  => $rawQ['explanation'],
        'source'       => $rawQ['references'],
    ];
}
// avance Q91-Q100
for ($id = 91; $id <= 100; $id++) {
    $rawQ = $flatQuestions[$id];
    [$opts, $correctIdx] = shuffleOptions($rawQ);
    $adorationList[] = [
        'id'           => $currentId++,
        'question'     => $rawQ['question'],
        'options'      => $opts,
        'niveau'       => 'avance',
        'bonneReponse' => $correctIdx,
        'explication'  => $rawQ['explanation'],
        'source'       => $rawQ['references'],
    ];
}

// 3) tawhid_preservation (30 questions : Q41-Q50, Q81-Q90, Q71-Q80)
//    debutant: Q41-Q50 (10)
//    intermediaire: Q81-Q90 (10)
//    avance: Q71-Q80 (10)
$preservationList = [];
// debutant Q41-Q50 (amulettes)
for ($id = 41; $id <= 50; $id++) {
    $rawQ = $flatQuestions[$id];
    [$opts, $correctIdx] = shuffleOptions($rawQ);
    $preservationList[] = [
        'id'           => $currentId++,
        'question'     => $rawQ['question'],
        'options'      => $opts,
        'niveau'       => 'debutant',
        'bonneReponse' => $correctIdx,
        'explication'  => $rawQ['explanation'],
        'source'       => $rawQ['references'],
    ];
}
// intermediaire Q81-Q90 (présages, augures, péchés du cœur)
for ($id = 81; $id <= 90; $id++) {
    $rawQ = $flatQuestions[$id];
    [$opts, $correctIdx] = shuffleOptions($rawQ);
    $preservationList[] = [
        'id'           => $currentId++,
        'question'     => $rawQ['question'],
        'options'      => $opts,
        'niveau'       => 'intermediaire',
        'bonneReponse' => $correctIdx,
        'explication'  => $rawQ['explanation'],
        'source'       => $rawQ['references'],
    ];
}
// avance Q71-Q80 (sorcellerie, voyance, astrologie)
for ($id = 71; $id <= 80; $id++) {
    $rawQ = $flatQuestions[$id];
    [$opts, $correctIdx] = shuffleOptions($rawQ);
    $preservationList[] = [
        'id'           => $currentId++,
        'question'     => $rawQ['question'],
        'options'      => $opts,
        'niveau'       => 'avance',
        'bonneReponse' => $correctIdx,
        'explication'  => $rawQ['explanation'],
        'source'       => $rawQ['references'],
    ];
}

echo "Génération des catégories Tawhid :\n";
echo "- tawhid_fondements : " . count($fondementsList) . " questions (IDs " . $fondementsList[0]['id'] . " à " . end($fondementsList)['id'] . ")\n";
echo "- tawhid_adoration  : " . count($adorationList) . " questions (IDs " . $adorationList[0]['id'] . " à " . end($adorationList)['id'] . ")\n";
echo "- tawhid_preservation : " . count($preservationList) . " questions (IDs " . $preservationList[0]['id'] . " à " . end($preservationList)['id'] . ")\n";
echo "Total : " . (count($fondementsList) + count($adorationList) + count($preservationList)) . " questions.\n";

// Sauvegarde dans questions.json
$existingQuestions = json_decode(file_get_contents($questionsFile), true);
// Backup
copy($questionsFile, $questionsFile . '.bak');

$existingQuestions['tawhid_fondements'] = $fondementsList;
$existingQuestions['tawhid_adoration'] = $adorationList;
$existingQuestions['tawhid_preservation'] = $preservationList;

file_put_contents($questionsFile, json_encode($existingQuestions, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
echo "Fichier questions.json mis à jour avec succès.\n";
