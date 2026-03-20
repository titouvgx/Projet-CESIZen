import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'widgets.dart';
import 'variables.dart';
import 'auth_service.dart';
import 'login_popup.dart';
import 'contenu_page.dart';
import 'diagnosticpage.dart';

// ─────────────────────────────────────────────
// PAGE VOTRE ESPACE
// ─────────────────────────────────────────────
class EspacePage extends StatefulWidget {
  const EspacePage({super.key});

  @override
  State<EspacePage> createState() => _EspacePageState();
}

class _EspacePageState extends State<EspacePage> {
  List<Map<String, dynamic>> _favorisArticles = [];
  List<Map<String, dynamic>> _favorisDiagnostics = [];
  List<Map<String, dynamic>> _historique = [];
  bool _loadingFavoris = true;
  bool _loadingHistorique = true;

  @override
  void initState() {
    super.initState();
    if (AuthService.isLoggedIn) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadFavoris(),
      _loadHistorique(),
    ]);
  }

  Future<void> _loadFavoris() async {
    try {
      final articles = await SupabaseService.getFavoris(AuthService.idUtilisateur!);
      final diagnostics = await SupabaseService.getDiagnosticsFavoris(AuthService.idUtilisateur!);
      if (mounted) {
        setState(() {
          _favorisArticles = articles;
          _favorisDiagnostics = diagnostics;
          _loadingFavoris = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement favoris : $e');
      if (mounted) setState(() => _loadingFavoris = false);
    }
  }

  Future<void> _loadHistorique() async {
    try {
      final data = await SupabaseService.getHistoriqueDiagnostics(AuthService.idUtilisateur!);
      if (mounted) {
        setState(() {
          _historique = data;
          _loadingHistorique = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement historique : $e');
      if (mounted) setState(() => _loadingHistorique = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    // Non connecté
    if (!AuthService.isLoggedIn) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          CESIZenNavBar(isMobile: isMobile, activePage: 'Votre espace'),
          Expanded(child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: kGreenLight, shape: BoxShape.circle),
                child: const Icon(Icons.person_outline, color: kGreen, size: 32),
              ),
              const SizedBox(height: 20),
              const Text('Connectez-vous pour accéder à votre espace',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
              const SizedBox(height: 8),
              const Text('Gérez votre profil, vos favoris et votre historique.',
                  style: TextStyle(fontSize: 14, color: kGrey)),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => showLoginPopup(context, onSuccess: () => setState(() {})),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
                child: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ]),
          )),
          const CESIZenFooter(),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          CESIZenNavBar(isMobile: isMobile, activePage: 'Votre espace'),
          _EspaceHero(isMobile: isMobile),

          // Profil
          _ProfilSection(isMobile: isMobile, onPasswordChanged: () => setState(() {})),

          // Favoris articles
          _FavorisArticlesSection(
            isMobile: isMobile,
            favoris: _favorisArticles,
            loading: _loadingFavoris,
            onRefresh: _loadFavoris,
          ),

          // Favoris diagnostics
          _FavorisDiagnosticsSection(
            isMobile: isMobile,
            favoris: _favorisDiagnostics,
            loading: _loadingFavoris,
            onRefresh: _loadFavoris,
          ),

          // Historique diagnostics
          _HistoriqueSection(
            isMobile: isMobile,
            historique: _historique,
            loading: _loadingHistorique,
            onRefresh: _loadHistorique,
          ),

          const CESIZenFooter(),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO
// ─────────────────────────────────────────────
class _EspaceHero extends StatelessWidget {
  final bool isMobile;
  const _EspaceHero({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Accueil', style: TextStyle(color: kGrey, fontSize: 13)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.chevron_right, size: 16, color: kGrey),
          ),
          Text('Votre espace', style: TextStyle(color: kGreen, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 20),
        const Text('Votre espace personnel',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 12),
        Text('Bienvenue ${AuthService.nom ?? ''} ! Gérez votre profil, vos favoris et votre historique.',
            style: const TextStyle(fontSize: 15, color: kGrey, height: 1.6)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION PROFIL
// ─────────────────────────────────────────────
class _ProfilSection extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onPasswordChanged;

  const _ProfilSection({required this.isMobile, required this.onPasswordChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Mon profil', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 24),

        isMobile
            ? Column(children: [
                _ProfilInfos(),
                const SizedBox(height: 20),
                _ProfilActions(onPasswordChanged: onPasswordChanged),
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 5, child: _ProfilInfos()),
                const SizedBox(width: 32),
                Expanded(flex: 3, child: _ProfilActions(onPasswordChanged: onPasswordChanged)),
              ]),
      ]),
    );
  }
}

class _ProfilInfos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        // Avatar
        Container(
          width: 72, height: 72,
          decoration: const BoxDecoration(color: kGreenLight, shape: BoxShape.circle),
          child: Center(
            child: Text(
              (AuthService.nom ?? 'U').substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kGreen),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Nom
        _ProfilChamp(icon: Icons.person_outline, label: 'Nom', valeur: AuthService.nom ?? '—'),
        const Divider(color: Color(0xFFE5E7EB), height: 24),

        // Email
        _ProfilChamp(
          icon: Icons.email_outlined,
          label: 'Email',
          valeur: AuthService.currentAuthUser?.email ?? '—',
        ),
      ]),
    );
  }
}

class _ProfilChamp extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valeur;
  const _ProfilChamp({required this.icon, required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: kGreen, size: 20),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: kGrey)),
        const SizedBox(height: 2),
        Text(valeur, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
      ]),
    ]);
  }
}

