<?php
/**
 * Convertit les 300 questions ouvertes Tadjwîd en QCM à 4 choix,
 * les intègre dans questions.json et translations.json.
 *
 * Usage : php backend/data/convert_tajwid.php
 */
declare(strict_types=1);

// ---------- Configuration ----------
$srcFile   = __DIR__ . '/user_tajwid_300.json';
$qFile     = __DIR__ . '/questions.json';
$tFile     = __DIR__ . '/translations.json';
$startId   = 331;          // premier ID coran_tajwid (remplace les anciens 331-360)
$perLevel  = 100;          // 100 questions par niveau => 300 total

// ---------- Lecture ----------
$raw = json_decode(file_get_contents($srcFile), true);
if (!is_array($raw) || count($raw) !== 300) {
    fwrite(STDERR, "ERREUR : $srcFile doit contenir exactement 300 éléments.\n");
    exit(1);
}

// ---------- Trier par niveau ----------
$buckets = ['debutant' => [], 'intermediaire' => [], 'avance' => []];
foreach ($raw as $item) {
    $lvl = mb_strtolower(trim($item['niveau_fr']));
    if (str_starts_with($lvl, 'd'))      $buckets['debutant'][] = $item;
    elseif (str_starts_with($lvl, 'i'))   $buckets['intermediaire'][] = $item;
    else                                   $buckets['avance'][] = $item;
}
echo "Niveaux bruts : débutant=" . count($buckets['debutant'])
   . " intermédiaire=" . count($buckets['intermediaire'])
   . " avancé=" . count($buckets['avance']) . "\n";

// Équilibrer à 100 par niveau
// Stratégie : trop dans intermédiaire (134) → on en descend en débutant et on en monte en avancé
$balanced = ['debutant' => [], 'intermediaire' => [], 'avance' => []];

// D'abord, prendre min(100, disponible) de chaque bucket
foreach (['debutant', 'intermediaire', 'avance'] as $lvl) {
    $balanced[$lvl] = array_splice($buckets[$lvl], 0, $perLevel);
}
// Distribuer les restes
$overflow = array_merge($buckets['debutant'], $buckets['intermediaire'], $buckets['avance']);
foreach (['avance', 'debutant', 'intermediaire'] as $lvl) {
    while (count($balanced[$lvl]) < $perLevel && !empty($overflow)) {
        $balanced[$lvl][] = array_shift($overflow);
    }
}
echo "Niveaux équilibrés : débutant=" . count($balanced['debutant'])
   . " intermédiaire=" . count($balanced['intermediaire'])
   . " avancé=" . count($balanced['avance']) . "\n";

// ---------- Construire un pool de distracteurs par thème ----------
// On regroupe toutes les réponses (FR) par thème pour piocher des distracteurs pertinents
$answersByTheme = [];
$allAnswers = [];
foreach ($raw as $item) {
    $theme = $item['theme_fr'] ?? 'general';
    $answersByTheme[$theme][] = $item['reponse_fr'];
    $allAnswers[] = $item['reponse_fr'];
}

/**
 * Tronque une réponse longue pour en faire un choix QCM lisible (max ~120 car).
 */
function truncateOption(string $text, int $maxLen = 120): string {
    $text = trim($text);
    // Retirer les préfixes "C'est ", "Il s'agit de ", etc. pour raccourcir
    $text = preg_replace('/^(C\'est |Il s\'agit d(e |\')|Ce sont |Ce sont les )/', '', $text);
    if (mb_strlen($text) <= $maxLen) return $text;
    // Couper au dernier espace avant maxLen
    $cut = mb_substr($text, 0, $maxLen);
    $lastSpace = mb_strrpos($cut, ' ');
    if ($lastSpace > 60) $cut = mb_substr($cut, 0, $lastSpace);
    return $cut . '…';
}

/**
 * Génère 3 distracteurs pour une question donnée.
 * Puise d'abord dans le même thème, puis dans le pool global.
 */
function makeDistractors(string $correctAnswer, string $theme, array &$answersByTheme, array &$allAnswers): array {
    $correct = truncateOption($correctAnswer);
    $correctNorm = mb_strtolower($correct);
    $distractors = [];
    $usedNorm = [$correctNorm];

    // Piocher dans le même thème d'abord
    $pool = $answersByTheme[$theme] ?? [];
    shuffle($pool);
    foreach ($pool as $ans) {
        if (count($distractors) >= 3) break;
        $opt = truncateOption($ans);
        $norm = mb_strtolower($opt);
        if ($norm === $correctNorm) continue;
        // Éviter les doublons
        $isDup = false;
        foreach ($usedNorm as $u) {
            if ($norm === $u || similar_text($norm, $u) / max(mb_strlen($norm), mb_strlen($u), 1) > 0.85) {
                $isDup = true; break;
            }
        }
        if ($isDup) continue;
        $distractors[] = $opt;
        $usedNorm[] = $norm;
    }

    // Compléter avec le pool global si nécessaire
    if (count($distractors) < 3) {
        $globalPool = $allAnswers;
        shuffle($globalPool);
        foreach ($globalPool as $ans) {
            if (count($distractors) >= 3) break;
            $opt = truncateOption($ans);
            $norm = mb_strtolower($opt);
            $isDup = false;
            foreach ($usedNorm as $u) {
                if ($norm === $u || similar_text($norm, $u) / max(mb_strlen($norm), mb_strlen($u), 1) > 0.8) {
                    $isDup = true; break;
                }
            }
            if ($isDup) continue;
            $distractors[] = $opt;
            $usedNorm[] = $norm;
        }
    }

    // Ultime fallback
    $fallbacks = [
        "Aucune de ces réponses",
        "Cela concerne un autre domaine du Tadjwîd",
        "Cette règle n'existe pas en Tadjwîd",
    ];
    $fi = 0;
    while (count($distractors) < 3) {
        $distractors[] = $fallbacks[$fi++ % count($fallbacks)];
    }

    return array_slice($distractors, 0, 3);
}

