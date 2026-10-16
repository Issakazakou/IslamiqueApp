import 'package:flutter_test/flutter_test.dart';
import 'package:mon_application/config/api_config.dart';

void main() {
  tearDown(() => ApiConfig.customBaseUrl = null);

  String normalized(String input) {
    ApiConfig.customBaseUrl = input;
    return ApiConfig.baseUrl;
  }

  group('ApiConfig.baseUrl (normalisation)', () {
    test('adresse publique sans schéma -> https', () {
      expect(normalized('quiz.example.com'), 'https://quiz.example.com');
      expect(normalized('8.8.8.8'), 'https://8.8.8.8');
      expect(normalized('172.32.0.5'), 'https://172.32.0.5'); // hors plage privée
    });

    test('adresse locale / privée sans schéma -> http', () {
      expect(normalized('192.168.1.20:8000'), 'http://192.168.1.20:8000');
      expect(normalized('10.0.2.2:8000'), 'http://10.0.2.2:8000');
      expect(normalized('172.20.0.5'), 'http://172.20.0.5');
      expect(normalized('localhost:8000'), 'http://localhost:8000');
      expect(normalized('monpc.local:8000'), 'http://monpc.local:8000');
      expect(normalized('100.109.88.197:8000'), 'http://100.109.88.197:8000'); // Tailscale
    });

    test('le schéma saisi est respecté et les "/" de fin sont retirés', () {
      expect(normalized('https://quiz.example.com/'), 'https://quiz.example.com');
      expect(normalized('http://quiz.example.com//'), 'http://quiz.example.com');
    });

    test('sans valeur personnalisée -> URL par défaut', () {
      ApiConfig.customBaseUrl = null;
      expect(ApiConfig.baseUrl, ApiConfig.defaultBaseUrl);
    });
  });

  group('ApiConfig.isInsecure', () {
    test('HTTP vers Internet est signalé', () {
      expect(ApiConfig.isInsecure('http://quiz.example.com'), isTrue);
      expect(ApiConfig.isInsecure('http://8.8.8.8'), isTrue);
    });

    test('HTTPS et réseau local ne sont pas signalés', () {
      expect(ApiConfig.isInsecure('https://quiz.example.com'), isFalse);
      expect(ApiConfig.isInsecure('quiz.example.com'), isFalse); // devient https
      expect(ApiConfig.isInsecure('http://192.168.1.2:8000'), isFalse);
      expect(ApiConfig.isInsecure('http://100.109.88.197:8000'), isFalse);
    });
  });
}
