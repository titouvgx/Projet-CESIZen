import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'variables.dart';
import 'auth_service.dart';
import 'home_page.dart';

// ─────────────────────────────────────────────
// PAGE ADMIN
// ─────────────────────────────────────────────
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _ongletActif = 0;

  final List<_OngletData> _onglets = const [
    _OngletData(label: 'Statistiques', icon: Icons.bar_chart_outlined),
    _OngletData(label: 'Utilisateurs', icon: Icons.people_outline),
    _OngletData(label: 'Contenus', icon: Icons.article_outlined),
    _OngletData(label: 'Holmes', icon: Icons.psychology_outlined),
    _OngletData(label: 'Messages', icon: Icons.mail_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    // Sécurité — redirige si pas admin
    if (!AuthService.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const HomePage()), (r) => false);
      });
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: isMobile
          ? _MobileLayout(
              onglets: _onglets,
              ongletActif: _ongletActif,
              onOngletChanged: (i) => setState(() => _ongletActif = i),
            )
          : _DesktopLayout(
              onglets: _onglets,
              ongletActif: _ongletActif,
              onOngletChanged: (i) => setState(() => _ongletActif = i),
            ),
    );
  }
}

// ─────────────────────────────────────────────
// LAYOUT DESKTOP — sidebar + contenu
// ─────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final List<_OngletData> onglets;
  final int ongletActif;
  final Function(int) onOngletChanged;

  const _DesktopLayout({required this.onglets, required this.ongletActif, required this.onOngletChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // Sidebar
      Container(
        width: 240,
        color: kText,
        child: Column(children: [
          // Header sidebar
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 12),
              const Text('Tableau de bord', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(AuthService.nom ?? 'Admin', style: const TextStyle(color: Colors.white60, fontSize: 13)),
            ]),
          ),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),

          // Onglets
          ...onglets.asMap().entries.map((e) => _SidebarItem(
            data: e.value,
            isActive: ongletActif == e.key,
            onTap: () => onOngletChanged(e.key),
          )),

          const Spacer(),
          const Divider(color: Colors.white12, height: 1),

          // Retour accueil
          ListTile(
            leading: const Icon(Icons.arrow_back, color: Colors.white60, size: 20),
            title: const Text('Retour au site', style: TextStyle(color: Colors.white60, fontSize: 14)),
            onTap: () => Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const HomePage()), (r) => false),
          ),
          const SizedBox(height: 8),
        ]),
      ),

      // Contenu principal
      Expanded(child: _ContenuOnglet(ongletActif: ongletActif)),
    ]);
  }
}

// ─────────────────────────────────────────────
// LAYOUT MOBILE — bottom nav
// ─────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final List<_OngletData> onglets;
  final int ongletActif;
  final Function(int) onOngletChanged;

  const _MobileLayout({required this.onglets, required this.ongletActif, required this.onOngletChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: kText,
        title: const Text('Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const HomePage()), (r) => false),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.admin_panel_settings, color: kGreen),
          ),
        ],
      ),
      body: _ContenuOnglet(ongletActif: ongletActif),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: ongletActif,
        onTap: onOngletChanged,
        selectedItemColor: kGreen,
        unselectedItemColor: kGrey,
        type: BottomNavigationBarType.fixed,
        items: onglets.map((o) => BottomNavigationBarItem(
          icon: Icon(o.icon),
          label: o.label,
        )).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIDEBAR ITEM
