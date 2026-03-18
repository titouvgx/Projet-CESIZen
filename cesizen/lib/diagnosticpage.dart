import 'package:flutter/material.dart';
import 'services/supabase_service.dart';

// ─────────────────────────────────────────────
// CONSTANTES (mêmes que home_page.dart)
// ─────────────────────────────────────────────
const kGreen = Color(0xFF2EAF6F);
const kGreenLight = Color(0xFFE8F7EF);
const kGreenDark = Color(0xFF1E8A55);
const kYellow = Color(0xFFF5C842);
const kGrey = Color(0xFF6B7280);
const kLightGrey = Color(0xFFF3F4F6);
const kText = Color(0xFF1F2937);

// Couleur + icône par thème de diagnostic
Color getThemeColor(String? theme) {
  switch (theme?.toLowerCase()) {
    case 'stress':    return const Color(0xFFEF4444);
    case 'sommeil':   return const Color(0xFF8B5CF6);
    case 'relations': return const Color(0xFF3B82F6);
    case 'bien-être': return const Color(0xFF10B981);
    default:          return kGreen;
  }
}

IconData getThemeIcon(String? theme) {
  switch (theme?.toLowerCase()) {
    case 'stress':    return Icons.self_improvement;
    case 'sommeil':   return Icons.bedtime_outlined;
    case 'relations': return Icons.people_outline;
    case 'bien-être': return Icons.favorite_border;
    default:          return Icons.psychology_outlined;
  }
}

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
    'theme': 'Bien-être',
    'description': 'Un bilan général de votre bien-être mental et émotionnel.',
    'duree': '7 min',
  },
];

// ─────────────────────────────────────────────
// PAGE DIAGNOSTIC
// ─────────────────────────────────────────────
class DiagnosticPage extends StatefulWidget {
  // isLoggedIn : true = citoyen connecté, false = visiteur anonyme
  final bool isLoggedIn;
  final String? idUtilisateur;

  const DiagnosticPage({
    super.key,
    this.isLoggedIn = false,
    this.idUtilisateur,
  });

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  List<Map<String, dynamic>> _historique = [];
  bool _loadingHistorique = true;

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn && widget.idUtilisateur != null) {
      _loadHistorique();
    } else {
      setState(() => _loadingHistorique = false);
    }
  }

  Future<void> _loadHistorique() async {
    try {
      final data = await SupabaseService.getHistoriqueDiagnostics(widget.idUtilisateur!);
      setState(() {
        _historique = data;
        _loadingHistorique = false;
      });
    } catch (e) {
      print('❌ Erreur chargement historique : $e');
      setState(() => _loadingHistorique = false);
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
            // ── NAVBAR ──
            _NavBar(isMobile: isMobile),

            // ── HERO DIAGNOSTIC ──
            _DiagnosticHero(isMobile: isMobile),

            // ── CHOIX DU DIAGNOSTIC ──
            _ChoixDiagnosticSection(isMobile: isMobile),

            // ── HISTORIQUE ──
            _HistoriqueSection(
              isMobile: isMobile,
              isLoggedIn: widget.isLoggedIn,
              historique: _historique,
              loading: _loadingHistorique,
            ),

            // ── FOOTER ──
            _Footer(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NAVBAR (identique home)
// ─────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  final bool isMobile;
  const _NavBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(8)),
              child: const Center(
                // TODO: Image.asset('assets/logo_cesizen.png')
                child: Text('CZ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
            const Text('CESIZen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kText)),
          ]),
          const Spacer(),
          if (!isMobile) ...[
            _NavItem('Accueil'),
            _NavItem('Diagnostics', isActive: true),
            _NavItem('Contenus'),
            _NavItem('Votre espace'),
            _NavItem('Besoin d\'aide ?'),
            const SizedBox(width: 16),
          ] else ...[
            IconButton(onPressed: () {}, icon: const Icon(Icons.menu, color: kText)),
          ],
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  const _NavItem(this.label, {this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {},
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? kGreen : kText,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
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
          // Fil d'ariane
          Row(children: [
            const Text('Accueil', style: TextStyle(color: kGrey, fontSize: 13)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.chevron_right, size: 16, color: kGrey),
            ),
            Text('Diagnostics', style: TextStyle(color: kGreen, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 20),
          const Text(
            'Diagnostics de bien-être',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: kText, height: 1.3),
          ),
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

          // Grille : 2 colonnes desktop, 1 mobile
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
          // Icône thème
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(theme,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kLightGrey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.access_time, size: 12, color: kGrey),
                            const SizedBox(width: 4),
                            Text(data['duree'] ?? '',
                                style: const TextStyle(fontSize: 11, color: kGrey)),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(data['description'] ?? '',
                        style: const TextStyle(fontSize: 13, color: kGrey, height: 1.5)),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigation vers la page du questionnaire
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (_) => QuestionnairePage(theme: theme)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
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
  final bool isLoggedIn;
  final List<Map<String, dynamic>> historique;
  final bool loading;

  const _HistoriqueSection({
    required this.isMobile,
    required this.isLoggedIn,
    required this.historique,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Historique de mes diagnostics',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 8),
          const Text('Retrouvez tous vos diagnostics passés et suivez votre évolution.',
              style: TextStyle(fontSize: 14, color: kGrey)),
          const SizedBox(height: 32),

          // Visiteur anonyme → aperçu flou + cadenas
          if (!isLoggedIn)
            _HistoriqueBloque()

          // Connecté → chargement
          else if (loading)
            const Center(child: CircularProgressIndicator(color: kGreen))

          // Connecté → aucun diagnostic
          else if (historique.isEmpty)
            _HistoriqueVide()

          // Connecté → liste
          else
            _HistoriqueListe(historique: historique, isMobile: isMobile),
        ],
      ),
    );
  }
}

// Historique flou pour visiteur anonyme
class _HistoriqueBloque extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Aperçu flou des lignes fictives
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
              child: Row(
                children: [
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
                ],
              ),
            )),
          ),
        ),

        // Overlay cadenas
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
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
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
                  onPressed: () {
                    // TODO: Navigation vers la page de connexion
                  },
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

