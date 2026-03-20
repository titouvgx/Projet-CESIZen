import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'questionnaire_page.dart';
import 'widgets.dart';
import 'variables.dart';
import 'auth_service.dart';
import 'login_popup.dart';

// ─────────────────────────────────────────────
// PAGE DIAGNOSTIC
// ─────────────────────────────────────────────
class DiagnosticPage extends StatefulWidget {
  const DiagnosticPage({super.key});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  List<Map<String, dynamic>> _historique = [];
  bool _loadingHistorique = true;

  @override
  void initState() {
    super.initState();
    _loadHistorique();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistorique();
  }

  Future<void> _loadHistorique() async {
    if (!AuthService.isLoggedIn || AuthService.idUtilisateur == null) {
      if (mounted) setState(() => _loadingHistorique = false);
      return;
    }
    try {
      final data = await SupabaseService.getHistoriqueDiagnostics(AuthService.idUtilisateur!);
      if (mounted) setState(() { _historique = data; _loadingHistorique = false; });
    } catch (e) {
      print('❌ Erreur historique : $e');
      if (mounted) setState(() => _loadingHistorique = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          CESIZenNavBar(isMobile: isMobile, activePage: 'Diagnostics'),
          _DiagnosticHero(isMobile: isMobile),
          _DiagnosticPresentation(isMobile: isMobile, onStart: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionnairePage()));
            _loadHistorique();
          }),
          _HistoriqueSection(
            isMobile: isMobile,
            historique: _historique,
            loading: _loadingHistorique,
            onRefresh: _loadHistorique,
          ),
          const CESIZenFooter(),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO
// ─────────────────────────────────────────────
class _DiagnosticHero extends StatelessWidget {
  final bool isMobile;
  const _DiagnosticHero({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Accueil', style: TextStyle(color: kGrey, fontSize: 13)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.chevron_right, size: 16, color: kGrey)),
          Text('Diagnostics', style: TextStyle(color: kGreen, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 20),
        const Text('Diagnostic de stress', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 12),
        const Text(
          'Basé sur l\'échelle de Holmes et Rahe, ce diagnostic évalue votre niveau de stress '
          'en fonction des événements vécus durant les 12 derniers mois.',
          style: TextStyle(fontSize: 15, color: kGrey, height: 1.6),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// PRÉSENTATION DU DIAGNOSTIC
// ─────────────────────────────────────────────
class _DiagnosticPresentation extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onStart;
  const _DiagnosticPresentation({required this.isMobile, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: isMobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _PresentationTexte(onStart: onStart),
              const SizedBox(height: 32),
              _NiveauxStress(),
            ])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 5, child: _PresentationTexte(onStart: onStart)),
              const SizedBox(width: 48),
              Expanded(flex: 4, child: _NiveauxStress()),
            ]),
    );
  }
}

class _PresentationTexte extends StatelessWidget {
  final VoidCallback onStart;
  const _PresentationTexte({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Comment ça fonctionne ?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
      const SizedBox(height: 16),

      _EtapeItem(numero: '1', texte: 'Parcourez la liste des 43 événements de vie'),
      _EtapeItem(numero: '2', texte: 'Cochez ceux que vous avez vécus dans les 12 derniers mois'),
      _EtapeItem(numero: '3', texte: 'Votre score total est calculé automatiquement'),
      _EtapeItem(numero: '4', texte: 'Découvrez votre niveau de stress et les recommandations associées'),

      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFE69C)),
        ),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline, color: Color(0xFF856404), size: 18),
          SizedBox(width: 10),
          Expanded(child: Text(
            'Ce test n\'est pas un diagnostic médical. Il vise à donner une indication générale de votre niveau de stress.',
            style: TextStyle(fontSize: 13, color: Color(0xFF856404), height: 1.5),
          )),
        ]),
      ),
      const SizedBox(height: 28),

      ElevatedButton.icon(
        onPressed: onStart,
        icon: const Icon(Icons.play_arrow_rounded, size: 20),
        label: const Text('Commencer le diagnostic', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: kGreen, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
      ),
    ]);
  }
}

