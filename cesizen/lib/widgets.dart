import 'package:flutter/material.dart';
import 'home_page.dart';
import 'diagnosticpage.dart';
import 'variables.dart';
import 'contenu_page.dart';
import 'aide_page.dart';
// ─────────────────────────────────────────────
// NAVBAR PARTAGÉE
// ─────────────────────────────────────────────
// Utilisation : CESIZenNavBar(isMobile: isMobile, activePage: 'Accueil')
// Pages disponibles : 'Accueil', 'Diagnostics', 'Contenus', 'Votre espace'
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
              // Logo icône
              Image.asset(
                'assets/images/logoCesiZen.png',
                height: 48,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              // Phrase logo
              Image.asset(
                'assets/images/PhraseLogoCesiZen.png',
                height: 48,
                fit: BoxFit.contain,
              ),
            ]),
          ),
          const Spacer(),

          if (!isMobile) ...[
            _NavItem(
              label: 'Accueil',
              isActive: activePage == 'Accueil',
              destination: HomePage(),
            ),
            _NavItem(
              label: 'Diagnostics',
              isActive: activePage == 'Diagnostics',
              destination: DiagnosticPage(),
            ),
            _NavItem(
              label: 'Contenus',
              isActive: activePage == 'Contenus',
              destination: ContenuPage(),
            ),
            _NavItem(
              label: 'Votre espace',
              isActive: activePage == 'Votre espace',
              // TODO: destination: const EspacePage(),
            ),
            _NavItem(
              label: 'Besoin d\'aide ?',
              isActive: activePage == 'Aide',
              destination: const AidePage(),
            ),
            const SizedBox(width: 16),
          ] else ...[
            IconButton(
              onPressed: () => _showMobileMenu(context),
              icon: const Icon(Icons.menu, color: kText),
            ),
          ],

          // Bouton connexion / déconnexion
          ElevatedButton(
            onPressed: () {
              // TODO: Navigation vers page connexion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              isLoggedIn ? 'Mon compte' : 'Se connecter',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Menu hamburger mobile
  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MobileMenuItem(label: 'Accueil', icon: Icons.home_outlined, destination: const HomePage()),
            _MobileMenuItem(label: 'Diagnostics', icon: Icons.psychology_outlined, destination: DiagnosticPage(isLoggedIn: isLoggedIn)),
            const _MobileMenuItem(label: 'Contenus', icon: Icons.article_outlined),
            const _MobileMenuItem(label: 'Votre espace', icon: Icons.person_outline),
            const _MobileMenuItem(label: 'Besoin d\'aide ?', icon: Icons.help_outline),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final Widget? destination;

  const _NavItem({
    required this.label,
    this.isActive = false,
    this.destination,
  });

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

class _MobileMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget? destination;

  const _MobileMenuItem({
    required this.label,
    required this.icon,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: kGreen),
      title: Text(label, style: const TextStyle(color: kText, fontSize: 15)),
      onTap: destination != null
          ? () {
              Navigator.pop(context); // ferme le menu
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
// Utilisation : const CESIZenFooter()
class CESIZenFooter extends StatelessWidget {
  const CESIZenFooter({super.key});

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