// ─────────────────────────────────────────────
class _SidebarItem extends StatelessWidget {
  final _OngletData data;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({required this.data, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? kGreen.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(data.icon, color: isActive ? kGreen : Colors.white60, size: 20),
        title: Text(data.label, style: TextStyle(
          color: isActive ? Colors.white : Colors.white70,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        )),
        onTap: onTap,
        dense: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONTENU SELON ONGLET
// ─────────────────────────────────────────────
class _ContenuOnglet extends StatelessWidget {
  final int ongletActif;
  const _ContenuOnglet({required this.ongletActif});

  @override
  Widget build(BuildContext context) {
    switch (ongletActif) {
      case 0: return const _StatistiquesTab();
      case 1: return const _UtilisateursTab();
      case 2: return const _ContenusTab();
      case 3: return const _HolmesTab();
      case 4: return const _MessagesTab();
      default: return const _StatistiquesTab();
    }
  }
}

// ─────────────────────────────────────────────
// WIDGETS COMMUNS
// ─────────────────────────────────────────────
class _AdminHeader extends StatelessWidget {
  final String titre;
  final String sousTitre;
  final IconData icon;
  final Widget? action;

  const _AdminHeader({required this.titre, required this.sousTitre, required this.icon, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: kGreen, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
          Text(sousTitre, style: const TextStyle(fontSize: 13, color: kGrey)),
        ])),
        if (action != null) action!,
      ]),
    );
  }
}

Widget _statCard(String label, String valeur, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(height: 16),
      Text(valeur, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 13, color: kGrey)),
    ]),
  );
}

// ─────────────────────────────────────────────
// TAB 0 — STATISTIQUES
// ─────────────────────────────────────────────
class _StatistiquesTab extends StatefulWidget {
  const _StatistiquesTab();

  @override
  State<_StatistiquesTab> createState() => _StatistiquesTabState();
}

class _StatistiquesTabState extends State<_StatistiquesTab> {
  final _client = Supabase.instance.client;
  int _nbUsers = 0, _nbDiagnostics = 0, _nbContenus = 0, _nbMessages = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final users = await _client.from('utilisateur').select('id_utilisateur');
      final diags = await _client.from('diagnostic').select('id_diagnostic');
      final contenus = await _client.from('contenu').select('id_contenu');
      final messages = await _client.from('contact_message').select('id_message');
      if (mounted) setState(() {
        _nbUsers = (users as List).length;
        _nbDiagnostics = (diags as List).length;
        _nbContenus = (contenus as List).length;
        _nbMessages = (messages as List).length;
        _loading = false;
      });
    } catch (e) {
      print('❌ Stats : $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(child: Column(children: [
      _AdminHeader(titre: 'Statistiques', sousTitre: 'Vue d\'ensemble de la plateforme', icon: Icons.bar_chart_outlined),
      Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: kGreen))
            : GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 2 : 4,
                crossAxisSpacing: 16, mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 1.1 : 1.3,
                children: [
                  _statCard('Utilisateurs', '$_nbUsers', Icons.people_outline, kGreen),
                  _statCard('Diagnostics', '$_nbDiagnostics', Icons.psychology_outlined, const Color(0xFF8B5CF6)),
                  _statCard('Articles', '$_nbContenus', Icons.article_outlined, const Color(0xFF3B82F6)),
                  _statCard('Messages', '$_nbMessages', Icons.mail_outline, const Color(0xFFF59E0B)),
                ],
              ),
      ),
    ]));
  }
}

// ─────────────────────────────────────────────
// TAB 1 — UTILISATEURS
// ─────────────────────────────────────────────
class _UtilisateursTab extends StatefulWidget {
  const _UtilisateursTab();

  @override
  State<_UtilisateursTab> createState() => _UtilisateursTabState();
}

