import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/auth_service.dart';

/// ---------------------------------------------------------------------------
/// UserProgress : progression locale de l'utilisateur
/// Mémorisée sur l'appareil (SharedPreferences) : série de jours, scores, badges.
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

  // ── Scores par catégorie : { 'coran_tajwid': {'done': 5, 'correct': 40} } ──
  final Map<String, Map<String, int>> _categoryStats = {
    'coran_mediter':        {'done': 0, 'correct': 0, 'total': 0},
    'coran_tajwid':         {'done': 0, 'correct': 0, 'total': 0},
    'coran_culture':        {'done': 0, 'correct': 0, 'total': 0},
    'hadith_fondements':    {'done': 0, 'correct': 0, 'total': 0},
    'hadith_comportement':  {'done': 0, 'correct': 0, 'total': 0},
    'hadith_sciences':      {'done': 0, 'correct': 0, 'total': 0},
    'hadith':               {'done': 0, 'correct': 0, 'total': 0},
    'fiqh_general':         {'done': 0, 'correct': 0, 'total': 0},
    'fiqh_priere':          {'done': 0, 'correct': 0, 'total': 0},
    'fiqh_funerailles':     {'done': 0, 'correct': 0, 'total': 0},
    'fiqh':                 {'done': 0, 'correct': 0, 'total': 0},
    'sira_mecquoise':       {'done': 0, 'correct': 0, 'total': 0},
    'sira_medinoise':       {'done': 0, 'correct': 0, 'total': 0},
    'sira_evenements':      {'done': 0, 'correct': 0, 'total': 0},
    'sira':                 {'done': 0, 'correct': 0, 'total': 0},
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

    final cat = _categoryStats.putIfAbsent(
      categoryId,
      () => {'done': 0, 'correct': 0, 'total': 0},
    );
    cat['done']    = (cat['done'] ?? 0) + 1;
    cat['correct'] = (cat['correct'] ?? 0) + correct;
    cat['total']   = (cat['total'] ?? 0) + total;

    // Mise à jour de la série de jours (comparaison par jour calendaire).
    final today = _dayOf(DateTime.now());
    final last = _lastPlayDate == null ? null : _dayOf(_lastPlayDate!);
    final diff = last == null ? null : today.difference(last).inDays;
    if (diff == null) {
      _streak = 1;
    } else if (diff == 1) {
      _streak++;
    } else if (diff != 0) {
      _streak = 1; // série interrompue
    }
    if (diff != 0) _dailyQuizCount = 0; // nouveau jour : le compteur repart de zéro
    _lastPlayDate = today;
    _dailyQuizCount++;
    if (_streak > _bestStreak) _bestStreak = _streak;

    // Vérification des badges
    _checkBadges();

    notifyListeners();
    _save();
    // Si l'utilisateur est connecté, ses statistiques sont envoyées à son compte.
    AuthService.instance.scheduleSync();
  }

  /// Jour calendaire en UTC (insensible aux changements d'heure).
  static DateTime _dayOf(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  /// Série affichée : 0 si le dernier quiz date d'avant-hier ou plus.
  int get activeStreak {
    final last = _lastPlayDate;
    if (last == null) return 0;
    final diff = _dayOf(DateTime.now()).difference(_dayOf(last)).inDays;
    return diff <= 1 ? _streak : 0;
  }

  /// Vrai si un quiz a déjà été terminé aujourd'hui.
  bool get playedToday {
    final last = _lastPlayDate;
    return last != null && _dayOf(DateTime.now()) == _dayOf(last);
  }

  // ── Synchronisation avec le compte ───────────────────────────────

  static String _dayString(DateTime d) {
    final day = _dayOf(d);
    return '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }

  /// Statistiques au format de l'API (`PUT /api/progress`).
  Map<String, dynamic> exportStats() => {
        'quizDone': _totalQuizDone,
        'questions': _totalQuestions,
        'correct': _totalCorrect,
        'streak': _streak,
        'bestStreak': _bestStreak,
        'lastPlay': _lastPlayDate == null ? null : _dayString(_lastPlayDate!),
        'badges': _badges.toList()..sort(),
        'categories': {
          for (final entry in _categoryStats.entries)
            entry.key: Map<String, int>.from(entry.value),
        },
      };

  /// Fusionne les statistiques du compte : totaux = valeur la plus haute, série = celle du
  /// dernier jour joué, badges réunis.
  void mergeStats(Map<String, dynamic> remote) {
    int intOf(Object? v) => v is int && v >= 0 ? v : 0;

    _totalQuizDone = math.max(_totalQuizDone, intOf(remote['quizDone']));
    _totalQuestions = math.max(_totalQuestions, intOf(remote['questions']));
    _totalCorrect = math.max(_totalCorrect, intOf(remote['correct']));

    final lastPlay = remote['lastPlay'];
    final remoteDay =
        lastPlay is String ? DateTime.tryParse('${lastPlay}T00:00:00Z') : null;
    final localDay = _lastPlayDate == null ? null : _dayOf(_lastPlayDate!);
    final remoteStreak = intOf(remote['streak']);
    if (remoteDay != null && (localDay == null || remoteDay.isAfter(localDay))) {
      _lastPlayDate = remoteDay;
      _streak = remoteStreak;
    } else if (remoteDay != null && localDay == remoteDay) {
      _streak = math.max(_streak, remoteStreak);
    }
    _bestStreak = math.max(math.max(_bestStreak, intOf(remote['bestStreak'])), _streak);

    final badges = remote['badges'];
    if (badges is List) {
      for (final badge in badges) {
        if (badge is String) _badges.add(badge);
      }
    }
    final categories = remote['categories'];
    if (categories is Map) {
      categories.forEach((id, value) {
        final target = _categoryStats[id];
        if (target == null || value is! Map) return;
        for (final field in ['done', 'correct', 'total']) {
          target[field] = math.max(target[field] ?? 0, intOf(value[field]));
        }
      });
    }
    notifyListeners();
    _save();
  }

  static const String _prefsKey = 'user_progress_v1';

  /// Restaure les statistiques mémorisées. À appeler au démarrage.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final data = json.decode(raw) as Map<String, dynamic>;
      _totalQuizDone = (data['quizDone'] as num?)?.toInt() ?? 0;
      _totalQuestions = (data['questions'] as num?)?.toInt() ?? 0;
      _totalCorrect = (data['correct'] as num?)?.toInt() ?? 0;
      _streak = (data['streak'] as num?)?.toInt() ?? 0;
      _bestStreak = (data['bestStreak'] as num?)?.toInt() ?? 0;
      _dailyQuizCount = (data['daily'] as num?)?.toInt() ?? 0;
      final last = data['lastPlay'] as String?;
      _lastPlayDate = last == null ? null : DateTime.tryParse(last);
      _badges
        ..clear()
        ..addAll((data['badges'] as List<dynamic>? ?? []).map((b) => b.toString()));
      final stats = data['categories'] as Map<String, dynamic>? ?? {};
      stats.forEach((id, value) {
        final target = _categoryStats[id];
        if (target == null || value is! Map) return;
        for (final key in ['done', 'correct', 'total']) {
          target[key] = (value[key] as num?)?.toInt() ?? 0;
        }
      });
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        json.encode({
          'quizDone': _totalQuizDone,
          'questions': _totalQuestions,
          'correct': _totalCorrect,
          'streak': _streak,
          'bestStreak': _bestStreak,
          'daily': _dailyQuizCount,
          'lastPlay': _lastPlayDate?.toIso8601String(),
          'badges': _badges.toList(),
          'categories': _categoryStats,
        }),
      );
    } catch (_) {}
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
    final coranDone = (_categoryStats['coran_mediter']?['done'] ?? 0) +
        (_categoryStats['coran_tajwid']?['done'] ?? 0) +
        (_categoryStats['coran_culture']?['done'] ?? 0);
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
    _save();
  }
}

/// ---------------------------------------------------------------------------
/// PremiumManager : gestion du statut Premium (freemium)
/// ---------------------------------------------------------------------------
class PremiumManager extends ChangeNotifier {
  static final PremiumManager instance = PremiumManager._();
  PremiumManager._();

  static const String _prefKey = 'app_user_is_premium';
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  // Limites pour les utilisateurs Free
  static const int freeQuizzesPerDay = 5;
  static const int freeLevelsUnlocked = 1; // seulement Débutant (index 0)

  /// Charge le statut Premium sauvegardé
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_prefKey) ?? false;
      notifyListeners();
    } catch (_) {}
  }

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

  /// Active l'accès Premium (simulé ou via achat in-app)
  Future<void> unlockPremium() async {
    _isPremium = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, true);
    } catch (_) {}
  }

  /// Révoque le statut Premium (ex: test ou fin d'abonnement)
  Future<void> revokePremium() async {
    _isPremium = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, false);
    } catch (_) {}
  }
}
