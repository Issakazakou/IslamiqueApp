<?php
declare(strict_types=1);

/**
 * Panneau d'administration minimal : ajouter, modifier et supprimer des questions
 * (data/questions.json) avec leurs traductions anglaise et arabe (data/translations.json).
 *
 * Accès : /admin, utilisateur « admin », mot de passe = variable QUIZ_ADMIN_PASSWORD
 * (panneau désactivé si elle est vide). À utiliser uniquement en HTTPS.
 * Fonctionne avec data/questions.json ; désactivé quand les questions viennent d'une base.
 */
final class AdminPanel
{
    public const CATEGORIES = [
        'coran_mediter' => 'Coran – Méditer',
        'coran_tajwid'  => 'Coran – Tajwid',
        'coran_culture' => 'Coran – Culture coranique',
        'hadith'        => 'Hadith',
        'fiqh'          => 'Fiqh',
        'sira'          => 'Sira',
    ];
    public const LEVELS = ['debutant' => 'Débutant', 'intermediaire' => 'Intermédiaire', 'avance' => 'Avancé'];
    public const LANGS  = ['en' => 'English', 'ar' => 'العربية'];
    private const OPTION_COUNT = 4;

    private string $dataDir;
    private string $password;
    private bool $dbMode;

    public function __construct(
        string $dataDir,
        string $password,
        bool $dbMode = false
    ) {
        $this->dataDir = $dataDir;
        $this->password = $password;
        $this->dbMode = $dbMode;
    }

    // ------------------------------------------------------------------ validation

    /**
     * Valide le formulaire et construit la question et ses traductions.
     *
     * @param array<string, mixed> $post
     * @return array{categorie: string, question: array<string, mixed>, translations: array<string, array<string, mixed>|null>}
     * @throws InvalidArgumentException message en français, affiché à l'administrateur
     */
    public static function parseForm(array $post, int $id): array
    {
        $cat = self::str($post['categorie'] ?? '');
        if (!isset(self::CATEGORIES[$cat])) {
            throw new InvalidArgumentException('Catégorie invalide.');
        }
        $level = self::str($post['niveau'] ?? '');
        if (!isset(self::LEVELS[$level])) {
            throw new InvalidArgumentException('Niveau invalide.');
        }
        $text = self::str($post['question'] ?? '');
        if ($text === '' || self::len($text) > 400) {
            throw new InvalidArgumentException('La question est requise (400 caractères maximum).');
        }
        $options = self::options($post['options'] ?? null, 'Les 4 choix de réponse');
        if ($options === null || count(array_unique($options)) !== self::OPTION_COUNT) {
            throw new InvalidArgumentException('Il faut 4 choix de réponse, tous renseignés et différents (300 caractères maximum).');
        }
        $right = $post['bonne'] ?? null;
        if (!is_string($right) || !preg_match('/^[0-3]$/', $right)) {
            throw new InvalidArgumentException('Indiquez la bonne réponse.');
        }
        $explication = self::str($post['explication'] ?? '');
        $source      = self::str($post['source'] ?? '');
        if (self::len($explication) > 1000 || self::len($source) > 200) {
            throw new InvalidArgumentException('Explication (1000 caractères max) ou source (200 max) trop longue.');
        }

        $question = [
            'id' => $id, 'question' => $text, 'options' => $options,
            'niveau' => $level, 'bonneReponse' => (int) $right,
        ];
        if ($explication !== '') {
            $question['explication'] = $explication;
        }
        if ($source !== '') {
            $question['source'] = $source;
        }

        $translations = [];
        foreach (self::LANGS as $lang => $label) {
            $translations[$lang] = self::parseTranslation($post[$lang] ?? null, $label);
        }
        return ['categorie' => $cat, 'question' => $question, 'translations' => $translations];
    }