class _UtilisateursTabState extends State<_UtilisateursTab> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadUsers(); }

  Future<void> _loadUsers() async {
    try {
      final data = await _client.from('utilisateur').select().order('date_creation', ascending: false);
      if (mounted) setState(() { _users = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _supprimerUser(String id, String nom) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Supprimer l\'utilisateur ?'),
        content: Text('Êtes-vous sûr de vouloir supprimer $nom ? Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmer == true) {
      await _client.from('utilisateur').delete().eq('id_utilisateur', id);
      _loadUsers();
    }
  }

  void _showFormUser(Map<String, dynamic> u) {
    final nomCtrl = TextEditingController(text: u['nom'] ?? '');
    final emailCtrl = TextEditingController(text: u['email'] ?? '');
    String roleSelectionne = u['role'] as String? ?? 'Citoyen connecte';
    final formKey = GlobalKey<FormState>();
    bool chargement = false;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 440),
          child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Modifier l\'utilisateur',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
              IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: kGrey)),
            ]),
            const SizedBox(height: 20),

            _champAdmin('Nom complet', nomCtrl, validator: (v) => v!.isEmpty ? 'Requis' : null),
            const SizedBox(height: 12),
            _champAdmin('Email', emailCtrl, keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (!v.contains('@')) return 'Email invalide';
                  return null;
                }),
            const SizedBox(height: 16),

            // Sélecteur de rôle
            const Text('Rôle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
            const SizedBox(height: 8),
            Row(children: [
              _RoleChip(
                label: 'Citoyen',
                valeur: 'Citoyen connecte',
                selectionne: roleSelectionne,
                couleur: kGreen,
                onTap: () => setS(() => roleSelectionne = 'Citoyen connecte'),
              ),
              const SizedBox(width: 10),
              _RoleChip(
                label: 'Admin',
                valeur: 'Admin',
                selectionne: roleSelectionne,
                couleur: const Color(0xFF856404),
                onTap: () => setS(() => roleSelectionne = 'Admin'),
              ),
            ]),
            const SizedBox(height: 24),

            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: chargement ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setS(() => chargement = true);
                try {
                  await _client.from('utilisateur').update({
                    'nom': nomCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'role': roleSelectionne,
                  }).eq('id_utilisateur', u['id_utilisateur']);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadUsers();
                } catch (e) { setS(() => chargement = false); }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: chargement
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.w600)),
            )),
          ])),
        ),
      ),
    ));
  }

  String _formatDate(String? d) {
    if (d == null) return '—';
    final date = DateTime.tryParse(d);
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _AdminHeader(
        titre: 'Utilisateurs', sousTitre: '${_users.length} comptes enregistrés', icon: Icons.people_outline,
        action: IconButton(onPressed: _loadUsers, icon: const Icon(Icons.refresh, color: kGreen)),
      ),
      Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: kGreen))
          : _users.isEmpty
              ? const Center(child: Text('Aucun utilisateur.', style: TextStyle(color: kGrey)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final u = _users[i];
                    final role = u['role'] as String? ?? '—';
                    final isAdmin = role == 'Admin';
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: isAdmin ? const Color(0xFFFFF3CD) : kGreenLight,
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text(
                              (u['nom'] as String? ?? 'U').substring(0, 1).toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold,
                                  color: isAdmin ? const Color(0xFF856404) : kGreen),
                            )),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(u['nom'] ?? '—',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kText)),
                            Text(u['email'] ?? '—', style: const TextStyle(fontSize: 12, color: kGrey)),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isAdmin ? const Color(0xFFFFF3CD) : kGreenLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(role, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                  color: isAdmin ? const Color(0xFF856404) : kGreen)),
                            ),
                            const SizedBox(height: 4),
                            Text(_formatDate(u['date_creation'] as String?),
                                style: const TextStyle(fontSize: 11, color: kGrey)),
                          ]),
                        ]),
                        const SizedBox(height: 12),
                        // Boutons actions
                        Row(children: [
                          Expanded(child: OutlinedButton.icon(
                            onPressed: () => _showFormUser(u),
                            icon: const Icon(Icons.edit_outlined, size: 14),
                            label: const Text('Modifier', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF3B82F6),
                              side: const BorderSide(color: Color(0xFF3B82F6)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          )),
                          const SizedBox(width: 8),
                          // Bouton toggle admin (sauf pour soi-même)
                          if (u['id_utilisateur'] != AuthService.idUtilisateur)
                            Expanded(child: OutlinedButton.icon(
                              onPressed: () async {
                                final nouveauRole = isAdmin ? 'Citoyen connecte' : 'Admin';
                                await _client.from('utilisateur')
                                    .update({'role': nouveauRole})
                                    .eq('id_utilisateur', u['id_utilisateur']);
                                _loadUsers();
                              },
                              icon: Icon(isAdmin ? Icons.person_outline : Icons.admin_panel_settings_outlined, size: 14),
                              label: Text(isAdmin ? 'Rétrograder' : 'Promouvoir admin',
                                  style: const TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isAdmin ? kGrey : const Color(0xFF856404),
                                side: BorderSide(color: isAdmin ? kGrey : const Color(0xFF856404)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            )),
                          const SizedBox(width: 8),
                          if (u['id_utilisateur'] != AuthService.idUtilisateur)
                            IconButton(
                              onPressed: () => _supprimerUser(u['id_utilisateur'], u['nom'] ?? ''),
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                              tooltip: 'Supprimer',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                        ]),
                      ]),
                    );
                  },
                ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
