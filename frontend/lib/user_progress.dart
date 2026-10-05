import 'package:flutter/foundation.dart';

/// ---------------------------------------------------------------------------
/// UserProgress : progression locale de l'utilisateur
/// Stocké en mémoire (à persister avec SharedPreferences en prod)
/// ---------------------------------------------------------------------------
class UserProgress extends ChangeNotifier {
  static final UserProgress instance = UserProgress._();
  UserProgress._();

  // ── Compteurs de sessions ──────────────────────────────────────
  int _totalQuizDone     = 0;
  int _totalQuestions    = 0;
  int _totalCorrect      = 0;
  int _streak            = 0;         // jours consécutifs
  int _bestStreak        = 0;
  int _dailyQuizCount    = 0;         // quizzes faits aujourd'hui
  DateTime? _lastPlayDate;

  // ── Scores par catégorie : { 'coran': {'done': 5, 'correct': 40} } ──
  final Map<String, Map<String, int>> _categoryStats = {
    'coran':  {'done': 0, 'correct': 0, 'total': 0},
    'hadith': {'done': 0, 'correct': 0, 'total': 0},
    'fiqh':   {'done': 0, 'correct': 0, 'total': 0},
    'sira':   {'done': 0, 'correct': 0, 'total': 0},
  };

  // ── Badges débloqués ──────────────────────────────────────────
  final Set<String> _badges = {};

  // ── Getters ──────────────────────────────────────────────────
  int get totalQuizDone   => _totalQuizDone;
  int get totalQuestions  => _totalQuestions;
  int get totalCorrect    => _totalCorrect;
  int get streak          => _streak;
  int get bestStreak      => _bestStreak;
  int get dailyQuizCount  => _dailyQuizCount;
  Set<String> get badges  => Set.unmodifiable(_badges);

  double get globalAccuracy =>
      _totalQuestions == 0 ? 0 : (_totalCorrect / _totalQuestions * 100);

  Map<String, Map<String, int>> get categoryStats =>
      Map.unmodifiable(_categoryStats);

  // ── Méthodes ─────────────────────────────────────────────────

  /// Appelé à la fin de chaque quiz
  void recordQuizResult({
    required String categoryId,
    required int correct,
    required int total,
  }) {
    _totalQuizDone++;
    _totalQuestions += total;
    _totalCorrect   += correct;

    final cat = _categoryStats[categoryId];
    if (cat != null) {
      cat['done']    = (cat['done'] ?? 0) + 1;
      cat['correct'] = (cat['correct'] ?? 0) + correct;
      cat['total']   = (cat['total'] ?? 0) + total;
    }

    // Mise à jour du streak journalier
    final today = DateTime.now();
    if (_lastPlayDate == null) {
      _streak = 1;
    } else {
      final diff = today.difference(_lastPlayDate!).inDays;
      if (diff == 0) {
        // Même jour, pas de changement de streak
      } else if (diff == 1) {
        _streak++;
      } else {
        _streak = 1;
      }
    }
    _lastPlayDate = today;
    _dailyQuizCount++;
    if (_streak > _bestStreak) _bestStreak = _streak;

    // Vérification des badges
    _checkBadges();

    notifyListeners();
  }

  void _checkBadges() {
    if (_totalQuizDone >= 1)   _badges.add('first_quiz');
    if (_totalQuizDone >= 10)  _badges.add('ten_quizzes');
    if (_totalQuizDone >= 50)  _badges.add('fifty_quizzes');
    if (_streak >= 3)          _badges.add('streak_3');
    if (_streak >= 7)          _badges.add('streak_7');
    if (_streak >= 30)         _badges.add('streak_30');
    if (globalAccuracy >= 80 && _totalQuestions >= 20) _badges.add('ace');
    if (globalAccuracy >= 90 && _totalQuestions >= 50) _badges.add('master');
    // Badge Coran spécifique
    final coranDone = _categoryStats['coran']?['done'] ?? 0;
    if (coranDone >= 5) _badges.add('coran_explorer');
  }

  void reset() {
    _totalQuizDone  = 0;
    _totalQuestions = 0;
    _totalCorrect   = 0;
    _streak         = 0;
    _bestStreak     = 0;
    _dailyQuizCount = 0;
    _lastPlayDate   = null;
    for (final cat in _categoryStats.values) {
      cat['done']    = 0;
      cat['correct'] = 0;
      cat['total']   = 0;
    }
    _badges.clear();
    notifyListeners();
  }
}

/// ---------------------------------------------------------------------------
/// PremiumManager : gestion du statut Premium (freemium)
/// ---------------------------------------------------------------------------
class PremiumManager extends ChangeNotifier {
  static final PremiumManager instance = PremiumManager._();
  PremiumManager._();

  bool _isPremium = false;

  bool get isPremium => _isPremium;

  // Limites pour les utilisateurs Free
  static const int freeQuizzesPerDay = 5;
  static const int freeLevelsUnlocked = 1; // seulement Débutant

  bool get canPlayToday {
    if (_isPremium) return true;
    return UserProgress.instance.dailyQuizCount < freeQuizzesPerDay;
  }

  int get remainingFreeQuizzes {
    if (_isPremium) return 999;
    return (freeQuizzesPerDay - UserProgress.instance.dailyQuizCount)
        .clamp(0, freeQuizzesPerDay);
  }

  bool isLevelUnlocked(int levelIndex) {
    if (_isPremium) return true;
    return levelIndex < freeLevelsUnlocked;
  }

  /// Simule un achat (en prod : in_app_purchase)
  void unlockPremium() {
    _isPremium = true;
    notifyListeners();
  }

  void revokePremium() {
    _isPremium = false;
    notifyListeners();
  }
}
