import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

// ─────────────────────────────────────────────
// SERVICE SUPABASE
// ─────────────────────────────────────────────
class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ─────────────────────────────────────────────
  // ÉVÉNEMENTS HOLMES ET RAHE
  // ─────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getEvenementsHolmes() async {
    try {
      final data = await _client
          .from('evenement_holmes')
          .select()
          .order('ordre', ascending: true);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      AppLogger.error('getEvenementsHolmes', context: 'SupabaseService', exception: e);
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // CONTENU
  // ─────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getContenuPublie() async {
    try {
      final data = await _client
          .from('contenu')
          .select()
          .eq('statut_publication', 'publié')
          .order('date_creation', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      AppLogger.error('getContenuPublie', context: 'SupabaseService', exception: e);
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getContenuParCategorie(String categorie) async {
    try {
      final data = await _client
          .from('contenu')
          .select()
          .eq('statut_publication', 'publié')
          .eq('categorie', categorie);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      AppLogger.error('getContenuParCategorie', context: 'SupabaseService', exception: e);
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getContenuById(String idContenu) async {
    try {
      final data = await _client
          .from('contenu')
          .select()
          .eq('id_contenu', idContenu)
          .maybeSingle();
      return data;
    } catch (e) {
      AppLogger.error('getContenuById', context: 'SupabaseService', exception: e);
      return null;
    }
  }

  static Future<List<String>> getCategories() async {
    try {
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
    } catch (e) {
      AppLogger.error('getCategories', context: 'SupabaseService', exception: e);
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // FAVORIS ARTICLES
  // ─────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getFavoris(String idUtilisateur) async {
    try {
      final data = await _client
          .from('favori')
          .select('*, contenu(*)')
          .eq('id_utilisateur', idUtilisateur);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      AppLogger.error('getFavoris', context: 'SupabaseService', exception: e);
      return [];
    }
  }

  static Future<void> addFavori(String idUtilisateur, String idContenu) async {
    try {
      await _client.from('favori').insert({
        'id_utilisateur': idUtilisateur,
        'id_contenu': idContenu,
      });
    } catch (e) {
      AppLogger.error('addFavori', context: 'SupabaseService', exception: e);
      rethrow;
    }
  }

  static Future<void> removeFavori(String idUtilisateur, String idContenu) async {
    try {
      await _client
          .from('favori')
          .delete()
          .eq('id_utilisateur', idUtilisateur)
          .eq('id_contenu', idContenu);
    } catch (e) {
      AppLogger.error('removeFavori', context: 'SupabaseService', exception: e);
      rethrow;
    }
  }

  static Future<bool> isFavori(String idUtilisateur, String idContenu) async {
    try {
      final data = await _client
          .from('favori')
          .select()
          .eq('id_utilisateur', idUtilisateur)
          .eq('id_contenu', idContenu)
          .maybeSingle();
      return data != null;
    } catch (e) {
      AppLogger.error('isFavori', context: 'SupabaseService', exception: e);
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // DIAGNOSTIC
  // ─────────────────────────────────────────────

  static Future<String> createDiagnostic(String idUtilisateur) async {
    try {
      final data = await _client
          .from('diagnostic')
          .insert({'id_utilisateur': idUtilisateur})
          .select()
          .single();
      return data['id_diagnostic'];
    } catch (e) {
      AppLogger.error('createDiagnostic', context: 'SupabaseService', exception: e);
      rethrow;
    }
  }

  static Future<void> updateDiagnostic(
    String idDiagnostic,
    int scoreTotal,
    String idPageResultat,
  ) async {
    try {
      await _client
          .from('diagnostic')
          .update({
            'score_total': scoreTotal,
            'id_page_resultat': idPageResultat,
          })
          .eq('id_diagnostic', idDiagnostic);
    } catch (e) {
      AppLogger.error('updateDiagnostic', context: 'SupabaseService', exception: e);
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getHistoriqueDiagnostics(String idUtilisateur) async {
    try {
      final data = await _client
          .from('diagnostic')
          .select('*, page_resultat(*)')
          .eq('id_utilisateur', idUtilisateur)
          .order('date_realisation', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      AppLogger.error('getHistoriqueDiagnostics', context: 'SupabaseService', exception: e);
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getDiagnosticsFavoris(String idUtilisateur) async {
    try {
      final data = await _client
          .from('diagnostic')
          .select('*, page_resultat(*)')
          .eq('id_utilisateur', idUtilisateur)
          .eq('est_favori', true)
          .order('date_realisation', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      AppLogger.error('getDiagnosticsFavoris', context: 'SupabaseService', exception: e);
      return [];
    }
  }

  static Future<void> toggleDiagnosticFavori(String idDiagnostic, bool estFavori) async {
    try {
      await _client
          .from('diagnostic')
          .update({'est_favori': estFavori})
          .eq('id_diagnostic', idDiagnostic);
    } catch (e) {
      AppLogger.error('toggleDiagnosticFavori', context: 'SupabaseService', exception: e);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // RÉPONSES HOLMES
  // ─────────────────────────────────────────────

  static Future<void> saveReponsesHolmes(
    String idDiagnostic,
    List<int> idEvenementsCochs,
  ) async {
    if (idEvenementsCochs.isEmpty) return;
    try {
      final rows = idEvenementsCochs.map((id) => {
        'id_diagnostic': idDiagnostic,
        'id_evenement': id,
      }).toList();
      await _client.from('reponse').insert(rows);
    } catch (e) {
      AppLogger.error('saveReponsesHolmes', context: 'SupabaseService', exception: e);
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getReponsesHolmes(String idDiagnostic) async {
    try {
      final data = await _client
          .from('reponse')
          .select('*, evenement_holmes(*)')
          .eq('id_diagnostic', idDiagnostic);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      AppLogger.error('getReponsesHolmes', context: 'SupabaseService', exception: e);
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // PAGE RÉSULTAT
  // ─────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getPageResultat(int scoreTotal) async {
    try {
      final data = await _client
          .from('page_resultat')
          .select()
          .lte('seuil_min', scoreTotal)
          .gte('seuil_max', scoreTotal)
          .maybeSingle();
      return data;
    } catch (e) {
      AppLogger.error('getPageResultat', context: 'SupabaseService', exception: e);
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // UTILISATEUR
  // ─────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getUtilisateur(String idUtilisateur) async {
    try {
      final data = await _client
          .from('utilisateur')
          .select()
          .eq('id_utilisateur', idUtilisateur)
          .maybeSingle();
      return data;
    } catch (e) {
      AppLogger.error('getUtilisateur', context: 'SupabaseService', exception: e);
      return null;
    }
  }

  static Future<void> updateNom(String idUtilisateur, String nouveauNom) async {
    try {
      await _client
          .from('utilisateur')
          .update({'nom': nouveauNom})
          .eq('id_utilisateur', idUtilisateur);
    } catch (e) {
      AppLogger.error('updateNom', context: 'SupabaseService', exception: e);
      rethrow;
    }
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
    try {
      await _client.from('contact_message').insert({
        'nom': nom,
        'email': email,
        'sujet': sujet,
        'message': message,
      });
    } catch (e) {
      AppLogger.error('envoyerMessage', context: 'SupabaseService', exception: e);
      rethrow;
    }
  }
}
