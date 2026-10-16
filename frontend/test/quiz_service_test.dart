import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mon_application/quiz_models.dart';
import 'package:mon_application/services/quiz_service.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  group('QuizService (sessions anti-triche)', () {
    test('mémorise la session et la renvoie à /check puis /submit', () async {
      final sentBodies = <String, Map<String, dynamic>>{};
      final client = MockClient((request) async {
        if (request.method == 'GET') {
          expect(request.url.queryParameters.containsKey('answers'), isFalse,
              reason: "l'app ne doit plus demander les bonnes réponses");
          return _json({
            'category': 'coran',
            'session': 'abc123',
            'count': 2,
            'questions': [
              {'id': 1, 'question': 'Q1 ?', 'options': ['a', 'b', 'c', 'd']},
              {'id': 2, 'question': 'Q2 ?', 'options': ['a', 'b', 'c', 'd']},
            ],
          });
        }
        sentBodies[request.url.path] = jsonDecode(request.body) as Map<String, dynamic>;
        if (request.url.path.endsWith('/check')) {
          return _json({'id': 1, 'choice': 0, 'correct': false, 'bonneReponse': 1});
        }
        return _json({
          'category': 'coran',
          'total': 1,
          'score': 0,
          'percentage': 0,
          'results': [
            {'id': 1, 'choice': 0, 'correct': false, 'bonneReponse': 1},
          ],
        });
      });

      final service = QuizService(client: client);
      final questions = await service.getQuestions('coran', limit: 2);
      expect(questions, hasLength(2));
      expect(questions.first.bonneReponse, isNull);

      final check = await service.checkAnswer('coran', 1, 0);
      expect(check.correct, isFalse);
      expect(check.bonneReponse, 1);
      expect(sentBodies['/api/quiz/coran/check']!['session'], 'abc123');
      expect(sentBodies['/api/quiz/coran/check']!['id'], 1);

      // gradeQuiz convertit indexQuestion -> idQuestion
      final graded = await service.gradeQuiz('coran', questions, {0: 0});
      expect(sentBodies['/api/quiz/coran/submit']!['session'], 'abc123');
      expect(sentBodies['/api/quiz/coran/submit']!['answers'], {'1': 0});
      expect(graded.results.single.bonneReponse, 1);
    });

    test('sans session (questions non chargées) : exception explicite', () async {
      final service = QuizService(client: MockClient((_) async => _json({})));
      expect(() => service.checkAnswer('coran', 1, 0), throwsException);
      expect(() => service.submitAnswers('coran', {1: 0}), throwsException);
    });

    test("une erreur serveur est remontée avec son message", () async {
      final client = MockClient((request) async {
        if (request.method == 'GET') {
          return _json({
            'session': 's',
            'questions': [
              {'id': 1, 'question': 'Q', 'options': ['a', 'b']},
            ],
          });
        }
        return _json({'error': 'Question déjà vérifiée avec un autre choix.'}, 409);
      });
      final service = QuizService(client: client);
      await service.getQuestions('coran');
      expect(
        () => service.checkAnswer('coran', 1, 1),
        throwsA(predicate((e) => e.toString().contains('409'))),
      );
    });
  });

  group('Modèles', () {
    test('QuizQuestion.withAnswer conserve le reste de la question', () {
      const q = QuizQuestion(id: 7, question: 'Q ?', options: ['a', 'b', 'c']);
      final revealed = q.withAnswer(2);
      expect(q.bonneReponse, isNull);
      expect(revealed.bonneReponse, 2);
      expect(revealed.id, 7);
      expect(revealed.options, ['a', 'b', 'c']);
    });

    test('QuizCheckResult.fromJson', () {
      final r = QuizCheckResult.fromJson({
        'id': 3,
        'choice': 1,
        'correct': true,
        'bonneReponse': 1,
      });
      expect(r.id, 3);
      expect(r.correct, isTrue);
      expect(r.bonneReponse, 1);
    });
  });
}