// TAB 2 — CONTENUS
// ─────────────────────────────────────────────
class _ContenusTab extends StatefulWidget {
  const _ContenusTab();

  @override
  State<_ContenusTab> createState() => _ContenusTabState();
}

class _ContenusTabState extends State<_ContenusTab> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _contenus = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadContenus(); }

  Future<void> _loadContenus() async {
    try {
      final data = await _client.from('contenu').select().order('date_creation', ascending: false);
      if (mounted) setState(() { _contenus = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _togglePublication(String id, String statut) async {
    final nouveau = statut == 'publié' ? 'brouillon' : 'publié';
    await _client.from('contenu').update({'statut_publication': nouveau}).eq('id_contenu', id);
    _loadContenus();
  }

  Future<void> _supprimerContenu(String id, String titre) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Supprimer l\'article ?'),
        content: Text('Voulez-vous supprimer "$titre" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmer == true) {
      await _client.from('contenu').delete().eq('id_contenu', id);
      _loadContenus();
    }
  }

  void _showFormContenu({Map<String, dynamic>? contenu}) {
    final titreCtrl = TextEditingController(text: contenu?['titre'] ?? '');
    final texteCtrl = TextEditingController(text: contenu?['texte'] ?? '');
    final categorieCtrl = TextEditingController(text: contenu?['categorie'] ?? '');
    final imageCtrl = TextEditingController(text: contenu?['image_url'] ?? '');
    final formKey = GlobalKey<FormState>();
    bool chargement = false;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(child: Form(key: formKey, child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(contenu == null ? 'Nouvel article' : 'Modifier l\'article',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: kGrey)),
              ]),
              const SizedBox(height: 20),
              _champAdmin('Titre', titreCtrl, validator: (v) => v!.isEmpty ? 'Requis' : null),
              const SizedBox(height: 12),
              _champAdmin('Catégorie', categorieCtrl, hint: 'Stress, Bien-être, Sommeil...', validator: (v) => v!.isEmpty ? 'Requis' : null),
              const SizedBox(height: 12),
              _champAdmin('URL de l\'image', imageCtrl, hint: 'https://...'),
              const SizedBox(height: 12),
              _champAdmin('Texte', texteCtrl, maxLines: 6, validator: (v) => v!.isEmpty ? 'Requis' : null),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: chargement ? null : () async {
                  if (!formKey.currentState!.validate()) return;
                  setS(() => chargement = true);
                  try {
                    final data = {
                      'titre': titreCtrl.text.trim(),
                      'texte': texteCtrl.text.trim(),
                      'categorie': categorieCtrl.text.trim(),
                      'image_url': imageCtrl.text.trim().isEmpty ? null : imageCtrl.text.trim(),
                      'statut_publication': 'brouillon',
                    };
                    if (contenu == null) {
                      await _client.from('contenu').insert(data);
                    } else {
                      await _client.from('contenu').update(data).eq('id_contenu', contenu['id_contenu']);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadContenus();
                  } catch (e) { setS(() => chargement = false); }
                },
                style: ElevatedButton.styleFrom(backgroundColor: kGreen, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: chargement
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(contenu == null ? 'Créer l\'article' : 'Enregistrer', style: const TextStyle(fontWeight: FontWeight.w600)),
              )),
            ],
          ))),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _AdminHeader(
        titre: 'Contenus', sousTitre: '${_contenus.length} articles', icon: Icons.article_outlined,
        action: Row(children: [
          IconButton(onPressed: _loadContenus, icon: const Icon(Icons.refresh, color: kGreen)),
          ElevatedButton.icon(
            onPressed: () => _showFormContenu(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Nouvel article'),
            style: ElevatedButton.styleFrom(backgroundColor: kGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ]),
      ),
      Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: kGreen))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _contenus.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final c = _contenus[i];
                final statut = c['statut_publication'] as String? ?? 'brouillon';
                final estPublie = statut == 'publié';
                final categColor = getCategorieColor(c['categorie'] as String? ?? '');
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(c['titre'] ?? '—',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kText))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: estPublie ? kGreenLight : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(statut, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: estPublie ? kGreen : kGrey)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: categColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(c['categorie'] ?? '—', style: TextStyle(fontSize: 11, color: categColor, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: OutlinedButton.icon(
                        onPressed: () => _togglePublication(c['id_contenu'], statut),
                        icon: Icon(estPublie ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 14),
                        label: Text(estPublie ? 'Dépublier' : 'Publier', style: const TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(foregroundColor: estPublie ? kGrey : kGreen,
                            side: BorderSide(color: estPublie ? kGrey : kGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(vertical: 8)),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton.icon(
                        onPressed: () => _showFormContenu(contenu: c),
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text('Modifier', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF3B82F6),
                            side: const BorderSide(color: Color(0xFF3B82F6)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(vertical: 8)),
                      )),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _supprimerContenu(c['id_contenu'], c['titre'] ?? ''),
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                      ),
                    ]),
                  ]),
                );
              },
            ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
