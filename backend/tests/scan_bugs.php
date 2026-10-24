<?php
declare(strict_types=1);

/**
 * Audit approfondi / scan de recherche de bugs sur tout le projet.
 */

$rootDir = dirname(__DIR__, 2);
$issues = [];

echo "=== SCAN 1 : VALIDATION DES FICHIERS DE QUESTIONS ===\n";
$questionsFile = $rootDir . '/backend/data/questions.json';
if (!file_exists($questionsFile)) {
    $issues[] = "[CRITICAL] questions.json manquant.";
} else {
    $qData = json_decode(file_get_contents($questionsFile), true);
    if (!is_array($qData)) {
        $issues[] = "[CRITICAL] questions.json n'est pas un JSON valide.";
    } else {
        $allIds = [];
        $totalQuestions = 0;
        foreach ($qData as $cat => $list) {
            if (!is_array($list)) {
                $issues[] = "[ERROR] La catégorie $cat n'est pas une liste.";
                continue;
            }
            foreach ($list as $idx => $q) {
                $totalQuestions++;
                $id = $q['id'] ?? null;
                if (!is_int($id)) {
                    $issues[] = "[ERROR] Catégorie $cat, question #$idx : 'id' manquant ou non entier.";
                } else {
                    if (isset($allIds[$id])) {
                        $issues[] = "[ERROR] ID dupliqué détecté : $id dans $cat (déjà présent dans " . $allIds[$id] . ").";
                    }
                    $allIds[$id] = $cat;
                }

                // Vérifier énoncé
                $question = $q['question'] ?? null;
                if (!is_string($question) || trim($question) === '') {
                    $issues[] = "[ERROR] Catégorie $cat, question id $id : énoncé vide.";
                }

                // Vérifier options
                $options = $q['options'] ?? null;
                if (!is_array($options) || count($options) < 2) {
                    $issues[] = "[ERROR] Catégorie $cat, question id $id : moins de 2 options.";
                } else {
                    if (count($options) !== count(array_unique($options))) {
                        $issues[] = "[WARNING] Catégorie $cat, question id $id : options en double détectées.";
                    }
                    foreach ($options as $optIdx => $opt) {
                        if (!is_string($opt) || trim($opt) === '') {
                            $issues[] = "[ERROR] Catégorie $cat, question id $id : option #$optIdx vide.";
                        }
                    }
                }

                // Vérifier bonneReponse
                $bonneRep = $q['bonneReponse'] ?? null;
                if (!is_int($bonneRep) || $bonneRep < 0 || (is_array($options) && $bonneRep >= count($options))) {
                    $issues[] = "[ERROR] Catégorie $cat, question id $id : bonneReponse ($bonneRep) hors limites.";
                }

                // Vérifier niveau
                $niveau = $q['niveau'] ?? null;
                if (!in_array($niveau, ['debutant', 'intermediaire', 'avance'], true)) {
                    $issues[] = "[WARNING] Catégorie $cat, question id $id : niveau '$niveau' non standard.";
                }
            }
        }
        echo "Questions totales vérifiées : $totalQuestions. IDs uniques : " . count($allIds) . ".\n";
    }
}

echo "\n=== SCAN 2 : VÉRIFICATION DES TRONCATURES SQL (TABLES NVARCHAR(255)) ===\n";
if (isset($qData) && is_array($qData)) {
    $longQuestions = [];
    $longOptions = [];
    foreach ($qData as $cat => $list) {
        foreach ($list as $q) {
            $id = $q['id'];
            $lenQ = mb_strlen($q['question'] ?? '');
            if ($lenQ > 255) {
                $longQuestions[] = ['id' => $id, 'cat' => $cat, 'len' => $lenQ, 'text' => $q['question']];
            }
            foreach ($q['options'] ?? [] as $opt) {
                $lenO = mb_strlen($opt);
                if ($lenO > 255) {
                    $longOptions[] = ['id' => $id, 'cat' => $cat, 'len' => $lenO, 'text' => $opt];
                }
            }
        }
    }
    if (count($longQuestions) > 0) {
        echo "[BUG POTENTIEL SQL SERVER] " . count($longQuestions) . " questions dépassent 255 caractères (la colonne dbo.questions.enonce est NVARCHAR(255)) !\n";
        foreach (array_slice($longQuestions, 0, 3) as $lq) {
            echo "  - ID {$lq['id']} ({$lq['cat']}) : {$lq['len']} car. -> \"{$lq['text']}\"\n";
        }
        $issues[] = "[SQL SERVER BUG] Questions > 255 caractères (enonce NVARCHAR(255) trop court, devrait être NVARCHAR(MAX) ou NVARCHAR(1000)).";
    } else {
        echo "Aucune question ne dépasse 255 caractères.\n";
    }

    if (count($longOptions) > 0) {
        echo "[BUG POTENTIEL SQL SERVER] " . count($longOptions) . " options dépassent 255 caractères !\n";
        $issues[] = "[SQL SERVER BUG] Options > 255 caractères (choix NVARCHAR(255) trop court).";
    } else {
        echo "Aucune option ne dépasse 255 caractères.\n";
    }
}

