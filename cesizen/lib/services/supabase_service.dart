import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────
// SERVICE SUPABASE
// ─────────────────────────────────────────────
class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ─────────────────────────────────────────────
  // ÉVÉNEMENTS HOLMES ET RAHE
  // ─────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getEvenementsHolmes() async {
    final data = await _client
        .from('evenement_holmes')
        .select()
        .order('ordre', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  // ─────────────────────────────────────────────
  // CONTENU
  // ─────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getContenuPublie() async {
    final data = await _client
        .from('contenu')
        .select()
        .eq('statut_publication', 'publié')
        .order('date_creation', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<List<Map<String, dynamic>>> getContenuParCategorie(String categorie) async {
    final data = await _client
        .from('contenu')
        .select()
        .eq('statut_publication', 'publié')
        .eq('categorie', categorie);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<Map<String, dynamic>?> getContenuById(String idContenu) async {
    final data = await _client
        .from('contenu')
        .select()
        .eq('id_contenu', idContenu)
        .maybeSingle();
    return data;
  }

  static Future<List<String>> getCategories() async {
    final data = await _client
        .from('contenu')
        .select('categorie')
        .eq('statut_publication', 'publié');
    final categories = data
        .map((e) => e['categorie'] as String? ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  // ─────────────────────────────────────────────
  // FAVORIS ARTICLES
  // ─────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getFavoris(String idUtilisateur) async {
    final data = await _client
        .from('favori')
        .select('*, contenu(*)')
        .eq('id_utilisateur', idUtilisateur);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> addFavori(String idUtilisateur, String idContenu) async {
    await _client.from('favori').insert({
      'id_utilisateur': idUtilisateur,
      'id_contenu': idContenu,
    });
  }

  static Future<void> removeFavori(String idUtilisateur, String idContenu) async {
    await _client
        .from('favori')
        .delete()
        .eq('id_utilisateur', idUtilisateur)
        .eq('id_contenu', idContenu);
  }

  static Future<bool> isFavori(String idUtilisateur, String idContenu) async {
    final data = await _client
        .from('favori')
        .select()
        .eq('id_utilisateur', idUtilisateur)
        .eq('id_contenu', idContenu)
        .maybeSingle();
    return data != null;
  }

  // ─────────────────────────────────────────────
  // DIAGNOSTIC
  // ─────────────────────────────────────────────

  static Future<String> createDiagnostic(String idUtilisateur) async {
    final data = await _client
        .from('diagnostic')
        .insert({'id_utilisateur': idUtilisateur})
        .select()
        .single();
    return data['id_diagnostic'];
  }

  static Future<void> updateDiagnostic(
    String idDiagnostic,
    int scoreTotal,
    String idPageResultat,
  ) async {
    await _client
        .from('diagnostic')
        .update({
          'score_total': scoreTotal,
          'id_page_resultat': idPageResultat,
        })
        .eq('id_diagnostic', idDiagnostic);
  }

  static Future<List<Map<String, dynamic>>> getHistoriqueDiagnostics(String idUtilisateur) async {
    final data = await _client
        .from('diagnostic')
        .select('*, page_resultat(*)')
        .eq('id_utilisateur', idUtilisateur)
        .order('date_realisation', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<List<Map<String, dynamic>>> getDiagnosticsFavoris(String idUtilisateur) async {
    final data = await _client
        .from('diagnostic')
        .select('*, page_resultat(*)')
        .eq('id_utilisateur', idUtilisateur)
        .eq('est_favori', true)
        .order('date_realisation', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> toggleDiagnosticFavori(String idDiagnostic, bool estFavori) async {
    await _client
        .from('diagnostic')
        .update({'est_favori': estFavori})
        .eq('id_diagnostic', idDiagnostic);
  }

  // ─────────────────────────────────────────────
  // RÉPONSES HOLMES
  // ─────────────────────────────────────────────

  // Sauvegarde les événements cochés
  static Future<void> saveReponsesHolmes(
    String idDiagnostic,
    List<int> idEvenementsCochs,
  ) async {
    if (idEvenementsCochs.isEmpty) return;
    final rows = idEvenementsCochs.map((id) => {
      'id_diagnostic': idDiagnostic,
      'id_evenement': id,
    }).toList();
    await _client.from('reponse').insert(rows);
  }

  // Récupère les réponses d'un diagnostic avec les détails des événements
  static Future<List<Map<String, dynamic>>> getReponsesHolmes(String idDiagnostic) async {
    final data = await _client
        .from('reponse')
        .select('*, evenement_holmes(*)')
        .eq('id_diagnostic', idDiagnostic);
    return List<Map<String, dynamic>>.from(data);
  }

  // ─────────────────────────────────────────────
  // PAGE RÉSULTAT
  // ─────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getPageResultat(int scoreTotal) async {
    final data = await _client
        .from('page_resultat')
        .select()
        .lte('seuil_min', scoreTotal)
        .gte('seuil_max', scoreTotal)
        .maybeSingle();
    return data;
  }

  // ─────────────────────────────────────────────
  // UTILISATEUR
  // ─────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getUtilisateur(String idUtilisateur) async {
    final data = await _client
        .from('utilisateur')
        .select()
        .eq('id_utilisateur', idUtilisateur)
        .maybeSingle();
    return data;
  }

  static Future<void> updateNom(String idUtilisateur, String nouveauNom) async {
    await _client
        .from('utilisateur')
        .update({'nom': nouveauNom})
        .eq('id_utilisateur', idUtilisateur);
  }

  // ─────────────────────────────────────────────
  // CONTACT
  // ─────────────────────────────────────────────

  static Future<void> envoyerMessage({
    required String nom,
    required String email,
    required String sujet,
    required String message,
  }) async {
    await _client.from('contact_message').insert({
      'nom': nom,
      'email': email,
      'sujet': sujet,
      'message': message,
    });
  }
}