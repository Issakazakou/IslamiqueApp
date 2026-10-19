import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ---------------------------------------------------------------------------
/// Catégorie de Quiz
/// ---------------------------------------------------------------------------
class QuizCategory {
  /// Identifiant utilisé par l'API : coran, hadith, fiqh, sira.
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  /// Sous-catégories : si la liste n'est pas vide, cette catégorie est un
  /// « groupe » (ex. Coran → Méditer, Tajwid…). Ce sont les sous-catégories
  /// qui portent les quiz, les niveaux et la progression.
  final List<QuizCategory> children;

  const QuizCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    this.children = const [],
  });

  bool get isGroup => children.isNotEmpty;

  /// Catégories qui portent réellement des quiz (elles-mêmes, ou leurs enfants).
  List<QuizCategory> get leaves => isGroup ? children : [this];
}

const List<QuizCategory> categories = [
  QuizCategory(
    id: 'coran',
    title: 'Coran',
    description: 'Méditer, Tajwid et culture coranique',
    icon: Icons.book_outlined,
    iconColor: AppColors.primary,
    iconBackground: AppColors.primaryTint,
    children: [
      QuizCategory(
        id: 'coran_mediter',
        title: 'Méditer',
        description: 'Réfléchir au sens des versets (tadabbur)',
        icon: Icons.self_improvement_outlined,
        iconColor: AppColors.primary,
        iconBackground: AppColors.primaryTint,
      ),
      QuizCategory(
        id: 'coran_tajwid',
        title: 'Tajwid',
        description: 'Les règles de la récitation',
        icon: Icons.record_voice_over_outlined,
        iconColor: AppColors.gold,
        iconBackground: AppColors.goldTint,
      ),
      QuizCategory(
        id: 'coran_culture',
        title: 'Culture coranique',
        description: 'Sourates, versets, prophètes et histoire',
        icon: Icons.menu_book_outlined,
        iconColor: AppColors.primary,
        iconBackground: AppColors.primaryTint,
      ),
    ],
  ),
  QuizCategory(
    id: 'hadith',
    title: 'Quiz Hadith',
    description: 'Enseignements, éthique et sciences du hadith',
    icon: Icons.auto_stories_outlined,
    iconColor: AppColors.gold,
    iconBackground: AppColors.goldTint,
    children: [
      QuizCategory(
        id: 'hadith_fondements',
        title: 'Grands Enseignements',
        description: 'Foi, intentions, piliers et 40 Hadiths Nawawi',
        icon: Icons.menu_book_outlined,
        iconColor: AppColors.gold,
        iconBackground: AppColors.goldTint,
      ),
      QuizCategory(
        id: 'hadith_comportement',
        title: 'Comportement & Adab',
        description: 'Éthique, fraternité, sincérité et noble caractère',
        icon: Icons.favorite_border_rounded,
        iconColor: AppColors.primary,
        iconBackground: AppColors.primaryTint,
      ),
      QuizCategory(
        id: 'hadith_sciences',
        title: 'Sciences du Hadith',
        description: 'Terminologie, chaîne de transmission et grands imams',
        icon: Icons.history_edu_outlined,
        iconColor: AppColors.gold,
        iconBackground: AppColors.goldTint,
      ),
    ],
  ),
  QuizCategory(
    id: 'fiqh',
    title: 'Quiz Fiqh',
    description: 'Bases, prière malikite et funérailles',
    icon: Icons.balance_outlined,
    iconColor: AppColors.primary,
    iconBackground: AppColors.primaryTint,
    children: [
      QuizCategory(
        id: 'fiqh_general',
        title: 'Fiqh Général',
        description: 'Purification, piliers, jeûne et bases',
        icon: Icons.menu_book_outlined,
        iconColor: AppColors.primary,
        iconBackground: AppColors.primaryTint,
      ),
      QuizCategory(
        id: 'fiqh_priere',
        title: 'La Prière',
        description: 'Sunnas, mérites et rattrapage (rite malikite)',
        icon: Icons.access_time_rounded,
        iconColor: AppColors.gold,
        iconBackground: AppColors.goldTint,
      ),
      QuizCategory(
        id: 'fiqh_funerailles',
        title: 'Les Funérailles',
        description: 'Assistance, lavage, linceul et enterrement',
        icon: Icons.airline_seat_flat_outlined,
        iconColor: AppColors.primary,
        iconBackground: AppColors.primaryTint,
      ),
    ],
  ),
  QuizCategory(
    id: 'sira',
    title: 'Sira du Prophète ﷺ',
    description: 'Période mecquoise, médinoise et grandes étapes',
    icon: Icons.update_outlined,
    iconColor: AppColors.gold,
    iconBackground: AppColors.goldTint,
    children: [
      QuizCategory(
        id: 'sira_mecquoise',
        title: 'Période Mecquoise',
        description: 'De la naissance à l\'Hégire',
        icon: Icons.location_on_outlined,
        iconColor: AppColors.gold,
        iconBackground: AppColors.goldTint,
      ),
      QuizCategory(
        id: 'sira_medinoise',
        title: 'Période Médinoise',
        description: 'Fondation de l\'État musulman et communauté',
        icon: Icons.mosque_outlined,
        iconColor: AppColors.primary,
        iconBackground: AppColors.primaryTint,
      ),
      QuizCategory(
        id: 'sira_evenements',
        title: 'Grandes Étapes & Victoires',
        description: 'Batailles, traités et accomplissement de la mission',
        icon: Icons.shield_outlined,
        iconColor: AppColors.gold,
        iconBackground: AppColors.goldTint,
      ),
    ],
  ),
];