// Filtre blur CSS-like via ColorFilter (compatible Flutter web + mobile)


// Historique vide
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
      child: Column(
        children: [
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
        ],
      ),
    );
  }
}

// Liste des diagnostics
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
        child: Row(
          children: [
            // Icône thème
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),

            // Thème + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(theme, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: kGrey),
                    const SizedBox(width: 4),
                    Text(date, style: const TextStyle(fontSize: 12, color: kGrey)),
                  ]),
                ],
              ),
            ),

            // Niveau + score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(niveau, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                ),
                if (scoreTotal != null) ...[
                  const SizedBox(height: 4),
                  Text('Score : $scoreTotal', style: const TextStyle(fontSize: 12, color: kGrey)),
                ],
              ],
            ),

            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: kGrey, size: 20),
          ],
        ),
      ),
    );
  }

  // Popup détail du diagnostic
  void _showDetailPopup(BuildContext context, Map<String, dynamic> diagnostic) {
    final theme = diagnostic['theme'] as String? ?? 'Diagnostic';
    final date = _formatDate(diagnostic['date_realisation'] as String?);
    final pageResultat = diagnostic['page_resultat'] as Map<String, dynamic>?;
    final scoreTotal = diagnostic['score_total'] as int?;
    final color = getThemeColor(theme);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(28),
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header popup
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: kGrey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE5E7EB)),
              const SizedBox(height: 20),

              // Score
              if (scoreTotal != null) ...[
                const Text('Score total', style: TextStyle(fontSize: 13, color: kGrey)),
                const SizedBox(height: 6),
                Text('$scoreTotal points',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 20),
              ],

              // Résultat
              if (pageResultat != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.assessment_outlined, color: color, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Niveau : ${pageResultat['niveau_stress'] ?? '—'}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text(pageResultat['message'] ?? '',
                          style: const TextStyle(fontSize: 13, color: kText, height: 1.5)),
                      if (pageResultat['recommandations'] != null) ...[
                        const SizedBox(height: 10),
                        const Text('Recommandations :',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGrey)),
                        const SizedBox(height: 4),
                        Text(pageResultat['recommandations'],
                            style: const TextStyle(fontSize: 13, color: kGrey, height: 1.5)),
                      ],
                    ],
                  ),
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
    );
  }
}

// ─────────────────────────────────────────────
// FOOTER (identique home)
// ─────────────────────────────────────────────
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kText,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('© 2026 CESIZen — Tous droits réservés',
              style: TextStyle(color: Colors.white60, fontSize: 13)),
          Row(children: const [
            Text('Mentions légales', style: TextStyle(color: Colors.white60, fontSize: 13)),
            SizedBox(width: 20),
            Text('Contact', style: TextStyle(color: Colors.white60, fontSize: 13)),
          ]),
        ],
      ),
    );
  }
}