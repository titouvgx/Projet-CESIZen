import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'variables.dart';
import 'utils/cesizen_utils.dart';
import 'admin.dart';

// ─────────────────────────────────────────────
// POPUP DE CONNEXION / INSCRIPTION
// Utilisation :
// showLoginPopup(context);
// ─────────────────────────────────────────────
Future<void> showLoginPopup(BuildContext context, {VoidCallback? onSuccess}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => _LoginPopup(onSuccess: onSuccess),
  );
}

// ── Mode de la popup ────────────────────────
enum _Mode { connexion, inscription, mdpOublie }

class _LoginPopup extends StatefulWidget {
  final VoidCallback? onSuccess;
  const _LoginPopup({this.onSuccess});

  @override
  State<_LoginPopup> createState() => _LoginPopupState();
}

class _LoginPopupState extends State<_LoginPopup> {

  // ── État ────────────────────────────────────
  _Mode _mode = _Mode.connexion;
  bool _chargement = false;
  bool _passwordVisible = false;
  String? _erreur;

  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Contrôleur dédié à l'email du formulaire MDP oublié
  final _emailMdpController = TextEditingController();
  final _formMdpKey = GlobalKey<FormState>();
  bool _mdpEnvoye = false; // true = email envoyé avec succès

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailMdpController.dispose();
    super.dispose();
  }

  // ── Soumission connexion / inscription ───────
  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _chargement = true; _erreur = null; });

    AuthResult result;

    if (_mode == _Mode.connexion) {
      result = await AuthService.seConnecter(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      result = await AuthService.sInscrire(
        nom: _nomController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (!mounted) return;
    setState(() => _chargement = false);

    if (result.success) {
      Navigator.pop(context);

      if (result.role == 'Admin') {
        _showConfirmationAdmin(context);
      } else {
        _showConfirmationUser(context);
      }

      widget.onSuccess?.call();
    } else {
      setState(() => _erreur = result.errorMessage);
    }
  }

  // ── Soumission mot de passe oublié ───────────
  Future<void> _envoyerReinit() async {
    if (!_formMdpKey.currentState!.validate()) return;
    setState(() { _chargement = true; _erreur = null; });

    final result = await AuthService.reinitialiserMotDePasse(
      email: _emailMdpController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _chargement = false;
      if (result.success) {
        _mdpEnvoye = true;
      } else {
        _erreur = result.errorMessage;
      }
    });
  }

  // ── Popup confirmation Admin ─────────────────
  void _showConfirmationAdmin(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings, color: Color(0xFF856404), size: 32),
            ),
            const SizedBox(height: 20),
            const Text('Connecté en tant qu\'Admin',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
            const SizedBox(height: 8),
            Text('Bienvenue ${AuthService.nom ?? ''} !',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: kGrey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFE69C)),
              ),
              child: const Text('Rôle : Administrateur',
                  style: TextStyle(fontSize: 12, color: Color(0xFF856404), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage()));
                },
                icon: const Icon(Icons.admin_panel_settings, size: 18),
                label: const Text('Accéder au tableau de bord', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF856404), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kGreen, side: const BorderSide(color: kGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Continuer sur le site', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Popup confirmation User ──────────────────
  void _showConfirmationUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(color: kGreenLight, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline, color: kGreen, size: 32),
            ),
            const SizedBox(height: 20),
            Text('Bienvenue ${AuthService.nom ?? ''} !',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
            const SizedBox(height: 8),
            const Text('Vous êtes maintenant connecté.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: kGrey)),
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
                child: const Text('Continuer', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Vue mot de passe oublié ──────────────────
  Widget _buildMdpOublie() {
    if (_mdpEnvoye) {
      // Écran de confirmation d'envoi
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(
            titre: 'Email envoyé',
            sousTitre: 'Vérifiez votre boîte mail',
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 32),
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(color: kGreenLight, shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_read_outlined, color: kGreen, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'Un lien de réinitialisation a été envoyé à :',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: kGrey),
          ),
          const SizedBox(height: 6),
          Text(
            _emailMdpController.text.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pensez à vérifier vos spams.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: kGrey),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() {
                _mode = _Mode.connexion;
                _mdpEnvoye = false;
                _emailMdpController.clear();
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Retour à la connexion',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ],
      );
    }

    // Formulaire de demande
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(
          titre: 'Mot de passe oublié',
          sousTitre: 'Nous vous enverrons un lien de réinitialisation',
          onClose: () => Navigator.pop(context),
        ),
        const SizedBox(height: 28),

        // Bouton retour
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => setState(() { _mode = _Mode.connexion; _erreur = null; }),
            child: Row(mainAxisSize: MainAxisSize.min, children: const [
              Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: kGreen),
              SizedBox(width: 4),
              Text('Retour', style: TextStyle(fontSize: 13, color: kGreen, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        Form(
          key: _formMdpKey,
          child: Column(children: [
            _ChampLogin(
              controller: _emailMdpController,
              label: 'Adresse email',
              hint: 'jean@exemple.fr',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: validerEmailCesizen,
            ),

            if (_erreur != null) ...[
              const SizedBox(height: 16),
              _buildErreur(_erreur!),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _chargement ? null : _envoyerReinit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen, foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _chargement
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Envoyer le lien',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  // ── Helper : header commun ───────────────────
  Widget _buildHeader({
    required String titre,
    required String sousTitre,
    required VoidCallback onClose,
  }) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titre,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 4),
        Text(sousTitre, style: const TextStyle(fontSize: 13, color: kGrey)),
      ]),
      IconButton(onPressed: onClose, icon: const Icon(Icons.close, color: kGrey)),
    ]);
  }

  // ── Helper : bloc erreur ─────────────────────
  Widget _buildErreur(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message,
            style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444)))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _mode == _Mode.mdpOublie
                ? KeyedSubtree(key: const ValueKey('mdp'), child: _buildMdpOublie())
                : KeyedSubtree(
                    key: const ValueKey('auth'),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // ── Header ──
                        _buildHeader(
                          titre: _mode == _Mode.connexion ? 'Se connecter' : 'Créer un compte',
                          sousTitre: _mode == _Mode.connexion
                              ? 'Accédez à votre espace personnel'
                              : 'Rejoignez CESIZen',
                          onClose: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 28),

                        // ── Onglets Connexion / Inscription ──
                        Container(
                          decoration: BoxDecoration(
                            color: kLightGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(children: [
                            _Onglet(
                              label: 'Connexion',
                              isActive: _mode == _Mode.connexion,
                              onTap: () => setState(() { _mode = _Mode.connexion; _erreur = null; }),
                            ),
                            _Onglet(
                              label: 'Inscription',
                              isActive: _mode == _Mode.inscription,
                              onTap: () => setState(() { _mode = _Mode.inscription; _erreur = null; }),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 28),

                        // ── Formulaire ──
                        Form(
                          key: _formKey,
                          child: Column(children: [

                            // Nom (inscription uniquement)
                            if (_mode == _Mode.inscription) ...[
                              _ChampLogin(
                                controller: _nomController,
                                label: 'Nom complet',
                                hint: 'Jean Dupont',
                                icon: Icons.person_outline,
                                validator: validerNomCesizen,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email
                            _ChampLogin(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'jean@exemple.fr',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Requis';
                                if (!v.contains('@')) return 'Email invalide';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Mot de passe
                            _ChampLogin(
                              controller: _passwordController,
                              label: 'Mot de passe',
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscureText: !_passwordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: kGrey, size: 18,
                                ),
                                onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                              ),
                              validator: (v) {
                                if (_mode == _Mode.inscription) return validerMotDePasseCesizen(v);
                                if (v == null || v.isEmpty) return 'Requis';
                                return null;
                              },
                            ),

                            // ── Lien "Mot de passe oublié ?" ──────────────
                            if (_mode == _Mode.connexion) ...[
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _mode = _Mode.mdpOublie;
                                    _erreur = null;
                                    // Pré-remplir l'email si déjà saisi
                                    _emailMdpController.text = _emailController.text;
                                  }),
                                  child: const Text(
                                    'Mot de passe oublié ?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: kGreen,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // Message d'erreur
                            if (_erreur != null) ...[
                              const SizedBox(height: 16),
                              _buildErreur(_erreur!),
                            ],

                            const SizedBox(height: 24),

                            // Bouton soumettre
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _chargement ? null : _soumettre,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kGreen, foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: _chargement
                                    ? const SizedBox(width: 20, height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(
                                        _mode == _Mode.connexion ? 'Se connecter' : 'Créer mon compte',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                              ),
                            ),
                          ]),
                        ),

                        // ── Basculer mode ──
                        const SizedBox(height: 20),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            _mode == _Mode.connexion ? 'Pas encore de compte ? ' : 'Déjà un compte ? ',
                            style: const TextStyle(fontSize: 13, color: kGrey),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _mode = _mode == _Mode.connexion ? _Mode.inscription : _Mode.connexion;
                              _erreur = null;
                            }),
                            child: Text(
                              _mode == _Mode.connexion ? 'S\'inscrire' : 'Se connecter',
                              style: const TextStyle(
                                  fontSize: 13, color: kGreen, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ONGLET CONNEXION / INSCRIPTION
// ─────────────────────────────────────────────
class _Onglet extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Onglet({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 1))]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? kText : kGrey,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CHAMP DE FORMULAIRE
// ─────────────────────────────────────────────
class _ChampLogin extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _ChampLogin({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
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
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: kText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kGrey, fontSize: 14),
            prefixIcon: Icon(icon, color: kGrey, size: 18),
            suffixIcon: suffixIcon,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}