    /**
     * @return array<string, mixed>|null null = aucune traduction saisie
     */
    private static function parseTranslation(mixed $raw, string $label): ?array
    {
        if (!is_array($raw)) {
            return null;
        }
        $text   = self::str($raw['question'] ?? '');
        $rawOpt = $raw['options'] ?? [];
        $opts   = is_array($rawOpt) ? array_map(static fn($o): string => self::str($o), $rawOpt) : [];
        $filledOpts = array_filter($opts, static fn(string $o): bool => $o !== '');
        $explication = self::str($raw['explication'] ?? '');
        $source      = self::str($raw['source'] ?? '');

        $out = [];
        if ($text !== '' || $filledOpts !== []) {
            $options = self::options($opts, 'Les choix');
            if ($text === '' || $options === null || count(array_unique($options)) !== self::OPTION_COUNT
                || self::len($text) > 400) {
                throw new InvalidArgumentException(
                    "Traduction $label incomplète : renseignez la question et les 4 choix (différents), ou videz-les tous."
                );
            }
            $out['question'] = $text;
            $out['options']  = $options;
        }
        if ($explication !== '') {
            if (self::len($explication) > 1000) {
                throw new InvalidArgumentException("Explication $label trop longue.");
            }
            $out['explication'] = $explication;
        }
        if ($source !== '') {
            if (self::len($source) > 200) {
                throw new InvalidArgumentException("Source $label trop longue.");
            }
            $out['source'] = $source;
        }
        return $out === [] ? null : $out;
    }

    /** @return list<string>|null 4 choix non vides de 300 caractères maximum, sinon null */
    private static function options(mixed $raw, string $what): ?array
    {
        if (!is_array($raw) || count($raw) !== self::OPTION_COUNT) {
            return null;
        }
        $out = [];
        foreach (array_values($raw) as $o) {
            $o = self::str($o);
            if ($o === '' || self::len($o) > 300) {
                return null;
            }
            $out[] = $o;
        }
        return $out;
    }

    private static function str(mixed $v): string
    {
        return is_string($v) ? trim(str_replace("\r", '', $v)) : '';
    }

    private static function len(string $s): int
    {
        return function_exists('mb_strlen') ? mb_strlen($s) : strlen($s);
    }

    // ------------------------------------------------------------------ requêtes

    public function handle(string $method, string $path): never
    {
        header('Cache-Control: no-store');
        header('X-Frame-Options: DENY');
        header('Content-Type: text/html; charset=utf-8');

        if ($this->password === '') {
            $this->page('Panneau désactivé', '<p>Définissez la variable d\'environnement <code>QUIZ_ADMIN_PASSWORD</code> pour activer le panneau d\'administration.</p>', 403);
        }
        $this->authorize();
        if ($this->dbMode) {
            $this->page('Panneau indisponible', '<p>Les questions viennent de la base de données (<code>QUIZ_DB_DSN</code>) : modifiez-les directement dans la base. Ce panneau ne gère que <code>data/questions.json</code>.</p>', 403);
        }

        if ($method === 'POST' && $path === '/admin/save') {
            $this->save();
        }
        if ($method === 'POST' && $path === '/admin/delete') {
            $this->delete();
        }
        if ($method === 'GET' && $path === '/admin') {
            $this->index();
        }
        $this->page('Introuvable', '<p>Page introuvable.</p>', 404);
    }

    private function authorize(): void
    {
        $user = $_SERVER['PHP_AUTH_USER'] ?? null;
        $pass = $_SERVER['PHP_AUTH_PW'] ?? null;
        if ($user === null) {
            $h = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
            if (is_string($h) && stripos($h, 'Basic ') === 0) {
                $decoded = base64_decode(substr($h, 6), true);
                if ($decoded !== false && str_contains($decoded, ':')) {
                    [$user, $pass] = explode(':', $decoded, 2);
                }
            }
        }
        $okUser = hash_equals('admin', is_string($user) ? $user : '');
        $okPass = hash_equals($this->password, is_string($pass) ? $pass : '');
        if (!($okUser && $okPass)) {
            usleep(500000); // ralentit les essais répétés
            header('WWW-Authenticate: Basic realm="Quiz admin", charset="UTF-8"');
            $this->page('Authentification requise', '<p>Identifiants incorrects.</p>', 401);
        }
    }

    private function csrf(): string
    {
        return hash_hmac('sha256', 'admin-csrf', $this->password);
    }

