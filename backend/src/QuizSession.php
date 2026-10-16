<?php
declare(strict_types=1);

/**
 * Erreur liée à une session de quiz.
 * Contient le code HTTP à renvoyer au client.
 */
final class SessionException extends RuntimeException
{
    public int $status;

    public function __construct(string $message, int $status)
    {
        parent::__construct($message);
        $this->status = $status;
    }
}

/**
 * Gestion des sessions de quiz avec stockage JSON.
 *
 * - Une session est créée lors du chargement des questions.
 * - Les identifiants des questions servies sont mémorisés.
 * - Une question ne peut être vérifiée qu'une seule fois,
 *   sauf si le client renvoie exactement le même choix.
 * - Le nombre de sessions créées par IP est limité.
 */
final class QuizSession
{
    /** Durée de vie d'une session : 6 heures. */
    public const TTL = 21600;

    /** Fenêtre de limitation : 1 heure. */
    private const RATE_WINDOW = 3600;

    private string $dir;

    public function __construct(string $dir)
    {
        $this->dir = $dir;
    }

    /**
     * Crée une nouvelle session de quiz.
     *
     * @param list<int> $ids Identifiants des questions servies.
     */
    public function create(string $category, array $ids): string
    {
        $this->ensureDir('sessions');
        $this->purgeExpired();

        $id = bin2hex(random_bytes(16));

        $data = [
            'category' => $category,
            'created'  => time(),
            'ids'      => array_values(
                array_map('intval', $ids)
            ),
            'checked'  => new stdClass(),
        ];

        $json = json_encode($data);

        if ($json === false ||
            file_put_contents(
                $this->file($id),
                $json,
                LOCK_EX
            ) === false
        ) {
            throw new SessionException(
                'Stockage des sessions indisponible.',
                500
            );
        }

        return $id;
    }

    /**
     * Lit et modifie une session sous verrou exclusif.
     *
     * Le callback reçoit les données par référence.
     *
     * @param callable(array<string,mixed>&): mixed $fn
     */
    public function mutate(
        string $id,
        string $category,
        callable $fn
    ): mixed {
        if (!preg_match('/^[a-f0-9]{32}$/', $id)) {
            throw new SessionException(
                'Session invalide.',
                401
            );
        }

        $file = $this->file($id);

        if (!is_file($file)) {
            throw new SessionException(
                'Session inconnue ou expirée : rechargez le quiz.',
                410
            );
        }

        $fh = fopen($file, 'c+');

        if ($fh === false) {
            throw new SessionException(
                'Session illisible.',
                500
            );
        }

        try {
            if (!flock($fh, LOCK_EX)) {
                throw new SessionException(
                    'Impossible de verrouiller la session.',
                    500
                );
            }

            rewind($fh);

            $content = stream_get_contents($fh);
            $data = json_decode(
                $content === false ? '' : $content,
                true
            );

            if (
                !is_array($data) ||
                ($data['category'] ?? null) !== $category ||
                time() - (int) ($data['created'] ?? 0) > self::TTL
            ) {
                throw new SessionException(
                    'Session inconnue ou expirée : rechargez le quiz.',
                    410
                );
            }

            // Convertit l'objet JSON en tableau PHP pour le callback.
            $data['checked'] = (array) ($data['checked'] ?? []);

            $result = $fn($data);

            // Conserve checked comme objet JSON.
            $data['checked'] = (object) $data['checked'];

            $json = json_encode($data);

            if ($json === false) {
                throw new SessionException(
                    'Impossible d encoder la session.',
                    500
                );
            }

            rewind($fh);

            if (!ftruncate($fh, 0)) {
                throw new SessionException(
                    'Impossible de mettre à jour la session.',
                    500
                );
            }

            $written = fwrite($fh, $json);

            if ($written === false || $written !== strlen($json)) {
                throw new SessionException(
                    'Écriture de la session incomplète.',
                    500
                );
            }

            if (!fflush($fh)) {
                throw new SessionException(
                    'Impossible de sauvegarder la session.',
                    500
                );
            }

            return $result;
        } finally {
            flock($fh, LOCK_UN);
            fclose($fh);
        }
    }

    /**
     * Enregistre une création de session pour une adresse IP.
     *
     * Retourne true si la limite est dépassée.
     */
    public function rateLimited(string $ip, int $limit): bool
    {
        if ($limit <= 0) {
            return false;
        }

        $this->ensureDir('ratelimit');

        $path = $this->dir . '/ratelimit/' . sha1($ip) . '.json';

        $fh = fopen($path, 'c+');

        if ($fh === false) {
            // Échec ouvert : la limitation n'est pas appliquée.
            // À surveiller en production.
            return false;
        }

        try {
            if (!flock($fh, LOCK_EX)) {
                throw new SessionException(
                    'Impossible de verrouiller le compteur.',
                    500
                );
            }

            rewind($fh);

            $content = stream_get_contents($fh);
            $d = json_decode(
                $content === false ? '' : $content,
                true
            );

            $now = time();

            if (
                !is_array($d) ||
                $now - (int) ($d['start'] ?? 0) >= self::RATE_WINDOW
            ) {
                $d = [
                    'start' => $now,
                    'count' => 0,
                ];
            }

            $d['count']++;

            $json = json_encode($d);

            if ($json === false) {
                throw new SessionException(
                    'Impossible de sauvegarder le compteur.',
                    500
                );
            }

            rewind($fh);

            if (!ftruncate($fh, 0)) {
                throw new SessionException(
                    'Impossible de réinitialiser le compteur.',
                    500
                );
            }

            $written = fwrite($fh, $json);

            if ($written === false || $written !== strlen($json)) {
                throw new SessionException(
                    'Écriture du compteur incomplète.',
                    500
                );
            }

            fflush($fh);

            return $d['count'] > $limit;
        } finally {
            flock($fh, LOCK_UN);
            fclose($fh);
        }
    }

    /**
     * Supprime occasionnellement les sessions et compteurs expirés.
     */
    public function purgeExpired(): void
    {
        // Nettoyage aléatoire : environ 1 appel sur 50.
        if (random_int(1, 50) !== 1) {
            return;
        }

        $directories = [
            ['sessions', self::TTL],
            ['ratelimit', self::RATE_WINDOW * 2],
        ];

        foreach ($directories as [$sub, $ttl]) {
            $path = $this->dir . '/' . $sub;

            if (!is_dir($path)) {
                continue;
            }

            foreach (glob($path . '/*.json') ?: [] as $file) {
                $mtime = @filemtime($file);

                if (
                    $mtime !== false &&
                    time() - $mtime > $ttl
                ) {
                    @unlink($file);
                }
            }
        }
    }

    /**
     * Retourne le chemin du fichier d'une session.
     */
    private function file(string $id): string
    {
        return $this->dir . '/sessions/' . $id . '.json';
    }

    /**
     * Crée un sous-dossier s'il n'existe pas.
     */
    private function ensureDir(string $sub): void
    {
        $path = $this->dir . '/' . $sub;

        if (
            !is_dir($path) &&
            !@mkdir($path, 0775, true) &&
            !is_dir($path)
        ) {
            throw new SessionException(
                'Stockage des sessions indisponible : vérifiez les permissions du dossier storage.',
                500
            );
        }
    }
}
