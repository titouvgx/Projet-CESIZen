import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────
// SERVICE D'AUTHENTIFICATION
// Singleton — accessible depuis toute l'app
// ─────────────────────────────────────────────
class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ── Utilisateur courant ──────────────────────
  // Retourne les infos Supabase Auth de l'utilisateur connecté
  static User? get currentAuthUser => _client.auth.currentUser;

  // Retourne les infos métier depuis ta table utilisateur
  static Map<String, dynamic>? _userProfile;
  static Map<String, dynamic>? get userProfile => _userProfile;

  // ── État de connexion ────────────────────────
  static bool get isLoggedIn => currentAuthUser != null;
  static bool get isAdmin => _userProfile?['role'] == 'Admin';
  static bool get isCitoyen => _userProfile?['role'] == 'Citoyen connecte';
  static String? get role => _userProfile?['role'] as String?;
  static String? get nom => _userProfile?['nom'] as String?;
  static String? get idUtilisateur => currentAuthUser?.id;

  // ── Connexion ────────────────────────────────
  static Future<AuthResult> seConnecter({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Connexion via Supabase Auth
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.error('Email ou mot de passe incorrect.');
      }

      // 2. Récupère le profil depuis ta table utilisateur
      await _chargerProfil(response.user!.id);

      // 3. Vérifie que le compte n'est pas supprimé
      if (_userProfile?['date_suppression'] != null) {
        await seDeconnecter();
        return AuthResult.error('Ce compte a été désactivé.');
      }

      return AuthResult.success(role: _userProfile?['role'] ?? '');

    } on AuthException catch (e) {
      return AuthResult.error(_traduireErreur(e.message));
    } catch (e) {
      return AuthResult.error('Une erreur est survenue. Veuillez réessayer.');
    }
  }

  // ── Inscription ──────────────────────────────
  static Future<AuthResult> sInscrire({
    required String nom,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Crée le compte Supabase Auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.error('Erreur lors de la création du compte.');
      }

      // 2. Crée l'entrée dans ta table utilisateur
      await _client.from('utilisateur').insert({
        'id_utilisateur': response.user!.id,
        'nom': nom,
        'email': email,
        'role': 'Citoyen connecte',
      });

      // 3. Charge le profil
      await _chargerProfil(response.user!.id);

      return AuthResult.success(role: 'Citoyen connecte');

    } on AuthException catch (e) {
      return AuthResult.error(_traduireErreur(e.message));
    } catch (e) {
      return AuthResult.error('Une erreur est survenue. Veuillez réessayer.');
    }
  }

  // ── Déconnexion ──────────────────────────────
  static Future<void> seDeconnecter() async {
    await _client.auth.signOut();
    _userProfile = null;
  }

  // ── Chargement du profil ─────────────────────
  static Future<void> _chargerProfil(String idUtilisateur) async {
    try {
      final data = await _client
          .from('utilisateur')
          .select()
          .eq('id_utilisateur', idUtilisateur)
          .maybeSingle();
      _userProfile = data;
    } catch (e) {
      print('❌ Erreur chargement profil : $e');
    }
  }

  // ── Restaure la session au démarrage ─────────
  // À appeler dans main.dart après Supabase.initialize
  static Future<void> restaurerSession() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      await _chargerProfil(user.id);
    }
  }

  // ── Traduction des erreurs Supabase ──────────
  static String _traduireErreur(String message) {
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
    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}

// ─────────────────────────────────────────────
// RÉSULTAT D'AUTHENTIFICATION
// ─────────────────────────────────────────────
class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? role;

  const AuthResult._({required this.success, this.errorMessage, this.role});

  factory AuthResult.success({required String role}) =>
      AuthResult._(success: true, role: role);

  factory AuthResult.error(String message) =>
      AuthResult._(success: false, errorMessage: message);
}