    private function checkCsrf(): void
    {
        $token = $_POST['csrf'] ?? '';
        if (!is_string($token) || !hash_equals($this->csrf(), $token)) {
            $this->page('Requête refusée', '<p>Jeton de sécurité invalide. Rechargez la page.</p>', 403);
        }
    }

    private function base(): string
    {
        return rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
    }

    private function redirect(string $query): never
    {
        header('Location: ' . $this->base() . '/admin' . $query);
        http_response_code(303);
        exit;
    }

    // ------------------------------------------------------------------ actions

    private function save(): never
    {
        $this->checkCsrf();
        $editId = (int) ($_POST['id'] ?? 0);

        try {
            $lock = $this->lock();
            $data = $this->read('questions.json');
            $tr   = $this->translations();

            if ($editId > 0 && $this->find($data, $editId) === null) {
                throw new InvalidArgumentException("Question $editId introuvable.");
            }
            $id     = $editId > 0 ? $editId : $this->nextId($data);
            $parsed = self::parseForm($_POST, $id);
            $cat    = $parsed['categorie'];

            // Retire l'ancienne version (en gardant la position si la catégorie ne change pas).
            $replaced = false;
            foreach ($data as $c => $list) {
                foreach ($list as $i => $q) {
                    if ((int) ($q['id'] ?? 0) === $id) {
                        if ($c === $cat) {
                            $data[$c][$i] = $parsed['question'];
                            $replaced = true;
                        } else {
                            unset($data[$c][$i]);
                            $data[$c] = array_values($data[$c]);
                        }
                        break 2;
                    }
                }
            }
            if (!$replaced) {
                $data[$cat][] = $parsed['question'];
            }

            foreach ($parsed['translations'] as $lang => $t) {
                if ($t === null) {
                    unset($tr[$lang][(string) $id]);
                } else {
                    $tr[$lang][(string) $id] = $t;
                }
            }
            $this->write('questions.json', $data);
            $this->write('translations.json', $tr);
            flock($lock, LOCK_UN);
            fclose($lock);
        } catch (InvalidArgumentException $e) {
            $this->index($e->getMessage(), $_POST);
        } catch (RuntimeException $e) {
            $this->page('Erreur', '<p>' . self::h($e->getMessage()) . '</p>', 500);
        }
        $this->redirect('?cat=' . rawurlencode($cat) . '&ok=1');
    }

    private function delete(): never
    {
        $this->checkCsrf();
        $id = (int) ($_POST['id'] ?? 0);
        try {
            $lock = $this->lock();
            $data = $this->read('questions.json');
            $tr   = $this->translations();
            $found = $this->find($data, $id);
            if ($found === null) {
                throw new InvalidArgumentException("Question $id introuvable.");
            }
            $cat = $found['cat'];
            $data[$cat] = array_values(array_filter(
                $data[$cat],
                static fn(array $q): bool => (int) ($q['id'] ?? 0) !== $id
            ));
            foreach (array_keys(self::LANGS) as $lang) {
                unset($tr[$lang][(string) $id]);
            }
            $this->write('questions.json', $data);
            $this->write('translations.json', $tr);
            flock($lock, LOCK_UN);
            fclose($lock);
        } catch (InvalidArgumentException $e) {
            $this->page('Erreur', '<p>' . self::h($e->getMessage()) . '</p>', 404);
        } catch (RuntimeException $e) {
            $this->page('Erreur', '<p>' . self::h($e->getMessage()) . '</p>', 500);
        }
        $this->redirect('?cat=' . rawurlencode($cat) . '&deleted=1');
    }

    // ------------------------------------------------------------------ données

    /** @return resource */
    private function lock()
    {
        $fh = @fopen($this->dataDir . '/.admin.lock', 'c');
        if ($fh === false || !flock($fh, LOCK_EX)) {
            throw new RuntimeException('Dossier data non inscriptible.');
        }
        return $fh;
    }

