import 'package:flutter/material.dart';
import 'services/supabase_service.dart';

// ─────────────────────────────────────────────
// CONSTANTES (mêmes que les autres pages)
// ─────────────────────────────────────────────
const kGreen = Color(0xFF2EAF6F);
const kGreenLight = Color(0xFFE8F7EF);
const kYellow = Color(0xFFF5C842);
const kGrey = Color(0xFF6B7280);
const kLightGrey = Color(0xFFF3F4F6);
const kText = Color(0xFF1F2937);

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

  // ── État ────────────────────────────────────
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _choix = [];
  Map<String, int> _reponses = {}; // id_question → id_choix
  bool _loading = true;
  bool _envoiEnCours = false;
  int _questionActuelle = 0; // index de la question affichée

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

  // ── Navigation entre questions ───────────────
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

  // ── Calcul du score total ────────────────────
  int _calculerScore() {
    int total = 0;
    for (final idChoix in _reponses.values) {
      final choix = _choix.firstWhere((c) => c['id_choix'] == idChoix, orElse: () => {});
      total += (choix['score'] as int? ?? 0);
    }
    return total;
  }

  // ── Soumission du diagnostic ─────────────────
  Future<void> _soumettre() async {
    if (_reponses.length < _questions.length) return;

    setState(() => _envoiEnCours = true);

    try {
      final scoreTotal = _calculerScore();

      // Trouve la page résultat correspondante
      final pageResultat = await SupabaseService.getPageResultat(scoreTotal);

      if (widget.isLoggedIn && widget.idUtilisateur != null) {
        // Crée le diagnostic en base
        final idDiagnostic = await SupabaseService.createDiagnostic(widget.idUtilisateur!);

        // Sauvegarde les réponses
        final reponses = _reponses.entries.map((e) => {
          'id_question': e.key,
          'id_choix': e.value,
        }).toList();
        await SupabaseService.saveReponses(idDiagnostic, reponses);

        // Met à jour le score et la page résultat
        if (pageResultat != null) {
          await SupabaseService.updateDiagnostic(
            idDiagnostic,
            scoreTotal,
            pageResultat['id_page_resultat'],
          );
        }
      }

      // Affiche le résultat
      if (mounted) {
        _showResultat(scoreTotal, pageResultat);
      }
    } catch (e) {
      print('❌ Erreur soumission : $e');
      setState(() => _envoiEnCours = false);
    }
  }

  // ── Popup résultat ───────────────────────────
  void _showResultat(int score, Map<String, dynamic>? pageResultat) {
    final color = getThemeColor(widget.theme);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône succès
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.check_circle_outline, color: color, size: 36),
              ),
              const SizedBox(height: 20),

              Text('Diagnostic ${widget.theme} terminé !',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
              const SizedBox(height: 8),

              // Score
              Text('Score total : $score points',
                  style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),

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
                          'Niveau : ${pageResultat['niveau_stress']}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                        ),
                      ]),
                      const SizedBox(height: 10),
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
                const SizedBox(height: 16),
              ] else ...[
                const Text('Aucun résultat trouvé pour ce score.',
                    style: TextStyle(fontSize: 13, color: kGrey)),
                const SizedBox(height: 16),
              ],

              // Message si non connecté
              if (!widget.isLoggedIn)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kLightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline, size: 16, color: kGrey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connectez-vous pour sauvegarder vos résultats et suivre votre évolution.',
                        style: TextStyle(fontSize: 12, color: kGrey),
                      ),
                    ),
                  ]),
                ),

              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // ferme popup
                      Navigator.pop(context); // retour page diagnostics
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kGreen, side: const BorderSide(color: kGreen),
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
                      // Recommence le même diagnostic
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final color = getThemeColor(widget.theme);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── NAVBAR ──
            _NavBar(isMobile: isMobile),

            // ── HERO ──
            _QuestionnaireHero(theme: widget.theme, isMobile: isMobile),

            // ── CONTENU ──
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(80),
                child: Center(child: CircularProgressIndicator(color: kGreen)),
              )
            else if (_questions.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
                child: Center(
                  child: Column(children: [
                    Icon(Icons.info_outline, color: kGrey, size: 48),
                    const SizedBox(height: 16),
                    const Text('Aucune question disponible pour ce thème.',
                        style: TextStyle(color: kGrey, fontSize: 15)),
                  ]),
                ),
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

            // ── FOOTER ──
            _Footer(),
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
    final color = getThemeColor(theme);
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fil d'ariane
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
              child: Icon(getThemeIcon(theme), color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Diagnostic $theme',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kText)),
              Text('Répondez honnêtement, il n\'y a pas de bonne ou mauvaise réponse.',
                  style: const TextStyle(fontSize: 13, color: kGrey)),
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

              // ── Barre de progression ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Question ${questionActuelle + 1} sur $total',
                      style: const TextStyle(fontSize: 13, color: kGrey, fontWeight: FontWeight.w500)),
                  Text('${(progression * 100).toInt()}%',
                      style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
                ],
              ),
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

              // ── Carte question ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Numéro + libellé
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
                        child: Text(
                          question['libelle'] ?? '',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kText, height: 1.4),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 28),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 20),

                    // Boutons radio
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
                            border: Border.all(
                              color: isSelected ? color : const Color(0xFFE5E7EB),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(children: [
                            // Bouton radio custom
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
                            Expanded(
                              child: Text(libelle, style: TextStyle(
                                fontSize: 14,
                                color: isSelected ? color : kText,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              )),
                            ),
                            // Score affiché discrètement
                            Text('$score pt${score > 1 ? 's' : ''}',
                                style: TextStyle(fontSize: 11, color: isSelected ? color : const Color(0xFFD1D5DB))),
                          ]),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Navigation ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bouton précédent
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

                  // Bouton suivant / soumettre
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
                          : const Text('Valider le diagnostic',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                ],
              ),

              // Indicateur de questions répondues
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

// ─────────────────────────────────────────────
// NAVBAR
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
                child: Text('CZ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
            const Text('CESIZen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kText)),
          ]),
          const Spacer(),
          if (!isMobile) ...[
            _NavItem('Accueil'),
            _NavItem('Diagnostics', onTap: () => Navigator.pop(context)),
            _NavItem('Contenus'),
            _NavItem('Votre espace'),
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
  final VoidCallback? onTap;
  const _NavItem(this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: onTap ?? () {},
        child: Text(label, style: const TextStyle(color: kText, fontSize: 14)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FOOTER
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