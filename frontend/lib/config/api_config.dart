import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration de l'accès au backend PHP.
///
/// L'URL est déterminée automatiquement selon la plateforme :
/// - Web / Windows / macOS / Linux : `http://127.0.0.1:8000`
/// - Émulateur Android             : `http://10.0.2.2:8000`
///
/// Pour un **téléphone physique**, l'utilisateur renseigne l'IP du PC
/// (ex. `http://192.168.1.20:8000`) dans les réglages. Cette valeur est
/// mémorisée via [save] et rechargée au démarrage par [load].
class ApiConfig {
  ApiConfig._();

  /// Clé SharedPreferences où est stockée l'URL personnalisée.
  static const String _prefsKey = 'server_base_url';

  /// Adresse IPv4 du serveur (PC hôte ou réseau)
  static const String targetIp = '100.109.88.197';

  /// URL par défaut configurée pour accès direct PC et réseau
  static const String defaultServerUrl = 'http://100.109.88.197:8000';

  /// URL personnalisée saisie dans les réglages.
  ///
  /// `null` (valeur par défaut) → on utilise [defaultBaseUrl].
  static String? customBaseUrl;

  /// URL par défaut selon la plateforme.
  /// L'IP `100.109.88.197` est utilisée en priorité pour permettre l'accès
  /// direct depuis le PC, le Web, l'émulateur et les smartphones sur le réseau.
  static String get defaultBaseUrl => defaultServerUrl;

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