    /** @return array<string, mixed> */
    private function read(string $name): array
    {
        $file = $this->dataDir . '/' . $name;
        if (!is_file($file)) {
            return [];
        }
        $decoded = json_decode((string) @file_get_contents($file), true);
        if (!is_array($decoded)) {
            throw new RuntimeException("Fichier $name illisible.");
        }
        return $decoded;
    }

    /** @return array<string, array<string, array<string, mixed>>> */
    private function translations(): array
    {
        $tr = $this->read('translations.json');
        foreach (array_keys(self::LANGS) as $lang) {
            if (!isset($tr[$lang]) || !is_array($tr[$lang])) {
                $tr[$lang] = [];
            }
        }
        return $tr;
    }

    /** @param array<string, mixed> $data */
    private function write(string $name, array $data): void
    {
        $file = $this->dataDir . '/' . $name;
        $tmp  = $file . '.tmp';
        $json = json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        if ($json === false || @file_put_contents($tmp, $json . "\n") === false || !@rename($tmp, $file)) {
            @unlink($tmp);
            throw new RuntimeException("Impossible d'écrire $name (droits du dossier data ?).");
        }
    }

    /**
     * @param array<string, mixed> $data
     * @return array{cat: string, q: array<string, mixed>}|null
     */
    private function find(array $data, int $id): ?array
    {
        foreach ($data as $cat => $list) {
            foreach ($list as $q) {
                if ((int) ($q['id'] ?? 0) === $id) {
                    return ['cat' => (string) $cat, 'q' => $q];
                }
            }
        }
        return null;
    }

    /** @param array<string, mixed> $data */
    private function nextId(array $data): int
    {
        $max = 0;
        foreach ($data as $list) {
            foreach ($list as $q) {
                $max = max($max, (int) ($q['id'] ?? 0));
            }
        }
        return $max + 1;
    }

    // ------------------------------------------------------------------ affichage

