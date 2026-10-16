import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mon_application/certificates.dart';
import 'package:mon_application/services/auth_service.dart';
import 'package:mon_application/stage_progress_manager.dart';
import 'package:mon_application/user_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(
      json.encode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final stats = UserProgress.instance;
  final certificates = CertificateManager.instance;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await StageProgressManager.instance.init();
    await certificates.init();
  });

  setUp(() async {
    stats.reset();
    await StageProgressManager.instance.clearProgress();
  });

  group('Statistiques', () {
    test('exportStats : format de l\'API', () {
      stats.recordQuizResult(categoryId: 'sira', correct: 4, total: 5);
      final exported = stats.exportStats();
      expect(exported['quizDone'], 1);
      expect(exported['questions'], 5);
      expect(exported['correct'], 4);
      expect(exported['lastPlay'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(exported['badges'], contains('first_quiz'));
      expect((exported['categories'] as Map)['sira'], {'done': 1, 'correct': 4, 'total': 5});
    });

    test('mergeStats : totaux = maximum, série du dernier jour, badges réunis', () {
      stats.recordQuizResult(categoryId: 'sira', correct: 4, total: 5);
      stats.mergeStats({
        'quizDone': 10,
        'questions': 50,
        'correct': 40,
        'streak': 6,
        'bestStreak': 9,
        'lastPlay': '2099-01-01',
        'badges': ['streak_3'],
        'categories': {
          'sira': {'done': 5, 'correct': 20, 'total': 25},
          'inconnue': {'done': 1, 'correct': 1, 'total': 1},
        },
      });
      expect(stats.totalQuizDone, 10);
      expect(stats.totalQuestions, 50);
      expect(stats.streak, 6);
      expect(stats.bestStreak, 9);
      expect(stats.badges, containsAll(['first_quiz', 'streak_3']));
      expect(stats.categoryStats['sira']!['done'], 5);

      // Une série plus ancienne venant du serveur n'écrase pas la série actuelle.
      stats.mergeStats({'streak': 99, 'lastPlay': '2000-01-01'});
      expect(stats.streak, 6);
    });
  });

  group('Certificats du serveur', () {
    test('applyRemote : date et code du serveur, catégories inconnues ignorées', () async {
      final sira = CertificateManager.all.firstWhere((c) => c.id == 'sira');
      expect(certificates.isEarned(sira), isFalse);
      await certificates.applyRemote([
        {'cat': 'sira', 'date': '2026-10-12', 'code': 'ABCD-EF01-2345'},
        {'cat': 'inconnue', 'date': '2026-10-12', 'code': 'AAAA-BBBB-CCCC'},
        'pas un certificat',
      ]);
      expect(certificates.isEarned(sira), isTrue);
      expect(certificates.codeOf(sira), 'ABCD-EF01-2345');
      expect(certificates.earnedOn(sira)!.year, 2026);
      expect(certificates.earnedOn(sira)!.day, 12);
    });
  });

  group('AuthService : profil', () {
    test('synchro : envoie les stats, applique stats et certificats, change le nom', () async {
      final sentStats = <Object?>[];
      AuthService.instance.client = MockClient((req) async {
        switch (req.url.path) {
          case '/api/auth/login':
            return _json({
              'token': 'b' * 64,
              'user': {'id': 'u1', 'email': 'a@b.co', 'name': 'Ali'},
            });
          case '/api/progress':
            sentStats.add((json.decode(req.body) as Map<String, dynamic>)['stats']);
            return _json({
              'progress': [],
              'stats': {
                'quizDone': 7,
                'questions': 35,
                'correct': 30,
                'streak': 2,
                'bestStreak': 3,
                'lastPlay': '2026-10-12',
                'badges': ['first_quiz'],
                'categories': {},
              },
              'certificates': [
                {'cat': 'sira', 'date': '2026-10-12', 'code': 'AAAA-BBBB-CCCC'},
              ],
            });
          case '/api/profile':
            return _json({
              'user': {'id': 'u1', 'email': 'a@b.co', 'name': 'Nouveau nom'},
            });
          case '/api/auth/logout':
            return _json({'ok': true});
        }
        return _json({'error': 'introuvable'}, 404);
      });

      await AuthService.instance.login(email: 'a@b.co', password: 'motdepasse1');
      expect(sentStats.first, isA<Map>());
      expect(stats.totalQuizDone, 7);
      expect(stats.badges, contains('first_quiz'));
      final sira = CertificateManager.all.firstWhere((c) => c.id == 'sira');
      expect(certificates.codeOf(sira), 'AAAA-BBBB-CCCC');
      expect(AuthService.instance.lastSync, isNotNull);

      await AuthService.instance.updateName('Nouveau nom');
      expect(AuthService.instance.user!.name, 'Nouveau nom');

      await AuthService.instance.logout();
      expect(AuthService.instance.isLoggedIn, isFalse);
      // Statistiques et certificats de l'appareil sont effacés à la déconnexion.
      expect(stats.totalQuizDone, 0);
      expect(certificates.isEarned(sira), isFalse);
    });
  });
}
