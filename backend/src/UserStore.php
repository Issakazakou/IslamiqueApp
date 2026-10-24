<?php
declare(strict_types=1);

final class AuthException extends RuntimeException
{
    public int $status;

    public function __construct(string $message, int $status)
    {
        parent::__construct($message);
        $this->status = $status;
    }
}

/**
 * Gestion des comptes utilisateurs, sessions, progression, statistiques et certificats.
 */
final class UserStore
{
    private string $dir;

    public function __construct(string $dir)
    {
        $this->dir = rtrim($dir, '/\\');
    }

    public function rateLimited(string $ip, int $limit): bool
    {
        if ($limit <= 0) {
            return false;
        }

        $this->ensureDir('ratelimit');
        $file = $this->dir . '/ratelimit/' . hash('sha256', $ip) . '_auth.json';
        $now = time();
        $window = 3600;

        $attempts = [];
        if (is_file($file)) {
            $data = json_decode((string) @file_get_contents($file), true);
            if (is_array($data)) {
                $attempts = array_filter($data, static fn($t) => is_int($t) && ($now - $t) < $window);
            }
        }

        if (count($attempts) >= $limit) {
            return true;
        }

        $attempts[] = $now;
        @file_put_contents($file, json_encode(array_values($attempts)), LOCK_EX);
        return false;
    }

    public function register(string $email, string $password, string $name = ''): array
    {
        $email = strtolower(trim($email));
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new AuthException('Adresse e-mail invalide.', 422);
        }
        if (strlen($password) < 8 || strlen($password) > 72) {
            throw new AuthException('Le mot de passe doit contenir entre 8 et 72 caracteres.', 422);
        }

        $this->ensureDir('users');
        $this->ensureDir('emails');

        $emailHash = hash('sha256', $email);
        $emailFile = $this->dir . '/emails/' . $emailHash . '.json';

        if (is_file($emailFile)) {
            throw new AuthException('Cette adresse e-mail est déjà utilisée.', 409);
        }

        $userId = bin2hex(random_bytes(16));
        $cleanName = trim($name) !== '' ? trim($name) : explode('@', $email)[0];

        $user = [
            'id'           => $userId,
            'email'        => $email,
            'name'         => $cleanName,
            'password'     => password_hash($password, PASSWORD_DEFAULT),
            'created'      => time(),
            'isPremium'    => false,
            'premiumUntil' => null,
        ];

        file_put_contents($this->dir . '/users/' . $userId . '.json', json_encode($user), LOCK_EX);
        file_put_contents($emailFile, json_encode(['id' => $userId]), LOCK_EX);