class _EtapeItem extends StatelessWidget {
  final String numero;
  final String texte;
  const _EtapeItem({required this.numero, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(numero,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(texte, style: const TextStyle(fontSize: 14, color: kText, height: 1.5)),
        )),
      ]),
    );
  }
}

class _NiveauxStress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Interprétation des scores',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 20),

        _NiveauItem(
          color: const Color(0xFF10B981),
          icon: Icons.sentiment_satisfied_alt,
          niveau: 'Faible',
          score: '< 150 points',
          description: 'Faible risque de développer un problème de santé lié au stress.',
        ),
        const SizedBox(height: 16),
        _NiveauItem(
          color: const Color(0xFFF59E0B),
          icon: Icons.sentiment_neutral,
          niveau: 'Modéré',
          score: '150 – 299 points',
          description: 'Risque modéré. Quelques ajustements peuvent aider à réduire le stress.',
        ),
        const SizedBox(height: 16),
        _NiveauItem(
          color: const Color(0xFFEF4444),
          icon: Icons.sentiment_dissatisfied,
          niveau: 'Élevé',
          score: '≥ 300 points',
          description: 'Risque élevé. Il est recommandé de consulter un professionnel de santé.',
        ),
      ]),
    );
  }
}

class _NiveauItem extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String niveau;
  final String score;
  final String description;

  const _NiveauItem({
    required this.color, required this.icon,
    required this.niveau, required this.score, required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(niveau, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(width: 8),
            Text(score, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
          ]),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 12, color: kGrey, height: 1.4)),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION HISTORIQUE
// ─────────────────────────────────────────────
class _HistoriqueSection extends StatelessWidget {
  final bool isMobile;
  final List<Map<String, dynamic>> historique;
  final bool loading;
  final VoidCallback onRefresh;

  const _HistoriqueSection({
    required this.isMobile, required this.historique,
    required this.loading, required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Historique de mes diagnostics',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
            SizedBox(height: 4),
            Text('Retrouvez vos diagnostics passés et suivez votre évolution.',
                style: TextStyle(fontSize: 14, color: kGrey)),
          ]),
          if (AuthService.isLoggedIn)
            IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh, color: kGreen)),
        ]),
        const SizedBox(height: 32),

        if (!AuthService.isLoggedIn)
          _HistoriqueBloque()
        else if (loading)
          const Center(child: CircularProgressIndicator(color: kGreen))
        else if (historique.isEmpty)
          _HistoriqueVide()
        else
          Column(children: historique.map((diag) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HistoriqueItem(diagnostic: diag, onFavoriToggle: onRefresh),
          )).toList()),
      ]),
    );
  }
}

class _HistoriqueBloque extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ImageFiltered(
        imageFilter: const ColorFilter.matrix([
          1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0.15, 0,
        ]),
        child: Column(children: List.generate(3, (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(
                color: kGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 120, height: 14, color: const Color(0xFFE5E7EB)),
              const SizedBox(height: 8),
              Container(width: 80, height: 12, color: const Color(0xFFE5E7EB)),
            ]),
            const Spacer(),
            Container(width: 60, height: 28, decoration: BoxDecoration(
                color: kGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8))),
          ]),
        ))),
      ),
      Positioned.fill(child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 56, height: 56,
            decoration: BoxDecoration(color: kGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(28)),
            child: const Icon(Icons.lock_outline, color: kGreen, size: 28)),
          const SizedBox(height: 16),
          const Text('Connectez-vous pour accéder à votre historique',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 8),
          const Text('Vos diagnostics passés sont sauvegardés et consultables à tout moment.',
              style: TextStyle(fontSize: 13, color: kGrey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => showLoginPopup(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
      )),
    ]);
  }
}

class _HistoriqueVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: [
        Container(width: 56, height: 56,
          decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(28)),
          child: const Icon(Icons.history, color: kGreen, size: 28)),
        const SizedBox(height: 16),
        const Text('Aucun diagnostic pour l\'instant',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 8),
        const Text('Commencez un diagnostic ci-dessus pour suivre votre évolution.',
            style: TextStyle(fontSize: 13, color: kGrey)),
      ]),
    );
  }
}