    private static function h(mixed $v): string
    {
        return htmlspecialchars((string) $v, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }

    private function page(string $title, string $body, int $status = 200): never
    {
        http_response_code($status);
        echo '<!doctype html><html lang="fr"><head><meta charset="utf-8">'
            . '<meta name="viewport" content="width=device-width, initial-scale=1">'
            . '<meta name="robots" content="noindex"><title>' . self::h($title) . ' – Quiz admin</title>'
            . '<style>'
            . 'body{font-family:system-ui,sans-serif;margin:0;background:#f4f6f5;color:#1b2b24}'
            . 'main{max-width:980px;margin:0 auto;padding:16px}'
            . 'h1{font-size:22px;color:#14573f}h2{font-size:17px;margin-top:28px}'
            . 'table{width:100%;border-collapse:collapse;background:#fff;border-radius:8px;overflow:hidden}'
            . 'th,td{padding:8px 10px;border-bottom:1px solid #e3e8e5;text-align:left;font-size:14px;vertical-align:top}'
            . 'th{background:#e8efec}'
            . 'form.card,.card{background:#fff;border-radius:8px;padding:14px;margin-top:12px}'
            . 'label{display:block;font-weight:600;font-size:13px;margin-top:10px}'
            . 'input[type=text],textarea,select{width:100%;box-sizing:border-box;padding:8px;border:1px solid #bcc9c3;border-radius:6px;font:inherit}'
            . '.opt{display:flex;gap:8px;align-items:center;margin-top:6px}.opt input[type=radio]{flex:none}'
            . 'button,.btn{background:#14573f;color:#fff;border:0;border-radius:6px;padding:8px 14px;font:inherit;cursor:pointer;text-decoration:none;display:inline-block}'
            . 'button.danger{background:#a33}.btn.light{background:#e8efec;color:#14573f}'
            . '.msg{padding:10px;border-radius:6px;margin-top:12px}.ok{background:#dff3e8}.err{background:#fbe0e0}'
            . '.tag{font-size:11px;background:#e8efec;border-radius:4px;padding:1px 5px;margin-right:3px}'
            . 'details{margin-top:12px}summary{cursor:pointer;font-weight:700}'
            . '</style></head><body><main>' . $body . '</main></body></html>';
        exit;
    }

    /**
     * @param array<string, mixed>|null $posted valeurs à réafficher après une erreur
     */
    private function index(?string $error = null, ?array $posted = null): never
    {
        $data = $this->read('questions.json');
        $tr   = $this->translations();
        $base = $this->base() . '/admin';

        $filter = is_string($_GET['cat'] ?? null) ? (string) $_GET['cat'] : '';
        $editId = (int) ($_GET['edit'] ?? ($posted['id'] ?? 0));
        $editing = $editId > 0 ? $this->find($data, $editId) : null;

        $h = fn(mixed $v): string => self::h($v);
        $out = '<h1>Quiz Islamique – Administration</h1>';
        if ($error !== null) {
            $out .= '<div class="msg err">' . $h($error) . '</div>';
        } elseif (isset($_GET['ok'])) {
            $out .= '<div class="msg ok">Question enregistrée.</div>';
        } elseif (isset($_GET['deleted'])) {
            $out .= '<div class="msg ok">Question supprimée.</div>';
        }

        // Filtre par catégorie
        $out .= '<p><a class="btn light" href="' . $h($base) . '">Toutes</a> ';
        foreach (self::CATEGORIES as $key => $label) {
            $n = count($data[$key] ?? []);
            $out .= '<a class="btn light" href="' . $h($base . '?cat=' . $key) . '">' . $h($label) . ' (' . $n . ')</a> ';
        }
        $out .= '</p>';

        // Liste
        $out .= '<table><tr><th>#</th><th>Catégorie</th><th>Niveau</th><th>Question</th><th>Langues</th><th></th></tr>';
        $shown = 0;
        foreach (self::CATEGORIES as $cat => $label) {
            if ($filter !== '' && $filter !== $cat) {
                continue;
            }
            foreach ($data[$cat] ?? [] as $q) {
                if (++$shown > 500) {
                    break 2;
                }
                $id = (int) $q['id'];
                $tags = '<span class="tag">FR</span>';
                foreach (self::LANGS as $lang => $_) {
                    if (isset($tr[$lang][(string) $id]['question'])) {
                        $tags .= '<span class="tag">' . strtoupper($lang) . '</span>';
                    }
                }
                $text = (string) $q['question'];
                $short = function_exists('mb_substr') ? mb_substr($text, 0, 90) : substr($text, 0, 90);
                $out .= '<tr><td>' . $id . '</td><td>' . $h($label) . '</td><td>' . $h(self::LEVELS[$q['niveau'] ?? ''] ?? '') . '</td>'
                    . '<td>' . $h($short) . (self::len($text) > 90 ? '…' : '') . '</td><td>' . $tags . '</td>'
                    . '<td style="white-space:nowrap"><a class="btn light" href="' . $h($base . '?edit=' . $id . ($filter !== '' ? '&cat=' . $filter : '')) . '#form">Modifier</a> '
                    . '<form method="post" action="' . $h($base . '/delete') . '" style="display:inline" onsubmit="return confirm(\'Supprimer cette question ?\')">'
                    . '<input type="hidden" name="csrf" value="' . $h($this->csrf()) . '"><input type="hidden" name="id" value="' . $id . '">'
                    . '<button class="danger">Supprimer</button></form></td></tr>';
            }
        }
        $out .= '</table>';

        // Formulaire (ajout ou modification)
        $v = [
            'id' => '', 'categorie' => $filter, 'niveau' => 'debutant', 'question' => '',
            'options' => ['', '', '', ''], 'bonne' => '0', 'explication' => '', 'source' => '',
        ];
        $trv = ['en' => [], 'ar' => []];
        if ($posted !== null) {
            $v = array_merge($v, array_intersect_key($posted, $v));
            foreach (array_keys(self::LANGS) as $lang) {
                $trv[$lang] = is_array($posted[$lang] ?? null) ? $posted[$lang] : [];
            }
        } elseif ($editing !== null) {
            $q = $editing['q'];
            $v = [
                'id' => (string) $q['id'], 'categorie' => $editing['cat'], 'niveau' => (string) ($q['niveau'] ?? 'debutant'),
                'question' => (string) $q['question'], 'options' => array_pad(array_values($q['options'] ?? []), 4, ''),
                'bonne' => (string) ($q['bonneReponse'] ?? 0), 'explication' => (string) ($q['explication'] ?? ''),
                'source' => (string) ($q['source'] ?? ''),
            ];
            foreach (array_keys(self::LANGS) as $lang) {
                $trv[$lang] = $tr[$lang][(string) $q['id']] ?? [];
            }
        }

        $out .= '<h2 id="form">' . ($v['id'] !== '' ? 'Modifier la question ' . $h($v['id']) : 'Ajouter une question') . '</h2>';
        $out .= '<form class="card" method="post" action="' . $h($base . '/save') . '">'
            . '<input type="hidden" name="csrf" value="' . $h($this->csrf()) . '">'
            . '<input type="hidden" name="id" value="' . $h($v['id']) . '">';

        $out .= '<label>Catégorie<select name="categorie">';
        foreach (self::CATEGORIES as $key => $label) {
            $out .= '<option value="' . $h($key) . '"' . ($v['categorie'] === $key ? ' selected' : '') . '>' . $h($label) . '</option>';
        }
        $out .= '</select></label><label>Niveau<select name="niveau">';
        foreach (self::LEVELS as $key => $label) {
            $out .= '<option value="' . $h($key) . '"' . ($v['niveau'] === $key ? ' selected' : '') . '>' . $h($label) . '</option>';
        }
        $out .= '</select></label>';
        $out .= '<label>Question (français)<textarea name="question" rows="2" maxlength="400" required>' . $h($v['question']) . '</textarea></label>';
        $out .= '<label>Choix de réponse (cochez la bonne réponse)</label>';
        $opts = is_array($v['options']) ? array_values($v['options']) : [];
        for ($i = 0; $i < 4; $i++) {
            $out .= '<div class="opt"><input type="radio" name="bonne" value="' . $i . '"' . ((string) $v['bonne'] === (string) $i ? ' checked' : '') . ' required>'
                . '<input type="text" name="options[]" maxlength="300" required value="' . $h($opts[$i] ?? '') . '"></div>';
        }
        $out .= '<label>Explication (facultatif)<textarea name="explication" rows="2" maxlength="1000">' . $h($v['explication']) . '</textarea></label>';
        $out .= '<label>Source (facultatif) – ex. Sourate Al-Baqarah (2), verset 286<input type="text" name="source" maxlength="200" value="' . $h($v['source']) . '"></label>';

        foreach (self::LANGS as $lang => $label) {
            $t = $trv[$lang];
            $topts = isset($t['options']) && is_array($t['options']) ? array_values($t['options']) : [];
            $dir = $lang === 'ar' ? ' dir="rtl"' : '';
            $open = $t !== [] ? ' open' : '';
            $out .= '<details' . $open . '><summary>Traduction : ' . $h($label) . ' (facultatif)</summary>'
                . '<label>Question<textarea name="' . $lang . '[question]" rows="2" maxlength="400"' . $dir . '>' . $h($t['question'] ?? '') . '</textarea></label>'
                . '<label>Les 4 choix, dans le même ordre que le français</label>';
            for ($i = 0; $i < 4; $i++) {
                $out .= '<div class="opt"><input type="text" name="' . $lang . '[options][]" maxlength="300"' . $dir . ' value="' . $h($topts[$i] ?? '') . '"></div>';
            }
            $out .= '<label>Explication<textarea name="' . $lang . '[explication]" rows="2" maxlength="1000"' . $dir . '>' . $h($t['explication'] ?? '') . '</textarea></label>'
                . '<label>Source<input type="text" name="' . $lang . '[source]" maxlength="200"' . $dir . ' value="' . $h($t['source'] ?? '') . '"></label>'
                . '</details>';
        }
        $out .= '<p><button>Enregistrer</button> ';
        if ($v['id'] !== '') {
            $out .= '<a class="btn light" href="' . $h($base) . '">Annuler</a>';
        }
        $out .= '</p></form>';

        $this->page('Questions', $out);
    }
}
