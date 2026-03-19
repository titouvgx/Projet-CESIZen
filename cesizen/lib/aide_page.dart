import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'widgets.dart';
import 'variables.dart';

// ─────────────────────────────────────────────
// PAGE BESOIN D'AIDE
// ─────────────────────────────────────────────
class AidePage extends StatefulWidget {
  const AidePage({super.key});

  @override
  State<AidePage> createState() => _AidePageState();
}

class _AidePageState extends State<AidePage> {

  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _sujetController = TextEditingController();
  final _messageController = TextEditingController();

  bool _envoiEnCours = false;
  bool _envoiReussi = false;

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _sujetController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _envoyerMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _envoiEnCours = true);

    try {
      await SupabaseService.envoyerMessage(
        nom: _nomController.text.trim(),
        email: _emailController.text.trim(),
        sujet: _sujetController.text.trim(),
        message: _messageController.text.trim(),
      );
      setState(() { _envoiEnCours = false; _envoiReussi = true; });
      _nomController.clear();
      _emailController.clear();
      _sujetController.clear();
      _messageController.clear();
    } catch (e) {
      print('❌ Erreur envoi message : $e');
      setState(() => _envoiEnCours = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Une erreur est survenue. Veuillez réessayer.'),
          backgroundColor: Color(0xFFEF4444),
        ));
      }
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
            CESIZenNavBar(isMobile: isMobile, activePage: 'Aide'),
            _AideHero(isMobile: isMobile),
            _AideBody(
              isMobile: isMobile,
              formKey: _formKey,
              nomController: _nomController,
              emailController: _emailController,
              sujetController: _sujetController,
              messageController: _messageController,
              envoiEnCours: _envoiEnCours,
              envoiReussi: _envoiReussi,
              onEnvoyer: _envoyerMessage,
              onNouveauMessage: () => setState(() => _envoiReussi = false),
            ),
            const CESIZenFooter(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO
// ─────────────────────────────────────────────
class _AideHero extends StatelessWidget {
  final bool isMobile;
  const _AideHero({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('Accueil', style: TextStyle(color: kGrey, fontSize: 13)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.chevron_right, size: 16, color: kGrey),
            ),
            Text('Besoin d\'aide ?',
                style: TextStyle(color: kGreen, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 20),
          const Text('Besoin d\'aide ?',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: kText, height: 1.3)),
          const SizedBox(height: 12),
          const Text(
            'Notre équipe est disponible pour répondre à toutes vos questions sur CESIZen.',
            style: TextStyle(fontSize: 15, color: kGrey, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CORPS
// ─────────────────────────────────────────────
class _AideBody extends StatelessWidget {
  final bool isMobile;
  final GlobalKey<FormState> formKey;
  final TextEditingController nomController;
  final TextEditingController emailController;
  final TextEditingController sujetController;
  final TextEditingController messageController;
  final bool envoiEnCours;
  final bool envoiReussi;
  final VoidCallback onEnvoyer;
  final VoidCallback onNouveauMessage;

  const _AideBody({
    required this.isMobile,
    required this.formKey,
    required this.nomController,
    required this.emailController,
    required this.sujetController,
    required this.messageController,
    required this.envoiEnCours,
    required this.envoiReussi,
    required this.onEnvoyer,
    required this.onNouveauMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: isMobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _InfosContact(),
              const SizedBox(height: 48),
              _Formulaire(
                formKey: formKey, nomController: nomController,
                emailController: emailController, sujetController: sujetController,
                messageController: messageController, envoiEnCours: envoiEnCours,
                envoiReussi: envoiReussi, onEnvoyer: onEnvoyer, onNouveauMessage: onNouveauMessage,
              ),
            ])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 4, child: _InfosContact()),
              const SizedBox(width: 60),
              Expanded(
                flex: 6,
                child: _Formulaire(
                  formKey: formKey, nomController: nomController,
                  emailController: emailController, sujetController: sujetController,
                  messageController: messageController, envoiEnCours: envoiEnCours,
                  envoiReussi: envoiReussi, onEnvoyer: onEnvoyer, onNouveauMessage: onNouveauMessage,
                ),
              ),
            ]),
    );
  }
}

