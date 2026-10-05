import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_models.dart';

/// ---------------------------------------------------------------------------
/// StageProgressManager : Gère et persiste la progression du parcours (étapes 1 à 5)
/// pour chaque catégorie et chaque niveau de difficulté.
/// ---------------------------------------------------------------------------
class StageProgressManager extends ChangeNotifier {
  static final StageProgressManager instance = StageProgressManager._();
  StageProgressManager._();

  SharedPreferences? _prefs;
  bool _initialized = false;

  // Options actuelles du joueur
  QuizOptions _options = const QuizOptions();
  QuizOptions get options => _options;

  /// Initialisation asynchrone (appelée dans main)
  Future<void> init() async {
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadOptions();
      _initialized = true;
      notifyListeners();
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  // Gestion des Options
  // -------------------------------------------------------------------------

  void _loadOptions() {
    if (_prefs == null) return;
    final timerEnabled = _prefs!.getBool('opt_timer_enabled') ?? true;
    final timerSeconds = _prefs!.getInt('opt_timer_seconds') ?? 20;
    final questionCount = _prefs!.getInt('opt_question_count') ?? 5;
    final instantFeedback = _prefs!.getBool('opt_instant_feedback') ?? true;
    final livesEnabled = _prefs!.getBool('opt_lives_enabled') ?? false;
    final livesCount = _prefs!.getInt('opt_lives_count') ?? 3;

    _options = QuizOptions(
      timerEnabled: timerEnabled,
      timerSeconds: timerSeconds,
      questionCount: questionCount,
      instantFeedback: instantFeedback,
      livesEnabled: livesEnabled,
      livesCount: livesCount,
    );
  }

  Future<void> updateOptions(QuizOptions newOptions) async {
    _options = newOptions;
    notifyListeners();
    if (_prefs == null) return;
    await _prefs!.setBool('opt_timer_enabled', newOptions.timerEnabled);
    await _prefs!.setInt('opt_timer_seconds', newOptions.timerSeconds);
    await _prefs!.setInt('opt_question_count', newOptions.questionCount);
    await _prefs!.setBool('opt_instant_feedback', newOptions.instantFeedback);
    await _prefs!.setBool('opt_lives_enabled', newOptions.livesEnabled);
    await _prefs!.setInt('opt_lives_count', newOptions.livesCount);
  }

  // -------------------------------------------------------------------------
  // Clés de persistance
  // -------------------------------------------------------------------------

  String _starKey(String cat, String lvl, int stage) =>
      'stage_${cat}_${lvl}_${stage}_stars';

  String _scoreKey(String cat, String lvl, int stage) =>
      'stage_${cat}_${lvl}_${stage}_score';

  String _totalKey(String cat, String lvl, int stage) =>
      'stage_${cat}_${lvl}_${stage}_total';

  // -------------------------------------------------------------------------
  // Lecture de la progression
  // -------------------------------------------------------------------------

  /// Vérifie si l'étape est débloquée.
  /// L'étape 1 est toujours débloquée.
  /// L'étape N (2..5) est débloquée si l'étape N-1 a obtenu au moins 1 étoile.
  bool isStageUnlocked(String categoryId, String levelValue, int stageNumber) {
    if (stageNumber <= 1) return true;
    final prevStars = getStageStars(categoryId, levelValue, stageNumber - 1);
    return prevStars >= 1;
  }

  /// Étoiles obtenues pour une étape (0 à 3)
  int getStageStars(String categoryId, String levelValue, int stageNumber) {
    return _prefs?.getInt(_starKey(categoryId, levelValue, stageNumber)) ?? 0;
  }

  /// Meilleur score obtenu
  int getStageHighScore(String categoryId, String levelValue, int stageNumber) {
    return _prefs?.getInt(_scoreKey(categoryId, levelValue, stageNumber)) ?? 0;
  }

  /// Total de questions de l'étape
  int getStageHighTotal(String categoryId, String levelValue, int stageNumber) {
    return _prefs?.getInt(_totalKey(categoryId, levelValue, stageNumber)) ?? 0;
  }

  /// Total d'étoiles cumulées pour une catégorie et un niveau (sur 15 max)
  int getTotalStars(String categoryId, String levelValue) {
    int total = 0;
    for (int i = 1; i <= 5; i++) {
      total += getStageStars(categoryId, levelValue, i);
    }
    return total;
  }

  /// Nombre d'étapes réussies (au moins 1 étoile) pour une catégorie et un niveau
  int getCompletedStagesCount(String categoryId, String levelValue) {
    int count = 0;
    for (int i = 1; i <= 5; i++) {
      if (getStageStars(categoryId, levelValue, i) >= 1) {
        count++;
      }
    }
    return count;
  }

  // -------------------------------------------------------------------------
  // Enregistrement des résultats
  // -------------------------------------------------------------------------

  /// Enregistre le résultat d'une étape et renvoie vrai si une nouvelle étape est débloquée
  Future<bool> recordStageResult({
    required String categoryId,
    required String levelValue,
    required int stageNumber,
    required int score,
    required int total,
  }) async {
    final pct = total > 0 ? (score / total) * 100 : 0.0;
    int stars = 0;
    if (pct >= 90) {
      stars = 3;
    } else if (pct >= 70) {
      stars = 2;
    } else if (pct >= 50) {
      stars = 1;
    }

    final prevStars = getStageStars(categoryId, levelValue, stageNumber);
    final prevHighScore = getStageHighScore(categoryId, levelValue, stageNumber);

    bool newlyUnlocked = false;

    // Si on a au moins 1 étoile et que l'étape suivante était bloquée
    if (stars >= 1 && stageNumber < 5) {
      final nextUnlockedBefore = isStageUnlocked(categoryId, levelValue, stageNumber + 1);
      if (!nextUnlockedBefore) {
        newlyUnlocked = true;
      }
    }

    // Sauvegarde si amélioration
    if (_prefs != null) {
      if (stars > prevStars) {
        await _prefs!.setInt(_starKey(categoryId, levelValue, stageNumber), stars);
      }
      if (score > prevHighScore) {
        await _prefs!.setInt(_scoreKey(categoryId, levelValue, stageNumber), score);
        await _prefs!.setInt(_totalKey(categoryId, levelValue, stageNumber), total);
      }
    }

    notifyListeners();
    return newlyUnlocked;
  }
}
