import 'package:flutter/material.dart';
import 'home_page.dart';
import 'diagnosticpage.dart';
import 'variables.dart';
import 'contenu_page.dart';
import 'aide_page.dart';
import 'login_popup.dart';
import 'auth_service.dart';
import 'espace_page.dart';
import 'admin.dart';

// ─────────────────────────────────────────────
// NAVBAR PARTAGÉE
// ─────────────────────────────────────────────
class CESIZenNavBar extends StatelessWidget {
  final bool isMobile;
  final String activePage;
  final bool isLoggedIn;

  const CESIZenNavBar({
    super.key,
    required this.isMobile,
    this.activePage = '',
    this.isLoggedIn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 12),
      child: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            ),
            child: Row(children: [
              Image.asset('assets/images/logoCesiZen.png', height: isMobile ? 36 : 48, fit: BoxFit.contain),
              const SizedBox(width: 8),
              // Phrase logo cachée sur mobile
              if (!isMobile)
                Image.asset('assets/images/PhraseLogoCesiZen.png', height: 40, fit: BoxFit.contain),
            ]),
          ),
          const Spacer(),

          if (!isMobile) ...[
            _NavItem(label: 'Accueil', isActive: activePage == 'Accueil', destination: const HomePage()),
            _NavItem(label: 'Diagnostics', isActive: activePage == 'Diagnostics', destination: const DiagnosticPage()),
            _NavItem(label: 'Contenus', isActive: activePage == 'Contenus', destination: const ContenuPage()),
            _NavItem(label: 'Votre espace', isActive: activePage == 'Votre espace', destination: const EspacePage()),
            _NavItem(label: 'Besoin d\'aide ?', isActive: activePage == 'Aide', destination: const AidePage()),
            const SizedBox(width: 16),
            // Bouton auth seulement sur desktop
            _AuthButton(),
          ] else ...[
            // Sur mobile : juste le hamburger
            IconButton(
              onPressed: () => _showMobileMenu(context),
              icon: const Icon(Icons.menu, color: kText),
            ),
          ],
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _MobileMenuItem(label: 'Accueil', icon: Icons.home_outlined, destination: const HomePage()),
          _MobileMenuItem(label: 'Diagnostics', icon: Icons.psychology_outlined, destination: const DiagnosticPage()),
          _MobileMenuItem(label: 'Contenus', icon: Icons.article_outlined, destination: const ContenuPage()),
          _MobileMenuItem(label: 'Votre espace', icon: Icons.person_outline, destination: const EspacePage()),
          _MobileMenuItem(label: 'Besoin d\'aide ?', icon: Icons.help_outline, destination: const AidePage()),
          const Divider(),
          // Bouton connexion dans le menu mobile
          SizedBox(
            width: double.infinity,
            child: _AuthButton(),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOUTON AUTH — StatefulWidget pour se rafraîchir
// ─────────────────────────────────────────────
class _AuthButton extends StatefulWidget {
  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {

  // ── Déconnexion avec confirmation ────────────
  Future<void> _seDeconnecter() async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(28),
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), shape: BoxShape.circle),
              child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 26),
            ),
            const SizedBox(height: 16),
            const Text('Se déconnecter ?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kText)),
            const SizedBox(height: 8),
            Text('Vous êtes connecté en tant que ${AuthService.nom ?? ''}.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: kGrey)),
            const SizedBox(height: 24),
            if (AuthService.isAdmin) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, false);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage()));
                  },
                  icon: const Icon(Icons.admin_panel_settings, size: 16),
                  label: const Text('Tableau de bord', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF856404), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kGrey,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );

    if (confirmer == true) {
      await AuthService.seDeconnecter();
      setState(() {}); // rafraîchit le bouton
      if (mounted) {
        // Retour à l'accueil après déconnexion
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = AuthService.isLoggedIn;

    return ElevatedButton(
      onPressed: () async {
        if (loggedIn) {
          await _seDeconnecter();
        } else {
          await showLoginPopup(context, onSuccess: () {
            setState(() {}); // rafraîchit le bouton après connexion
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: loggedIn ? Colors.white : kGreen,
        foregroundColor: loggedIn ? kText : Colors.white,
        side: loggedIn ? const BorderSide(color: Color(0xFFE5E7EB)) : BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: loggedIn ? 0 : 2,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          loggedIn ? Icons.person_outline : Icons.login,
          size: 16,
          color: loggedIn ? kText : Colors.white,
        ),
        const SizedBox(width: 6),
        Text(
          loggedIn ? AuthService.nom ?? 'Mon compte' : 'Se connecter',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// NAV ITEM
// ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final Widget? destination;

  const _NavItem({required this.label, this.isActive = false, this.destination});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: destination != null
            ? () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => destination!),
                  (route) => false,
                )
            : null,
        child: Text(label, style: TextStyle(
          color: isActive ? kGreen : kText,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        )),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MOBILE MENU ITEM
// ─────────────────────────────────────────────
class _MobileMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget? destination;

  const _MobileMenuItem({required this.label, required this.icon, this.destination});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: kGreen),
      title: Text(label, style: const TextStyle(color: kText, fontSize: 15)),
      onTap: destination != null
          ? () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => destination!),
                (route) => false,
              );
            }
          : null,
    );
  }
}

// ─────────────────────────────────────────────
// FOOTER PARTAGÉ
// ─────────────────────────────────────────────
class CESIZenFooter extends StatelessWidget {
  const CESIZenFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Container(
      color: kText,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 24),
      child: isMobile
          ? const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('© 2026 CESIZen — Tous droits réservés',
                  style: TextStyle(color: Colors.white60, fontSize: 13)),
              SizedBox(height: 12),
              Row(children: [
                Text('Mentions légales', style: TextStyle(color: Colors.white60, fontSize: 13)),
                SizedBox(width: 20),
                Text('Contact', style: TextStyle(color: Colors.white60, fontSize: 13)),
              ]),
            ])
          : Row(
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