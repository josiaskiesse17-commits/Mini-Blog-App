import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Version simulée corrigée
class LoginScreenSimule extends StatelessWidget {
  const LoginScreenSimule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Correction ici : 'child' au lieu de 'box'
          children: [
            const TextField(
              key: Key('email_field'),
              decoration: InputDecoration(labelText: 'Email'),
            ),
            const TextField(
              key: Key('password_field'),
              obscureText: true,
              decoration: InputDecoration(labelText: 'Mot de passe'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulation d'une action de connexion
              },
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('Tests de l\'Écran de Connexion', () {
    testWidgets('Vérification de la présence des champs essentiels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreenSimule())),
      );

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Se connecter'), findsOneWidget);
    });

    testWidgets(
      'Simulation de la saisie utilisateur dans l\'écran de connexion',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: LoginScreenSimule())),
        );

        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'MotDePasse123!',
        );
        await tester.pump();

        expect(find.text('test@example.com'), findsOneWidget);
      },
    );
  });
}
