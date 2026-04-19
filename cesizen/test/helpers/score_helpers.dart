// ─────────────────────────────────────────────────────────────
// HELPERS — Fonctions extraites de questionnaire_page.dart
// À placer dans : test/helpers/score_helpers.dart
// ─────────────────────────────────────────────────────────────

/// Calcule le score total Holmes et Rahe
/// evenements : liste des événements [{id_evenement, score, ...}]
/// quantites  : Map<id_evenement, nombre_de_fois>
int calculerScore(
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

/// Retourne le nombre d'événements avec quantité > 0
int nbEvenementsCochs(Map<int, int> quantites) {
  return quantites.values.where((q) => q > 0).length;
}

/// Détermine le niveau de stress selon le score
/// Seuils : < 150 = Faible | 150-299 = Modéré | >= 300 = Élevé
String getNiveauStress(int score) {
  if (score < 150) return 'Faible';
  if (score < 300) return 'Modéré';
  return 'Élevé';
}

/// Formate une date ISO en jj/mm/aaaa
String formaterDate(String? dateStr) {
  if (dateStr == null) return '';
  final date = DateTime.tryParse(dateStr);
  if (date == null) return '';
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
