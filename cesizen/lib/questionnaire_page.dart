import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'widgets.dart';
import 'variables.dart';
import 'auth_service.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  List<Map<String, dynamic>> _evenements = [];
  Map<int, int> _quantites = {};
  bool _loading = true;
  bool _envoiEnCours = false;

  @override
  void initState() {
    super.initState();
    _loadEvenements();
  }

  Future<void> _loadEvenements() async {
    try {
      final data = await SupabaseService.getEvenementsHolmes();
      if (mounted) {
        setState(() {
          _evenements = data;
          for (final ev in data) {
            _quantites[ev['id_evenement'] as int] = 0;
          }
          _loading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur : $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  int _calculerScore() {
    int total = 0;
    for (final ev in _evenements) {
      final id = ev['id_evenement'] as int;
      final score = ev['score'] as int;
      total += (_quantites[id] ?? 0) * score;
    }
    return total;
  }

  int get _nbEvenementsCoches => _quantites.values.where((q) => q > 0).length;

  Future<void> _soumettre() async {
    if (_nbEvenementsCoches == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Indiquez au moins un événement vécu pour continuer.'),
        backgroundColor: kGrey,
      ));
      return;
    }
    setState(() => _envoiEnCours = true);
    try {
      final scoreTotal = _calculerScore();
      final pageResultat = await SupabaseService.getPageResultat(scoreTotal);

      if (AuthService.isLoggedIn && AuthService.idUtilisateur != null) {
        final idDiagnostic = await SupabaseService.createDiagnostic(AuthService.idUtilisateur!);
        final List<int> ids = [];
        for (final ev in _evenements) {
          final id = ev['id_evenement'] as int;
          final q = _quantites[id] ?? 0;
          for (int i = 0; i < q; i++) ids.add(id);
        }
        await SupabaseService.saveReponsesHolmes(idDiagnostic, ids);
        if (pageResultat != null) {
          await SupabaseService.updateDiagnostic(idDiagnostic, scoreTotal, pageResultat['id_page_resultat']);
        }
      }
      if (mounted) _showResultat(scoreTotal, pageResultat);
    } catch (e) {
      print('❌ Erreur soumission : $e');
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  void _showResultat(int score, Map<String, dynamic>? pageResultat) {
    final niveau = pageResultat?['niveau_stress'] as String? ?? '—';
    Color niveauColor; IconData niveauIcon;
    switch (niveau) {
      case 'Faible': niveauColor = const Color(0xFF10B981); niveauIcon = Icons.sentiment_satisfied_alt; break;
      case 'Modéré': niveauColor = const Color(0xFFF59E0B); niveauIcon = Icons.sentiment_neutral; break;
      case 'Élevé':  niveauColor = const Color(0xFFEF4444); niveauIcon = Icons.sentiment_dissatisfied; break;
      default:       niveauColor = kGrey; niveauIcon = Icons.help_outline;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(28),
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 72, height: 72,
              decoration: BoxDecoration(color: niveauColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(niveauIcon, color: niveauColor, size: 40)),
            const SizedBox(height: 16),
            const Text('Diagnostic terminé !', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: niveauColor.withOpacity(0.07), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: niveauColor.withOpacity(0.2)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Column(children: [
                  Text('$score', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: niveauColor)),
                  const Text('points', style: TextStyle(fontSize: 12, color: kGrey)),
                ]),
                Container(width: 1, height: 48, color: niveauColor.withOpacity(0.2)),
                Column(children: [
                  Icon(niveauIcon, color: niveauColor, size: 32),
                  const SizedBox(height: 4),
                  Text(niveau, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: niveauColor)),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            Text('$_nbEvenementsCoches événement${_nbEvenementsCoches > 1 ? 's' : ''} renseigné${_nbEvenementsCoches > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 13, color: kGrey)),
            const SizedBox(height: 16),

            if (pageResultat != null) ...[
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: kLightGrey, borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.info_outline, color: niveauColor, size: 16),
                    const SizedBox(width: 8),
                    const Text('Message', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGrey)),
                  ]),
                  const SizedBox(height: 8),
                  Text(pageResultat['message'] ?? '', style: const TextStyle(fontSize: 13, color: kText, height: 1.5)),
                  if (pageResultat['recommandations'] != null) ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      Icon(Icons.lightbulb_outline, color: niveauColor, size: 16),
                      const SizedBox(width: 8),
                      const Text('Recommandations', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGrey)),
                    ]),
                    const SizedBox(height: 8),
                    Text(pageResultat['recommandations'], style: const TextStyle(fontSize: 13, color: kText, height: 1.5)),
                  ],
                ]),
              ),
              const SizedBox(height: 16),
            ],

            if (!AuthService.isLoggedIn)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFE69C)),
                ),
                child: const Row(children: [
                  Icon(Icons.lock_outline, size: 16, color: Color(0xFF856404)),
                  SizedBox(width: 8),
                  Expanded(child: Text('Connectez-vous pour sauvegarder vos résultats.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF856404)))),
                ]),
              ),

            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                style: OutlinedButton.styleFrom(
                  foregroundColor: kGrey, side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Retour', style: TextStyle(fontWeight: FontWeight.w600)),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    for (final key in _quantites.keys) { _quantites[key] = 0; }
                    _envoiEnCours = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Recommencer', style: TextStyle(fontWeight: FontWeight.w600)),
              )),
            ]),
          ])),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final scoreActuel = _calculerScore();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          CESIZenNavBar(isMobile: isMobile, activePage: 'Diagnostics'),

          // Hero
          Container(
            color: kLightGrey,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('Diagnostics', style: TextStyle(color: kGrey, fontSize: 13)),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.chevron_right, size: 16, color: kGrey)),
                Text('Questionnaire',
                    style: TextStyle(color: kGreen, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 16),
              const Text('Échelle de Holmes et Rahe',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kText)),
              const SizedBox(height: 8),
              const Text(
                'Pour chaque événement vécu durant les 12 derniers mois, indiquez combien de fois il s\'est produit.',
                style: TextStyle(fontSize: 14, color: kGrey, height: 1.5),
              ),
            ]),
          ),

          // Contenu
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 80, vertical: 32),
            child: _loading
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(60),
                    child: CircularProgressIndicator(color: kGreen)))
                : Column(children: [

                    // Score en temps réel
                    if (_nbEvenementsCoches > 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: kGreenLight, borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kGreen.withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.calculate_outlined, color: kGreen, size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text(
                            '$_nbEvenementsCoches événement${_nbEvenementsCoches > 1 ? 's' : ''} — Score : $scoreActuel pts',
                            style: const TextStyle(fontSize: 13, color: kGreenDark, fontWeight: FontWeight.w600),
                          )),
                        ]),
                      ),

                    // En-tête colonnes — desktop seulement
                    if (!isMobile)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: kLightGrey, borderRadius: BorderRadius.circular(8)),
                        child: const Row(children: [
                          Expanded(child: Text('Événement',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGrey))),
                          SizedBox(width: 8),
                          SizedBox(width: 52, child: Text('Points', textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGrey))),
                          SizedBox(width: 8),
                          SizedBox(width: 106, child: Center(child: Text('Nombre de fois',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGrey)))),
                        ]),
                      ),
                    const SizedBox(height: 8),

                    // Liste des événements
                    ..._evenements.map((ev) {
                      final id = ev['id_evenement'] as int;
                      final score = ev['score'] as int;
                      final quantite = _quantites[id] ?? 0;
                      final actif = quantite > 0;

                      // Sélecteur +/-
                      Widget selecteur = Row(mainAxisSize: MainAxisSize.min, children: [
                        GestureDetector(
                          onTap: quantite > 0
                              ? () => setState(() => _quantites[id] = quantite - 1)
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              color: quantite > 0 ? kGreen : const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.remove, size: 14,
                                color: quantite > 0 ? Colors.white : kGrey),
                          ),
                        ),
                        SizedBox(
                          width: 34,
                          child: Text('$quantite', textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                                  color: actif ? kGreenDark : kGrey)),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _quantites[id] = quantite + 1),
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add, size: 14, color: Colors.white),
                          ),
                        ),
                      ]);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.symmetric(
                            horizontal: 14, vertical: isMobile ? 12 : 10),
                        decoration: BoxDecoration(
                          color: actif ? kGreenLight : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: actif ? kGreen : const Color(0xFFE5E7EB), width: actif ? 2 : 1),
                        ),
                        child: isMobile
                            // ── Mobile : libellé en haut, pts + sélecteur en bas ──
                            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(ev['libelle'] as String,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: actif ? kGreenDark : kText,
                                        fontWeight: actif ? FontWeight.w600 : FontWeight.normal)),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: actif ? kGreen.withOpacity(0.15) : kLightGrey,
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Text('$score pts',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: actif ? kGreenDark : kGrey,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    selecteur,
                                  ],
                                ),
                              ])
                            // ── Desktop : 1 ligne ──
                            : Row(children: [
                                Expanded(child: Text(ev['libelle'] as String,
                                    style: TextStyle(fontSize: 14,
                                        color: actif ? kGreenDark : kText,
                                        fontWeight: actif ? FontWeight.w600 : FontWeight.normal))),
                                const SizedBox(width: 8),
                                SizedBox(width: 52,
                                    child: Text('$score pts', textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12,
                                            color: actif ? kGreenDark : kGrey,
                                            fontWeight: FontWeight.w600))),
                                const SizedBox(width: 8),
                                SizedBox(width: 106, child: Center(child: selecteur)),
                              ]),
                      );
                    }),

                    const SizedBox(height: 32),

                    // Bouton valider
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _envoiEnCours ? null : _soumettre,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kYellow, foregroundColor: kText,
                          disabledBackgroundColor: const Color(0xFFE5E7EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _envoiEnCours
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: kText))
                            : Text(
                                _nbEvenementsCoches == 0
                                    ? 'Indiquez les événements vécus puis validez'
                                    : 'Valider mon diagnostic (score : $scoreActuel pts)',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ),
                  ]),
          ),

          const CESIZenFooter(),
        ]),
      ),
    );
  }
}