echo "\n=== SCAN 3 : COHÉRENCE FRONTEND DART / CLEFS DE TRADUCTION ===\n";
$dartFiles = glob($rootDir . '/frontend/lib/*.dart');
$dartFiles = array_merge($dartFiles, glob($rootDir . '/frontend/lib/**/*.dart'));

// Extraire les clefs de traduction appelées dans le code Dart : context.tr('...') ou tr('...')
$calledKeys = [];
foreach ($dartFiles as $file) {
    $content = file_get_contents($file);
    if (preg_match_all("/(?:context\.)?tr\(\s*'([^']+)'\s*[\),]/", $content, $m)) {
        foreach ($m[1] as $k) {
            $calledKeys[$k][] = basename($file);
        }
    }
}

// Extraire les clefs définies dans app_strings.dart
$stringsFile = $rootDir . '/frontend/lib/app_strings.dart';
$stringsContent = file_get_contents($stringsFile);
preg_match_all("/'([a-zA-Z0-9_]+)'\s*:\s*\{/", $stringsContent, $m);
$definedKeys = array_flip($m[1]);

$missingKeys = [];
foreach ($calledKeys as $key => $files) {
    if ($key === 'cle') continue; // Exemple dans les commentaires docstrings
    if (!isset($definedKeys[$key])) {
        // Ignorer les clefs dynamiques avec variables comme badge_$badge
        if (str_contains($key, '$') || str_starts_with($key, 'stage_') && str_ends_with($key, '_desc')) {
            continue;
        }
        $missingKeys[$key] = array_unique($files);
    }
}

if (count($missingKeys) > 0) {
    echo "Clefs de traduction potentiellement manquantes :\n";
    foreach ($missingKeys as $k => $fl) {
        echo "  - '$k' appelée dans : " . implode(', ', $fl) . "\n";
        $issues[] = "[I18N BUG] Clef '$k' appelée mais non définie dans app_strings.dart.";
    }
} else {
    echo "Toutes les clefs statiques appelées (" . count($calledKeys) . " clefs) sont bien définies dans app_strings.dart !\n";
}

echo "\n=== SCAN 4 : PROGRESSION ET CERTIFICATS DANS FRONTEND ===\n";
// Vérifier la cohérence entre categories dans quiz_models.dart et les certificats / stats
$quizModelsFile = $rootDir . '/frontend/lib/quiz_models.dart';
$userProgressFile = $rootDir . '/frontend/lib/user_progress.dart';

$qmContent = file_get_contents($quizModelsFile);
$upContent = file_get_contents($userProgressFile);

// Extraire les ID de sous-catégories (feuilles)
preg_match_all("/id:\s*'([a-z_]+)'/", $qmContent, $m);
$modelIds = array_unique($m[1]);

foreach ($modelIds as $mid) {
    if (!str_contains($upContent, "'$mid'")) {
        echo "[WARNING] Catégorie '$mid' présente dans quiz_models.dart mais absente de _categoryStats dans user_progress.dart !\n";
        $issues[] = "[PROGRESS BUG] Catégorie '$mid' absente de _categoryStats dans user_progress.dart.";
    }
}

echo "\n=== RÉSUMÉ DE L'AUDIT ===\n";
if (empty($issues)) {
    echo "-> 0 ANOMALIE DÉTECTÉE. LE PROJET EST SAIN ET TOTALEMENT FONCTIONNEL !\n";
} else {
    echo count($issues) . " PROBLÈME(S) DÉTECTÉ(S) :\n";
    foreach ($issues as $issue) {
        echo "  " . $issue . "\n";
    }
}
