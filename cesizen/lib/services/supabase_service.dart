import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// SERVICE SUPABASE — Point d'accès unique à la base de données
// Utilisation : SupabaseService.getQuestions()
// ============================================================

class SupabaseService {
  // Client Supabase accessible partout
  static final SupabaseClient _client = Supabase.instance.client;

  // ─────────────────────────────────────────────
  // QUESTIONS
  // ─────────────────────────────────────────────

  // Récupère toutes les questions actives
  static Future<List<Map<String, dynamic>>> getQuestions() async {
    final data = await _client
        .from('question')
        .select()
        .eq('active', true);
    return List<Map<String, dynamic>>.from(data);
  }

  // Récupère toutes les questions (actives et inactives) — pour l'admin
  static Future<List<Map<String, dynamic>>> getAllQuestions() async {
    final data = await _client
        .from('question')
        .select();
    return List<Map<String, dynamic>>.from(data);
  }

  // ─────────────────────────────────────────────
  // CHOIX DE RÉPONSE
  // ─────────────────────────────────────────────

  // Récupère les 5 choix de réponse (Jamais → Toujours)
  static Future<List<Map<String, dynamic>>> getChoixReponse() async {
    final data = await _client
        .from('choix_reponse')
        .select()
        .order('id_choix', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  // ─────────────────────────────────────────────
  // CONTENU
  // ─────────────────────────────────────────────

  // Récupère tous les contenus publiés
  static Future<List<Map<String, dynamic>>> getContenuPublie() async {
    final data = await _client
        .from('contenu')
        .select()
        .eq('statut_publication', 'publié')
        .order('date_creation', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  // Récupère les contenus par catégorie
  static Future<List<Map<String, dynamic>>> getContenuParCategorie(String categorie) async {
    final data = await _client
        .from('contenu')
        .select()
        .eq('statut_publication', 'publié')
        .eq('categorie', categorie);
    return List<Map<String, dynamic>>.from(data);
  }

  // Récupère un contenu par son id
  static Future<Map<String, dynamic>?> getContenuById(String idContenu) async {
    final data = await _client
        .from('contenu')
        .select()
        .eq('id_contenu', idContenu)
        .maybeSingle();
    return data;
  }

  // ─────────────────────────────────────────────
  // FAVORIS
  // ─────────────────────────────────────────────

  // Récupère les favoris d'un utilisateur avec les détails du contenu
  static Future<List<Map<String, dynamic>>> getFavoris(String idUtilisateur) async {
    final data = await _client
        .from('favori')
        .select('*, contenu(*)')
        .eq('id_utilisateur', idUtilisateur);
    return List<Map<String, dynamic>>.from(data);
  }

  // Ajoute un favori
  static Future<void> addFavori(String idUtilisateur, String idContenu) async {
    await _client.from('favori').insert({
      'id_utilisateur': idUtilisateur,
      'id_contenu': idContenu,
    });
  }

  // Supprime un favori
  static Future<void> removeFavori(String idUtilisateur, String idContenu) async {
    await _client
        .from('favori')
        .delete()
        .eq('id_utilisateur', idUtilisateur)
        .eq('id_contenu', idContenu);
  }

  // Vérifie si un contenu est en favori
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

  // Crée un nouveau diagnostic et retourne son id
  static Future<String> createDiagnostic(String idUtilisateur) async {
    final data = await _client
        .from('diagnostic')
        .insert({'id_utilisateur': idUtilisateur})
        .select()
        .single();
    return data['id_diagnostic'];
  }

  // Sauvegarde le score total et la page résultat d'un diagnostic
  static Future<void> updateDiagnostic(String idDiagnostic, int scoreTotal, String idPageResultat) async {
    await _client
        .from('diagnostic')
        .update({
          'score_total': scoreTotal,
          'id_page_resultat': idPageResultat,
        })
        .eq('id_diagnostic', idDiagnostic);
  }

  // Récupère l'historique des diagnostics d'un utilisateur
  static Future<List<Map<String, dynamic>>> getHistoriqueDiagnostics(String idUtilisateur) async {
    final data = await _client
        .from('diagnostic')
        .select('*, page_resultat(*)')
        .eq('id_utilisateur', idUtilisateur)
        .order('date_realisation', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  // Récupère un diagnostic avec toutes ses réponses
  static Future<Map<String, dynamic>?> getDiagnosticById(String idDiagnostic) async {
    final data = await _client
        .from('diagnostic')
        .select('*, reponse(*, question(*), choix_reponse(*))')
        .eq('id_diagnostic', idDiagnostic)
        .maybeSingle();
    return data;
  }

  // ─────────────────────────────────────────────
  // RÉPONSES
  // ─────────────────────────────────────────────

  // Insère toutes les réponses d'un diagnostic en une seule fois
  static Future<void> saveReponses(String idDiagnostic, List<Map<String, dynamic>> reponses) async {
    // reponses = [{'id_question': '...', 'id_choix': 2}, ...]
    final rows = reponses.map((r) => {
      'id_diagnostic': idDiagnostic,
      'id_question': r['id_question'],
      'id_choix': r['id_choix'],
    }).toList();

    await _client.from('reponse').insert(rows);
  }

  // ─────────────────────────────────────────────
  // PAGE RÉSULTAT
  // ─────────────────────────────────────────────

  // Trouve la page résultat correspondant à un score
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

  // Récupère le profil d'un utilisateur
  static Future<Map<String, dynamic>?> getUtilisateur(String idUtilisateur) async {
    final data = await _client
        .from('utilisateur')
        .select()
        .eq('id_utilisateur', idUtilisateur)
        .maybeSingle();
    return data;
  }

  // Met à jour le nom d'un utilisateur
  static Future<void> updateNom(String idUtilisateur, String nouveauNom) async {
    await _client
        .from('utilisateur')
        .update({'nom': nouveauNom})
        .eq('id_utilisateur', idUtilisateur);
  }
}