// ---------- Construire les questions QCM ----------
$newQuestions = [];
$newTranslationsEn = [];
$newTranslationsAr = [];
$currentId = $startId;

foreach (['debutant', 'intermediaire', 'avance'] as $lvl) {
    foreach ($balanced[$lvl] as $item) {
        $correctFr = truncateOption($item['reponse_fr']);
        $distractors = makeDistractors($item['reponse_fr'], $item['theme_fr'] ?? 'general', $answersByTheme, $allAnswers);

        // Placer la bonne réponse à une position aléatoire
        $options = $distractors;
        $correctIndex = random_int(0, 3);
        array_splice($options, $correctIndex, 0, [$correctFr]);

        $q = [
            'id'           => $currentId,
            'question'     => $item['question_fr'],
            'options'      => $options,
            'niveau'       => $lvl,
            'bonneReponse' => $correctIndex,
            'explication'  => $item['reponse_fr'],
            'source'       => $item['reference_chapitre'] ?? '',
        ];
        $newQuestions[] = $q;

        // Traduction EN
        $correctEn = truncateOption($item['reponse_en'] ?? $item['reponse_fr']);
        $optionsEn = $options; // Copie des distracteurs FR par défaut
        $optionsEn[$correctIndex] = $correctEn;
        // Pour les distracteurs EN, on garde le FR (les traductions AR/EN des réponses secondaires
        // ne sont pas disponibles dans le fichier source pour les distracteurs)
        $trEn = [
            'question' => $item['question_en'] ?? $item['question_fr'],
            'options'  => $optionsEn,
        ];
        if (!empty($item['reponse_en']) && $item['reponse_en'] !== $item['reponse_fr']) {
            $trEn['explication'] = $item['reponse_en'];
        }
        $newTranslationsEn[(string)$currentId] = $trEn;

        // Traduction AR
        $correctAr = truncateOption($item['reponse_ar'] ?? $item['reponse_fr']);
        $optionsAr = $options;
        $optionsAr[$correctIndex] = $correctAr;
        $trAr = [
            'question' => $item['question_ar'] ?? $item['question_fr'],
            'options'  => $optionsAr,
        ];
        if (!empty($item['reponse_ar']) && $item['reponse_ar'] !== $item['reponse_fr']) {
            $trAr['explication'] = $item['reponse_ar'];
        }
        $newTranslationsAr[(string)$currentId] = $trAr;

        $currentId++;
    }
}

echo "Questions QCM générées : " . count($newQuestions) . " (IDs $startId à " . ($currentId - 1) . ")\n";

// ---------- Vérifier la qualité ----------
$errors = 0;
foreach ($newQuestions as $q) {
    if (count($q['options']) !== 4) { echo "ERREUR: id={$q['id']} n'a pas 4 options\n"; $errors++; }
    if ($q['bonneReponse'] < 0 || $q['bonneReponse'] >= 4) { echo "ERREUR: id={$q['id']} bonneReponse hors limites\n"; $errors++; }
    $unique = array_unique($q['options']);
    if (count($unique) !== 4) { echo "ATTENTION: id={$q['id']} options non uniques\n"; /* pas fatal */ }
}
if ($errors > 0) { echo "$errors erreur(s) fatale(s). Abandon.\n"; exit(1); }

// ---------- Mettre à jour questions.json ----------
$questions = json_decode(file_get_contents($qFile), true, 512, JSON_THROW_ON_ERROR);
$questions['coran_tajwid'] = $newQuestions;
$jsonOpts = JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT;
file_put_contents($qFile, json_encode($questions, $jsonOpts) . "\n");
echo "questions.json mis à jour (" . count($newQuestions) . " questions coran_tajwid).\n";

// ---------- Mettre à jour translations.json ----------
$translations = json_decode(file_get_contents($tFile), true, 512, JSON_THROW_ON_ERROR);
// Supprimer les anciennes traductions tajwid (331-360)
foreach (['en', 'ar'] as $lang) {
    if (!isset($translations[$lang])) $translations[$lang] = [];
    for ($id = 331; $id <= 360; $id++) {
        unset($translations[$lang][(string)$id]);
    }
}
// Ajouter les nouvelles
foreach ($newTranslationsEn as $id => $tr) {
    $translations['en'][$id] = $tr;
}
foreach ($newTranslationsAr as $id => $tr) {
    $translations['ar'][$id] = $tr;
}
file_put_contents($tFile, json_encode($translations, $jsonOpts) . "\n");
echo "translations.json mis à jour (" . count($newTranslationsEn) . " traductions EN + AR).\n";

echo "\nTerminé avec succès.\n";
