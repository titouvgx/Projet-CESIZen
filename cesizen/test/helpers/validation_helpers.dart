// ─────────────────────────────────────────────────────────────
// HELPERS — Fonctions de validation des formulaires
// À placer dans : test/helpers/validation_helpers.dart
// ─────────────────────────────────────────────────────────────

/// Valide un email — retourne null si valide, message d'erreur sinon
String? validerEmail(String? value) {
  if (value == null || value.isEmpty) return 'Ce champ est requis';
  if (!value.contains('@')) return 'Email invalide';
  return null;
}

/// Valide un mot de passe — retourne null si valide, message d'erreur sinon
String? validerMotDePasse(String? value) {
  if (value == null || value.isEmpty) return 'Ce champ est requis';
  if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères.';
  return null;
}

/// Valide un champ nom — retourne null si valide, message d'erreur sinon
String? validerNom(String? value) {
  if (value == null || value.isEmpty) return 'Ce champ est requis';
  return null;
}

/// Valide la confirmation de mot de passe
String? validerConfirmation(String? value, String motDePasse) {
  if (value == null || value.isEmpty) return 'Ce champ est requis';
  if (value != motDePasse) return 'Les mots de passe ne correspondent pas';
  return null;
}
