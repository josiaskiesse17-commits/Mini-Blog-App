import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_blog_app/main.dart';

void main() {
  testWidgets(
    'Diagnostic : Vérification de l\'écran de démarrage',
    (WidgetTester tester) async {
      // 1. Charger l'application avec Riverpod.
      await tester.pumpWidget(
        const ProviderScope(
          child: MiniBlogApp(),
        ),
      );

      await tester.pump();

      // 2. Chercher si un Placeholder est encore affiché.
      final placeholderFinder = find.byType(Placeholder);

      // 3. Vérification officielle.
      if (placeholderFinder.evaluate().isNotEmpty) {
        debugPrint('--- DIAGNOSTIC TESTEUR ---');
        debugPrint(
          'ALERTE : L\'interface graphique n\'est pas encore entièrement connectée.',
        );
        debugPrint(
          'Un composant Placeholder est encore présent dans l\'application.',
        );
        debugPrint('--------------------------');
      }

      // 4. L'application doit démarrer sans afficher de Placeholder.
      expect(placeholderFinder, findsNothing);
    },
  );
}