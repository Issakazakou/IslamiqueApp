import 'package:flutter_test/flutter_test.dart';
import 'package:mon_application/certificates.dart';
import 'package:mon_application/quiz_models.dart';
import 'package:mon_application/stage_progress_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final progress = StageProgressManager.instance;
  final certificates = CertificateManager.instance;

  QuizCategory byId(String id) =>
      CertificateManager.all.firstWhere((c) => c.id == id);

  /// Réussit (1 étoile) toutes les étapes des catégories données, sauf [skip].
  Future<void> complete(List<String> ids, {String? skipLevel, int? skipStage}) {
    return progress.mergeProgress([
      for (final id in ids)
        for (final level in QuizLevel.values)
          for (var stage = 1; stage <= 5; stage++)
            if (!(level.apiValue == skipLevel && stage == skipStage))
              {
                'cat': id,
                'lvl': level.apiValue,
                'stage': stage,
                'stars': 1,
                'score': 3,
                'total': 5,
              },
    ]);
  }

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await progress.init();
    await certificates.init();
  });

  setUp(() async {
    await progress.clearProgress();
    certificates.takePending();
  });

  test('pas de certificat tant que toutes les étapes ne sont pas réussies', () async {
    await complete(['sira_mecquoise'], skipLevel: 'avance', skipStage: 5);
    final sira = byId('sira_mecquoise');
    expect(certificates.completedStages(sira), 14);
    expect(certificates.totalStages(sira), 15);
    expect(certificates.isComplete(sira), isFalse);
    expect(certificates.isEarned(sira), isFalse);
  });

  test('certificat délivré à la dernière étape, annoncé une seule fois', () async {
    await complete(['sira_mecquoise'], skipLevel: 'avance', skipStage: 5);
    await progress.recordStageResult(
      categoryId: 'sira_mecquoise',
      levelValue: 'avance',
      stageNumber: 5,
      score: 5,
      total: 5,
    );
    final fresh = await certificates.refresh(announce: true);
    expect(fresh.map((c) => c.id), ['sira_mecquoise']);
    expect(certificates.isEarned(byId('sira_mecquoise')), isTrue);
    expect(certificates.earnedOn(byId('sira_mecquoise')), isNotNull);
    expect(certificates.takePending().map((c) => c.id), ['sira_mecquoise']);
    expect(certificates.takePending(), isEmpty);
    // Un second passage ne redélivre rien.
    expect(await certificates.refresh(announce: true), isEmpty);
  });

  test('le certificat Coran exige ses 3 sous-catégories', () async {
    await complete(['coran_mediter', 'coran_tajwid']);
    expect(certificates.isEarned(byId('coran_mediter')), isTrue);
    expect(certificates.isEarned(byId('coran_tajwid')), isTrue);
    expect(certificates.isEarned(byId('coran')), isFalse);

    await complete(['coran_culture']);
    expect(certificates.isEarned(byId('coran_culture')), isTrue);
    expect(certificates.isEarned(byId('coran')), isTrue);
    expect(certificates.totalStages(byId('coran')), 45);
  });

  test('le certificat Sira exige ses 3 sous-catégories', () async {
    await complete(['sira_mecquoise', 'sira_medinoise']);
    expect(certificates.isEarned(byId('sira_mecquoise')), isTrue);
    expect(certificates.isEarned(byId('sira_medinoise')), isTrue);
    expect(certificates.isEarned(byId('sira')), isFalse);

    await complete(['sira_evenements']);
    expect(certificates.isEarned(byId('sira_evenements')), isTrue);
    expect(certificates.isEarned(byId('sira')), isTrue);
    expect(certificates.totalStages(byId('sira')), 45);
  });

  test('effacer la progression (déconnexion) retire les certificats', () async {
    await complete(['hadith_fondements']);
    expect(certificates.isEarned(byId('hadith_fondements')), isTrue);
    await progress.clearProgress();
    expect(certificates.isEarned(byId('hadith_fondements')), isFalse);
  });

  test('le nom du certificat est mémorisé', () async {
    await certificates.setName('  Issaka  ');
    expect(certificates.name, 'Issaka');
  });
}