        unset($user['password']);
        $user['isPremium'] = ($user['isPremium'] ?? false) && (($user['premiumUntil'] ?? 0) === null || ($user['premiumUntil'] ?? 0) > time());
        return $user;
    }

    public function login(string $email, string $password): array
    {
        $email = strtolower(trim($email));
        $emailHash = hash('sha256', $email);
        $emailFile = $this->dir . '/emails/' . $emailHash . '.json';

        if (!is_file($emailFile)) {
            throw new AuthException('Identifiants incorrects.', 401);
        }

        $map = json_decode((string) file_get_contents($emailFile), true);
        $userId = $map['id'] ?? null;
        if (!is_string($userId)) {
            throw new AuthException('Identifiants incorrects.', 401);
        }

        $userFile = $this->dir . '/users/' . $userId . '.json';
        if (!is_file($userFile)) {
            throw new AuthException('Identifiants incorrects.', 401);
        }

        $user = json_decode((string) file_get_contents($userFile), true);
        if (!is_array($user) || !password_verify($password, $user['password'] ?? '')) {
            throw new AuthException('Identifiants incorrects.', 401);
        }

        unset($user['password']);
        $user['isPremium'] = ($user['isPremium'] ?? false) && (($user['premiumUntil'] ?? 0) === null || ($user['premiumUntil'] ?? 0) > time());
        return $user;
    }

    public function createToken(array $user): string
    {
        $this->ensureDir('tokens');
        $token = bin2hex(random_bytes(32)); // 64 hex chars
        $tokenHash = hash('sha256', $token);

        $data = [
            'userId'  => $user['id'],
            'created' => time(),
            'expires' => time() + (90 * 86400),
        ];

        file_put_contents($this->dir . '/tokens/' . $tokenHash . '.json', json_encode($data), LOCK_EX);
        return $token;
    }

    public function authenticate(?string $token): array
    {
        if ($token === null || !preg_match('/^[a-f0-9]{64}$/', $token)) {
            throw new AuthException('Non authentifié.', 401);
        }

        $tokenHash = hash('sha256', $token);
        $tokenFile = $this->dir . '/tokens/' . $tokenHash . '.json';

        if (!is_file($tokenFile)) {
            throw new AuthException('Session invalide ou expirée.', 401);
        }

        $data = json_decode((string) file_get_contents($tokenFile), true);
        if (!is_array($data) || ($data['expires'] ?? 0) < time()) {
            @unlink($tokenFile);
            throw new AuthException('Session expirée.', 401);
        }

        $userId = $data['userId'] ?? '';
        $userFile = $this->dir . '/users/' . $userId . '.json';
        if (!is_file($userFile)) {
            throw new AuthException('Utilisateur inconnu.', 401);
        }

        $user = json_decode((string) file_get_contents($userFile), true);
        if (!is_array($user)) {
            throw new AuthException('Erreur compte utilisateur.', 500);
        }

        unset($user['password']);
        $user['isPremium'] = ($user['isPremium'] ?? false) && (($user['premiumUntil'] ?? 0) === null || ($user['premiumUntil'] ?? 0) > time());
        return $user;
    }

    public function revokeToken(?string $token): void
    {
        if ($token !== null && preg_match('/^[a-f0-9]{64}$/', $token)) {
            $tokenHash = hash('sha256', $token);
            @unlink($this->dir . '/tokens/' . $tokenHash . '.json');
        }
    }

    public function changePassword(string $userId, string $oldPassword, string $newPassword): void
    {
        if (strlen($newPassword) < 8 || strlen($newPassword) > 72) {
            throw new AuthException('Le nouveau mot de passe doit contenir entre 8 et 72 caractères.', 422);
        }

        $userFile = $this->dir . '/users/' . $userId . '.json';
        if (!is_file($userFile)) {
            throw new AuthException('Utilisateur introuvable.', 404);
        }

        $user = json_decode((string) file_get_contents($userFile), true);
        if (!is_array($user) || !password_verify($oldPassword, $user['password'] ?? '')) {
            throw new AuthException('Ancien mot de passe incorrect.', 401);
        }

        $user['password'] = password_hash($newPassword, PASSWORD_DEFAULT);
        file_put_contents($userFile, json_encode($user), LOCK_EX);
    }

    public function deleteAccount(string $userId): void
    {
        $userFile = $this->dir . '/users/' . $userId . '.json';
        if (!is_file($userFile)) {
            throw new AuthException('Utilisateur introuvable.', 404);
        }

        $user = json_decode((string) file_get_contents($userFile), true);
        $email = $user['email'] ?? '';
        if ($email !== '') {
            $emailHash = hash('sha256', strtolower(trim($email)));
            @unlink($this->dir . '/emails/' . $emailHash . '.json');
        }

        // Supprimer toutes les données liées à l'utilisateur
        @unlink($userFile);
        @unlink($this->dir . '/progress/' . $userId . '.json');
        @unlink($this->dir . '/stats/' . $userId . '.json');
        @unlink($this->dir . '/certificates/' . $userId . '.json');
        @unlink($this->dir . '/bookmarks/' . $userId . '.json');

        // Révoquer les jetons de cet utilisateur
        foreach (glob($this->dir . '/tokens/*.json') ?: [] as $tokenFile) {
            $tData = json_decode((string) @file_get_contents($tokenFile), true);
            if (is_array($tData) && ($tData['userId'] ?? '') === $userId) {
                @unlink($tokenFile);
            }
        }
    }

    public function setPremium(string $userId, int $durationDays): array
    {
        $userFile = $this->dir . '/users/' . $userId . '.json';
        if (!is_file($userFile)) {
            throw new AuthException('Utilisateur introuvable.', 404);
        }

        $user = json_decode((string) file_get_contents($userFile), true);
        if (!is_array($user)) {
            throw new AuthException('Erreur utilisateur.', 500);
        }

        $now = time();
        $base = max($now, (int) ($user['premiumUntil'] ?? 0));
        $user['isPremium'] = true;
        $user['premiumUntil'] = $base + ($durationDays * 86400);

        file_put_contents($userFile, json_encode($user), LOCK_EX);
        unset($user['password']);
        return $user;
    }

    public function bookmarks(string $userId): array
    {
        $file = $this->dir . '/bookmarks/' . $userId . '.json';
        if (!is_file($file)) {
            return [];
        }
        $data = json_decode((string) file_get_contents($file), true);
        return is_array($data) ? array_values($data) : [];
    }

    public function saveBookmarks(string $userId, array $questionIds): array
    {
        $this->ensureDir('bookmarks');
        $file = $this->dir . '/bookmarks/' . $userId . '.json';
        $ids = array_values(array_unique(array_filter(array_map('intval', $questionIds), static fn(int $id) => $id > 0)));
        if (count($ids) > 1000) {
            throw new AuthException('Limite de 1000 favoris atteinte.', 422);
        }
        file_put_contents($file, json_encode($ids, JSON_PRETTY_PRINT), LOCK_EX);
        return $ids;
    }

    public function leaderboard(int $limit = 20): array
    {
        $statsDir = $this->dir . '/stats';
        if (!is_dir($statsDir)) {
            return [];
        }

        $scores = [];
        foreach (glob($statsDir . '/*.json') ?: [] as $file) {
            $userId = basename($file, '.json');
            $userFile = $this->dir . '/users/' . $userId . '.json';
            if (!is_file($userFile)) {
                continue;
            }

            $uData = json_decode((string) @file_get_contents($userFile), true);
            $sData = json_decode((string) @file_get_contents($file), true);
            if (!is_array($uData) || !is_array($sData)) {
                continue;
            }

            $name = (string) ($uData['name'] ?? 'Pèlerin Anonyme');
            $correct = (int) ($sData['correct'] ?? 0);
            $streak = (int) ($sData['streak'] ?? 0);
            $bestStreak = (int) ($sData['bestStreak'] ?? 0);
            $quizDone = (int) ($sData['quizDone'] ?? 0);
            $isPremium = ($uData['isPremium'] ?? false) && (($uData['premiumUntil'] ?? 0) === null || ($uData['premiumUntil'] ?? 0) > time());

            // Score composite gamifié : (bonnes réponses * 10) + (streak * 15) + (quiz terminés * 5)
            $points = ($correct * 10) + ($bestStreak * 15) + ($quizDone * 5);

            $scores[] = [
                'userId'     => substr($userId, 0, 8) . '...',
                'name'       => $name,
                'points'     => $points,
                'correct'    => $correct,
                'streak'     => $streak,
                'bestStreak' => $bestStreak,
                'quizDone'   => $quizDone,
                'isPremium'  => $isPremium,
            ];
        }

        usort($scores, static fn($a, $b) => $b['points'] <=> $a['points']);
        return array_slice($scores, 0, max(1, min(100, $limit)));
    }

    public function updateName(array $user, string $name): array
    {
        $cleanName = trim($name);
        if ($cleanName === '') {
            throw new AuthException('Le nom ne peut pas être vide.', 422);
        }

        $userFile = $this->dir . '/users/' . $user['id'] . '.json';
        if (!is_file($userFile)) {
            throw new AuthException('Utilisateur introuvable.', 404);
        }

        $data = json_decode((string) file_get_contents($userFile), true);
        $data['name'] = $cleanName;
        file_put_contents($userFile, json_encode($data), LOCK_EX);

        unset($data['password']);
        return $data;
    }

    public function progress(string $userId): array
    {
        $file = $this->dir . '/progress/' . $userId . '.json';
        if (!is_file($file)) {
            return [];
        }
        $data = json_decode((string) file_get_contents($file), true);
        return is_array($data) ? array_values($data) : [];
    }

    public function mergeProgress(string $userId, array $newProgress): array
    {
        $this->ensureDir('progress');
        $file = $this->dir . '/progress/' . $userId . '.json';
        $current = [];

        if (is_file($file)) {
            $raw = json_decode((string) file_get_contents($file), true);
            if (is_array($raw)) {
                foreach ($raw as $e) {
                    $key = ($e['cat'] ?? '') . ':' . ($e['lvl'] ?? '') . ':' . ($e['stage'] ?? '');
                    $current[$key] = $e;
                }
            }
        }

        foreach ($newProgress as $entry) {
            $key = ($entry['cat'] ?? '') . ':' . ($entry['lvl'] ?? '') . ':' . ($entry['stage'] ?? '');
            if (!isset($current[$key])) {
                $current[$key] = $entry;
            } else {
                $old = $current[$key];
                $bestStars = max((int) ($old['stars'] ?? 0), (int) ($entry['stars'] ?? 0));
                $bestScore = max((int) ($old['score'] ?? 0), (int) ($entry['score'] ?? 0));
                $current[$key] = array_merge($old, $entry, [
                    'stars' => $bestStars,
                    'score' => $bestScore,
                ]);
            }
        }

        $list = array_values($current);
        file_put_contents($file, json_encode($list, JSON_PRETTY_PRINT), LOCK_EX);
        return $list;
    }

    public function stats(string $userId): array
    {
        $file = $this->dir . '/stats/' . $userId . '.json';
        $default = [
            'quizDone'   => 0,
            'questions'  => 0,
            'correct'    => 0,
            'streak'     => 0,
            'bestStreak' => 0,
            'lastPlay'   => null,
            'badges'     => [],
            'categories' => [],
        ];
        if (!is_file($file)) {
            return $default;
        }
        $data = json_decode((string) file_get_contents($file), true);
        return is_array($data) ? array_merge($default, $data) : $default;
    }

    public function mergeStats(string $userId, array $newStats): array
    {
        $this->ensureDir('stats');
        $file = $this->dir . '/stats/' . $userId . '.json';
        $current = $this->stats($userId);

        $totalQuestions = max((int) $current['questions'], (int) ($newStats['questions'] ?? 0));
        $correctAnswers = min($totalQuestions, max((int) $current['correct'], (int) ($newStats['correct'] ?? 0)));

        $merged = [
            'quizDone'   => max((int) $current['quizDone'], (int) ($newStats['quizDone'] ?? 0)),
            'questions'  => $totalQuestions,
            'correct'    => $correctAnswers,
            'streak'     => (int) ($newStats['streak'] ?? $current['streak']),
            'bestStreak' => max((int) $current['bestStreak'], (int) ($newStats['bestStreak'] ?? 0)),
            'lastPlay'   => $newStats['lastPlay'] ?? $current['lastPlay'],
            'badges'     => array_values(array_unique(array_merge($current['badges'] ?? [], $newStats['badges'] ?? []))),
            'categories' => $current['categories'] ?? [],
        ];

        if (isset($newStats['categories']) && is_array($newStats['categories'])) {
            foreach ($newStats['categories'] as $catId => $v) {
                if (!isset($merged['categories'][$catId])) {
                    $catTotal = (int) ($v['total'] ?? 0);
                    $catCorrect = min($catTotal, (int) ($v['correct'] ?? 0));
                    $merged['categories'][$catId] = [
                        'done'    => (int) ($v['done'] ?? 0),
                        'correct' => $catCorrect,
                        'total'   => $catTotal,
                    ];
                } else {
                    $catTotal = max((int) ($merged['categories'][$catId]['total'] ?? 0), (int) ($v['total'] ?? 0));
                    $catCorrect = min($catTotal, max((int) ($merged['categories'][$catId]['correct'] ?? 0), (int) ($v['correct'] ?? 0)));
                    $merged['categories'][$catId] = [
                        'done'    => max((int) ($merged['categories'][$catId]['done'] ?? 0), (int) ($v['done'] ?? 0)),
                        'correct' => $catCorrect,
                        'total'   => $catTotal,
                    ];
                }
            }
        }

        file_put_contents($file, json_encode($merged, JSON_PRETTY_PRINT), LOCK_EX);
        return $merged;
    }

    public function issueCertificates(string $userId, string $userName, array $defs, array $levelIds): array
    {
        $this->ensureDir('certificates');
        $certFile = $this->dir . '/certificates/' . $userId . '.json';
        $existing = [];

        if (is_file($certFile)) {
            $raw = json_decode((string) file_get_contents($certFile), true);
            if (is_array($raw)) {
                $existing = $raw;
            }
        }

        $progressList = $this->progress($userId);
        $completedSet = [];
        foreach ($progressList as $p) {
            if (($p['stars'] ?? 0) >= 1) {
                $completedSet[($p['cat'] ?? '') . ':' . ($p['lvl'] ?? '') . ':' . ($p['stage'] ?? '')] = true;
            }
        }

        $existingByCat = [];
        foreach ($existing as $c) {
            $existingByCat[$c['cat']] = $c;
        }

        $secretKey = $this->secretKey();

        foreach ($defs as $def) {
            $catId = $def['id'];
            $leaves = $def['leaves'] ?? [$catId];
            $allDone = true;

            foreach ($leaves as $leaf) {
                foreach ($levelIds as $lvl) {
                    for ($stage = 1; $stage <= 5; $stage++) {
                        if (!isset($completedSet["$leaf:$lvl:$stage"])) {
                            $allDone = false;
                            break 3;
                        }
                    }
                }
            }

            if ($allDone && !isset($existingByCat[$catId])) {
                $rawCode = strtoupper(hash_hmac('sha256', "$userId:$catId", $secretKey));
                $code = substr($rawCode, 0, 4) . '-' . substr($rawCode, 4, 4) . '-' . substr($rawCode, 8, 4);

                $cert = [
                    'cat'   => $catId,
                    'title' => $def['title'],
                    'name'  => $userName,
                    'code'  => $code,
                    'date'  => gmdate('Y-m-d'),
                ];
                $existing[] = $cert;
                $existingByCat[$catId] = $cert;

                // Index public par code
                $normCode = strtoupper(str_replace('-', '', $code));
                $this->ensureDir('cert_index');
                file_put_contents($this->dir . '/cert_index/' . $normCode . '.json', json_encode($cert), LOCK_EX);
            }
        }

        file_put_contents($certFile, json_encode($existing, JSON_PRETTY_PRINT), LOCK_EX);
        return $existing;
    }

    public function verifyCertificate(string $code): ?array
    {
        $norm = strtoupper(str_replace('-', '', trim($code)));
        if (!preg_match('/^[A-F0-9]{12}$/', $norm)) {
            return null;
        }

        $file = $this->dir . '/cert_index/' . $norm . '.json';
        if (!is_file($file)) {
            return null;
        }

        $data = json_decode((string) file_get_contents($file), true);
        return is_array($data) ? $data : null;
    }

    private function secretKey(): string
    {
        $keyFile = $this->dir . '/secret.key';
        if (!is_file($keyFile)) {
            $key = bin2hex(random_bytes(32));
            @file_put_contents($keyFile, $key, LOCK_EX);
            return $key;
        }
        return trim((string) @file_get_contents($keyFile));
    }

    private function ensureDir(string $sub): void
    {
        $path = $this->dir . '/' . $sub;
        if (!is_dir($path)) {
            @mkdir($path, 0775, true);
        }
    }
}
