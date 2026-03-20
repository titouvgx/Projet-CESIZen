import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'questionnaire_page.dart';
import 'widgets.dart';
import 'variables.dart';
import 'auth_service.dart';
import 'login_popup.dart';

// ─────────────────────────────────────────────
// TYPES DE DIAGNOSTICS DISPONIBLES
// ─────────────────────────────────────────────
const List<Map<String, String>> kTypesDiagnostics = [
  {
    'theme': 'Stress',
    'description': 'Évaluez votre niveau de stress et découvrez des pistes pour mieux le gérer au quotidien.',
    'duree': '5 min',
  },
  {
    'theme': 'Sommeil',
    'description': 'Analysez la qualité de votre sommeil et identifiez les facteurs qui l\'impactent.',
    'duree': '4 min',
  },
  {
    'theme': 'Relations',
    'description': 'Explorez la qualité de vos relations sociales et votre sentiment de connexion aux autres.',
    'duree': '6 min',
  },
  {
    'theme': 'Santé',
    'description': 'Un bilan général de votre bien-être mental et émotionnel.',
    'duree': '7 min',
  },
];

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

  // Se redéclenche quand on revient sur la page (ex: après un diagnostic)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistorique();
  }

  Future<void> _loadHistorique() async {
    if (!AuthService.isLoggedIn || AuthService.idUtilisateur == null) {
      setState(() => _loadingHistorique = false);
      return;
    }
    try {
      final data = await SupabaseService.getHistoriqueDiagnostics(AuthService.idUtilisateur!);
      if (mounted) {
        setState(() {
          _historique = data;
          _loadingHistorique = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement historique : $e');
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
        child: Column(
          children: [
            CESIZenNavBar(isMobile: isMobile, activePage: 'Diagnostics'),
            _DiagnosticHero(isMobile: isMobile),
            _ChoixDiagnosticSection(isMobile: isMobile),
            _HistoriqueSection(
              isMobile: isMobile,
              historique: _historique,
              loading: _loadingHistorique,
              onRefresh: _loadHistorique,
            ),
            const CESIZenFooter(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO DIAGNOSTIC
// ─────────────────────────────────────────────
class _DiagnosticHero extends StatelessWidget {
  final bool isMobile;
  const _DiagnosticHero({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Accueil', style: TextStyle(color: kGrey, fontSize: 13)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.chevron_right, size: 16, color: kGrey),
            ),
            Text('Diagnostics', style: TextStyle(color: kGreen, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 20),
          const Text('Diagnostics de bien-être',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: kText, height: 1.3)),
          const SizedBox(height: 12),
          const Text(
            'Choisissez un diagnostic adapté à vos besoins. Chaque questionnaire est anonyme, gratuit et ne prend que quelques minutes.',
            style: TextStyle(fontSize: 15, color: kGrey, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION CHOIX DU DIAGNOSTIC
// ─────────────────────────────────────────────
class _ChoixDiagnosticSection extends StatelessWidget {
  final bool isMobile;
  const _ChoixDiagnosticSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choisissez votre diagnostic',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 8),
          const Text('Des questionnaires courts pour mieux vous comprendre.',
              style: TextStyle(fontSize: 14, color: kGrey)),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isMobile ? 2.8 : 2.2,
            ),
            itemCount: kTypesDiagnostics.length,
            itemBuilder: (context, index) {
              return _DiagnosticCard(data: kTypesDiagnostics[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _DiagnosticCard extends StatelessWidget {
  final Map<String, String> data;
  const _DiagnosticCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = data['theme'] ?? '';
    final color = getThemeColor(theme);
    final icon = getThemeIcon(theme);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(theme, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: kLightGrey, borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.access_time, size: 12, color: kGrey),
                        const SizedBox(width: 4),
                        Text(data['duree'] ?? '', style: const TextStyle(fontSize: 11, color: kGrey)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(data['description'] ?? '', style: const TextStyle(fontSize: 13, color: kGrey, height: 1.5)),
                ]),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => QuestionnairePage(theme: theme)),
                    );
                    // Rafraîchit l'historique au retour du questionnaire
                    if (context.mounted) {
                      final state = context.findAncestorStateOfType<_DiagnosticPageState>();
                      state?._loadHistorique();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text('Commencer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
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
    required this.isMobile,
    required this.historique,
    required this.loading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Historique de mes diagnostics',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
              SizedBox(height: 4),
              Text('Retrouvez tous vos diagnostics passés et suivez votre évolution.',
                  style: TextStyle(fontSize: 14, color: kGrey)),
            ]),
            // Bouton rafraîchir
            if (AuthService.isLoggedIn)
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: kGreen),
                tooltip: 'Rafraîchir',
              ),
          ]),
          const SizedBox(height: 32),

          if (!AuthService.isLoggedIn)
            _HistoriqueBloque()
          else if (loading)
            const Center(child: CircularProgressIndicator(color: kGreen))
          else if (historique.isEmpty)
            _HistoriqueVide()
          else
            _HistoriqueListe(historique: historique, isMobile: isMobile),
        ],
      ),
    );
  }
}

class _HistoriqueBloque extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageFiltered(
          imageFilter: const ColorFilter.matrix([
            1, 0, 0, 0, 0,
            0, 1, 0, 0, 0,
            0, 0, 1, 0, 0,
            0, 0, 0, 0.15, 0,
          ]),
          child: Column(
            children: List.generate(3, (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
            )),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: kGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(28)),
                  child: const Icon(Icons.lock_outline, color: kGreen, size: 28),
                ),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoriqueVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(28)),
          child: const Icon(Icons.history, color: kGreen, size: 28),
        ),
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

class _HistoriqueListe extends StatelessWidget {
  final List<Map<String, dynamic>> historique;
  final bool isMobile;
  const _HistoriqueListe({required this.historique, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: historique.map((diag) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _HistoriqueItem(diagnostic: diag),
      )).toList(),
    );
  }
}

class _HistoriqueItem extends StatelessWidget {
  final Map<String, dynamic> diagnostic;
  const _HistoriqueItem({required this.diagnostic});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = diagnostic['theme'] as String? ?? 'Diagnostic';
    final date = _formatDate(diagnostic['date_realisation'] as String?);
    final pageResultat = diagnostic['page_resultat'] as Map<String, dynamic>?;
    final niveau = pageResultat?['niveau_stress'] as String? ?? '—';
    final scoreTotal = diagnostic['score_total'] as int?;
    final color = getThemeColor(theme);
    final icon = getThemeIcon(theme);

    return GestureDetector(
      onTap: () => _showDetailPopup(context, diagnostic),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(theme, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 12, color: kGrey),
                const SizedBox(width: 4),
                Text(date, style: const TextStyle(fontSize: 12, color: kGrey)),
              ]),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(niveau, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            ),
            if (scoreTotal != null) ...[
              const SizedBox(height: 4),
              Text('Score : $scoreTotal / 5', style: const TextStyle(fontSize: 12, color: kGrey)),
            ],
          ]),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right, color: kGrey, size: 20),
        ]),
      ),
    );
  }

  void _showDetailPopup(BuildContext context, Map<String, dynamic> diagnostic) {
    final theme = diagnostic['theme'] as String? ?? 'Diagnostic';
    final date = _formatDate(diagnostic['date_realisation'] as String?);
    final pageResultat = diagnostic['page_resultat'] as Map<String, dynamic>?;
    final scoreTotal = diagnostic['score_total'] as int?;
    final color = getThemeColor(theme);
    final niveau = pageResultat?['niveau_stress'] as String? ?? '—';

    // Couleur selon le niveau
    Color niveauColor;
    IconData niveauIcon;
    switch (niveau) {
      case 'Faible':
        niveauColor = const Color(0xFF10B981);
        niveauIcon = Icons.sentiment_satisfied_alt;
        break;
      case 'Modéré':
        niveauColor = const Color(0xFFF59E0B);
        niveauIcon = Icons.sentiment_neutral;
        break;
      case 'Élevé':
        niveauColor = const Color(0xFFEF4444);
        niveauIcon = Icons.sentiment_dissatisfied;
        break;
      default:
        niveauColor = kGrey;
        niveauIcon = Icons.help_outline;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(28),
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(getThemeIcon(theme), color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(theme, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText)),
                      Text(date, style: const TextStyle(fontSize: 12, color: kGrey)),
                    ]),
                  ]),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: kGrey)),
                ]),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFE5E7EB)),
                const SizedBox(height: 20),

                // Score + Niveau
                if (scoreTotal != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: niveauColor.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: niveauColor.withOpacity(0.2)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      Column(children: [
                        Text('$scoreTotal / 5',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: niveauColor)),
                        const SizedBox(height: 4),
                        const Text('Score', style: TextStyle(fontSize: 12, color: kGrey)),
                      ]),
                      Container(width: 1, height: 40, color: niveauColor.withOpacity(0.2)),
                      Column(children: [
                        Icon(niveauIcon, color: niveauColor, size: 28),
                        const SizedBox(height: 4),
                        Text(niveau, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: niveauColor)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],

                // Message + recommandations
                if (pageResultat != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kLightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(Icons.info_outline, color: niveauColor, size: 16),
                        const SizedBox(width: 8),
                        const Text('Message', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGrey)),
                      ]),
                      const SizedBox(height: 8),
                      Text(pageResultat['message'] ?? '',
                          style: const TextStyle(fontSize: 13, color: kText, height: 1.5)),
                      if (pageResultat['recommandations'] != null) ...[
                        const SizedBox(height: 12),
                        Row(children: [
                          Icon(Icons.lightbulb_outline, color: niveauColor, size: 16),
                          const SizedBox(width: 8),
                          const Text('Recommandations', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGrey)),
                        ]),
                        const SizedBox(height: 8),
                        Text(pageResultat['recommandations'],
                            style: const TextStyle(fontSize: 13, color: kText, height: 1.5)),
                      ],
                    ]),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: kLightGrey, borderRadius: BorderRadius.circular(12)),
                    child: const Text('Aucun résultat disponible pour ce diagnostic.',
                        style: TextStyle(fontSize: 13, color: kGrey)),
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}