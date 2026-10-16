<?php
declare(strict_types=1);

/**
 * Accès aux questions. La logique (catégories, niveaux, tirage) ne dépend pas de la
 * source : les données viennent soit du fichier JSON ([fromJsonFile]), soit d'une base
 * de données ([DatabaseQuestionLoader::load]).
 *
 * Forme attendue des données :
 *   [ 'coran_tajwid' => [ ['id'=>1, 'question'=>'…', 'options'=>['a','b','c','d'],
 *                   'niveau'=>'debutant', 'bonneReponse'=>1], … ], 'hadith' => […], … ]
 */
final class QuestionRepository
{
    /** Métadonnées d'affichage des catégories. */
    private const META = [
        'coran_mediter' => ['title' => 'Méditer',            'description' => 'Réfléchir au sens des versets (tadabbur)', 'parent' => 'coran'],
        'coran_tajwid'  => ['title' => 'Tajwid',             'description' => 'Les règles de la récitation',              'parent' => 'coran'],
        'coran_culture' => ['title' => 'Culture coranique',  'description' => 'Sourates, versets, prophètes et histoire',  'parent' => 'coran'],
        'hadith' => ['title' => 'Quiz Hadith',        'description' => 'Découvrez les enseignements des hadiths'],
        'fiqh'   => ['title' => 'Quiz Fiqh',          'description' => 'Testez vos connaissances en jurisprudence islamique'],
        'sira'   => ['title' => 'Sira du Prophète ﷺ', 'description' => 'Découvrez la vie du Prophète ﷺ'],
    ];

    /** Niveaux : position de la tranche (1/3 des questions de la catégorie). */
    public const LEVELS = ['debutant' => 0, 'intermediaire' => 1, 'avance' => 2];

    /** @var array<string, list<array<string, mixed>>> */
    private array $data;

    /**
     * Traductions : langue -> id de question -> champs traduits
     * (`question`, `options`, `explication`, `source`). Le français est la langue
     * d'origine ; une question sans traduction reste en français.
     *
     * @var array<string, array<string, array<string, mixed>>>
     */
    private array $translations = [];

    /** @param array<string, list<array<string, mixed>>> $data */
    public function __construct(array $data)
    {
        $this->data = $data;
    }

    /** @param array<string, array<string, array<string, mixed>>> $translations */
    public function setTranslations(array $translations): void
    {
        $this->translations = $translations;
    }

    /** Charge `translations.json` s'il existe (sinon : aucune traduction). */
    public function loadTranslationsFile(string $file): void
    {
        if (!is_file($file)) {
            return;
        }
        $decoded = json_decode((string) @file_get_contents($file), true);
        if (is_array($decoded)) {
            $this->translations = $decoded;
        }
    }

    /** Langue demandée normalisée : 'fr' (défaut), 'en' ou 'ar'. */
    public static function normalizeLang(mixed $lang): string
    {
        $code = is_string($lang) ? strtolower(substr(trim($lang), 0, 2)) : '';
        return in_array($code, ['en', 'ar'], true) ? $code : 'fr';
    }

    /**
     * Applique la traduction à une question. L'ordre des choix est conservé : l'index de
     * la bonne réponse reste donc valable. Si la traduction est absente ou incohérente
     * (nombre de choix différent), la question reste en français.
     *
     * @param array<string, mixed> $q
     * @return array<string, mixed>
     */
    public function localize(array $q, string $lang): array
    {
        if ($lang === 'fr') {
            return $q;
        }
        $t = $this->translations[$lang][(string) ($q['id'] ?? '')] ?? null;
        if (!is_array($t)) {
            return $q;
        }
        $options = $t['options'] ?? null;
        $optionsOk = is_array($options) && count($options) === count($q['options'] ?? []);
        if ($optionsOk && is_string($t['question'] ?? null) && $t['question'] !== '') {
            $q['question'] = $t['question'];
            $q['options']  = array_values(array_map('strval', $options));
        }
        foreach (['explication', 'source'] as $field) {
            if (is_string($t[$field] ?? null) && $t[$field] !== '') {
                $q[$field] = $t[$field];
            }
        }
        return $q;
    }

    public static function fromJsonFile(string $file): self
    {
        $json = @file_get_contents($file);
        if ($json === false) {
            throw new RuntimeException("Fichier de questions introuvable : $file");
        }
        $decoded = json_decode($json, true, 512, JSON_THROW_ON_ERROR);
        if (!is_array($decoded)) {
            throw new RuntimeException('Format de questions invalide.');
        }
        return new self($decoded);
    }

    /** @return list<array<string, mixed>> */
    public function categories(): array
    {
        $out = [];
        foreach ($this->data as $id => $questions) {
            $meta = self::META[$id] ?? ['title' => ucfirst((string) $id), 'description' => ''];
            $out[] = [
                'id'            => $id,
                'title'         => $meta['title'],
                'description'   => $meta['description'],
                'questionCount' => count($questions),
                'levels'        => array_keys(self::LEVELS),
                'parent'        => $meta['parent'] ?? null,
            ];
        }
        return $out;
    }

    public function hasCategory(string $category): bool
    {
        return isset($this->data[$category]);
    }

    /** @return list<array<string, mixed>> */
    public function all(string $category): array
    {
        return $this->data[$category] ?? [];
    }

    public static function isValidLevel(string $level): bool
    {
        return isset(self::LEVELS[$level]);
    }

    /**
     * Retourne les questions d'une catégorie, filtrées par niveau (optionnel).
     * Le niveau vient du champ `niveau` de chaque question ; s'il est absent,
     * on se replie sur les tiers dans l'ordre du fichier (ancien comportement).
     *
     * @return list<array<string, mixed>>
     */
    public function pick(string $category, ?string $level, int $limit, bool $random): array
    {
        $questions = $this->all($category);

        if ($level !== null) {
            if ($questions !== [] && isset($questions[0]['niveau'])) {
                $questions = array_values(array_filter(
                    $questions,
                    static fn(array $q): bool => ($q['niveau'] ?? null) === $level
                ));
            } else {
                $size      = (int) ceil(count($questions) / 3);
                $questions = array_slice($questions, self::LEVELS[$level] * $size, $size);
            }
        }
        if ($random) {
            shuffle($questions);
        }
        return $limit > 0 ? array_slice($questions, 0, $limit) : $questions;
    }

    /** @return array<int, array<string, mixed>> questions indexées par id */
    public function indexById(string $category): array
    {
        $map = [];
        foreach ($this->all($category) as $q) {
            $map[(int) $q['id']] = $q;
        }
        return $map;
    }
}
