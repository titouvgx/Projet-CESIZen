// ─────────────────────────────────────────────
// UTILITAIRES CESIZEN
// lib/utils/cesizen_utils.dart
//
// Fonctions pures extraites EXACTEMENT du code de l'app.
// Les tests importent CE fichier — si tu modifies une règle
// métier ici, les tests échouent automatiquement.
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// CALCUL SCORE HOLMES ET RAHE
// Source : _QuestionnairePageState._calculerScore()
// questionnaire_page.dart
// ─────────────────────────────────────────────

/// Calcule le score total Holmes et Rahe.
/// Formule : somme de (quantites[id] ?? 0) * score pour chaque événement.
int calculerScoreHolmes(
  List<Map<String, dynamic>> evenements,
  Map<int, int> quantites,
) {
  int total = 0;
  for (final ev in evenements) {
    final id    = ev['id_evenement'] as int;
    final score = ev['score'] as int;
    total += (quantites[id] ?? 0) * score;
  }
  return total;
}

/// Retourne le nombre d'événements avec quantité > 0.
/// Source : _nbEvenementsCoches dans questionnaire_page.dart
int nbEvenementsCochesHolmes(Map<int, int> quantites) =>
    quantites.values.where((q) => q > 0).length;

// ─────────────────────────────────────────────
// NIVEAUX DE STRESS
// Source : seuils de la table page_resultat en base
// Faible : 0-149 | Modéré : 150-299 | Élevé : 300+
// ─────────────────────────────────────────────

/// Détermine le niveau de stress à partir d'un score Holmes.
String getNiveauStressLocal(int score) {
  if (score < 150) return 'Faible';
  if (score < 300) return 'Modéré';
  return 'Élevé';
}

// ─────────────────────────────────────────────
// VALIDATIONS FORMULAIRES
// Source : validator: inline dans login_popup.dart
// ─────────────────────────────────────────────

/// Valide un email.
/// Retourne null si valide, message d'erreur sinon.
String? validerEmailCesizen(String? value) {
  if (value == null || value.trim().isEmpty) return 'Requis';
  if (!value.contains('@')) return 'Email invalide';
  return null;
}

/// Valide un mot de passe (min 6 caractères).
String? validerMotDePasseCesizen(String? value) {
  if (value == null || value.isEmpty) return 'Requis';
  if (value.length < 6) return 'Min. 6 caractères';
  return null;
}

/// Valide un champ nom (non vide).
String? validerNomCesizen(String? value) {
  if (value == null || value.trim().isEmpty) return 'Requis';
  return null;
}

/// Valide la confirmation du mot de passe.
String? validerConfirmationCesizen(String? value, String motDePasse) {
  if (value == null || value.isEmpty) return 'Requis';
  if (value != motDePasse) return 'Les mots de passe ne correspondent pas';
  return null;
}

// ─────────────────────────────────────────────
// FILTRAGE CONTENUS
// Source : _contenusFiltres dans contenu_page.dart lignes 57-63
//
// ⚠️ IMPORTANT : cette fonction reproduit EXACTEMENT _contenusFiltres.
// getContenuPublie() filtre déjà sur statut='publié' côté Supabase.
// Donc ici on ne filtre PAS sur statut_publication — les données
// en entrée sont déjà des articles publiés.
// ─────────────────────────────────────────────

/// Filtre les articles selon la recherche et la catégorie.
/// Reproduit exactement _contenusFiltres dans contenu_page.dart.
List<Map<String, dynamic>> filtrerContenus({
  required List<Map<String, dynamic>> tous,
  required String recherche,
  required String categorieSelectionnee,
}) {
  return tous.where((c) {
    // Filtre catégorie — ligne 59-60 de contenu_page.dart
    final matchCategorie = categorieSelectionnee == 'Tous' ||
        c['categorie'] == categorieSelectionnee;

    // Filtre recherche — ligne 61-63 de contenu_page.dart
    final matchRecherche = recherche.isEmpty ||
        (c['titre'] as String? ?? '').toLowerCase().contains(recherche.toLowerCase()) ||
        (c['categorie'] as String? ?? '').toLowerCase().contains(recherche.toLowerCase());

    return matchCategorie && matchRecherche;
  }).toList();
}

// ─────────────────────────────────────────────
// FORMATAGE DATE
// Source : _formatDate() dans diagnosticpage.dart ligne 444-449
// ─────────────────────────────────────────────

/// Formate une date ISO en jj/mm/aaaa.
/// Retourne '' si la date est null ou invalide.
String formaterDateCesizen(String? d) {
  if (d == null) return '';
  final date = DateTime.tryParse(d);
  if (date == null) return '';
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

// ─────────────────────────────────────────────
// GARDES D'ACCÈS
// Source : conditions extraites directement des pages
// Ces fonctions centralisent les règles d'accès testables.
// ─────────────────────────────────────────────

/// Détermine si un favori peut être ajouté/retiré.
/// Source : _toggleFavori() dans contenu_page.dart ligne 538 :
///   if (!AuthService.isLoggedIn) → bloquer
bool peutGererFavoris(bool isLoggedIn) => isLoggedIn;

/// Détermine si un diagnostic peut être sauvegardé.
/// Source : questionnaire_page.dart ligne 62 :
///   if (AuthService.isLoggedIn && AuthService.idUtilisateur != null)
bool peutSauvegarderDiagnostic(bool isLoggedIn, String? idUtilisateur) =>
    isLoggedIn && idUtilisateur != null;

/// Détermine si l'historique doit être chargé ou bloqué.
/// Source : diagnosticpage.dart ligne 36 :
///   if (!AuthService.isLoggedIn || AuthService.idUtilisateur == null) → return
bool peutChargerHistorique(bool isLoggedIn, String? idUtilisateur) =>
    isLoggedIn && idUtilisateur != null;

/// Détermine si EspacePage affiche le contenu ou l'invitation.
/// Source : espace_page.dart ligne 81 :
///   if (!AuthService.isLoggedIn) → afficher invitation
bool peutAccederEspacePage(bool isLoggedIn) => isLoggedIn;

/// Détermine si les boutons admin (modifier/supprimer) sont visibles.
/// Source : admin.dart ligne 560 :
///   if (u['id_utilisateur'] != AuthService.idUtilisateur) → afficher boutons
bool boutonsAdminVisibles(String idUtilisateurLigne, String? idAdminConnecte) =>
    idUtilisateurLigne != idAdminConnecte;

/// Calcule le nouveau statut après toggle publication.
/// Source : _togglePublication() dans admin.dart ligne 624 :
///   final nouveau = statut == 'publié' ? 'brouillon' : 'publié';
String toggleStatutPublication(String statutActuel) =>
    statutActuel == 'publié' ? 'brouillon' : 'publié';

// ─────────────────────────────────────────────
// ISOLATION DONNÉES
// Source : filtre WHERE id_utilisateur = X dans Supabase
// Reproduit le comportement de getHistoriqueDiagnostics(id)
// ─────────────────────────────────────────────

/// Filtre une liste par id_utilisateur.
List<Map<String, dynamic>> filtrerParUtilisateur(
  List<Map<String, dynamic>> donnees,
  String idUtilisateur,
) =>
    donnees.where((d) => d['id_utilisateur'] == idUtilisateur).toList();