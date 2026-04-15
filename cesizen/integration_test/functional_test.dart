// ─────────────────────────────────────────────
// TESTS FONCTIONNELS — Parcours utilisateur
// Lancer : flutter test integration_test/functional_test.dart
// ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cesizen/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── TF-01 à TF-05 : Authentification ─────────
  group('TF-AUTH | Parcours authentification', () {

    testWidgets('TF-01 | Ouverture popup connexion depuis la navbar', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter').first);
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('TF-02 | Basculer vers le mode inscription', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inscription'));
      await tester.pumpAndSettle();

      expect(find.text('Nom complet'), findsOneWidget);
      expect(find.text('Créer mon compte'), findsOneWidget);
    });

    testWidgets('TF-03 | Connexion avec champs vides affiche les erreurs', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter').first);
      await tester.pumpAndSettle();

      final btnSubmit = find.widgetWithText(ElevatedButton, 'Se connecter');
      await tester.tap(btnSubmit.last);
      await tester.pumpAndSettle();

      expect(find.text('Requis'), findsWidgets);
    });

    testWidgets('TF-04 | Email invalide affiche erreur de validation', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'emailinvalide');
      final btnSubmit = find.widgetWithText(ElevatedButton, 'Se connecter');
      await tester.tap(btnSubmit.last);
      await tester.pumpAndSettle();

      expect(find.text('Email invalide'), findsOneWidget);
    });

    testWidgets('TF-05 | Lien mot de passe oublié ouvre la vue dédiée', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      expect(find.text('Mot de passe oublié'), findsOneWidget);
      expect(find.text('Envoyer le lien'), findsOneWidget);
    });
  });

  // ── TF-06 à TF-09 : Navigation ───────────────
  group('TF-NAV | Navigation entre pages', () {

    testWidgets('TF-06 | Page d\'accueil charge correctement', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('Accueil'), findsWidgets);
    });

    testWidgets('TF-07 | Navigation vers Diagnostics', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Diagnostics').first);
      await tester.pumpAndSettle();

      expect(find.text('Diagnostics'), findsWidgets);
    });

    testWidgets('TF-08 | Navigation vers Contenus', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Contenus').first);
      await tester.pumpAndSettle();

      expect(find.text('Contenus'), findsWidgets);
    });

    testWidgets('TF-09 | Navigation vers Besoin d\'aide', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Besoin d\'aide ?').first);
      await tester.pumpAndSettle();

      expect(find.text('Besoin d\'aide ?'), findsWidgets);
    });
  });

  // ── TF-10 à TF-13 : MDP oublié ───────────────
  group('TF-RESET | Parcours mot de passe oublié', () {

    testWidgets('TF-10 | Soumission email vide affiche erreur', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Envoyer le lien'));
      await tester.pumpAndSettle();

      expect(find.text('Requis'), findsOneWidget);
    });

    testWidgets('TF-11 | Email invalide dans reset affiche erreur', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'emailsansarobase');
      await tester.tap(find.text('Envoyer le lien'));
      await tester.pumpAndSettle();

      expect(find.text('Email invalide'), findsOneWidget);
    });

    testWidgets('TF-12 | Bouton Retour depuis MDP oublié revient à la connexion', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retour'));
      await tester.pumpAndSettle();

      expect(find.text('Se connecter'), findsWidgets);
    });

    testWidgets('TF-13 | Fermeture popup depuis la vue MDP oublié', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Mot de passe oublié'), findsNothing);
    });
  });

  // ── TF-14 à TF-16 : Inscription ──────────────
  group('TF-INSCR | Parcours inscription', () {

    testWidgets('TF-14 | Mot de passe trop court affiche erreur', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inscription'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Jean Dupont');
      await tester.enterText(fields.at(1), 'jean@exemple.fr');
      await tester.enterText(fields.at(2), 'abc');

      await tester.tap(find.text('Créer mon compte'));
      await tester.pumpAndSettle();

      expect(find.text('Min. 6 caractères'), findsOneWidget);
    });

    testWidgets('TF-15 | Inscription champs vides affiche erreurs', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inscription'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Créer mon compte'));
      await tester.pumpAndSettle();

      expect(find.text('Requis'), findsWidgets);
    });

    testWidgets('TF-16 | Basculer inscription → connexion cache le champ nom', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inscription'));
      await tester.pumpAndSettle();

      expect(find.text('Nom complet'), findsOneWidget);

      await tester.tap(find.text('Connexion'));
      await tester.pumpAndSettle();

      expect(find.text('Nom complet'), findsNothing);
    });
  });
}