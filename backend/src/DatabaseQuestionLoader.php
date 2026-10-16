<?php
declare(strict_types=1);

/**
 * Charge les questions depuis une base de données relationnelle (SQL Server, ou tout PDO).
 *
 * Tables attendues (voir sql/sqlserver_toutes_categories.sql) :
 *   questions (id, categorie, niveau, enonce)
 *   choix     (id, question_id, choix, est_correct)     -- 1 ligne par choix, ordre = ordre de `id`
 *
 * La « bonne réponse » est l'INDEX (0, 1, 2…) du choix dont est_correct = 1, comme `bonneReponse`
 * dans questions.json. Il faut donc insérer les choix dans l'ordre d'affichage voulu.
 */
final class DatabaseQuestionLoader
{
    /**
     * @param string $schema Schéma SQL ('dbo' pour SQL Server, '' pour aucun préfixe)
     * @return array<string, list<array<string, mixed>>>
     */
    public static function load(PDO $pdo, string $schema = 'dbo'): array
    {
        if ($schema !== '' && !preg_match('/^[A-Za-z_][A-Za-z0-9_]*$/', $schema)) {
            throw new InvalidArgumentException('Nom de schéma invalide.');
        }
        $prefix = $schema === '' ? '' : $schema . '.';
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        /** @var array<int, array<string, mixed>> $byId */
        $byId = [];
        $order = [];
        $stmt = $pdo->query("SELECT id, categorie, niveau, enonce FROM {$prefix}questions ORDER BY id");
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $id = (int) $row['id'];
            $byId[$id] = [
                'id'           => $id,
                'question'     => (string) $row['enonce'],
                'options'      => [],
                'niveau'       => (string) $row['niveau'],
                'bonneReponse' => -1,
                '_categorie'   => (string) $row['categorie'],
                '_correct'     => 0,
            ];
            $order[] = $id;
        }

        $stmt = $pdo->query("SELECT question_id, choix, est_correct FROM {$prefix}choix ORDER BY question_id, id");
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $qid = (int) $row['question_id'];
            if (!isset($byId[$qid])) {
                continue; // choix orphelin : ignoré
            }
            $byId[$qid]['options'][] = (string) $row['choix'];
            if ((int) $row['est_correct'] === 1) {
                $byId[$qid]['bonneReponse'] = count($byId[$qid]['options']) - 1;
                $byId[$qid]['_correct']++;
            }
        }

        $data = [];
        foreach ($order as $id) {
            $q = $byId[$id];
            if (count($q['options']) < 2) {
                throw new RuntimeException("Question $id : au moins 2 choix sont nécessaires.");
            }
            if ($q['_correct'] !== 1) {
                throw new RuntimeException("Question $id : il faut exactement 1 bonne réponse ({$q['_correct']} trouvée(s)).");
            }
            $cat = $q['_categorie'];
            unset($q['_categorie'], $q['_correct']);
            $data[$cat][] = $q;
        }
        if ($data === []) {
            throw new RuntimeException('Aucune question en base de données.');
        }
        return $data;
    }
}
