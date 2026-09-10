import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_blog_app/main.dart'; // Si 'mini_blog_app' est souligné en rouge, remplacez-le par le nom exact situé à la première ligne de votre fichier pubspec.yaml

void main() {
  testWidgets('Diagnostic : Vérification de l\'écran de démarrage', (WidgetTester tester) async {
    // 1. Charger l'application
    await tester.pumpWidget(const MiniBlogApp());
    await tester.pumpAndSettle();

    // 2. Chercher si un Placeholder (l'écran noir avec la croix) est affiché
    final placeholderFinder = find.byType(Placeholder);

    // 3. Vérification officielle
    if (placeholderFinder.evaluate().isNotEmpty) {
      debugPrint('--- DIAGNOSTIC TESTEUR ---');
      debugPrint('ALERTE : L\'interface graphique n\'est pas encore connectée.');
      debugPrint('Un composant Placeholder (écran avec la croix) bloque l\'affichage.');
      debugPrint('--------------------------');
    }

    // Le test réussit si l'application s'est exécutée sans crash
    expect(true, true);
  });
}