class _HistoriqueItem extends StatelessWidget {
  final Map<String, dynamic> diagnostic;
  final VoidCallback onFavoriToggle;
  const _HistoriqueItem({required this.diagnostic, required this.onFavoriToggle});

  String _formatDate(String? d) {
    if (d == null) return '';
    final date = DateTime.tryParse(d);
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(diagnostic['date_realisation'] as String?);
    final pageResultat = diagnostic['page_resultat'] as Map<String, dynamic>?;
    final niveau = pageResultat?['niveau_stress'] as String? ?? '—';
    final scoreTotal = diagnostic['score_total'] as int?;
    final estFavori = diagnostic['est_favori'] as bool? ?? false;

    Color niveauColor;
    switch (niveau) {
      case 'Faible': niveauColor = const Color(0xFF10B981); break;
      case 'Modéré': niveauColor = const Color(0xFFF59E0B); break;
      case 'Élevé':  niveauColor = const Color(0xFFEF4444); break;
      default:       niveauColor = kGrey;
    }

    return GestureDetector(
      onTap: () => _showDetailPopup(context, diagnostic),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: niveauColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.psychology_outlined, color: niveauColor, size: 22)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Diagnostic de stress',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: kGrey),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(fontSize: 12, color: kGrey)),
            ]),
          ])),
          if (scoreTotal != null) ...[
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: niveauColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(niveau, style: TextStyle(fontSize: 12, color: niveauColor, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              Text('$scoreTotal pts', style: const TextStyle(fontSize: 12, color: kGrey)),
            ]),
            const SizedBox(width: 8),
          ],
          IconButton(
            onPressed: () async {
              await SupabaseService.toggleDiagnosticFavori(diagnostic['id_diagnostic'], !estFavori);
              onFavoriToggle();
            },
            icon: Icon(estFavori ? Icons.bookmark : Icons.bookmark_border,
                color: estFavori ? kGreen : kGrey, size: 22),
            tooltip: estFavori ? 'Retirer des favoris' : 'Ajouter aux favoris',
          ),
          const Icon(Icons.chevron_right, color: kGrey, size: 20),
        ]),
      ),
    );
  }

  void _showDetailPopup(BuildContext context, Map<String, dynamic> diagnostic) {
    final date = _formatDate(diagnostic['date_realisation'] as String?);
    final pageResultat = diagnostic['page_resultat'] as Map<String, dynamic>?;
    final scoreTotal = diagnostic['score_total'] as int?;
    final niveau = pageResultat?['niveau_stress'] as String? ?? '—';

    Color niveauColor; IconData niveauIcon;
    switch (niveau) {
      case 'Faible': niveauColor = const Color(0xFF10B981); niveauIcon = Icons.sentiment_satisfied_alt; break;
      case 'Modéré': niveauColor = const Color(0xFFF59E0B); niveauIcon = Icons.sentiment_neutral; break;
      case 'Élevé':  niveauColor = const Color(0xFFEF4444); niveauIcon = Icons.sentiment_dissatisfied; break;
      default:       niveauColor = kGrey; niveauIcon = Icons.help_outline;
    }

    showDialog(context: context, builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(28),
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: niveauColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(niveauIcon, color: niveauColor, size: 22)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Diagnostic de stress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText)),
                Text(date, style: const TextStyle(fontSize: 12, color: kGrey)),
              ]),
            ]),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: kGrey)),
          ]),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 20),

          if (scoreTotal != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: niveauColor.withOpacity(0.07), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: niveauColor.withOpacity(0.2)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Column(children: [
                  Text('$scoreTotal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: niveauColor)),
                  const Text('points', style: TextStyle(fontSize: 12, color: kGrey)),
                ]),
                Container(width: 1, height: 40, color: niveauColor.withOpacity(0.2)),
                Column(children: [
                  Icon(niveauIcon, color: niveauColor, size: 28),
                  Text(niveau, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: niveauColor)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
          ],

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
          ],

          const SizedBox(height: 24),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ])),
      ),
    ));
  }
}