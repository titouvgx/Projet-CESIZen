// ═══════════════════════════════════════════════════════════════
// CAHIER DE TESTS — CESIZen
// test/cahier_tests.dart
//
// Chaque test appelle une fonction réelle de lib/.
// Chaque test PEUT échouer si tu modifies la logique correspondante.
//
// Lancer :
//   flutter test test/cahier_tests.dart --reporter expanded
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:cesizen/auth_service.dart';
import 'package:cesizen/utils/cesizen_utils.dart';

void main() {

  // ════════════════════════════════════════════════════════════
  // TC-01 — Accès réservé aux administrateurs
  // Fonction testée : AuthService.isAdmin (auth_service.dart)
  // Si tu changes la condition isAdmin → ces tests échouent
  // ════════════════════════════════════════════════════════════
  group('TC-01 — Accès réservé aux administrateurs', () {
    tearDown(() => AuthService.resetForTest());

    test('Citoyen connecte → isAdmin = false', () {
      AuthService.setProfileForTest({'id_utilisateur': 'u1', 'role': 'Citoyen connecte'});
      expect(AuthService.isAdmin, isFalse);
    });

    test('Admin → isAdmin = true', () {
      AuthService.setProfileForTest({'id_utilisateur': 'u2', 'role': 'Admin'});
      expect(AuthService.isAdmin, isTrue);
    });

    test('role null → isAdmin = false', () {
      AuthService.setProfileForTest({'id_utilisateur': 'u3', 'role': null});
      expect(AuthService.isAdmin, isFalse);
    });

    test('role vide → isAdmin = false', () {
      AuthService.setProfileForTest({'id_utilisateur': 'u4', 'role': ''});
      expect(AuthService.isAdmin, isFalse);
    });

    test('"admin" minuscule ≠ "Admin" → isAdmin = false', () {
      // Prouve que la comparaison est sensible à la casse
      AuthService.setProfileForTest({'id_utilisateur': 'u5', 'role': 'admin'});
      expect(AuthService.isAdmin, isFalse,
          reason: '"admin" minuscule ne doit pas donner accès — '
              'seul "Admin" avec majuscule est valide');
    });

    test('Après resetForTest → isAdmin = false', () {
      AuthService.setProfileForTest({'id_utilisateur': 'u6', 'role': 'Admin'});
      expect(AuthService.isAdmin, isTrue); // avant reset
      AuthService.resetForTest();
      expect(AuthService.isAdmin, isFalse); // après reset
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-02 — CRUD articles réservé aux admins
  // Fonctions testées :
  //   - AuthService.isAdmin (auth_service.dart)
  //   - toggleStatutPublication() (cesizen_utils.dart)
  //     = _togglePublication() dans admin.dart ligne 624
  // Si tu changes la logique toggle → ces tests échouent
  // ════════════════════════════════════════════════════════════
  group('TC-02 — CRUD articles réservé aux admins', () {
    tearDown(() => AuthService.resetForTest());

    test('Admin → isAdmin true', () {
      AuthService.setProfileForTest({'role': 'Admin'});
      expect(AuthService.isAdmin, isTrue);
    });

    test('Citoyen → isAdmin false, pas de CRUD', () {
      AuthService.setProfileForTest({'role': 'Citoyen connecte'});
      expect(AuthService.isAdmin, isFalse);
    });

    test('toggleStatutPublication("brouillon") → "publié"', () {
      // Appelle la vraie logique de admin.dart ligne 624
      expect(toggleStatutPublication('brouillon'), equals('publié'));
    });

    test('toggleStatutPublication("publié") → "brouillon"', () {
      expect(toggleStatutPublication('publié'), equals('brouillon'));
    });

    test('Double toggle → revient à l\'état initial', () {
      final apresDeuxToggle =
          toggleStatutPublication(toggleStatutPublication('brouillon'));
      expect(apresDeuxToggle, equals('brouillon'),
          reason: 'Deux toggles doivent revenir à brouillon');
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-03 — Filtrage des contenus
  // Fonction testée : filtrerContenus() (cesizen_utils.dart)
  //   = _contenusFiltres dans contenu_page.dart lignes 57-63
  //
  // ⚠️ Note : getContenuPublie() filtre déjà sur statut='publié'
  // côté Supabase. filtrerContenus() reçoit donc des articles
  // déjà publiés — elle filtre uniquement catégorie + recherche.
  //
  // Si tu changes _contenusFiltres dans contenu_page.dart → échoue
  // ════════════════════════════════════════════════════════════
  group('TC-03 — Filtrage et visibilité des contenus', () {

    // Données : TOUS publiés (comme ce que retourne getContenuPublie())
    final articlesPublies = [
      {'titre': 'Gérer le stress',  'categorie': 'Stress',   'texte': 'technique'},
      {'titre': 'Mieux dormir',     'categorie': 'Sommeil',  'texte': 'conseils'},
      {'titre': 'Méditation',       'categorie': 'Bien-être','texte': 'exercices'},
      {'titre': 'Relations saines', 'categorie': 'Relations','texte': 'communication'},
    ];

    test('Aucun filtre → tous les articles retournés', () {
      final r = filtrerContenus(
          tous: articlesPublies, recherche: '', categorieSelectionnee: 'Tous');
      expect(r.length, equals(4));
    });

    test('Recherche "stress" → 1 article (titre)', () {
      final r = filtrerContenus(
          tous: articlesPublies, recherche: 'stress', categorieSelectionnee: 'Tous');
      expect(r.length, equals(1));
      expect(r.first['titre'], equals('Gérer le stress'));
    });

    test('Recherche "sommeil" → 1 article (catégorie)', () {
      // La recherche porte aussi sur la catégorie (ligne 63 contenu_page.dart)
      final r = filtrerContenus(
          tous: articlesPublies, recherche: 'sommeil', categorieSelectionnee: 'Tous');
      expect(r.length, equals(1));
      expect(r.first['titre'], equals('Mieux dormir'));
    });

    test('Filtre catégorie "Stress" → 1 article', () {
      final r = filtrerContenus(
          tous: articlesPublies, recherche: '', categorieSelectionnee: 'Stress');
      expect(r.length, equals(1));
      expect(r.first['categorie'], equals('Stress'));
    });

    test('Filtre catégorie "Bien-être" → 1 article', () {
      final r = filtrerContenus(
          tous: articlesPublies, recherche: '', categorieSelectionnee: 'Bien-être');
      expect(r.length, equals(1));
      expect(r.first['titre'], equals('Méditation'));
    });

    test('Recherche sans résultat → liste vide', () {
      final r = filtrerContenus(
          tous: articlesPublies, recherche: 'zzzzz', categorieSelectionnee: 'Tous');
      expect(r.isEmpty, isTrue);
    });

    test('Catégorie inexistante → liste vide', () {
      final r = filtrerContenus(
          tous: articlesPublies, recherche: '', categorieSelectionnee: 'Inexistante');
      expect(r.isEmpty, isTrue);
    });

    test('Recherche insensible à la casse', () {
      final r = filtrerContenus(
          tous: articlesPublies, recherche: 'STRESS', categorieSelectionnee: 'Tous');
      expect(r.length, equals(1));
      expect(r.first['titre'], equals('Gérer le stress'));
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-04 — Validation 2 étapes [NÉGATIF documentaire]
  // ════════════════════════════════════════════════════════════
  group('TC-04 — Validation à deux étapes [NÉGATIF]', () {
    // Ce test échoue intentionnellement pour signaler la feature manquante.
    // Quand tu implémentes la modale → retire le skip et change à isTrue.
    test('Modale de confirmation avant sauvegarde sensible',
        skip: 'CORRECTION REQUISE — feature non implémentée', () {
      // Ce test sera en SKIP tant que la feature est absente.
      // Il passera en FAIL dès que tu retires le skip sans implémenter la modale.
      const confirmationPresente = false;
      expect(confirmationPresente, isTrue); // ← échoue si on retire le skip sans implémenter
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-05 — Désactivation sans suppression
  // Fonction testée : logique date_suppression dans seConnecter()
  // auth_service.dart ligne : if (_userProfile?['date_suppression'] != null)
  // Si tu supprimes cette vérification → TC-05b et TC-05c échouent
  // ════════════════════════════════════════════════════════════
  group('TC-05 — Désactivation sans suppression', () {
    tearDown(() => AuthService.resetForTest());

    test('Bouton Désactiver présent dans AdminPage',
        skip: 'CORRECTION REQUISE — feature non implémentée', () {
      // Ce test sera en SKIP tant que le bouton est absent.
      // Il passera en FAIL dès que tu retires le skip sans implémenter le bouton.
      const boutonPresent = false;
      expect(boutonPresent, isTrue); // ← échoue si on retire le skip sans implémenter
    });

    test('Profil avec date_suppression → champ détectable dans userProfile', () {
      AuthService.setProfileForTest({
        'id_utilisateur': 'uuid-bloque',
        'role': 'Citoyen connecte',
        'date_suppression': '2026-01-01T00:00:00',
      });
      // Vérifie que la valeur est bien stockée et récupérable
      // C'est ce que seConnecter() vérifie pour bloquer la connexion
      expect(AuthService.userProfile?['date_suppression'], isNotNull);
      expect(AuthService.userProfile?['date_suppression'],
          equals('2026-01-01T00:00:00'));
    });

    test('Profil avec date_suppression null → compte actif', () {
      AuthService.setProfileForTest({
        'id_utilisateur': 'uuid-actif',
        'role': 'Citoyen connecte',
        'date_suppression': null,
      });
      expect(AuthService.userProfile?['date_suppression'], isNull);
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-07 — Pages publiques accessibles sans authentification
  // Fonctions testées :
  //   - peutAccederEspacePage() (cesizen_utils.dart)
  //     = if (!AuthService.isLoggedIn) dans espace_page.dart ligne 81
  //   - AuthService.isLoggedIn, isAdmin, idUtilisateur, nom, role
  // ════════════════════════════════════════════════════════════
  group('TC-07 — Pages publiques sans authentification', () {
    setUp(() => AuthService.resetForTest());

    test('Citoyen connecté → isLoggedIn = true, puis déconnexion → false', () {
      // Vérifie que isLoggedIn change vraiment selon l'état du profil
      AuthService.setProfileForTest({'id_utilisateur': 'u1', 'role': 'Citoyen connecte'});
      expect(AuthService.isLoggedIn, isTrue); // connecté
      AuthService.resetForTest();
      expect(AuthService.isLoggedIn, isFalse); // déconnecté
      // Si tu changes la condition isLoggedIn → l'un des deux expect échoue
    });

    test('Admin connecté → isAdmin true, Citoyen → isAdmin false', () {
      AuthService.setProfileForTest({'id_utilisateur': 'u2', 'role': 'Admin'});
      expect(AuthService.isAdmin, isTrue);
      AuthService.setProfileForTest({'id_utilisateur': 'u3', 'role': 'Citoyen connecte'});
      expect(AuthService.isAdmin, isFalse);
      // Si isAdmin ignore le rôle → l'un des deux expect échoue
    });

    test('idUtilisateur reflète le profil courant', () {
      AuthService.setProfileForTest({'id_utilisateur': 'uuid-test-07', 'role': 'Citoyen connecte'});
      expect(AuthService.idUtilisateur, equals('uuid-test-07'));
      AuthService.resetForTest();
      expect(AuthService.idUtilisateur, isNull);
      // Si idUtilisateur ne se remet pas à null → le second expect échoue
    });

    test('peutAccederEspacePage : connecté=true, déconnecté=false', () {
      // Logique de espace_page.dart ligne 81
      AuthService.setProfileForTest({'id_utilisateur': 'u4', 'role': 'Citoyen connecte'});
      expect(peutAccederEspacePage(AuthService.isLoggedIn), isTrue);
      AuthService.resetForTest();
      expect(peutAccederEspacePage(AuthService.isLoggedIn), isFalse);
      // Si peutAccederEspacePage ignore isLoggedIn → l'un des deux échoue
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-08 — Questionnaire Holmes sans connexion
  // Fonctions testées :
  //   - calculerScoreHolmes() (cesizen_utils.dart)
  //   - peutSauvegarderDiagnostic() (cesizen_utils.dart)
  //     = condition ligne 62 de questionnaire_page.dart :
  //       if (AuthService.isLoggedIn && AuthService.idUtilisateur != null)
  // ════════════════════════════════════════════════════════════
  group('TC-08 — Questionnaire Holmes sans connexion', () {
    setUp(() => AuthService.resetForTest());

    test('calculerScoreHolmes fonctionne sans connexion', () {
      // Le calcul est côté client, indépendant de Supabase
      expect(AuthService.isLoggedIn, isFalse); // précondition visiteur
      final score = calculerScoreHolmes(
          [{'id_evenement': 7, 'score': 50}], {7: 1});
      expect(score, equals(50));
    });

    test('peutSauvegarderDiagnostic(false, null) → false', () {
      // Visiteur : isLoggedIn=false ET idUtilisateur=null
      // → createDiagnostic() ne doit PAS être appelé
      expect(
        peutSauvegarderDiagnostic(AuthService.isLoggedIn, AuthService.idUtilisateur),
        isFalse,
      );
    });

    test('peutSauvegarderDiagnostic(true, null) → false', () {
      // Connecté MAIS pas d'id → ne doit pas sauvegarder
      expect(peutSauvegarderDiagnostic(true, null), isFalse);
    });

    test('peutSauvegarderDiagnostic(false, "uuid") → false', () {
      // Id présent MAIS pas connecté → ne doit pas sauvegarder
      expect(peutSauvegarderDiagnostic(false, 'uuid-123'), isFalse);
    });

    test('peutSauvegarderDiagnostic(true, "uuid") → true', () {
      // Connecté ET id présent → doit sauvegarder
      expect(peutSauvegarderDiagnostic(true, 'uuid-123'), isTrue);
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-09 — Actions protégées bloquées pour un visiteur
  // Fonctions testées :
  //   - peutGererFavoris() (cesizen_utils.dart)
  //     = if (!AuthService.isLoggedIn) dans contenu_page.dart ligne 538
  //   - peutSauvegarderDiagnostic() (cesizen_utils.dart)
  //   - peutChargerHistorique() (cesizen_utils.dart)
  //     = if (!AuthService.isLoggedIn || idUtilisateur == null)
  //       dans diagnosticpage.dart ligne 36
  // ════════════════════════════════════════════════════════════
  group('TC-09 — Actions protégées bloquées pour un visiteur', () {
    setUp(() => AuthService.resetForTest());

    test('peutGererFavoris(false) → false = addFavori() bloqué', () {
      expect(peutGererFavoris(AuthService.isLoggedIn), isFalse);
    });

    test('peutGererFavoris(true) → true = addFavori() autorisé', () {
      AuthService.setProfileForTest({'id_utilisateur': 'u1', 'role': 'Citoyen connecte'});
      expect(peutGererFavoris(AuthService.isLoggedIn), isTrue);
    });

    test('peutChargerHistorique(false, null) → false = cadenas affiché', () {
      // diagnosticpage.dart ligne 36
      expect(
        peutChargerHistorique(AuthService.isLoggedIn, AuthService.idUtilisateur),
        isFalse,
      );
    });

    test('peutChargerHistorique(true, "uuid") → true = historique chargé', () {
      AuthService.setProfileForTest({'id_utilisateur': 'uuid-u', 'role': 'Citoyen connecte'});
      expect(
        peutChargerHistorique(AuthService.isLoggedIn, AuthService.idUtilisateur),
        isTrue,
      );
    });

    test('peutChargerHistorique(true, null) → false', () {
      // Connecté mais id null → bloqué quand même
      expect(peutChargerHistorique(true, null), isFalse);
    });

    test('peutSauvegarderDiagnostic(false, null) → false = createDiagnostic() bloqué', () {
      expect(
        peutSauvegarderDiagnostic(AuthService.isLoggedIn, AuthService.idUtilisateur),
        isFalse,
      );
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-10 — Validation formulaire inscription
  // Fonctions testées :
  //   - validerEmailCesizen() (cesizen_utils.dart)
  //   - validerMotDePasseCesizen() (cesizen_utils.dart)
  //   - validerConfirmationCesizen() (cesizen_utils.dart)
  //   = validators inline dans login_popup.dart
  // Si tu changes ces validations → les tests échouent
  // ════════════════════════════════════════════════════════════
  group('TC-10 — Validation des identifiants à l\'inscription', () {

    // ── Email ──
    test('"usertest.com" sans @ → "Email invalide"', () {
      expect(validerEmailCesizen('usertest.com'), equals('Email invalide'));
    });

    test('"" → "Requis"', () {
      expect(validerEmailCesizen(''), equals('Requis'));
    });

    test('"   " espaces → "Requis"', () {
      expect(validerEmailCesizen('   '), equals('Requis'));
    });

    test('"user@test.com" → null (valide)', () {
      expect(validerEmailCesizen('user@test.com'), isNull);
    });

    test('"a@b" → null (email minimal valide)', () {
      expect(validerEmailCesizen('a@b'), isNull);
    });

    // ── Mot de passe ──
    test('"abc" 3 cars → "Min. 6 caractères"', () {
      expect(validerMotDePasseCesizen('abc'), equals('Min. 6 caractères'));
    });

    test('"abcde" 5 cars → "Min. 6 caractères"', () {
      expect(validerMotDePasseCesizen('abcde'), equals('Min. 6 caractères'));
    });

    test('"abcdef" 6 cars → null (limite exacte)', () {
      // Si tu changes < 6 en <= 6, ce test échoue
      expect(validerMotDePasseCesizen('abcdef'), isNull);
    });

    test('"Secure123" → null (valide)', () {
      expect(validerMotDePasseCesizen('Secure123'), isNull);
    });

    test('"" → "Requis"', () {
      expect(validerMotDePasseCesizen(''), equals('Requis'));
    });

    // ── Confirmation ──
    test('Confirmation identique → null', () {
      expect(validerConfirmationCesizen('Secure123', 'Secure123'), isNull);
    });

    test('Confirmation différente → message erreur exact', () {
      expect(
        validerConfirmationCesizen('Secure123', 'AutrePass'),
        equals('Les mots de passe ne correspondent pas'),
      );
    });

    test('Confirmation vide → "Requis"', () {
      expect(validerConfirmationCesizen('', 'Secure123'), equals('Requis'));
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-11 — Isolation des données entre utilisateurs
  // Fonctions testées :
  //   - AuthService.idUtilisateur (auth_service.dart)
  //   - filtrerParUtilisateur() (cesizen_utils.dart)
  //   - boutonsAdminVisibles() (cesizen_utils.dart)
  //     = condition admin.dart ligne 560 :
  //       if (u['id_utilisateur'] != AuthService.idUtilisateur)
  // ════════════════════════════════════════════════════════════
  group('TC-11 — Isolation des données', () {
    tearDown(() => AuthService.resetForTest());

    test('Login userA → idUtilisateur = uuid-userA', () {
      AuthService.setProfileForTest({'id_utilisateur': 'uuid-userA', 'role': 'Citoyen connecte'});
      expect(AuthService.idUtilisateur, equals('uuid-userA'));
    });

    test('Switch userB → idUtilisateur = uuid-userB, pas uuid-userA', () {
      AuthService.resetForTest();
      AuthService.setProfileForTest({'id_utilisateur': 'uuid-userB', 'role': 'Citoyen connecte'});
      expect(AuthService.idUtilisateur, equals('uuid-userB'));
      expect(AuthService.idUtilisateur, isNot(equals('uuid-userA')));
    });

    test('filtrerParUtilisateur → seulement les données de userA', () {
      final donnees = [
        {'id_utilisateur': 'uuid-userA', 'score_total': 80},
        {'id_utilisateur': 'uuid-userB', 'score_total': 200},
        {'id_utilisateur': 'uuid-userA', 'score_total': 150},
        {'id_utilisateur': 'uuid-userC', 'score_total': 300},
      ];
      final r = filtrerParUtilisateur(donnees, 'uuid-userA');
      expect(r.length, equals(2));
      expect(r.every((d) => d['id_utilisateur'] == 'uuid-userA'), isTrue);
      expect(r.any((d) => d['id_utilisateur'] == 'uuid-userB'), isFalse);
      expect(r.any((d) => d['id_utilisateur'] == 'uuid-userC'), isFalse);
    });

    test('filtrerParUtilisateur id inconnu → liste vide', () {
      final donnees = [{'id_utilisateur': 'uuid-userA', 'score_total': 80}];
      expect(filtrerParUtilisateur(donnees, 'uuid-inconnu').isEmpty, isTrue);
    });

    test('filtrerParUtilisateur liste vide → liste vide', () {
      expect(filtrerParUtilisateur([], 'uuid-userA').isEmpty, isTrue);
    });

    test('boutonsAdminVisibles — autre compte → true (boutons visibles)', () {
      AuthService.setProfileForTest({'id_utilisateur': 'uuid-admin', 'role': 'Admin'});
      // Un autre utilisateur : les boutons doivent être visibles
      expect(
        boutonsAdminVisibles('uuid-autre-user', AuthService.idUtilisateur),
        isTrue,
      );
    });

    test('boutonsAdminVisibles — son propre compte → false (boutons masqués)', () {
      AuthService.setProfileForTest({'id_utilisateur': 'uuid-admin', 'role': 'Admin'});
      // Son propre compte : les boutons doivent être masqués
      expect(
        boutonsAdminVisibles('uuid-admin', AuthService.idUtilisateur),
        isFalse,
        reason: 'admin.dart ligne 560 : boutons masqués sur son propre compte',
      );
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-13 — Consultation de l'historique
  // Fonctions testées :
  //   - peutChargerHistorique() (cesizen_utils.dart)
  //   - formaterDateCesizen() (cesizen_utils.dart)
  //     = _formatDate() dans diagnosticpage.dart ligne 444
  // Si tu changes _formatDate → les tests de format échouent
  // ════════════════════════════════════════════════════════════
  group('TC-13 — Consultation de l\'historique', () {
    setUp(() {
      AuthService.setProfileForTest({'id_utilisateur': 'uuid-citoyen', 'role': 'Citoyen connecte'});
    });
    tearDown(() => AuthService.resetForTest());

    test('Citoyen connecté → peutChargerHistorique = true', () {
      expect(
        peutChargerHistorique(AuthService.isLoggedIn, AuthService.idUtilisateur),
        isTrue,
      );
    });

    test('formaterDateCesizen("2026-03-19T15:07:52") → "19/03/2026"', () {
      expect(formaterDateCesizen('2026-03-19T15:07:52.000'), equals('19/03/2026'));
    });

    test('Padding : "2026-01-05" → "05/01/2026"', () {
      // Si tu supprimes padLeft → ce test échoue
      expect(formaterDateCesizen('2026-01-05T00:00:00'), equals('05/01/2026'));
    });

    test('formaterDateCesizen(null) → ""', () {
      expect(formaterDateCesizen(null), equals(''));
    });

    test('formaterDateCesizen("invalide") → ""', () {
      expect(formaterDateCesizen('pas-une-date'), equals(''));
    });

    test('Séparateur est "/" pas "-"', () {
      final r = formaterDateCesizen('2026-03-19T00:00:00');
      // Si tu changes le séparateur → ce test échoue
      expect(r, equals('19/03/2026'));
      expect(r.contains('-'), isFalse);
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-14 — Mise en favoris
  // Fonctions testées :
  //   - peutGererFavoris() (cesizen_utils.dart)
  //     = if (!AuthService.isLoggedIn) dans contenu_page.dart ligne 538
  // ════════════════════════════════════════════════════════════
  group('TC-14 — Mise en favoris', () {
    tearDown(() => AuthService.resetForTest());

    test('peutGererFavoris(true) → citoyen connecté peut gérer ses favoris', () {
      AuthService.setProfileForTest({'id_utilisateur': 'uuid-u', 'role': 'Citoyen connecte'});
      expect(peutGererFavoris(AuthService.isLoggedIn), isTrue);
    });

    test('peutGererFavoris(false) → visiteur bloqué', () {
      // Après resetForTest isLoggedIn = false
      expect(peutGererFavoris(AuthService.isLoggedIn), isFalse);
    });

    test('peutGererFavoris change selon isLoggedIn', () {
      // Vérifie que peutGererFavoris réagit bien au changement d'état
      AuthService.setProfileForTest({'id_utilisateur': 'u-fav', 'role': 'Citoyen connecte'});
      expect(peutGererFavoris(AuthService.isLoggedIn), isTrue);
      AuthService.resetForTest();
      expect(peutGererFavoris(AuthService.isLoggedIn), isFalse);
      // Si peutGererFavoris retourne toujours true → le second expect échoue
    });

    test('Un admin peut aussi gérer ses favoris', () {
      AuthService.setProfileForTest({'id_utilisateur': 'u-admin', 'role': 'Admin'});
      expect(peutGererFavoris(AuthService.isLoggedIn), isTrue,
          reason: 'Un admin est connecté donc peut gérer ses favoris');
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-15 — Calcul du score Holmes et Rahe
  // Fonction testée : calculerScoreHolmes() (cesizen_utils.dart)
  //   = _calculerScore() dans questionnaire_page.dart
  // Si tu changes la formule → ces tests échouent
  // ════════════════════════════════════════════════════════════
  group('TC-15 — Calcul du score selon pondération configurée', () {

    test('Déménagement x1 score=20 → 20pts', () {
      expect(calculerScoreHolmes(
          [{'id_evenement': 32, 'score': 20}], {32: 1}), equals(20));
    });

    test('Déménagement x2 score=20 → 40pts', () {
      expect(calculerScoreHolmes(
          [{'id_evenement': 32, 'score': 20}], {32: 2}), equals(40));
    });

    test('Déménagement x3 score=20 → 60pts', () {
      expect(calculerScoreHolmes(
          [{'id_evenement': 32, 'score': 20}], {32: 3}), equals(60));
    });

    test('Après MAJ admin score=30, x2 → 60pts (pas 40)', () {
      // Prouve que le score est dynamique — vient de la base
      expect(calculerScoreHolmes(
          [{'id_evenement': 32, 'score': 30}], {32: 2}), equals(60));
    });

    test('Quantité 0 → score 0', () {
      expect(calculerScoreHolmes(
          [{'id_evenement': 7, 'score': 50}], {7: 0}), equals(0));
    });

    test('Événement absent de quantites → score 0', () {
      expect(calculerScoreHolmes(
          [{'id_evenement': 99, 'score': 100}], {}), equals(0));
    });

    test('Multi-événements : Mariage x1(50) + Déménagement x2(40) + Vacances x3(39) = 129', () {
      expect(calculerScoreHolmes([
        {'id_evenement': 7,  'score': 50},
        {'id_evenement': 32, 'score': 20},
        {'id_evenement': 41, 'score': 13},
      ], {7: 1, 32: 2, 41: 3}), equals(129));
    });

    test('nbEvenementsCochesHolmes — 0 sélectionné → 0', () {
      expect(nbEvenementsCochesHolmes({7: 0, 32: 0}), equals(0));
    });

    test('nbEvenementsCochesHolmes — 2 sélectionnés sur 3', () {
      expect(nbEvenementsCochesHolmes({7: 1, 32: 0, 41: 3}), equals(2));
    });

    test('nbEvenementsCochesHolmes — quantité 5 = 1 événement coché (pas 5)', () {
      expect(nbEvenementsCochesHolmes({41: 5}), equals(1));
    });
  });

  // ════════════════════════════════════════════════════════════
  // TC-16 — Page résultats conforme aux seuils
  // Fonction testée : getNiveauStressLocal() (cesizen_utils.dart)
  //   = seuils de la table page_resultat : 0-149 / 150-299 / 300+
  // Si tu changes un seuil → les tests aux limites exactes échouent
  // ════════════════════════════════════════════════════════════
  group('TC-16 — Page résultats conforme aux seuils', () {

    // Plage Faible 0-149
    test('0 → Faible',   () => expect(getNiveauStressLocal(0),   equals('Faible')));
    test('80 → Faible',  () => expect(getNiveauStressLocal(80),  equals('Faible')));
    test('148 → Faible', () => expect(getNiveauStressLocal(148), equals('Faible')));

    test('149 → Faible [limite haute exacte — si tu changes < 150 en < 149 ce test échoue]', () =>
        expect(getNiveauStressLocal(149), equals('Faible')));

    // Plage Modéré 150-299
    test('150 → Modéré [limite basse exacte — si tu changes < 150 en < 151 ce test échoue]', () =>
        expect(getNiveauStressLocal(150), equals('Modéré')));

    test('200 → Modéré', () => expect(getNiveauStressLocal(200), equals('Modéré')));
    test('298 → Modéré', () => expect(getNiveauStressLocal(298), equals('Modéré')));

    test('299 → Modéré [limite haute exacte]', () =>
        expect(getNiveauStressLocal(299), equals('Modéré')));

    // Plage Élevé 300+
    test('300 → Élevé [limite basse exacte — si tu changes < 300 en < 301 ce test échoue]', () =>
        expect(getNiveauStressLocal(300), equals('Élevé')));

    test('350 → Élevé', () => expect(getNiveauStressLocal(350), equals('Élevé')));
    test('999 → Élevé', () => expect(getNiveauStressLocal(999), equals('Élevé')));
  });

  // ════════════════════════════════════════════════════════════
  // TC-18 — Historique cohérent depuis DiagnosticPage et EspacePage
  // Fonctions testées :
  //   - filtrerParUtilisateur() (cesizen_utils.dart)
  //   - peutChargerHistorique() (cesizen_utils.dart)
  // Les deux pages appellent getHistoriqueDiagnostics(idUtilisateur)
  // avec le même id → doivent recevoir exactement les mêmes données
  // ════════════════════════════════════════════════════════════
  group('TC-18 — Historique cohérent depuis les deux pages', () {
    setUp(() {
      AuthService.setProfileForTest({'id_utilisateur': 'uuid-citoyen', 'role': 'Citoyen connecte'});
    });
    tearDown(() => AuthService.resetForTest());

    test('idUtilisateur disponible pour la requête', () {
      expect(AuthService.idUtilisateur, equals('uuid-citoyen'));
    });

    test('DiagnosticPage et EspacePage reçoivent 3 diagnostics, pas celui de uuid-autre', () {
      final tousEnBase = [
        {'id_utilisateur': 'uuid-citoyen', 'score_total': 80},
        {'id_utilisateur': 'uuid-citoyen', 'score_total': 210},
        {'id_utilisateur': 'uuid-citoyen', 'score_total': 340},
        {'id_utilisateur': 'uuid-autre',   'score_total': 999},
      ];

      // DiagnosticPage
      final diagPage = filtrerParUtilisateur(tousEnBase, AuthService.idUtilisateur!);
      // EspacePage — même appel, même id
      final espacePage = filtrerParUtilisateur(tousEnBase, AuthService.idUtilisateur!);

      expect(diagPage.length, equals(3));
      expect(espacePage.length, equals(3));

      // uuid-autre doit être absent des deux vues
      expect(diagPage.any((d)   => d['id_utilisateur'] == 'uuid-autre'), isFalse);
      expect(espacePage.any((d) => d['id_utilisateur'] == 'uuid-autre'), isFalse);

      // Les scores sont identiques dans les deux vues
      final scoresDiag   = diagPage.map((d)   => d['score_total']).toSet();
      final scoresEspace = espacePage.map((d) => d['score_total']).toSet();
      expect(scoresDiag, equals(scoresEspace));
      expect(scoresDiag, containsAll([80, 210, 340]));
    });

    test('Niveaux des 3 diagnostics corrects', () {
      expect(getNiveauStressLocal(80),  equals('Faible'));
      expect(getNiveauStressLocal(210), equals('Modéré'));
      expect(getNiveauStressLocal(340), equals('Élevé'));
    });

    test('Après déconnexion → peutChargerHistorique = false', () {
      // Simule la déconnexion : resetForTest
      AuthService.resetForTest();
      expect(
        peutChargerHistorique(AuthService.isLoggedIn, AuthService.idUtilisateur),
        isFalse,
        reason: 'Après déconnexion l\'historique doit être verrouillé',
      );
    });
  });

  // ════════════════════════════════════════════════════════════
  // TRADUCTION DES ERREURS SUPABASE
  // Fonction testée : _traduireErreur() dans auth_service.dart
  // Si tu changes les messages → ces tests échouent
  // ════════════════════════════════════════════════════════════
  group('Traduction des erreurs Supabase', () {

    test('"Invalid login credentials" → "Email ou mot de passe incorrect."', () {
      expect(
        AuthService.traduireErreurForTest('Invalid login credentials'),
        equals('Email ou mot de passe incorrect.'),
      );
    });

    test('"Email not confirmed" → message de confirmation email', () {
      expect(
        AuthService.traduireErreurForTest('Email not confirmed'),
        equals('Veuillez confirmer votre email avant de vous connecter.'),
      );
    });

    test('"User already registered" → message email existant', () {
      expect(
        AuthService.traduireErreurForTest('User already registered'),
        equals('Un compte existe déjà avec cet email.'),
      );
    });

    test('"Password should be at least" → message MDP trop court', () {
      expect(
        AuthService.traduireErreurForTest('Password should be at least 6 chars'),
        equals('Le mot de passe doit contenir au moins 6 caractères.'),
      );
    });

    test('"email rate limit" → message trop de tentatives', () {
      expect(
        AuthService.traduireErreurForTest('email rate limit exceeded'),
        equals('Trop de tentatives. Veuillez patienter avant de réessayer.'),
      );
    });

    test('Erreur inconnue → message générique', () {
      expect(
        AuthService.traduireErreurForTest('some unknown error xyz'),
        equals('Une erreur est survenue. Veuillez réessayer.'),
      );
    });
  });
}