class _ProfilActions extends StatelessWidget {
  final VoidCallback onPasswordChanged;
  const _ProfilActions({required this.onPasswordChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Modifier le profil
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showModifierProfil(context),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Modifier le profil'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kGreen, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ]);
  }

  void _showModifierProfil(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nomController = TextEditingController(text: AuthService.nom ?? '');
    final emailController = TextEditingController(text: AuthService.currentAuthUser?.email ?? '');
    final nouveauMdpController = TextEditingController();
    final confirmMdpController = TextEditingController();
    bool chargement = false;
    bool mdpVisible = false;
    bool changerMdp = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(28),
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Header
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Modifier le profil',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: kGrey)),
                  ]),
                  const SizedBox(height: 24),

                  // ── Nom ──
                  _ChampProfil(
                    controller: nomController,
                    label: 'Nom complet',
                    hint: 'Jean Dupont',
                    icon: Icons.person_outline,
                    validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Email ──
                  _ChampProfil(
                    controller: emailController,
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
                  const SizedBox(height: 20),

                  // ── Toggle changer mot de passe ──
                  GestureDetector(
                    onTap: () => setStateDialog(() => changerMdp = !changerMdp),
                    child: Row(children: [
                      Icon(changerMdp ? Icons.expand_less : Icons.expand_more, color: kGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        changerMdp ? 'Annuler le changement de mot de passe' : 'Changer le mot de passe',
                        style: const TextStyle(fontSize: 13, color: kGreen, fontWeight: FontWeight.w600),
                      ),
                    ]),
                  ),

                  // ── Champs mot de passe ──
                  if (changerMdp) ...[
                    const SizedBox(height: 16),
                    _ChampMdp(
                      controller: nouveauMdpController,
                      label: 'Nouveau mot de passe',
                      visible: mdpVisible,
                      onToggle: () => setStateDialog(() => mdpVisible = !mdpVisible),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (v.length < 6) return 'Min. 6 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _ChampMdp(
                      controller: confirmMdpController,
                      label: 'Confirmer le mot de passe',
                      visible: mdpVisible,
                      onToggle: () => setStateDialog(() => mdpVisible = !mdpVisible),
                      validator: (v) {
                        if (changerMdp && v != nouveauMdpController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ── Bouton enregistrer ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: chargement ? null : () async {
                        if (!formKey.currentState!.validate()) return;
                        setStateDialog(() => chargement = true);

                        try {
                          final client = Supabase.instance.client;

                          // Mise à jour du nom dans la table utilisateur
                          if (nomController.text.trim() != AuthService.nom) {
                            await SupabaseService.updateNom(
                              AuthService.idUtilisateur!,
                              nomController.text.trim(),
                            );
                          }

                          // Mise à jour email + mot de passe dans Supabase Auth
                          final attrs = UserAttributes(
                            email: emailController.text.trim() != AuthService.currentAuthUser?.email
                                ? emailController.text.trim()
                                : null,
                            password: changerMdp && nouveauMdpController.text.isNotEmpty
                                ? nouveauMdpController.text
                                : null,
                          );

                          if (attrs.email != null || attrs.password != null) {
                            await client.auth.updateUser(attrs);
                          }

                          // Recharge le profil
                          await AuthService.restaurerSession();

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Profil mis à jour avec succès !'),
                              backgroundColor: kGreen,
                            ));
                          }
                        } catch (e) {
                          setStateDialog(() => chargement = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Erreur : $e'),
                              backgroundColor: const Color(0xFFEF4444),
                            ));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen, foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE5E7EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: chargement
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Enregistrer les modifications',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Champ texte pour le profil
class _ChampProfil extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ChampProfil({
    required this.controller, required this.label,
    required this.hint, required this.icon,
    this.keyboardType, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: kText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kGrey, fontSize: 14),
          prefixIcon: Icon(icon, color: kGrey, size: 18),
          filled: true, fillColor: kLightGrey,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kGreen, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEF4444))),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    ]);
  }
}

