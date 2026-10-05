<?php
declare(strict_types=1);

/**
 * Accès aux questions (fichier JSON).
 */
final class QuestionRepository
{
    /** Métadonnées d'affichage des catégories. */
    private const META = [
        'coran'  => ['title' => 'Quiz Coran',         'description' => 'Testez vos connaissances sur le Coran'],
        'hadith' => ['title' => 'Quiz Hadith',        'description' => 'Découvrez les enseignements des hadiths'],
        'fiqh'   => ['title' => 'Quiz Fiqh',          'description' => 'Testez vos connaissances en jurisprudence islamique'],
        'sira'   => ['title' => 'Sira du Prophète ﷺ', 'description' => 'Découvrez la vie du Prophète ﷺ'],
    ];

    /** Niveaux : position de la tranche (1/3 des questions de la catégorie). */
    public const LEVELS = ['debutant' => 0, 'intermediaire' => 1, 'avance' => 2];

    /** @var array<string, list<array<string, mixed>>> */
    private array $data;

    public function __construct(string $file)
    {
        $json = @file_get_contents($file);
        if ($json === false) {
            throw new RuntimeException("Fichier de questions introuvable : $file");
        }
        $decoded = json_decode($json, true, 512, JSON_THROW_ON_ERROR);
        if (!is_array($decoded)) {
            throw new RuntimeException('Format de questions invalide.');
        }
        $this->data = $decoded;
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
     * Le niveau correspond à un tiers des questions, dans l'ordre du fichier.
     *
     * @return list<array<string, mixed>>
     */
    public function pick(string $category, ?string $level, int $limit, bool $random): array
    {
        $questions = $this->all($category);

        if ($level !== null) {
            $size      = (int) ceil(count($questions) / 3);
            $questions = array_slice($questions, self::LEVELS[$level] * $size, $size);
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
