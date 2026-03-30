import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'variables.dart';
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

class _LoginPopup extends StatefulWidget {
  final VoidCallback? onSuccess;
  const _LoginPopup({this.onSuccess});

  @override
  State<_LoginPopup> createState() => _LoginPopupState();
}

class _LoginPopupState extends State<_LoginPopup> {

  // ── État ────────────────────────────────────
  bool _modeConnexion = true; // true = connexion, false = inscription
  bool _chargement = false;
  bool _passwordVisible = false;
  String? _erreur;

  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Soumission ───────────────────────────────
  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _chargement = true; _erreur = null; });

    AuthResult result;

    if (_modeConnexion) {
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
      Navigator.pop(context); // ferme la popup login

      // Popup de confirmation selon le rôle
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ── Header ──
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    _modeConnexion ? 'Se connecter' : 'Créer un compte',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _modeConnexion ? 'Accédez à votre espace personnel' : 'Rejoignez CESIZen',
                    style: const TextStyle(fontSize: 13, color: kGrey),
                  ),
                ]),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: kGrey),
                ),
              ]),
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
                    isActive: _modeConnexion,
                    onTap: () => setState(() { _modeConnexion = true; _erreur = null; }),
                  ),
                  _Onglet(
                    label: 'Inscription',
                    isActive: !_modeConnexion,
                    onTap: () => setState(() { _modeConnexion = false; _erreur = null; }),
                  ),
                ]),
              ),
              const SizedBox(height: 28),

              // ── Formulaire ──
              Form(
                key: _formKey,
                child: Column(children: [

                  // Nom (inscription uniquement)
                  if (!_modeConnexion) ...[
                    _ChampLogin(
                      controller: _nomController,
                      label: 'Nom complet',
                      hint: 'Jean Dupont',
                      icon: Icons.person_outline,
                      validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
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
                        _passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: kGrey, size: 18,
                      ),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      if (!_modeConnexion && v.length < 6) return 'Min. 6 caractères';
                      return null;
                    },
                  ),

                  // Message d'erreur
                  if (_erreur != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_erreur!,
                            style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444)))),
                      ]),
                    ),
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
                              _modeConnexion ? 'Se connecter' : 'Créer mon compte',
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
                  _modeConnexion ? 'Pas encore de compte ? ' : 'Déjà un compte ? ',
                  style: const TextStyle(fontSize: 13, color: kGrey),
                ),
                GestureDetector(
                  onTap: () => setState(() { _modeConnexion = !_modeConnexion; _erreur = null; }),
                  child: Text(
                    _modeConnexion ? 'S\'inscrire' : 'Se connecter',
                    style: const TextStyle(fontSize: 13, color: kGreen, fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ],
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