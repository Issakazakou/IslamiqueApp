import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_models.dart';
import 'services/auth_service.dart';
import 'stage_progress_manager.dart';

/// 3 niveaux × 5 étapes à terminer (au moins 1 étoile chacune) pour obtenir le certificat
/// d'une catégorie.
const int stagesPerCategory = 15;

/// ---------------------------------------------------------------------------
/// CertificateManager : certificats de réussite.
///
/// Un certificat est délivré pour une catégorie quand TOUTES ses étapes (3 niveaux ×
/// 5 étapes) sont réussies (≥ 1 étoile). Le groupe « Coran » donne aussi son propre
/// certificat quand ses 3 sous-catégories sont terminées.
///
/// La date d'obtention est mémorisée sur l'appareil, sous le préfixe `stage_cert_` :
/// elle est donc effacée avec la progression lors d'une déconnexion.
/// ---------------------------------------------------------------------------
class CertificateManager extends ChangeNotifier {
  static final CertificateManager instance = CertificateManager._();
  CertificateManager._();

  static const String _datePrefix = 'stage_cert_';
  static const String _codePrefix = 'stage_certcode_';
  static const String _nameKey = 'cert_name';

  SharedPreferences? _prefs;
  final List<QuizCategory> _pending = [];

  /// Catégories donnant droit à un certificat : le groupe Coran puis chaque catégorie de quiz.
  static final List<QuizCategory> all = categories
      .expand((c) => c.isGroup ? [c, ...c.children] : [c])
      .toList(growable: false);

  /// À appeler au démarrage, après `StageProgressManager.init()`.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {}
    await refresh();
  }

  // ── Progression vers un certificat ────────────────────────────────

  int completedStages(QuizCategory category) {
    final progress = StageProgressManager.instance;
    var done = 0;
    for (final leaf in category.leaves) {
      for (final level in QuizLevel.values) {
        for (var stage = 1; stage <= 5; stage++) {
          if (progress.getStageStars(leaf.id, level.apiValue, stage) >= 1) done++;
        }
      }
    }
    return done;
  }

  int totalStages(QuizCategory category) =>
      category.leaves.length * stagesPerCategory;

  bool isComplete(QuizCategory category) =>
      completedStages(category) >= totalStages(category);

  // ── Certificats obtenus ───────────────────────────────────────────

  DateTime? earnedOn(QuizCategory category) {
    final raw = _prefs?.getString('$_datePrefix${category.id}');
    return raw == null ? null : DateTime.tryParse(raw);
  }

  bool isEarned(QuizCategory category) => earnedOn(category) != null;

  /// Code de vérification délivré par le serveur (null tant que le certificat n'est pas
  /// synchronisé avec un compte).
  String? codeOf(QuizCategory category) =>
      _prefs?.getString('$_codePrefix${category.id}');

  /// Applique les certificats délivrés par le serveur : sa date et son code font foi.
  Future<void> applyRemote(List<dynamic> remote) async {
    final prefs = _prefs;
    if (prefs == null) return;
    var changed = false;
    for (final item in remote) {
      if (item is! Map) continue;
      final cat = item['cat'];
      final date = item['date'];
      final code = item['code'];
      if (cat is! String || date is! String || code is! String) continue;
      if (!all.any((c) => c.id == cat) || DateTime.tryParse(date) == null) continue;
      if (prefs.getString('$_datePrefix$cat') != date) {
        await prefs.setString('$_datePrefix$cat', date);
        changed = true;
      }
      if (prefs.getString('$_codePrefix$cat') != code) {
        await prefs.setString('$_codePrefix$cat', code);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  int get earnedCount => all.where(isEarned).length;

  /// Délivre les certificats des catégories terminées et renvoie ceux obtenus à l'instant.
  /// [announce] : les mémorise pour l'écran de résultat (voir [takePending]).
  Future<List<QuizCategory>> refresh({bool announce = false}) async {
    final prefs = _prefs;
    if (prefs == null) return const [];
    final fresh = <QuizCategory>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final category in all) {
      if (isComplete(category) && prefs.getString('$_datePrefix${category.id}') == null) {
        await prefs.setString('$_datePrefix${category.id}', today.toIso8601String());
        fresh.add(category);
      }
    }
    if (announce) _pending.addAll(fresh);
    if (fresh.isNotEmpty) notifyListeners();
    return fresh;
  }

  /// Certificats obtenus depuis le dernier appel (affichés une seule fois à l'écran de résultat).
  List<QuizCategory> takePending() {
    final out = List<QuizCategory>.of(_pending);
    _pending.clear();
    return out;
  }

  // ── Nom affiché sur le certificat ─────────────────────────────────

  /// Nom choisi par l'utilisateur, sinon nom de son compte, sinon vide.
  String get name {
    final custom = _prefs?.getString(_nameKey)?.trim() ?? '';
    if (custom.isNotEmpty) return custom;
    return AuthService.instance.user?.name.trim() ?? '';
  }

  Future<void> setName(String value) async {
    await _prefs?.setString(_nameKey, value.trim());
    notifyListeners();
  }
}
