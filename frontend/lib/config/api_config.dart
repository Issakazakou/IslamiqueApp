import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration de l'accès au backend.
///
/// Priorité de résolution : URL saisie dans les réglages, puis
/// `--dart-define=API_BASE_URL=...`, puis URL locale adaptée à la plateforme.
///
/// Exemples :
/// `flutter run --dart-define=API_BASE_URL=https://api.exemple.com`
/// `flutter build web --dart-define=API_BASE_URL=https://api.exemple.com`
class ApiConfig {
  ApiConfig._();

  /// Clé SharedPreferences où est stockée l'URL personnalisée.
  static const String _prefsKey = 'server_base_url';

  /// URL injectée au moment de la compilation ou du lancement.
  static const String _compileTimeBaseUrl =
      String.fromEnvironment('API_BASE_URL');

  /// URL personnalisée saisie dans les réglages.
  ///
  /// `null` (valeur par défaut) → on utilise [defaultBaseUrl].
  static String? customBaseUrl;

  /// URL locale par défaut selon la plateforme.
  ///
  /// Sur le Web, l'API est servie depuis la même origine. Sur Android,
  /// `10.0.2.2` désigne la machine hôte depuis l'émulateur. Les autres
  /// plateformes utilisent localhost.
  static String get defaultBaseUrl {
    if (_compileTimeBaseUrl.trim().isNotEmpty) {
      return _normalize(_compileTimeBaseUrl);
    }
    if (kIsWeb) {
      return Uri.base.origin;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  /// URL actuellement utilisée (personnalisée si définie, sinon par défaut).
  static String get baseUrl {
    final custom = customBaseUrl?.trim() ?? '';
    if (custom.isNotEmpty) {
      return _normalize(custom);
    }
    return defaultBaseUrl;
  }

  /// Charge l'URL mémorisée. À appeler une seule fois au démarrage de l'app.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey)?.trim() ?? '';
      customBaseUrl = saved.isEmpty ? null : saved;
    } catch (_) {
      customBaseUrl = null;
    }
  }

  /// Enregistre (ou efface si [url] est vide) l'URL personnalisée et la
  /// mémorise pour les prochains lancements.
  static Future<void> save(String? url) async {
    final value = url?.trim() ?? '';
    customBaseUrl = value.isEmpty ? null : value;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (customBaseUrl == null) {
        await prefs.remove(_prefsKey);
      } else {
        await prefs.setString(_prefsKey, customBaseUrl!);
      }
    } catch (_) {
      // Stockage optionnel : en cas d'échec on garde la valeur en mémoire.
    }
  }

  /// Ajoute `http://` si absent et retire les `/` de fin.
  static String _normalize(String url) {
    var u = url.trim();
    if (u.isEmpty) {
      return defaultBaseUrl;
    }
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      u = 'http://$u';
    }
    return u.replaceAll(RegExp(r'/+$'), '');
  }

  /// Test de connexion au backend PHP (`/api/health`).
  ///
  /// [urlToTest] : URL à tester. Si `null` ou vide, on teste [baseUrl].
  static Future<bool> checkHealth([String? urlToTest]) async {
    final provided = urlToTest?.trim() ?? '';
    final target = _normalize(provided.isNotEmpty ? provided : baseUrl);
    final uri = Uri.parse('$target/api/health');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        return decoded is Map && decoded['status'] == 'ok';
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
