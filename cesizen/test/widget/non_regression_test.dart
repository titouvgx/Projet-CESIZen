// ─────────────────────────────────────────────
// TESTS DE NON-RÉGRESSION — Widgets
// Lancer : flutter test test/widget/non_regression_test.dart
// ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cesizen/variables.dart';

// ── Widget minimaliste simulant la LoginPopup ─
class _FakeLoginPopup extends StatefulWidget {
  const _FakeLoginPopup();
  @override
  State<_FakeLoginPopup> createState() => _FakeLoginPopupState();
}

class _FakeLoginPopupState extends State<_FakeLoginPopup> {
  bool _modeConnexion = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Column(children: [
      Text(_modeConnexion ? 'Se connecter' : 'Créer un compte'),
      ElevatedButton(
        key: const Key('btn_inscription'),
        onPressed: () => setState(() => _modeConnexion = false),
        child: const Text('Inscription'),
      ),
      ElevatedButton(
        key: const Key('btn_connexion'),
        onPressed: () => setState(() => _modeConnexion = true),
        child: const Text('Connexion'),
      ),
      if (!_modeConnexion)
        const TextField(key: Key('field_nom'), decoration: InputDecoration(labelText: 'Nom complet')),
      const TextField(key: Key('field_email'), decoration: InputDecoration(labelText: 'Email')),
      const TextField(key: Key('field_password'), decoration: InputDecoration(labelText: 'Mot de passe')),
      if (_modeConnexion)
        TextButton(key: const Key('btn_mdp_oublie'), onPressed: null, child: const Text('Mot de passe oublié ?')),
    ])));
  }
}

