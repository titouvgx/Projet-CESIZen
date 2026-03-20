import 'package:flutter/material.dart';

import 'services/supabase_service.dart';
import 'diagnosticpage.dart';
import 'variables.dart';
import 'widgets.dart';
import 'contenu_page.dart';

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
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _choix = [];
  Map<String, int> _reponses = {};
  bool _loadingContenus = true;
  bool _loadingQuestions = true;

  @override
  void initState() {
    super.initState();
    _loadContenus();
    _loadQuestions();
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

  Future<void> _loadQuestions() async {
    try {
      final questions = await SupabaseService.getQuestions();
      final choix = await SupabaseService.getChoixReponse();
      setState(() {
        _questions = questions;
        _choix = choix;
        _loadingQuestions = false;
      });
    } catch (e) {
      print('❌ Erreur chargement questions : $e');
      setState(() => _loadingQuestions = false);
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
            // ── NAVBAR depuis widgets.dart ──
            CESIZenNavBar(isMobile: isMobile, activePage: 'Accueil'),

            _HeroSection(isMobile: isMobile),
            _AboutSection(isMobile: isMobile),

            _TrendingSection(
              isMobile: isMobile,
              contenus: _contenus,
              loading: _loadingContenus,
            ),

            _DiagnosticSection(
              isMobile: isMobile,
              questions: _questions,
              choix: _choix,
              reponses: _reponses,
              loading: _loadingQuestions,
              onReponseChanged: (idQuestion, idChoix) {
                setState(() => _reponses[idQuestion] = idChoix);
              },
            ),

            // ── FOOTER depuis widgets.dart ──
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
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kText, height: 1.3)),
        const SizedBox(height: 16),
        const Text(
          'CESIZen est une plateforme publique pour informer, prévenir et sensibiliser sur les enjeux de santé mentale de manière apaisante et pédagogique.',
          style: TextStyle(fontSize: 15, color: kGrey, height: 1.6),
        ),
        const SizedBox(height: 28),
        Row(children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DiagnosticPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text('Faire un diagnostic'),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContenuPage(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: kGreen, side: const BorderSide(color: kGreen),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text('Découvrir les contenus'),
          ),
        ]),
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
        child: Image.asset(
          'assets/images/HEROzen.jpg',
          fit: BoxFit.cover,
        ),
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

  const _TrendingSection({
    required this.isMobile,
    required this.contenus,
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
    final tagColor = getCategorieColor(categorie); // ← depuis variables.dart

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: contenu['image_url'] != null
                ? Image.network(
                    contenu['image_url'],
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160, color: const Color(0xFFD1D5DB),
                      child: const Center(child: Icon(Icons.image, size: 36, color: Color(0xFF9CA3AF))),
                    ),
                  )
                : Container(
                    height: 160, color: const Color(0xFFD1D5DB),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.image, size: 36, color: Color(0xFF9CA3AF)),
                        const SizedBox(height: 6),
                        Text('Photo $categorie', textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                      ]),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(categorie,
                    style: TextStyle(color: tagColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 10),
              Text(contenu['titre'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kText)),
              const SizedBox(height: 8),
              Text(
                (contenu['texte'] ?? '').length > 100
                    ? '${(contenu['texte'] as String).substring(0, 100)}...'
                    : contenu['texte'] ?? '',
                style: const TextStyle(fontSize: 13, color: kGrey, height: 1.5),
              ),
              const SizedBox(height: 12),
              GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContenuPage()),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lire l\'article',
                    style: TextStyle(
                      color: kGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14, color: kGreen),
                ],
              ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION DIAGNOSTIC
// ─────────────────────────────────────────────
class _DiagnosticSection extends StatelessWidget {
  final bool isMobile;
  final List<Map<String, dynamic>> questions;
  final List<Map<String, dynamic>> choix;
  final Map<String, int> reponses;
  final bool loading;
  final Function(String idQuestion, int idChoix) onReponseChanged;

  const _DiagnosticSection({
    required this.isMobile,
    required this.questions,
    required this.choix,
    required this.reponses,
    required this.loading,
    required this.onReponseChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: isMobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _DiagnosticLeft(),
              const SizedBox(height: 32),
              _DiagnosticQuestions(
                isMobile: isMobile,
                questions: questions,
                choix: choix,
                reponses: reponses,
                loading: loading,
                onReponseChanged: onReponseChanged,
              ),
            ])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: _DiagnosticLeft()),
              const SizedBox(width: 48),
              Expanded(
                flex: 7,
                child: _DiagnosticQuestions(
                  isMobile: isMobile,
                  questions: questions,
                  choix: choix,
                  reponses: reponses,
                  loading: loading,
                  onReponseChanged: onReponseChanged,
                ),
              ),
            ]),
    );
  }
}

class _DiagnosticLeft extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Évaluez votre bien-être',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 12),
        const Text(
          'Notre questionnaire simple et anonyme vous permet d\'obtenir une évaluation générale de votre état de bien-être actuel.',
          style: TextStyle(fontSize: 14, color: kGrey, height: 1.6),
        ),
        const SizedBox(height: 8),
        const Text(
          'Cet outil n\'est pas un diagnostic médical. Il vise à fournir des indications générales sur votre bien-être mental.',
          style: TextStyle(fontSize: 13, color: kGrey, height: 1.6),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DiagnosticPage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kGreen, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          child: const Text('Commencer le diagnostic'),
        ),
      ],
    );
  }
}

class _DiagnosticQuestions extends StatelessWidget {
  final bool isMobile;
  final List<Map<String, dynamic>> questions;
  final List<Map<String, dynamic>> choix;
  final Map<String, int> reponses;
  final bool loading;
  final Function(String idQuestion, int idChoix) onReponseChanged;

  const _DiagnosticQuestions({
    required this.isMobile,
    required this.questions,
    required this.choix,
    required this.reponses,
    required this.loading,
    required this.onReponseChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: kGreen));
    }
    if (questions.isEmpty) {
      return const Text('Aucune question disponible.', style: TextStyle(color: kGrey));
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 2.2 : 0.85,
          ),
          itemCount: questions.length > 3 ? 3 : questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            final idQuestion = question['id_question'] as String;
            return _QuestionCard(
              numero: index + 1,
              question: question,
              choix: choix,
              selectedChoix: reponses[idQuestion],
              onChanged: (idChoix) => onReponseChanged(idQuestion, idChoix),
            );
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: reponses.length >= 3 ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DiagnosticPage()),
              );
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: kYellow,
              foregroundColor: kText,
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              reponses.length == questions.length
                  ? 'Valider le diagnostic'
                  : 'Accéder aux diagnostics complets',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int numero;
  final Map<String, dynamic> question;
  final List<Map<String, dynamic>> choix;
  final int? selectedChoix;
  final Function(int idChoix) onChanged;

  const _QuestionCard({
    required this.numero,
    required this.question,
    required this.choix,
    required this.selectedChoix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text('$numero',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                question['libelle'] ?? '',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText, height: 1.4),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 8),
          ...choix.map((c) {
            final idChoix = c['id_choix'] as int;
            final libelle = c['libelle'] as String;
            final isSelected = selectedChoix == idChoix;

            return GestureDetector(
              onTap: () => onChanged(idChoix),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? kGreen : const Color(0xFFD1D5DB), width: 2),
                      color: isSelected ? kGreen : Colors.white,
                    ),
                    child: isSelected
                        ? const Center(child: Icon(Icons.circle, size: 8, color: Colors.white))
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(libelle, style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? kGreen : kGrey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  )),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }
}