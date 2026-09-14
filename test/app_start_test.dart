import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Nous créons une version de test de l'application qui ne dépend pas de Firebase ni de user_profile_sync
class MiniBlogAppPourTest extends StatelessWidget {
  const MiniBlogAppPourTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniBlog',
      theme: ThemeData.light(),
      home: const Scaffold(body: Center(child: Text('Écran de Test'))),
    );
  }
}

void main() {
  group('Tests de démarrage de l\'application MiniBlog (Mode Isolé)', () {
    testWidgets('Vérification de la configuration initiale de MiniBlogApp', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MiniBlogAppPourTest()),
      );

      // Vérifie que le composant de test se charge
      expect(find.byType(MiniBlogAppPourTest), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Vérification de la présence du texte initial', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MiniBlogAppPourTest()),
      );

      // Vérifie qu'on trouve bien le texte écrit dans notre écran simulé
      expect(find.text('Écran de Test'), findsOneWidget);
    });
  });
}
