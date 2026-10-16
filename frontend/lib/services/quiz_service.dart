import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../quiz_models.dart';

class QuizService {
  final http.Client _client;

  QuizService({http.Client? client}) : _client = client ?? http.Client();

  /// Session de quiz créée par le serveur au chargement des questions.
  /// Elle est renvoyée à `/check` et `/submit` (anti-triche : une question ne
  /// peut être vérifiée qu'une fois par session).
  String? _session;

  /// Langue dans laquelle le quiz a été chargé : les explications reviennent dans la même langue.
  String? _sessionLang;

  String _requireSession() {
    final s = _session;
    if (s == null || s.isEmpty) {
      throw Exception('Aucune session de quiz : rechargez les questions.');
    }
    return s;
  }

  /// Récupère la liste des questions pour une catégorie et un niveau donnés depuis le backend PHP.
  ///
  /// [lang] : code de langue ('fr', 'en', 'ar') envoyé au serveur (?lang=ar).
  /// Le serveur renvoie la traduction quand elle existe, sinon le français.
  Future<List<QuizQuestion>> getQuestions(
    String categoryId, {
    String? level,
    int? limit,
    bool random = true,
    bool answers = false, // le serveur ignore `answers=1` en production
    String? lang,
  }) async {
    final queryParams = <String, String>{};
    if (level != null && level.isNotEmpty) {
      queryParams['level'] = level;
    }
    if (limit != null && limit > 0) {
      queryParams['limit'] = limit.toString();
    }
    if (random) {
      queryParams['random'] = '1';
    }
    if (answers) {
      queryParams['answers'] = '1';
    }
    if (lang != null && lang.isNotEmpty) {
      queryParams['lang'] = lang;
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/questions/$categoryId')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 8));
    } catch (e) {
      _throwConnectionError(e);
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur serveur (${response.statusCode})${_serverMessage(response)}',
      );
    }

    final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic> && decoded.containsKey('questions')) {
      _session = decoded['session'] as String?;
      _sessionLang = (lang != null && lang.isNotEmpty) ? lang : null;
      final List<dynamic> list = decoded['questions'];
      return list
          .map((item) => QuizQuestion.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else if (decoded is List) {
      return decoded
          .map((item) => QuizQuestion.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    throw Exception('Format de réponse inattendu du serveur PHP.');
  }

  /// Extrait le champ `error` renvoyé par le backend, sous la forme ` : message`.
  String _serverMessage(http.Response response) {
    try {
      final errJson = json.decode(utf8.decode(response.bodyBytes));
      if (errJson is Map && errJson.containsKey('error')) {
        return ' : ${errJson['error']}';
      }
    } catch (_) {}
    return '';
  }

  /// Erreur réseau : le serveur backend est injoignable.
  Never _throwConnectionError(Object cause) {
    throw Exception(
      'Impossible de contacter le serveur backend PHP (${ApiConfig.baseUrl}).\n'
      'Vérifiez que le serveur PHP est lancé (avec run_backend.bat).\n\n'
      'Détail : $cause',
    );
  }

  /// Récupère les questions pour une étape spécifique du parcours (1 à 5).
  /// Les questions du niveau sont ordonnées et découpées en 5 tranches successives.
  Future<List<QuizQuestion>> getStageQuestions(
    String categoryId, {
    required String level,
    required int stageNumber, // 1 à 5
    int? questionCount,
    String? lang,
  }) async {
    final allLevelQuestions = await getQuestions(
      categoryId,
      level: level,
      limit: 100,
      random: false,
      answers: false,
      lang: lang,
    );

    if (allLevelQuestions.isEmpty) return [];

    final int total = allLevelQuestions.length;
    final int sliceSize = (total / 5).ceil();
    final int startIndex = ((stageNumber - 1) * sliceSize).clamp(0, total);
    final int endIndex = (startIndex + sliceSize).clamp(startIndex, total);

    List<QuizQuestion> stageList = allLevelQuestions.sublist(startIndex, endIndex);

    if (stageList.isEmpty) {
      stageList = allLevelQuestions;
    }

    final int desiredCount = questionCount ?? 5;
    if (desiredCount > 0 && stageList.length > desiredCount) {
      stageList = stageList.take(desiredCount).toList();
    }

    return stageList;
  }

  /// Vérifie UNE réponse côté serveur et révèle la bonne réponse de cette
  /// question. [choice] = -1 signifie « temps écoulé ».
  Future<QuizCheckResult> checkAnswer(
    String categoryId,
    int questionId,
    int choice,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/quiz/$categoryId/check');

    final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode({
              'session': _requireSession(),
              'id': questionId,
              'choice': choice,
              if (_sessionLang != null) 'lang': _sessionLang,
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      _throwConnectionError(e);
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur ${response.statusCode} lors de la vérification'
        '${_serverMessage(response)}.',
      );
    }

    final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic>) {
      return QuizCheckResult.fromJson(decoded);
    }
    throw Exception('Format de réponse inattendu du serveur.');
  }

  /// Corrige tout le quiz côté serveur.
  ///
  /// [userAnswers] : indexQuestion -> indexOption (-1 = temps écoulé), tel que
  /// stocké par l'écran de quiz. Les index sont convertis en id de question,
  /// comme l'attend l'API.
  Future<QuizSubmissionResult> gradeQuiz(
    String categoryId,
    List<QuizQuestion> questions,
    Map<int, int> userAnswers,
  ) {
    final byId = <int, int>{};
    userAnswers.forEach((index, choice) {
      if (index >= 0 && index < questions.length) {
        byId[questions[index].id] = choice;
      }
    });
    return submitAnswers(categoryId, byId);
  }

  /// Soumet les réponses au backend PHP pour validation officielle
  /// ([answers] : idQuestion -> indexOption).
  Future<QuizSubmissionResult> submitAnswers(
    String categoryId,
    Map<int, int> answers,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/quiz/$categoryId/submit');

    final payload = {
      'session': _requireSession(),
      'answers': answers.map((key, value) => MapEntry(key.toString(), value)),
      if (_sessionLang != null) 'lang': _sessionLang,
    };

    final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      _throwConnectionError(e);
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur ${response.statusCode} lors de la soumission du quiz'
        '${_serverMessage(response)}.',
      );
    }

    final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic>) {
      return QuizSubmissionResult.fromJson(decoded);
    }
    throw Exception('Format de réponse inattendu du serveur.');
  }

  /// Récupère la liste des catégories depuis le backend PHP
  Future<List<Map<String, dynamic>>> getCategories() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/categories');

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 8));
    } catch (e) {
      _throwConnectionError(e);
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur serveur (${response.statusCode}) lors de la récupération '
        'des catégories${_serverMessage(response)}.',
      );
    }

    final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));
    if (decoded is List) {
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    throw Exception('Format de réponse inattendu du serveur PHP.');
  }
}
