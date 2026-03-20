import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'widgets.dart';
import 'variables.dart';
import 'auth_service.dart';

// ─────────────────────────────────────────────
// PAGE QUESTIONNAIRE
// ─────────────────────────────────────────────
class QuestionnairePage extends StatefulWidget {
  final String theme;
  final bool isLoggedIn;
  final String? idUtilisateur;

  const QuestionnairePage({
    super.key,
    required this.theme,
    this.isLoggedIn = false,
    this.idUtilisateur,
  });

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {

  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _choix = [];
  Map<String, int> _reponses = {};
  bool _loading = true;
  bool _envoiEnCours = false;
  int _questionActuelle = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final questions = await SupabaseService.getQuestionsByTheme(widget.theme);
      final choix = await SupabaseService.getChoixReponse();
      setState(() {
        _questions = questions;
        _choix = choix;
        _loading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement questionnaire : $e');
      setState(() => _loading = false);
    }
  }

  void _questionSuivante() {
    if (_questionActuelle < _questions.length - 1) {
      setState(() => _questionActuelle++);
    }
  }

  void _questionPrecedente() {
    if (_questionActuelle > 0) {
      setState(() => _questionActuelle--);
    }
  }

  int _calculerScore() {
  if (_questions.isEmpty || _choix.isEmpty) return 0;
  
  int total = 0;
  for (final idChoix in _reponses.values) {
    final choix = _choix.firstWhere(
      (c) => c['id_choix'] == idChoix,
      orElse: () => {},
    );
    total += (choix['score'] as int? ?? 0);
  }

  // Score max = nb questions × score max par question (4)
  final scoreMax = _questions.length * 4;
  if (scoreMax == 0) return 0;

  // Ramène sur 5 et arrondit
  final scoreSur5 = (total / scoreMax * 5).round();
  
  print('🔢 Score brut: $total / $scoreMax → Score/5: $scoreSur5');
  return scoreSur5;
}

  Future<void> _soumettre() async {
    if (_reponses.length < _questions.length) return;
    setState(() => _envoiEnCours = true);

    try {
      final scoreTotal = _calculerScore();
      final pageResultat = await SupabaseService.getPageResultat(
      scoreTotal,
      theme: widget.theme,
    );

      if (AuthService.isLoggedIn && AuthService.idUtilisateur != null) {
        final idDiagnostic = await SupabaseService.createDiagnostic(
          AuthService.idUtilisateur!,
          theme: widget.theme,
        );
        final reponses = _reponses.entries.map((e) => {
          'id_question': e.key,
          'id_choix': e.value,
        }).toList();
        await SupabaseService.saveReponses(idDiagnostic, reponses);
        if (pageResultat != null) {
          await SupabaseService.updateDiagnostic(idDiagnostic, scoreTotal, pageResultat['id_page_resultat']);
        }
      }

      if (mounted) _showResultat(scoreTotal, pageResultat);
    } catch (e) {
      print('❌ Erreur soumission : $e');
      setState(() => _envoiEnCours = false);
    }
  }

  void _showResultat(int score, Map<String, dynamic>? pageResultat) {
    final niveau = pageResultat?['niveau_stress'] as String? ?? '—';

    // Couleur + icône selon le niveau
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
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── Icône niveau ──
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(color: niveauColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(niveauIcon, color: niveauColor, size: 40),
                ),
                const SizedBox(height: 16),

                Text('Diagnostic ${widget.theme} terminé !',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
                const SizedBox(height: 20),

                // ── Score + Niveau ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: niveauColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: niveauColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        Text('$score / 5',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: niveauColor)),
                        const SizedBox(height: 4),
                        const Text('Score', style: TextStyle(fontSize: 12, color: kGrey)),
                      ]),
                      Container(width: 1, height: 40, color: niveauColor.withOpacity(0.2)),
                      Column(children: [
                        Text(niveau,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: niveauColor)),
                        const SizedBox(height: 4),
                        const Text('Niveau', style: TextStyle(fontSize: 12, color: kGrey)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Message + recommandations ──
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
                    child: const Text('Aucun résultat trouvé pour ce score.',
                        style: TextStyle(fontSize: 13, color: kGrey)),
                  ),
                ],
                const SizedBox(height: 16),

                // ── Message si non connecté ──
                if (!AuthService.isLoggedIn)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFE69C)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.lock_outline, size: 16, color: Color(0xFF856404)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Connectez-vous pour sauvegarder vos résultats.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF856404)),
                        ),
                      ),
                    ]),
                  ),

                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kGrey, side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Retour', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _reponses = {};
                          _questionActuelle = 0;
                          _envoiEnCours = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Recommencer', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final color = getThemeColor(widget.theme); // ← depuis variables.dart

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── NAVBAR depuis widgets.dart ──
            CESIZenNavBar(isMobile: isMobile, activePage: 'Diagnostics', isLoggedIn: AuthService.isLoggedIn),

            _QuestionnaireHero(theme: widget.theme, isMobile: isMobile),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(80),
                child: Center(child: CircularProgressIndicator(color: kGreen)),
              )
            else if (_questions.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
                child: Center(child: Column(children: [
                  const Icon(Icons.info_outline, color: kGrey, size: 48),
                  const SizedBox(height: 16),
                  const Text('Aucune question disponible pour ce thème.',
                      style: TextStyle(color: kGrey, fontSize: 15)),
                ])),
              )
            else
              _QuestionnaireContenu(
                isMobile: isMobile,
                questions: _questions,
                choix: _choix,
                reponses: _reponses,
                questionActuelle: _questionActuelle,
                envoiEnCours: _envoiEnCours,
                color: color,
                onReponseChanged: (idQuestion, idChoix) {
                  setState(() => _reponses[idQuestion] = idChoix);
                },
                onSuivante: _questionSuivante,
                onPrecedente: _questionPrecedente,
                onSoumettre: _soumettre,
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
// HERO QUESTIONNAIRE
// ─────────────────────────────────────────────
class _QuestionnaireHero extends StatelessWidget {
  final String theme;
  final bool isMobile;
  const _QuestionnaireHero({required this.theme, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final color = getThemeColor(theme); // ← depuis variables.dart
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('Diagnostics', style: TextStyle(color: kGrey, fontSize: 13)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.chevron_right, size: 16, color: kGrey),
            ),
            Text(theme, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(getThemeIcon(theme), color: color, size: 24), // ← depuis variables.dart
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Diagnostic $theme',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kText)),
              const Text('Répondez honnêtement, il n\'y a pas de bonne ou mauvaise réponse.',
                  style: TextStyle(fontSize: 13, color: kGrey)),
            ]),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONTENU DU QUESTIONNAIRE
// ─────────────────────────────────────────────
class _QuestionnaireContenu extends StatelessWidget {
  final bool isMobile;
  final List<Map<String, dynamic>> questions;
  final List<Map<String, dynamic>> choix;
  final Map<String, int> reponses;
  final int questionActuelle;
  final bool envoiEnCours;
  final Color color;
  final Function(String, int) onReponseChanged;
  final VoidCallback onSuivante;
  final VoidCallback onPrecedente;
  final VoidCallback onSoumettre;

  const _QuestionnaireContenu({
    required this.isMobile,
    required this.questions,
    required this.choix,
    required this.reponses,
    required this.questionActuelle,
    required this.envoiEnCours,
    required this.color,
    required this.onReponseChanged,
    required this.onSuivante,
    required this.onPrecedente,
    required this.onSoumettre,
  });

  @override
  Widget build(BuildContext context) {
    final question = questions[questionActuelle];
    final idQuestion = question['id_question'] as String;
    final total = questions.length;
    final progression = (questionActuelle + 1) / total;
    final estDerniere = questionActuelle == total - 1;
    final aRepondu = reponses.containsKey(idQuestion);
    final toutesRepondues = reponses.length == total;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 48),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Question ${questionActuelle + 1} sur $total',
                    style: const TextStyle(fontSize: 13, color: kGrey, fontWeight: FontWeight.w500)),
                Text('${(progression * 100).toInt()}%',
                    style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progression,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
                      child: Center(
                        child: Text('${questionActuelle + 1}',
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(question['libelle'] ?? '',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kText, height: 1.4)),
                    ),
                  ]),
                  const SizedBox(height: 28),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 20),

                  ...choix.map((c) {
                    final idChoix = c['id_choix'] as int;
                    final libelle = c['libelle'] as String;
                    final score = c['score'] as int;
                    final isSelected = reponses[idQuestion] == idChoix;

                    return GestureDetector(
                      onTap: () => onReponseChanged(idQuestion, idChoix),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.07) : Colors.white,
                          border: Border.all(color: isSelected ? color : const Color(0xFFE5E7EB), width: isSelected ? 2 : 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? color : const Color(0xFFD1D5DB), width: 2),
                              color: isSelected ? color : Colors.white,
                            ),
                            child: isSelected
                                ? const Center(child: Icon(Icons.circle, size: 9, color: Colors.white))
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(libelle, style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? color : kText,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ))),
                          Text('$score pt${score > 1 ? 's' : ''}',
                              style: TextStyle(fontSize: 11, color: isSelected ? color : const Color(0xFFD1D5DB))),
                        ]),
                      ),
                    );
                  }),
                ]),
              ),
              const SizedBox(height: 32),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                if (questionActuelle > 0)
                  OutlinedButton.icon(
                    onPressed: onPrecedente,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Précédent'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kGrey, side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  )
                else
                  const SizedBox(),

                if (!estDerniere)
                  ElevatedButton.icon(
                    onPressed: aRepondu ? onSuivante : null,
                    icon: const Text('Suivant'),
                    label: const Icon(Icons.arrow_forward, size: 16),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color, foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: toutesRepondues && !envoiEnCours ? onSoumettre : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kYellow, foregroundColor: kText,
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    ),
                    child: envoiEnCours
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: kText))
                        : const Text('Valider le diagnostic', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
              ]),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${reponses.length} / $total question${reponses.length > 1 ? 's' : ''} répondue${reponses.length > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 12, color: kGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}