// ─────────────────────────────────────────────
// INFOS DE CONTACT
// ─────────────────────────────────────────────
class _InfosContact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contactez-nous',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 12),
        const Text(
          'Vous avez une question, un problème ou une suggestion ? Notre équipe vous répond dans les plus brefs délais.',
          style: TextStyle(fontSize: 14, color: kGrey, height: 1.6),
        ),
        const SizedBox(height: 40),

        _ContactCard(icon: Icons.email_outlined, titre: 'Email',
            valeur: 'support@cesizen.fr', sousTitre: 'Réponse sous 24h ouvrées'),
        const SizedBox(height: 16),

        _ContactCard(icon: Icons.phone_outlined, titre: 'Téléphone',
            valeur: '+33 1 23 45 67 89', sousTitre: 'Lun–Ven, 9h–18h'),
        const SizedBox(height: 16),

        _ContactCard(icon: Icons.access_time_outlined, titre: 'Horaires du support',
            valeur: 'Lundi – Vendredi', sousTitre: '9h00 – 18h00'),
        const SizedBox(height: 32),

        // Avertissement urgence
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE69C)),
          ),
          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.warning_amber_outlined, color: Color(0xFF856404), size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'En cas d\'urgence psychologique, contactez le 3114 (numéro national de prévention du suicide), disponible 24h/24.',
                style: TextStyle(fontSize: 13, color: Color(0xFF856404), height: 1.5),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String titre;
  final String valeur;
  final String sousTitre;

  const _ContactCard({
    required this.icon, required this.titre,
    required this.valeur, required this.sousTitre,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: kGreen, size: 22),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titre, style: const TextStyle(fontSize: 12, color: kGrey)),
          const SizedBox(height: 2),
          Text(valeur, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 2),
          Text(sousTitre, style: const TextStyle(fontSize: 12, color: kGrey)),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// FORMULAIRE DE CONTACT
// ─────────────────────────────────────────────
class _Formulaire extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nomController;
  final TextEditingController emailController;
  final TextEditingController sujetController;
  final TextEditingController messageController;
  final bool envoiEnCours;
  final bool envoiReussi;
  final VoidCallback onEnvoyer;
  final VoidCallback onNouveauMessage;

  const _Formulaire({
    required this.formKey, required this.nomController,
    required this.emailController, required this.sujetController,
    required this.messageController, required this.envoiEnCours,
    required this.envoiReussi, required this.onEnvoyer,
    required this.onNouveauMessage,
  });

  @override
  Widget build(BuildContext context) {
    // ── Succès ──
    if (envoiReussi) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(color: kGreenLight, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_outline, color: kGreen, size: 36),
          ),
          const SizedBox(height: 20),
          const Text('Message envoyé !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 8),
          const Text(
            'Merci pour votre message. Notre équipe vous répondra dans les plus brefs délais.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: kGrey, height: 1.6),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: onNouveauMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Envoyer un autre message', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
      );
    }

    // ── Formulaire ──
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Envoyer un message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
            const SizedBox(height: 4),
            const Text('Tous les champs sont obligatoires.',
                style: TextStyle(fontSize: 13, color: kGrey)),
            const SizedBox(height: 28),

            // Nom + Email
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 400;
              final nom = _ChampTexte(
                controller: nomController, label: 'Nom complet',
                hint: 'Jean Dupont', icon: Icons.person_outline,
                validator: (v) => v == null || v.isEmpty ? 'Ce champ est requis' : null,
              );
              final email = _ChampTexte(
                controller: emailController, label: 'Email',
                hint: 'jean@exemple.fr', icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ce champ est requis';
                  if (!v.contains('@')) return 'Email invalide';
                  return null;
                },
              );
              return isWide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: nom), const SizedBox(width: 16), Expanded(child: email)])
                  : Column(children: [nom, const SizedBox(height: 16), email]);
            }),
            const SizedBox(height: 16),

            _ChampTexte(
              controller: sujetController, label: 'Sujet',
              hint: 'Décrivez brièvement votre demande', icon: Icons.subject_outlined,
              validator: (v) => v == null || v.isEmpty ? 'Ce champ est requis' : null,
            ),
            const SizedBox(height: 16),

            _ChampTexte(
              controller: messageController, label: 'Message',
              hint: 'Décrivez votre demande en détail...', icon: Icons.message_outlined,
              maxLines: 5,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ce champ est requis';
                if (v.length < 20) return 'Message trop court (min. 20 caractères)';
                return null;
              },
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: envoiEnCours ? null : onEnvoyer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen, foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: envoiEnCours
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Envoyer le message',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CHAMP TEXTE RÉUTILISABLE
// ─────────────────────────────────────────────
class _ChampTexte extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ChampTexte({
    required this.controller, required this.label,
    required this.hint, required this.icon,
    this.maxLines = 1, this.keyboardType, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: kText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kGrey, fontSize: 14),
            prefixIcon: maxLines == 1 ? Icon(icon, color: kGrey, size: 18) : null,
            filled: true,
            fillColor: kLightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16, vertical: maxLines > 1 ? 16 : 12,
            ),
          ),
        ),
      ],
    );
  }
}