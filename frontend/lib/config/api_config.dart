import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration de l'accès au backend PHP.
///
/// **Production** : l'URL est injectée à la compilation, en HTTPS :
/// ```
/// flutter build apk --dart-define=API_BASE_URL=https://quiz.mondomaine.com
/// ```
///
/// **Développement** (sans `API_BASE_URL`) :
/// - Web / Windows / macOS / Linux / iOS simulateur : `http://127.0.0.1:8000`
/// - Émulateur Android                              : `http://10.0.2.2:8000`
///
/// Pour un **téléphone physique** en développement, l'utilisateur renseigne
/// l'adresse du PC dans les réglages (ex. `192.168.1.20:8000`). Cette valeur
/// est mémorisée via [save] et rechargée au démarrage par [load].
///
/// Le HTTP en clair n'est autorisé par le système qu'en debug/profile (Android)
/// et sur le réseau local (iOS). Une release doit donc utiliser HTTPS.
class ApiConfig {
  ApiConfig._();

  /// Clé SharedPreferences où est stockée l'URL personnalisée.
  static const String _prefsKey = 'server_base_url';

  /// URL du backend injectée à la compilation (`--dart-define=API_BASE_URL=...`).
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// URL personnalisée saisie dans les réglages.
  ///
  /// `null` (valeur par défaut) → on utilise [defaultBaseUrl].
  static String? customBaseUrl;

  /// URL par défaut : celle injectée à la compilation, sinon une adresse
  /// de développement locale selon la plateforme.
  static String get defaultBaseUrl {
    if (_envBaseUrl.trim().isNotEmpty) {
      return _normalize(_envBaseUrl);
    }
    if (kIsWeb) return 'http://127.0.0.1:8000';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000' // émulateur Android → PC hôte
        : 'http://127.0.0.1:8000';
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

  /// Ajoute le schéma si absent et retire les `/` de fin.
  ///
  /// Sans schéma saisi : `http://` pour une adresse locale/privée (PC, réseau
  /// domestique, Tailscale), `https://` pour tout le reste.
  static String _normalize(String url) {
    var u = url.trim();
    if (u.isEmpty) {
      return defaultBaseUrl;
    }
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      final host = u.split('/').first.split(':').first;
      u = '${_isLocalHost(host) ? 'http' : 'https'}://$u';
    }
    return u.replaceAll(RegExp(r'/+$'), '');
  }

  /// Vrai pour `localhost`, les adresses privées (10.x, 172.16-31.x, 192.168.x),
  /// le CGNAT/Tailscale (100.64-127.x), `10.0.2.2`, `*.local` et les noms sans point.
  static bool _isLocalHost(String host) {
    final h = host.toLowerCase();
    if (h == 'localhost' || h.endsWith('.local') || !h.contains('.')) return true;
    final parts = h.split('.');
    if (parts.length != 4) return false;
    final n = parts.map(int.tryParse).toList();
    if (n.any((x) => x == null)) return false;
    final a = n[0]!, b = n[1]!;
    return a == 127 ||
        a == 10 ||
        (a == 192 && b == 168) ||
        (a == 172 && b >= 16 && b <= 31) ||
        (a == 100 && b >= 64 && b <= 127);
  }

  /// Vrai si [url] utilise `http://` vers une adresse **non locale** :
  /// les données (réponses du quiz) circuleraient alors en clair sur Internet.
  static bool isInsecure(String url) {
    final u = _normalize(url);
    if (!u.startsWith('http://')) return false;
    final uri = Uri.tryParse(u);
    return uri == null || !_isLocalHost(uri.host);
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
