import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mon_application/services/auth_service.dart';
import 'package:mon_application/stage_progress_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(
      json.encode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manager = StageProgressManager.instance;
  final token = 'a' * 64;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await manager.init();
  });

  setUp(() async {
    await manager.clearProgress();
  });

  group('Fusion de la progression', () {
    test('garde toujours le meilleur résultat', () async {
      await manager.recordStageResult(
        categoryId: 'coran_tajwid',
        levelValue: 'debutant',
        stageNumber: 1,
        score: 3,
        total: 5,
      );
      expect(manager.getStageStars('coran_tajwid', 'debutant', 1), 1);

      await manager.mergeProgress([
        {'cat': 'coran_tajwid', 'lvl': 'debutant', 'stage': 1, 'stars': 3, 'score': 5, 'total': 5},
        {'cat': 'coran_tajwid', 'lvl': 'debutant', 'stage': 2, 'stars': 2, 'score': 4, 'total': 5},
      ]);
      expect(manager.getStageStars('coran_tajwid', 'debutant', 1), 3);
      expect(manager.getStageStars('coran_tajwid', 'debutant', 2), 2);

      // Un résultat moins bon venant du serveur n'écrase rien.
      await manager.mergeProgress([
        {'cat': 'coran_tajwid', 'lvl': 'debutant', 'stage': 1, 'stars': 1, 'score': 3, 'total': 5},
      ]);
      expect(manager.getStageStars('coran_tajwid', 'debutant', 1), 3);
    });

    test('export puis effacement', () async {
      await manager.mergeProgress([
        {'cat': 'sira', 'lvl': 'avance', 'stage': 3, 'stars': 2, 'score': 4, 'total': 5},
      ]);
      final exported = manager.exportProgress();
      expect(exported, hasLength(1));
      expect(exported.first['cat'], 'sira');
      expect(exported.first['stage'], 3);

      await manager.clearProgress();
      expect(manager.exportProgress(), isEmpty);
    });

    test('ignore les entrées invalides', () async {
      await manager.mergeProgress([
        {'cat': 'sira', 'lvl': 'avance', 'stage': 9, 'stars': 2, 'score': 4, 'total': 5},
        {'cat': 'sira', 'lvl': 'avance', 'stage': 1, 'stars': 'x', 'score': 4, 'total': 5},
        'pas une entrée',
      ]);
      expect(manager.exportProgress(), isEmpty);
    });
  });

  group('AuthService', () {
    test('mauvais mot de passe -> AuthException 401, pas de session', () async {
      AuthService.instance.client = MockClient(
        (_) async => _json({'error': 'E-mail ou mot de passe incorrect.'}, 401),
      );
      await expectLater(
        AuthService.instance.login(email: 'a@b.co', password: 'faux'),
        throwsA(isA<AuthException>().having((e) => e.status, 'status', 401)),
      );
      expect(AuthService.instance.isLoggedIn, isFalse);
    });

    test('connexion, synchronisation puis déconnexion', () async {
      final requests = <String>[];
      AuthService.instance.client = MockClient((req) async {
        requests.add('${req.method} ${req.url.path}');
        switch (req.url.path) {
          case '/api/auth/login':
            return _json({
              'token': token,
              'user': {'id': 'u1', 'email': 'a@b.co', 'name': 'Ali'},
            });
          case '/api/progress':
            expect(req.headers['Authorization'], 'Bearer $token');
            return _json({
              'progress': [
                {'cat': 'sira', 'lvl': 'debutant', 'stage': 1, 'stars': 2, 'score': 4, 'total': 5},
              ],
            });
          case '/api/auth/logout':
            return _json({'ok': true});
        }
        return _json({'error': 'introuvable'}, 404);
      });

      await AuthService.instance.login(email: 'a@b.co', password: 'motdepasse1');
      expect(AuthService.instance.isLoggedIn, isTrue);
      expect(AuthService.instance.user?.name, 'Ali');
      expect(requests.first, 'POST /api/auth/login');
      expect(requests, contains('PUT /api/progress'));
      // La progression du compte est appliquée sur l'appareil.
      expect(manager.getStageStars('sira', 'debutant', 1), 2);

      await AuthService.instance.logout();
      expect(AuthService.instance.isLoggedIn, isFalse);
      expect(requests, contains('POST /api/auth/logout'));
      // La progression locale est effacée à la déconnexion.
      expect(manager.exportProgress(), isEmpty);
    });
  });
}