class _ChampMdp extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool visible;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _ChampMdp({
    required this.controller, required this.label,
    required this.visible, required this.onToggle, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        obscureText: !visible,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: kText),
        decoration: InputDecoration(
          hintText: '••••••••',
          prefixIcon: const Icon(Icons.lock_outline, color: kGrey, size: 18),
          suffixIcon: IconButton(
            icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: kGrey, size: 18),
            onPressed: onToggle,
          ),
          filled: true, fillColor: kLightGrey,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kGreen, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
// SECTION FAVORIS ARTICLES
// ─────────────────────────────────────────────
class _FavorisArticlesSection extends StatelessWidget {
  final bool isMobile;
  final List<Map<String, dynamic>> favoris;
  final bool loading;
  final VoidCallback onRefresh;

  const _FavorisArticlesSection({
    required this.isMobile, required this.favoris,
    required this.loading, required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [
            Icon(Icons.favorite, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 10),
            Text('Articles favoris', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
          ]),
          IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh, color: kGreen)),
        ]),
        const SizedBox(height: 24),

        if (loading)
          const Center(child: CircularProgressIndicator(color: kGreen))
        else if (favoris.isEmpty)
          _EmptyFavoris(message: 'Aucun article en favori', icon: Icons.article_outlined,
              action: 'Découvrir les articles', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContenuPage())))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 16, mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 2.5 : 0.75,
            ),
            itemCount: favoris.length,
            itemBuilder: (context, index) {
              final contenu = favoris[index]['contenu'] as Map<String, dynamic>? ?? favoris[index];
              return _FavoriArticleCard(
                contenu: contenu,
                onRemove: () async {
                  await SupabaseService.removeFavori(AuthService.idUtilisateur!, contenu['id_contenu']);
                  onRefresh();
                },
              );
            },
          ),
      ]),
    );
  }
}

class _FavoriArticleCard extends StatelessWidget {
  final Map<String, dynamic> contenu;
  final VoidCallback onRemove;

  const _FavoriArticleCard({required this.contenu, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final categorie = contenu['categorie'] as String? ?? '';
    final tagColor = getCategorieColor(categorie);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Stack(children: [
            contenu['image_url'] != null
                ? Image.network(contenu['image_url'], height: 130, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _PlaceholderImage(categorie: categorie))
                : _PlaceholderImage(categorie: categorie),
            // Bouton supprimer favori
            Positioned(top: 8, right: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                  child: const Icon(Icons.favorite, color: Color(0xFFEF4444), size: 18),
                ),
              ),
            ),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: tagColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(categorie, style: TextStyle(color: tagColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Text(contenu['titre'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kText)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final String categorie;
  const _PlaceholderImage({required this.categorie});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130, color: const Color(0xFFD1D5DB),
      child: const Center(child: Icon(Icons.image, size: 32, color: Color(0xFF9CA3AF))),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION FAVORIS DIAGNOSTICS
// ─────────────────────────────────────────────
class _FavorisDiagnosticsSection extends StatelessWidget {
  final bool isMobile;
  final List<Map<String, dynamic>> favoris;
  final bool loading;
  final VoidCallback onRefresh;

  const _FavorisDiagnosticsSection({
    required this.isMobile, required this.favoris,
    required this.loading, required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [
            Icon(Icons.bookmark, color: kGreen, size: 22),
            SizedBox(width: 10),
            Text('Diagnostics favoris', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
          ]),
          IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh, color: kGreen)),
        ]),
        const SizedBox(height: 24),

        if (loading)
          const Center(child: CircularProgressIndicator(color: kGreen))
        else if (favoris.isEmpty)
          _EmptyFavoris(message: 'Aucun diagnostic en favori', icon: Icons.psychology_outlined,
              action: 'Faire un diagnostic', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticPage())))
        else
          Column(children: favoris.map((diag) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FavoriDiagnosticCard(diagnostic: diag, onRemove: () async {
              await SupabaseService.toggleDiagnosticFavori(diag['id_diagnostic'], false);
              onRefresh();
            }),
          )).toList()),
      ]),
    );
  }
}