// TAB 3 — HOLMES ET RAHE
// ─────────────────────────────────────────────
class _HolmesTab extends StatefulWidget {
  const _HolmesTab();

  @override
  State<_HolmesTab> createState() => _HolmesTabState();
}

class _HolmesTabState extends State<_HolmesTab> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _evenements = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadEvenements(); }

  Future<void> _loadEvenements() async {
    try {
      final data = await _client.from('evenement_holmes').select().order('ordre', ascending: true);
      if (mounted) setState(() { _evenements = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  void _showFormEvenement({Map<String, dynamic>? ev}) {
    final libelleCtrl = TextEditingController(text: ev?['libelle'] ?? '');
    final scoreCtrl = TextEditingController(text: ev?['score']?.toString() ?? '');
    final ordreCtrl = TextEditingController(text: ev?['ordre']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(context: context, builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 440),
        child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(ev == null ? 'Nouvel événement' : 'Modifier l\'événement',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
            IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: kGrey)),
          ]),
          const SizedBox(height: 20),
          _champAdmin('Libellé', libelleCtrl, validator: (v) => v!.isEmpty ? 'Requis' : null),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _champAdmin('Score (pts)', scoreCtrl, keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requis' : null)),
            const SizedBox(width: 12),
            Expanded(child: _champAdmin('Ordre', ordreCtrl, keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requis' : null)),
          ]),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'libelle': libelleCtrl.text.trim(),
                'score': int.tryParse(scoreCtrl.text) ?? 0,
                'ordre': int.tryParse(ordreCtrl.text) ?? 0,
              };
              if (ev == null) {
                await _client.from('evenement_holmes').insert(data);
              } else {
                await _client.from('evenement_holmes').update(data).eq('id_evenement', ev['id_evenement']);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              _loadEvenements();
            },
            style: ElevatedButton.styleFrom(backgroundColor: kGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: Text(ev == null ? 'Créer' : 'Enregistrer', style: const TextStyle(fontWeight: FontWeight.w600)),
          )),
        ])),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _AdminHeader(
        titre: 'Échelle de Holmes', sousTitre: '${_evenements.length} événements', icon: Icons.psychology_outlined,
        action: Row(children: [
          IconButton(onPressed: _loadEvenements, icon: const Icon(Icons.refresh, color: kGreen)),
          ElevatedButton.icon(
            onPressed: () => _showFormEvenement(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Ajouter'),
            style: ElevatedButton.styleFrom(backgroundColor: kGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ]),
      ),
      Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: kGreen))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _evenements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final ev = _evenements[i];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: kLightGrey, borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Text('${ev['ordre']}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kGrey))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(ev['libelle'] ?? '—',
                        style: const TextStyle(fontSize: 13, color: kText))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(20)),
                      child: Text('${ev['score']} pts',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGreen)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showFormEvenement(ev: ev),
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF3B82F6)),
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                    ),
                  ]),
                );
              },
            ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
