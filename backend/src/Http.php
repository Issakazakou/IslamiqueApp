<?php
declare(strict_types=1);

/**
 * Petits utilitaires HTTP / JSON.
 */
final class Http
{
    public static function cors(): void
    {
        // Origine autorisée (applications web). Les apps mobiles n'en ont pas besoin.
        // Définir QUIZ_CORS_ORIGIN=https://mon-site.com pour restreindre (défaut : *).
        $origin = getenv('QUIZ_CORS_ORIGIN') ?: '*';
        header('Access-Control-Allow-Origin: ' . $origin);
        if ($origin !== '*') {
            header('Vary: Origin');
        }
        header('Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization');
    }

    public static function json(mixed $data, int $status = 200): never
    {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
        exit;
    }

    public static function error(string $message, int $status): never
    {
        self::json(['error' => $message], $status);
    }

    /** @return array<string, mixed> */
    public static function body(): array
    {
        $raw = file_get_contents('php://input') ?: '';
        if ($raw === '') {
            return [];
        }
        $data = json_decode($raw, true);
        if (!is_array($data)) {
            self::error('Corps JSON invalide.', 400);
        }
        return $data;
    }

    /** Jeton « Authorization: Bearer … » de la requête (ou null). */
    public static function bearerToken(): ?string
    {
        $h = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
        if ($h === '' && function_exists('getallheaders')) {
            foreach (getallheaders() as $k => $v) {
                if (strcasecmp((string) $k, 'Authorization') === 0) {
                    $h = (string) $v;
                }
            }
        }
        return preg_match('/^Bearer\s+([A-Za-z0-9]+)$/', (string) $h, $m) ? $m[1] : null;
    }

    /** Chemin de la requête, sans le préfixe du dossier de déploiement. */
    public static function path(): string
    {
        $path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
        $base = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
        if ($base !== '' && str_starts_with($path, $base)) {
            $path = substr($path, strlen($base));
        }
        return '/' . trim($path, '/');
    }
}