class _FavoriDiagnosticCard extends StatelessWidget {
  final Map<String, dynamic> diagnostic;
  final VoidCallback onRemove;

  const _FavoriDiagnosticCard({required this.diagnostic, required this.onRemove});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = diagnostic['theme'] as String? ?? 'Diagnostic';
    final date = _formatDate(diagnostic['date_realisation'] as String?);
    final pageResultat = diagnostic['page_resultat'] as Map<String, dynamic>?;
    final niveau = pageResultat?['niveau_stress'] as String? ?? '—';
    final scoreTotal = diagnostic['score_total'] as int?;
    final color = getThemeColor(theme);
    final icon = getThemeIcon(theme);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(theme, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 12, color: kGrey),
            const SizedBox(width: 4),
            Text(date, style: const TextStyle(fontSize: 12, color: kGrey)),
          ]),
        ])),
        if (scoreTotal != null) ...[
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(niveau, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 4),
            Text('Score : $scoreTotal / 5', style: const TextStyle(fontSize: 12, color: kGrey)),
          ]),
          const SizedBox(width: 12),
        ],
        // Bouton retirer favori
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.bookmark, color: kGreen, size: 22),
          tooltip: 'Retirer des favoris',
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION HISTORIQUE
// ─────────────────────────────────────────────
class _HistoriqueSection extends StatelessWidget {
  final bool isMobile;
  final List<Map<String, dynamic>> historique;
  final bool loading;
  final VoidCallback onRefresh;

  const _HistoriqueSection({
    required this.isMobile, required this.historique,
    required this.loading, required this.onRefresh,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [
            Icon(Icons.history, color: kGreen, size: 22),
            SizedBox(width: 10),
            Text('Historique des diagnostics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
          ]),
          IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh, color: kGreen)),
        ]),
        const SizedBox(height: 24),

        if (loading)
          const Center(child: CircularProgressIndicator(color: kGreen))
        else if (historique.isEmpty)
          _EmptyFavoris(message: 'Aucun diagnostic effectué', icon: Icons.psychology_outlined,
              action: 'Faire un diagnostic', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticPage())))
        else
          Column(children: historique.map((diag) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HistoriqueItem(diagnostic: diag, onFavoriToggle: onRefresh),
          )).toList()),
      ]),
    );
  }
}

class _HistoriqueItem extends StatelessWidget {
  final Map<String, dynamic> diagnostic;
  final VoidCallback onFavoriToggle;

  const _HistoriqueItem({required this.diagnostic, required this.onFavoriToggle});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = diagnostic['theme'] as String? ?? 'Diagnostic';
    final date = _formatDate(diagnostic['date_realisation'] as String?);
    final pageResultat = diagnostic['page_resultat'] as Map<String, dynamic>?;
    final niveau = pageResultat?['niveau_stress'] as String? ?? '—';
    final scoreTotal = diagnostic['score_total'] as int?;
    final estFavori = diagnostic['est_favori'] as bool? ?? false;
    final color = getThemeColor(theme);
    final icon = getThemeIcon(theme);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(theme, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 12, color: kGrey),
            const SizedBox(width: 4),
            Text(date, style: const TextStyle(fontSize: 12, color: kGrey)),
          ]),
        ])),
        if (scoreTotal != null) ...[
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(niveau, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 4),
            Text('Score : $scoreTotal / 5', style: const TextStyle(fontSize: 12, color: kGrey)),
          ]),
          const SizedBox(width: 8),
        ],
        // Bouton favori
        IconButton(
          onPressed: () async {
            await SupabaseService.toggleDiagnosticFavori(diagnostic['id_diagnostic'], !estFavori);
            onFavoriToggle();
          },
          icon: Icon(
            estFavori ? Icons.bookmark : Icons.bookmark_border,
            color: estFavori ? kGreen : kGrey,
            size: 22,
          ),
          tooltip: estFavori ? 'Retirer des favoris' : 'Ajouter aux favoris',
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// ÉTAT VIDE FAVORIS
// ─────────────────────────────────────────────
class _EmptyFavoris extends StatelessWidget {
  final String message;
  final IconData icon;
  final String action;
  final VoidCallback onTap;

  const _EmptyFavoris({
    required this.message, required this.icon,
    required this.action, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(28)),
          child: Icon(icon, color: kGreen, size: 28),
        ),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: kGreen, side: const BorderSide(color: kGreen),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(action),
        ),
      ]),
    );
  }
}