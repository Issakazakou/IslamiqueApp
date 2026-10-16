import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../certificates.dart';
import '../config/api_config.dart';
import '../stage_progress_manager.dart';
import '../user_progress.dart';

/// Utilisateur connecté.
class AuthUser {
  final String id;
  final String email;
  final String name;

  const AuthUser({required this.id, required this.email, required this.name});

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: (json['id'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'name': name};
}

/// Erreur de compte : [message] vient du serveur (en français) ;
/// [network] = le serveur n'a pas pu être joint.
class AuthException implements Exception {
  final String message;
  final int status;
  final bool network;

  const AuthException(this.message, {this.status = 0, this.network = false});

  @override
  String toString() => message;
}

/// ---------------------------------------------------------------------------
/// AuthService : inscription, connexion et synchronisation de la progression.
///
/// - Le jeton de connexion est mémorisé sur l'appareil (SharedPreferences).
/// - La progression (étoiles par étape) est fusionnée avec celle du compte :
///   on garde toujours le meilleur résultat, sur l'appareil comme sur le serveur.
/// - Utilisable sans compte : la progression reste alors locale.
/// ---------------------------------------------------------------------------
class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._();
  AuthService._();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const Duration _timeout = Duration(seconds: 10);

  http.Client _client = http.Client();

  /// Pour les tests.
  @visibleForTesting
  set client(http.Client value) => _client = value;

  String? _token;
  AuthUser? _user;
  Timer? _debounce;
  bool _syncing = false;
  bool _syncAgain = false;
  DateTime? _lastSync;

  bool get isLoggedIn => _token != null && _user != null;
  AuthUser? get user => _user;

  /// Dernière synchronisation réussie avec le compte (null : pas encore).
  DateTime? get lastSync => _lastSync;

  /// À appeler au démarrage : restaure la session mémorisée.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final rawUser = prefs.getString(_userKey);
      if (token != null && rawUser != null) {
        _user = AuthUser.fromJson(json.decode(rawUser) as Map<String, dynamic>);
        _token = token;
        notifyListeners();
      }
    } catch (_) {}
    if (isLoggedIn) {
      unawaited(syncProgress().catchError((Object _) {}));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _authenticate('/api/auth/register', {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      });

  Future<void> login({required String email, required String password}) =>
      _authenticate('/api/auth/login', {
        'email': email.trim(),
        'password': password,
      });

  Future<void> _authenticate(String path, Map<String, dynamic> body) async {
    final data = await _send('POST', path, body);
    final token = data['token'];
    final user = data['user'];
    if (token is! String || user is! Map) {
      throw const AuthException('Réponse inattendue du serveur.');
    }
    _token = token;
    _user = AuthUser.fromJson(Map<String, dynamic>.from(user));
    await _persist();
    notifyListeners();
    // La connexion reste valable même si la synchronisation échoue.
    try {
      await syncProgress();
    } catch (_) {}
  }

  /// Envoie la progression locale au serveur, reçoit la progression fusionnée
  /// et l'applique sur l'appareil.
  Future<void> syncProgress() async {
    if (_token == null) return;
    if (_syncing) {
      _syncAgain = true; // une synchro est en cours : on en refera une juste après
      return;
    }
    _syncing = true;
    try {
      do {
        _syncAgain = false;
        await _syncOnce();
      } while (_syncAgain);
    } finally {
      _syncing = false;
    }
  }

  Future<void> _syncOnce() async {
    try {
      final data = await _send(
        'PUT',
        '/api/progress',
        {
          'progress': StageProgressManager.instance.exportProgress(),
          'stats': UserProgress.instance.exportStats(),
        },
        auth: true,
      );
      final remote = data['progress'];
      if (remote is List) {
        await StageProgressManager.instance.mergeProgress(remote);
      }
      final stats = data['stats'];
      if (stats is Map) {
        UserProgress.instance.mergeStats(Map<String, dynamic>.from(stats));
      }
      // Les certificats sont délivrés par le serveur (date et code de vérification).
      final certificates = data['certificates'];
      if (certificates is List) {
        await CertificateManager.instance.applyRemote(certificates);
      }
      _lastSync = DateTime.now();
      notifyListeners();
    } on AuthException catch (e) {
      if (e.status == 401) await _clearSession(); // jeton expiré ou révoqué
      rethrow;
    }
  }

  /// Change le nom du compte.
  Future<void> updateName(String name) async {
    try {
      final data = await _send('PUT', '/api/profile', {'name': name.trim()}, auth: true);
      final user = data['user'];
      if (user is Map) {
        _user = AuthUser.fromJson(Map<String, dynamic>.from(user));
        await _persist();
        notifyListeners();
      }
    } on AuthException catch (e) {
      if (e.status == 401) await _clearSession();
      rethrow;
    }
  }

  /// Synchronisation différée (appelée après chaque étape terminée).
  void scheduleSync() {
    if (!isLoggedIn) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      unawaited(syncProgress().catchError((Object _) {}));
    });
  }

  /// Déconnexion : la progression est d'abord envoyée au compte, puis effacée
  /// de l'appareil pour qu'elle ne se mélange pas avec un autre compte.
  /// Lève une [AuthException] si la progression n'a pas pu être sauvegardée.
  Future<void> logout() async {
    if (_token != null) {
      await syncProgress();
      try {
        await _send('POST', '/api/auth/logout', null, auth: true);
      } catch (_) {}
    }
    await _clearSession();
    await StageProgressManager.instance.clearProgress();
    UserProgress.instance.reset();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token ?? '');
      await prefs.setString(_userKey, json.encode(_user?.toJson() ?? {}));
    } catch (_) {}
  }

  Future<void> _clearSession() async {
    _debounce?.cancel();
    _token = null;
    _user = null;
    _lastSync = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (_) {}
    notifyListeners();
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path,
    Map<String, dynamic>? body, {
    bool auth = false,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      if (auth && _token != null) 'Authorization': 'Bearer $_token',
    };
    final encoded = body == null ? null : json.encode(body);

    final http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers).timeout(_timeout);
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: encoded)
              .timeout(_timeout);
        default:
          response = await _client
              .post(uri, headers: headers, body: encoded)
              .timeout(_timeout);
      }
    } catch (_) {
      throw const AuthException('Serveur injoignable.', network: true);
    }

    Map<String, dynamic> decoded = {};
    try {
      final raw = json.decode(utf8.decode(response.bodyBytes));
      if (raw is Map) decoded = Map<String, dynamic>.from(raw);
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw AuthException(
      (decoded['error'] ?? 'Erreur serveur (${response.statusCode}).').toString(),
      status: response.statusCode,
    );
  }
}