/// Toutes les catégories qui portent des quiz (les groupes sont remplacés par
/// leurs sous-catégories) : sert à la progression et à la synchronisation.
final List<QuizCategory> leafCategories =
    categories.expand((c) => c.leaves).toList(growable: false);

/// ---------------------------------------------------------------------------
/// Niveau de difficulté
/// ---------------------------------------------------------------------------
enum QuizLevel {
  debutant(
    apiValue: 'debutant',
    title: 'Débutant',
    description: 'Les bases pour bien commencer',
    icon: Icons.signal_cellular_alt_1_bar,
    iconColor: AppColors.primary,
    iconBackground: AppColors.primaryTint,
  ),
  intermediaire(
    apiValue: 'intermediaire',
    title: 'Intermédiaire',
    description: 'Approfondissez vos connaissances',
    icon: Icons.signal_cellular_alt_2_bar,
    iconColor: AppColors.gold,
    iconBackground: AppColors.goldTint,
  ),
  avance(
    apiValue: 'avance',
    title: 'Avancé',
    description: 'Des questions pour les plus exigeants',
    icon: Icons.signal_cellular_alt,
    iconColor: Colors.white,
    iconBackground: AppColors.primary,
  );

  final String apiValue;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const QuizLevel({
    required this.apiValue,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });
}

/// ---------------------------------------------------------------------------
/// Modèle d'une question renvoyée par l'API PHP
/// ---------------------------------------------------------------------------
class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int? bonneReponse;

  /// Explication et source de la réponse (révélées par le serveur après la réponse).
  final String? explication;
  final String? source;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.bonneReponse,
    this.explication,
    this.source,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      question: (json['question'] ?? '').toString(),
      options: (json['options'] as List<dynamic>? ?? [])
          .map((opt) => opt.toString())
          .toList(),
      bonneReponse: json['bonneReponse'] != null
          ? (json['bonneReponse'] is int
              ? json['bonneReponse'] as int
              : int.tryParse(json['bonneReponse'].toString()))
          : null,
    );
  }

  /// Copie de la question avec la bonne réponse (révélée par le serveur
  /// APRÈS que le joueur a répondu).
  QuizQuestion withAnswer(int answer, {String? explication, String? source}) {
    return QuizQuestion(
      id: id,
      question: question,
      options: options,
      bonneReponse: answer,
      explication: explication ?? this.explication,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      if (bonneReponse != null) 'bonneReponse': bonneReponse,
    };
  }
}

/// ---------------------------------------------------------------------------
/// Modèles pour la soumission / résultat de quiz
/// ---------------------------------------------------------------------------
class QuizResultItem {
  final int id;
  final int choice;
  final bool correct;
  final int bonneReponse;

  const QuizResultItem({
    required this.id,
    required this.choice,
    required this.correct,
    required this.bonneReponse,
  });

