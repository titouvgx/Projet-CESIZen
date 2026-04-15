// ─────────────────────────────────────────────
// TESTS UNITAIRES — AuthService & Validators
// Lancer : flutter test test/unit/auth_service_test.dart
// ─────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:cesizen/auth_service.dart';

void main() {

  // ── TU-01 à TU-05 : AuthResult ───────────────
  group('TU-AUTH | AuthResult', () {

    test('TU-01 | success() retourne success=true avec le rôle', () {
      final result = AuthResult.success(role: 'Admin');
      expect(result.success, isTrue);
      expect(result.role, equals('Admin'));
      expect(result.errorMessage, isNull);
    });

    test('TU-02 | error() retourne success=false avec le message', () {
      final result = AuthResult.error('Email invalide');
      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Email invalide'));
      expect(result.role, isNull);
    });

    test('TU-03 | success() avec rôle Citoyen connecte', () {
      final result = AuthResult.success(role: 'Citoyen connecte');
      expect(result.success, isTrue);
      expect(result.role, equals('Citoyen connecte'));
    });

    test('TU-04 | error() avec message vide', () {
      final result = AuthResult.error('');
      expect(result.success, isFalse);
      expect(result.errorMessage, equals(''));
    });

    test('TU-05 | deux AuthResult indépendants ne se partagent pas', () {
      final r1 = AuthResult.success(role: 'Admin');
      final r2 = AuthResult.error('Erreur');
      expect(r1.success, isNot(equals(r2.success)));
    });
  });

  // ── TU-06 à TU-10 : Validators email ─────────
  group('TU-VALID | Validation email', () {

    String? validateEmail(String? value) {
      if (value == null || value.isEmpty) return 'Requis';
      if (!value.contains('@')) return 'Email invalide';
      return null;
    }

    test('TU-06 | email valide retourne null', () {
      expect(validateEmail('jean@exemple.fr'), isNull);
    });

    test('TU-07 | email sans @ retourne erreur', () {
      expect(validateEmail('jeanexemple.fr'), equals('Email invalide'));
    });

    test('TU-08 | email vide retourne Requis', () {
      expect(validateEmail(''), equals('Requis'));
    });

    test('TU-09 | email null retourne Requis', () {
      expect(validateEmail(null), equals('Requis'));
    });

    test('TU-10 | email avec sous-domaine valide', () {
      expect(validateEmail('jean@mail.exemple.fr'), isNull);
    });
  });

  // ── TU-11 à TU-15 : Validators mot de passe ──
  group('TU-VALID | Validation mot de passe', () {

    String? validatePassword(String? value, {bool inscription = true}) {
      if (value == null || value.isEmpty) return 'Requis';
      if (inscription && value.length < 6) return 'Min. 6 caractères';
      return null;
    }

    test('TU-11 | mot de passe valide retourne null', () {
      expect(validatePassword('motdepasse123'), isNull);
    });

    test('TU-12 | mot de passe vide retourne Requis', () {
      expect(validatePassword(''), equals('Requis'));
    });

    test('TU-13 | mot de passe trop court retourne erreur', () {
      expect(validatePassword('abc'), equals('Min. 6 caractères'));
    });

    test('TU-14 | mot de passe exactement 6 caractères valide', () {
      expect(validatePassword('abcdef'), isNull);
    });

    test('TU-15 | mot de passe en mode connexion sans min. longueur', () {
      expect(validatePassword('abc', inscription: false), isNull);
    });
  });

  // ── TU-16 à TU-18 : Validators nom ───────────
  group('TU-VALID | Validation nom complet', () {

    String? validateNom(String? value) {
      if (value == null || value.isEmpty) return 'Requis';
      return null;
    }

    test('TU-16 | nom valide retourne null', () {
      expect(validateNom('Jean Dupont'), isNull);
    });

    test('TU-17 | nom vide retourne Requis', () {
      expect(validateNom(''), equals('Requis'));
    });

    test('TU-18 | nom null retourne Requis', () {
      expect(validateNom(null), equals('Requis'));
    });
  });

  // ── TU-19 à TU-22 : Traduction erreurs ───────
  group('TU-ERR | Traduction erreurs Supabase', () {

    String traduireErreur(String message) {
      if (message.contains('Invalid login credentials')) {
        return 'Email ou mot de passe incorrect.';
      }
      if (message.contains('Email not confirmed')) {
        return 'Veuillez confirmer votre email avant de vous connecter.';
      }
      if (message.contains('User already registered')) {
        return 'Un compte existe déjà avec cet email.';
      }
      if (message.contains('Password should be at least')) {
        return 'Le mot de passe doit contenir au moins 6 caractères.';
      }
      if (message.contains('For security purposes') || message.contains('email rate limit')) {
        return 'Trop de tentatives. Veuillez patienter avant de réessayer.';
      }
      return 'Une erreur est survenue. Veuillez réessayer.';
    }

    test('TU-19 | Invalid login credentials traduit correctement', () {
      expect(traduireErreur('Invalid login credentials'),
          equals('Email ou mot de passe incorrect.'));
    });

    test('TU-20 | Email not confirmed traduit correctement', () {
      expect(traduireErreur('Email not confirmed'),
          equals('Veuillez confirmer votre email avant de vous connecter.'));
    });

    test('TU-21 | User already registered traduit correctement', () {
      expect(traduireErreur('User already registered'),
          equals('Un compte existe déjà avec cet email.'));
    });

    test('TU-22 | erreur inconnue retourne message générique', () {
      expect(traduireErreur('Some unknown error'),
          equals('Une erreur est survenue. Veuillez réessayer.'));
    });

    test('TU-23 | rate limit traduit correctement', () {
      expect(traduireErreur('For security purposes, you can only request this once every 60 seconds'),
          equals('Trop de tentatives. Veuillez patienter avant de réessayer.'));
    });
  });
}