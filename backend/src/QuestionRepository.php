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
        'coran_mediter'       => ['title' => 'Méditer',            'description' => 'Réfléchir au sens des versets (tadabbur)', 'parent' => 'coran'],
        'coran_tajwid'        => ['title' => 'Tajwid',             'description' => 'Les règles de la récitation',              'parent' => 'coran'],
        'coran_culture'       => ['title' => 'Culture coranique',  'description' => 'Sourates, versets, prophètes et histoire',  'parent' => 'coran'],
        'baqarah_audio'       => ['title' => 'Al-Baqarah (Audio)', 'description' => 'Écoute la récitation et complète le verset en arabe', 'parent' => 'coran'],
        'hadith_fondements'   => ['title' => 'Grands Enseignements', 'description' => 'Foi, intentions, piliers et 40 Hadiths Nawawi', 'parent' => 'hadith'],
        'hadith_comportement' => ['title' => 'Comportement & Adab', 'description' => 'Éthique, fraternité, sincérité et noble caractère', 'parent' => 'hadith'],
        'hadith_sciences'     => ['title' => 'Sciences du Hadith',  'description' => 'Terminologie, chaîne de transmission et grands imams', 'parent' => 'hadith'],
        'fiqh_general'        => ['title' => 'Fiqh Général',       'description' => 'Purification, piliers, jeûne et bases',    'parent' => 'fiqh'],
        'fiqh_priere'         => ['title' => 'La Prière',          'description' => 'Sunnas, mérites et rattrapage (rite malikite)', 'parent' => 'fiqh'],
        'fiqh_funerailles'    => ['title' => 'Les Funérailles',    'description' => 'Assistance, lavage, linceul et enterrement',    'parent' => 'fiqh'],
        'sira_mecquoise'      => ['title' => 'Période Mecquoise',  'description' => 'De la naissance à l\'Hégire',             'parent' => 'sira'],
        'sira_medinoise'      => ['title' => 'Période Médinoise',  'description' => 'Fondation de l\'État musulman et communauté', 'parent' => 'sira'],
        'sira_evenements'     => ['title' => 'Grandes Étapes & Victoires', 'description' => 'Batailles, traités et accomplissement de la mission', 'parent' => 'sira'],
        'tawhid_fondements'   => ['title' => 'Fondements & Unicité',        'description' => 'Raison de la création, mérites, Lâ ilâha illâ Allâh et crainte du Shirk', 'parent' => 'tawhid'],
        'tawhid_adoration'    => ['title' => 'Adoration & Vénération',      'description' => 'Sacrifices, vœux, intercession, Noms Divins et serments',                  'parent' => 'tawhid'],
        'tawhid_preservation' => ['title' => 'Mises en garde & Superstitions', 'description' => 'Amulettes, sorcellerie, voyance, astrologie et augures',                 'parent' => 'tawhid'],
        'hadith'              => ['title' => 'Quiz Hadith',        'description' => 'Découvrez les enseignements des hadiths'],
        'fiqh'                => ['title' => 'Quiz Fiqh',          'description' => 'Bases, prière malikite et funérailles'],
        'sira'                => ['title' => 'Sira du Prophète ﷺ', 'description' => 'Découvrez la vie du Prophète ﷺ'],
        'tawhid'              => ['title' => 'Quiz Tawhid',        'description' => 'Fondements, adoration exclusive et préservation de la foi'],
    ];

    /** Niveaux : position de la tranche (1/3 des questions de la catégorie). */
    public const LEVELS = ['debutant' => 0, 'intermediaire' => 1, 'avance' => 2];

    /** Alias des categories pour compatibilite descendante. */
    private const ALIASES = [
        'fiqh'   => 'fiqh_general',
        'hadith' => 'hadith_fondements',
        'sira'   => 'sira_mecquoise',
        'tawhid' => 'tawhid_fondements',
    ];

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
        if (isset(self::ALIASES[$category]) && isset($this->data[self::ALIASES[$category]])) {
            return true;
        }
        return isset($this->data[$category]);
    }

    /** @return list<array<string, mixed>> */
    public function all(string $category): array
    {
        if (isset(self::ALIASES[$category]) && !isset($this->data[$category]) && isset($this->data[self::ALIASES[$category]])) {
            return $this->data[self::ALIASES[$category]];
        }
        return $this->data[$category] ?? [];
    }

    /**
     * Retourne les questions correspondant aux identifiants donnés.
     *
     * @param list<int> $ids
     * @return list<array<string, mixed>>
     */
    public function findByIds(array $ids): array
    {
        $idSet = array_flip($ids);
        $found = [];
        foreach ($this->data as $questions) {
            foreach ($questions as $q) {
                if (isset($idSet[(int) $q['id']])) {
                    $found[] = $q;
                }
            }
        }
        return $found;
    }

    /**
     * Sélectionne les questions pour le défi quotidien en fonction de la date du jour.
     *
     * @return list<array<string, mixed>>
     */
    public function dailyChallenge(string $date, int $count = 10): array
    {
        $allQuestions = [];
        foreach ($this->data as $cat => $questions) {
            foreach ($questions as $q) {
                $q['category'] = $cat;
                $allQuestions[] = $q;
            }
        }

        if ($allQuestions === []) {
            return [];
        }

        // Graine déterministe basée sur la date (ex: "2026-10-20")
        $seed = crc32($date);
        mt_srand($seed);

        $keys = array_keys($allQuestions);
        // Mélange Fisher-Yates avec la graine du jour
        for ($i = count($keys) - 1; $i > 0; $i--) {
            $j = mt_rand(0, $i);
            $tmp = $keys[$i];
            $keys[$i] = $keys[$j];
            $keys[$j] = $tmp;
        }

        mt_srand(); // Rétablir le générateur par défaut

        $selected = [];
        for ($k = 0; $k < min($count, count($keys)); $k++) {
            $selected[] = $allQuestions[$keys[$k]];
        }
        return $selected;
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