// TAB 4 — MESSAGES DE CONTACT
// ─────────────────────────────────────────────
class _MessagesTab extends StatefulWidget {
  const _MessagesTab();

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadMessages(); }

  Future<void> _loadMessages() async {
    try {
      final data = await _client.from('contact_message').select().order('date_envoi', ascending: false);
      if (mounted) setState(() { _messages = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _marquerLu(String id, bool lu) async {
    await _client.from('contact_message').update({'lu': !lu}).eq('id_message', id);
    _loadMessages();
  }

  String _formatDate(String? d) {
    if (d == null) return '—';
    final date = DateTime.tryParse(d);
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final nonLus = _messages.where((m) => m['lu'] == false).length;
    return Column(children: [
      _AdminHeader(
        titre: 'Messages', sousTitre: '$nonLus non lu${nonLus > 1 ? 's' : ''}', icon: Icons.mail_outline,
        action: IconButton(onPressed: _loadMessages, icon: const Icon(Icons.refresh, color: kGreen)),
      ),
      Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: kGreen))
          : _messages.isEmpty
              ? const Center(child: Text('Aucun message.', style: TextStyle(color: kGrey)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final m = _messages[i];
                    final lu = m['lu'] as bool? ?? false;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lu ? Colors.white : kGreenLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: lu ? const Color(0xFFE5E7EB) : kGreen.withOpacity(0.3)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          if (!lu)
                            Container(
                              width: 8, height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle),
                            ),
                          Expanded(child: Text(m['sujet'] ?? '—',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kText))),
                          Text(_formatDate(m['date_envoi'] as String?),
                              style: const TextStyle(fontSize: 11, color: kGrey)),
                        ]),
                        const SizedBox(height: 4),
                        Text('${m['nom'] ?? '—'} — ${m['email'] ?? '—'}',
                            style: const TextStyle(fontSize: 12, color: kGrey)),
                        const SizedBox(height: 8),
                        Text(m['message'] ?? '', style: const TextStyle(fontSize: 13, color: kText, height: 1.5)),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _marquerLu(m['id_message'], lu),
                            icon: Icon(lu ? Icons.mark_email_unread_outlined : Icons.mark_email_read_outlined,
                                size: 14, color: kGreen),
                            label: Text(lu ? 'Marquer non lu' : 'Marquer comme lu',
                                style: const TextStyle(fontSize: 12, color: kGreen)),
                          ),
                        ),
                      ]),
                    );
                  },
                ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
// CHIP DE SÉLECTION DE RÔLE
// ─────────────────────────────────────────────
class _RoleChip extends StatelessWidget {
  final String label;
  final String valeur;
  final String selectionne;
  final Color couleur;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label, required this.valeur,
    required this.selectionne, required this.couleur, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectionne == valeur;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? couleur.withOpacity(0.12) : kLightGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? couleur : const Color(0xFFE5E7EB), width: isSelected ? 2 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(valeur == 'Admin' ? Icons.admin_panel_settings_outlined : Icons.person_outline,
              size: 16, color: isSelected ? couleur : kGrey),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? couleur : kGrey,
          )),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CHAMP FORMULAIRE ADMIN
// ─────────────────────────────────────────────
Widget _champAdmin(
  String label,
  TextEditingController controller, {
  String? hint,
  int maxLines = 1,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        filled: true, fillColor: kLightGrey,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kGreen, width: 2)),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: maxLines > 1 ? 14 : 10),
      ),
    ),
  ]);
}

// ─────────────────────────────────────────────
// DATA CLASS
// ─────────────────────────────────────────────
class _OngletData {
  final String label;
  final IconData icon;
  const _OngletData({required this.label, required this.icon});
}