import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_application/main.dart';

void main() {
  testWidgets('Écran initial avec choix de connexion puis accès accueil', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const QuizIslamiqueApp());
    await tester.pumpAndSettle();

    // Vérifie la présence de l'écran de choix initial
    expect(find.text('Quiz Islamique'), findsWidgets);
    expect(find.text('Se connecter à mon compte'), findsOneWidget);
    expect(find.text('Continuer sans compte'), findsOneWidget);

    // L'utilisateur choisit « Continuer sans compte »
    await tester.tap(find.text('Continuer sans compte'));
    await tester.pumpAndSettle();

    // Vérifie l'accès à l'accueil et ses 4 catégories principales
    expect(find.text('Coran'), findsOneWidget);
    expect(find.text('Quiz Hadith'), findsWidgets);
    expect(find.text('Quiz Fiqh'), findsWidgets);
    expect(find.text('Sira du Prophète ﷺ'), findsWidgets);
  });
}
