import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreenSimule extends StatelessWidget {
  const LoginScreenSimule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            ElevatedButton(onPressed: () {}, child: const Text('Se connecter')),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('Tests de l ecran de connexion', () {
    testWidgets('Les champs essentiels sont presents', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreenSimule())),
      );

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Se connecter'), findsOneWidget);
    });

    testWidgets('La saisie utilisateur fonctionne', (
      WidgetTester tester,
    ) async {
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
    });
  });
}
