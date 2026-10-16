import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_application/main.dart';

void main() {
  testWidgets('Rendu initial de la page d\'accueil', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const QuizIslamiqueApp());
    await tester.pumpAndSettle();

    expect(find.text('Quiz Islamique'), findsWidgets);
    expect(find.text('Coran'), findsOneWidget);
    expect(find.text('Quiz Hadith'), findsWidgets);
    expect(find.text('Quiz Fiqh'), findsWidgets);
  });
}
