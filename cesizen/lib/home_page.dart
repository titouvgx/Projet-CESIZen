import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'diagnosticpage.dart';
import 'variables.dart';
import 'widgets.dart';
import 'contenu_page.dart';
import 'questionnaire_page.dart';

// ─────────────────────────────────────────────
// APP
// ─────────────────────────────────────────────
class CESIZenApp extends StatelessWidget {
  const CESIZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CESIZen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2EAF6F)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

// ─────────────────────────────────────────────
// PAGE PRINCIPALE
// ─────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Map<String, dynamic>> _contenus = [];
  bool _loadingContenus = true;

  @override
  void initState() {
    super.initState();
    _loadContenus();
  }

  Future<void> _loadContenus() async {
    try {
      final data = await SupabaseService.getContenuPublie();
      setState(() {
        _contenus = data.take(3).toList();
        _loadingContenus = false;
      });
    } catch (e) {
      print('❌ Erreur chargement contenus : $e');
      setState(() => _loadingContenus = false);
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
            CESIZenNavBar(isMobile: isMobile, activePage: 'Accueil'),
            _HeroSection(isMobile: isMobile),
            _AboutSection(isMobile: isMobile),
            _TrendingSection(isMobile: isMobile, contenus: _contenus, loading: _loadingContenus),
            _DiagnosticSection(isMobile: isMobile),
            const CESIZenFooter(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION HERO
// ─────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final bool isMobile;
  const _HeroSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: isMobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _HeroText(), const SizedBox(height: 32), _HeroImage()])
          : Row(children: [
              Expanded(flex: 5, child: _HeroText()),
              const SizedBox(width: 48),
              Expanded(flex: 4, child: _HeroImage()),
            ]),
    );
  }
}

class _HeroText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prenez soin de\nvotre santé mentale',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kText, height: 1.3)),
        const SizedBox(height: 16),
        const Text(
          'CESIZen est une plateforme publique pour informer, prévenir et sensibiliser sur les enjeux de santé mentale de manière apaisante et pédagogique.',
          style: TextStyle(fontSize: 15, color: kGrey, height: 1.6),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticPage())),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: const Text('Faire un diagnostic'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContenuPage())),
              style: OutlinedButton.styleFrom(
                foregroundColor: kGreen, side: const BorderSide(color: kGreen),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: const Text('Découvrir les contenus'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 340,
        child: Image.asset('assets/images/HEROzen.jpg', fit: BoxFit.cover),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION À PROPOS
// ─────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  final bool isMobile;
  const _AboutSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _AboutCardData(icon: Icons.info_outline, color: kGreen, title: 'Informer',
          description: 'Des contenus fiables et accessibles pour mieux comprendre la santé mentale.'),
      _AboutCardData(icon: Icons.shield_outlined, color: kGreen, title: 'Prévenir',
          description: 'Des outils simples pour évaluer votre bien-être et prévenir les difficultés.'),
      _AboutCardData(icon: Icons.favorite_border, color: const Color(0xFFEF4444), title: 'Sensibiliser',
          description: 'Une approche bienveillante pour déstigmatiser les questions de santé mentale.'),
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: Column(children: [
        const Text('À propos de CESIZen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 40),
        isMobile
            ? Column(children: cards.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 16), child: _AboutCard(data: c))).toList())
            : Row(children: cards.map((c) => Expanded(
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: _AboutCard(data: c)))).toList()),
      ]),
    );
  }
}

class _AboutCardData {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  const _AboutCardData({required this.icon, required this.color, required this.title, required this.description});
}

