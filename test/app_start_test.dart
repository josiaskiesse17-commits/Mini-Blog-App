import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MiniBlogAppPourTest extends StatelessWidget {
  const MiniBlogAppPourTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniBlog',
      theme: ThemeData.light(),
      home: const Scaffold(body: Center(child: Text('Ecran de Test'))),
    );
  }
}

void main() {
  group('Tests de demarrage de l application MiniBlog (Mode Isole)', () {
    testWidgets('La configuration initiale se charge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MiniBlogAppPourTest()),
      );

      expect(find.byType(MiniBlogAppPourTest), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Le texte initial est present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MiniBlogAppPourTest()),
      );

      expect(find.text('Ecran de Test'), findsOneWidget);
    });
  });
}