  factory QuizResultItem.fromJson(Map<String, dynamic> json) {
    return QuizResultItem(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      choice: json['choice'] is int ? json['choice'] as int : int.parse(json['choice'].toString()),
      correct: json['correct'] == true,
      bonneReponse: json['bonneReponse'] is int
          ? json['bonneReponse'] as int
          : int.parse(json['bonneReponse'].toString()),
    );
  }
}

/// Réponse de `POST /api/quiz/{categorie}/check` (vérification d'UNE réponse).
class QuizCheckResult {
  final int id;
  final int choice;
  final bool correct;
  final int bonneReponse;
  final String? explication;
  final String? source;

  const QuizCheckResult({
    required this.id,
    required this.choice,
    required this.correct,
    required this.bonneReponse,
    this.explication,
    this.source,
  });

  factory QuizCheckResult.fromJson(Map<String, dynamic> json) {
    return QuizCheckResult(
      id: (json['id'] as num).toInt(),
      choice: (json['choice'] as num).toInt(),
      correct: json['correct'] == true,
      bonneReponse: (json['bonneReponse'] as num).toInt(),
      explication: json['explication'] as String?,
      source: json['source'] as String?,
    );
  }
}

class QuizSubmissionResult {
  final String category;
  final int total;
  final int score;
  final double percentage;
  final List<QuizResultItem> results;

  const QuizSubmissionResult({
    required this.category,
    required this.total,
    required this.score,
    required this.percentage,
    required this.results,
  });

  factory QuizSubmissionResult.fromJson(Map<String, dynamic> json) {
    return QuizSubmissionResult(
      category: (json['category'] ?? '').toString(),
      total: (json['total'] ?? 0) as int,
      score: (json['score'] ?? 0) as int,
      percentage: (json['percentage'] is num) ? (json['percentage'] as num).toDouble() : 0.0,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((item) => QuizResultItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Étape du parcours (Niveau 1 à 5)
/// ---------------------------------------------------------------------------
class QuizStage {
  final int number; // 1 à 5
  final String titleKey;
  final String descKey;
  final IconData icon;

  const QuizStage({
    required this.number,
    required this.titleKey,
    required this.descKey,
    required this.icon,
  });
}

const List<QuizStage> defaultStages = [
  QuizStage(
    number: 1,
    titleKey: 'stage_1_title',
    descKey: 'stage_1_desc',
    icon: Icons.flag_outlined,
  ),
  QuizStage(
    number: 2,
    titleKey: 'stage_2_title',
    descKey: 'stage_2_desc',
    icon: Icons.explore_outlined,
  ),
  QuizStage(
    number: 3,
    titleKey: 'stage_3_title',
    descKey: 'stage_3_desc',
    icon: Icons.lightbulb_outline,
  ),
  QuizStage(
    number: 4,
    titleKey: 'stage_4_title',
    descKey: 'stage_4_desc',
    icon: Icons.auto_awesome_outlined,
  ),
  QuizStage(
    number: 5,
    titleKey: 'stage_5_title',
    descKey: 'stage_5_desc',
    icon: Icons.emoji_events_outlined,
  ),
];

/// ---------------------------------------------------------------------------
/// Options du Quiz personnalisables par l'utilisateur
/// ---------------------------------------------------------------------------
class QuizOptions {
  final bool timerEnabled;
  final int timerSeconds;
  final int questionCount;
  final bool instantFeedback;
  final bool livesEnabled;
  final int livesCount;

  const QuizOptions({
    this.timerEnabled = true,
    this.timerSeconds = 20,
    this.questionCount = 5,
    this.instantFeedback = true,
    this.livesEnabled = false,
    this.livesCount = 3,
  });

  QuizOptions copyWith({
    bool? timerEnabled,
    int? timerSeconds,
    int? questionCount,
    bool? instantFeedback,
    bool? livesEnabled,
    int? livesCount,
  }) {
    return QuizOptions(
      timerEnabled: timerEnabled ?? this.timerEnabled,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      questionCount: questionCount ?? this.questionCount,
      instantFeedback: instantFeedback ?? this.instantFeedback,
      livesEnabled: livesEnabled ?? this.livesEnabled,
      livesCount: livesCount ?? this.livesCount,
    );
  }
}