class _AboutCard extends StatelessWidget {
  final _AboutCardData data;
  const _AboutCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: data.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(data.icon, color: data.color, size: 22),
        ),
        const SizedBox(height: 16),
        Text(data.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kText)),
        const SizedBox(height: 8),
        Text(data.description, style: const TextStyle(fontSize: 14, color: kGrey, height: 1.5)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION CONTENU EN VOGUE
// ─────────────────────────────────────────────
class _TrendingSection extends StatelessWidget {
  final bool isMobile;
  final List<Map<String, dynamic>> contenus;
  final bool loading;

  const _TrendingSection({required this.isMobile, required this.contenus, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contenu en vogue',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 32),
          if (loading)
            const Center(child: CircularProgressIndicator(color: kGreen))
          else if (contenus.isEmpty)
            const Center(child: Text('Aucun contenu disponible.', style: TextStyle(color: kGrey)))
          else
            isMobile
                ? Column(children: contenus.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _ArticleCard(contenu: c))).toList())
                : Row(children: contenus.map((c) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _ArticleCard(contenu: c)))).toList()),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Map<String, dynamic> contenu;
  const _ArticleCard({required this.contenu});

  @override
  Widget build(BuildContext context) {
    final categorie = contenu['categorie'] as String? ?? '';
    final tagColor = getCategorieColor(categorie);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: contenu['image_url'] != null
              ? Image.network(contenu['image_url'], height: 160, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 160, color: const Color(0xFFD1D5DB),
                      child: const Center(child: Icon(Icons.image, size: 36, color: Color(0xFF9CA3AF)))))
              : Container(height: 160, color: const Color(0xFFD1D5DB),
                  child: const Center(child: Icon(Icons.image, size: 36, color: Color(0xFF9CA3AF)))),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: tagColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(categorie, style: TextStyle(color: tagColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            Text(contenu['titre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kText)),
            const SizedBox(height: 8),
            Text(
              (contenu['texte'] ?? '').length > 100
                  ? '${(contenu['texte'] as String).substring(0, 100)}...'
                  : contenu['texte'] ?? '',
              style: const TextStyle(fontSize: 13, color: kGrey, height: 1.5),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContenuPage())),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Lire l\'article', style: TextStyle(color: kGreen, fontSize: 13, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: kGreen),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION DIAGNOSTIC — présentation Holmes et Rahe
// ─────────────────────────────────────────────
class _DiagnosticSection extends StatelessWidget {
  final bool isMobile;
  const _DiagnosticSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: isMobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _DiagnosticTexte(),
              const SizedBox(height: 32),
              _DiagnosticNiveaux(),
            ])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 5, child: _DiagnosticTexte()),
              const SizedBox(width: 48),
              Expanded(flex: 4, child: _DiagnosticNiveaux()),
            ]),
    );
  }
}

class _DiagnosticTexte extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Évaluez votre niveau de stress',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kText)),
      const SizedBox(height: 12),
      const Text(
        'Notre diagnostic est basé sur l\'échelle de Holmes et Rahe, un outil scientifiquement reconnu. '
        'Il évalue votre stress à partir des événements vécus durant les 12 derniers mois.',
        style: TextStyle(fontSize: 14, color: kGrey, height: 1.6),
      ),
      const SizedBox(height: 8),
      const Text(
        'Cet outil n\'est pas un diagnostic médical. Il fournit des indications générales sur votre niveau de stress.',
        style: TextStyle(fontSize: 13, color: kGrey, height: 1.6),
      ),
      const SizedBox(height: 24),

      // 3 étapes résumées
      _MiniEtape(icon: Icons.checklist_outlined, texte: '43 événements de vie à cocher'),
      _MiniEtape(icon: Icons.calculate_outlined, texte: 'Score calculé automatiquement'),
      _MiniEtape(icon: Icons.insights_outlined, texte: 'Résultat et recommandations personnalisés'),

      const SizedBox(height: 28),
      ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionnairePage())),
        icon: const Icon(Icons.play_arrow_rounded, size: 20),
        label: const Text('Commencer le diagnostic', style: TextStyle(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: kGreen, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    ]);
  }
}

class _MiniEtape extends StatelessWidget {
  final IconData icon;
  final String texte;
  const _MiniEtape({required this.icon, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: kGreen, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(texte, style: const TextStyle(fontSize: 14, color: kText)),
        ),
      ]),
    );
  }
}

class _DiagnosticNiveaux extends StatelessWidget {
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
        const Text('Niveaux de stress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 20),
        _NiveauRow(color: const Color(0xFF10B981), icon: Icons.sentiment_satisfied_alt,
            niveau: 'Faible', score: '< 150 pts'),
        const SizedBox(height: 12),
        _NiveauRow(color: const Color(0xFFF59E0B), icon: Icons.sentiment_neutral,
            niveau: 'Modéré', score: '150–299 pts'),
        const SizedBox(height: 12),
        _NiveauRow(color: const Color(0xFFEF4444), icon: Icons.sentiment_dissatisfied,
            niveau: 'Élevé', score: '≥ 300 pts'),
      ]),
    );
  }
}

class _NiveauRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String niveau;
  final String score;
  const _NiveauRow({required this.color, required this.icon, required this.niveau, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(niveau, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          Text(score, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
        ]),
      ]),
    );
  }
}