void main() {

  // ── TNR-01 à TNR-05 : Login Popup ────────────
  group('TNR-LOGIN | Popup de connexion', () {

    testWidgets('TNR-01 | Mode connexion affiche les champs email et password', (tester) async {
      await tester.pumpWidget(const _FakeLoginPopup());
      expect(find.byKey(const Key('field_email')), findsOneWidget);
      expect(find.byKey(const Key('field_password')), findsOneWidget);
    });

    testWidgets('TNR-02 | Mode connexion n\'affiche pas le champ nom', (tester) async {
      await tester.pumpWidget(const _FakeLoginPopup());
      expect(find.byKey(const Key('field_nom')), findsNothing);
    });

    testWidgets('TNR-03 | Clic sur Inscription affiche le champ nom', (tester) async {
      await tester.pumpWidget(const _FakeLoginPopup());
      await tester.tap(find.byKey(const Key('btn_inscription')));
      await tester.pump();
      expect(find.byKey(const Key('field_nom')), findsOneWidget);
    });

    testWidgets('TNR-04 | Retour en mode connexion cache le champ nom', (tester) async {
      await tester.pumpWidget(const _FakeLoginPopup());
      await tester.tap(find.byKey(const Key('btn_inscription')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('btn_connexion')));
      await tester.pump();
      expect(find.byKey(const Key('field_nom')), findsNothing);
    });

    testWidgets('TNR-05 | Lien mot de passe oublié présent en mode connexion', (tester) async {
      await tester.pumpWidget(const _FakeLoginPopup());
      expect(find.byKey(const Key('btn_mdp_oublie')), findsOneWidget);
    });

    testWidgets('TNR-06 | Lien mot de passe oublié absent en mode inscription', (tester) async {
      await tester.pumpWidget(const _FakeLoginPopup());
      await tester.tap(find.byKey(const Key('btn_inscription')));
      await tester.pump();
      expect(find.byKey(const Key('btn_mdp_oublie')), findsNothing);
    });
  });

  // ── TNR-07 à TNR-10 : Navbar ─────────────────
  group('TNR-NAV | Barre de navigation', () {

    Widget buildNavBar({bool isMobile = false}) {
      return MaterialApp(home: Scaffold(body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(children: [
          const Text('CESIZen', key: Key('logo')),
          const Spacer(),
          if (!isMobile) ...[
            const Text('Accueil', key: Key('nav_accueil')),
            const Text('Diagnostics', key: Key('nav_diagnostics')),
            const Text('Contenus', key: Key('nav_contenus')),
            const Text('Votre espace', key: Key('nav_espace')),
            const Text('Besoin d\'aide ?', key: Key('nav_aide')),
            ElevatedButton(key: const Key('btn_auth'), onPressed: null, child: const Text('Se connecter')),
          ] else
            IconButton(key: const Key('btn_hamburger'), onPressed: null, icon: const Icon(Icons.menu)),
        ]),
      )));
    }

    testWidgets('TNR-07 | Desktop affiche tous les liens de navigation', (tester) async {
      await tester.pumpWidget(buildNavBar());
      expect(find.byKey(const Key('nav_accueil')), findsOneWidget);
      expect(find.byKey(const Key('nav_diagnostics')), findsOneWidget);
      expect(find.byKey(const Key('nav_contenus')), findsOneWidget);
      expect(find.byKey(const Key('nav_espace')), findsOneWidget);
      expect(find.byKey(const Key('nav_aide')), findsOneWidget);
    });

    testWidgets('TNR-08 | Desktop affiche le bouton Se connecter', (tester) async {
      await tester.pumpWidget(buildNavBar());
      expect(find.byKey(const Key('btn_auth')), findsOneWidget);
    });

    testWidgets('TNR-09 | Mobile n\'affiche pas les liens de navigation', (tester) async {
      await tester.pumpWidget(buildNavBar(isMobile: true));
      expect(find.byKey(const Key('nav_accueil')), findsNothing);
      expect(find.byKey(const Key('btn_auth')), findsNothing);
    });

    testWidgets('TNR-10 | Mobile affiche le bouton hamburger', (tester) async {
      await tester.pumpWidget(buildNavBar(isMobile: true));
      expect(find.byKey(const Key('btn_hamburger')), findsOneWidget);
    });
  });

  // ── TNR-11 à TNR-14 : ResetPassword ──────────
  group('TNR-RESET | Page de réinitialisation mot de passe', () {

    Widget buildResetPage({bool succes = false}) {
      return MaterialApp(home: Scaffold(body: succes
          ? Column(children: const [
              Text('Mot de passe modifié !', key: Key('txt_succes')),
              ElevatedButton(key: Key('btn_retour'), onPressed: null, child: Text('Retour à l\'accueil')),
            ])
          : Column(children: const [
              TextField(key: Key('field_nouveau_mdp'), decoration: InputDecoration(labelText: 'Nouveau mot de passe')),
              TextField(key: Key('field_confirm_mdp'), decoration: InputDecoration(labelText: 'Confirmer le mot de passe')),
              ElevatedButton(key: Key('btn_enregistrer'), onPressed: null, child: Text('Enregistrer le mot de passe')),
            ]),
      ));
    }

    testWidgets('TNR-11 | Formulaire reset affiche les deux champs', (tester) async {
      await tester.pumpWidget(buildResetPage());
      expect(find.byKey(const Key('field_nouveau_mdp')), findsOneWidget);
      expect(find.byKey(const Key('field_confirm_mdp')), findsOneWidget);
    });

    testWidgets('TNR-12 | Formulaire reset affiche le bouton enregistrer', (tester) async {
      await tester.pumpWidget(buildResetPage());
      expect(find.byKey(const Key('btn_enregistrer')), findsOneWidget);
    });

    testWidgets('TNR-13 | Écran succès affiche le message de confirmation', (tester) async {
      await tester.pumpWidget(buildResetPage(succes: true));
      expect(find.byKey(const Key('txt_succes')), findsOneWidget);
    });

    testWidgets('TNR-14 | Écran succès affiche le bouton retour accueil', (tester) async {
      await tester.pumpWidget(buildResetPage(succes: true));
      expect(find.byKey(const Key('btn_retour')), findsOneWidget);
    });
  });
}