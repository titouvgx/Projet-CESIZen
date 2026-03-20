import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'variables.dart';
import 'widgets.dart';
import 'auth_service.dart';

// ─────────────────────────────────────────────
// PAGE CONTENU
// ─────────────────────────────────────────────
class ContenuPage extends StatefulWidget {
  const ContenuPage({super.key});

  @override
  State<ContenuPage> createState() => _ContenuPageState();
}

class _ContenuPageState extends State<ContenuPage> {

  // ── État ────────────────────────────────────
  List<Map<String, dynamic>> _contenus = [];
  List<String> _categories = [];
  String _categorieSelectionnee = 'Tous';
  String _recherche = '';
  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Chargement des données ───────────────────
  Future<void> _loadData() async {
    try {
      final contenus = await SupabaseService.getContenuPublie();
      final categories = await SupabaseService.getCategories();
      setState(() {
        _contenus = contenus;
        _categories = ['Tous', ...categories];
        _loading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement contenus : $e');
      setState(() => _loading = false);
    }
  }

  // ── Filtrage des contenus ────────────────────
  List<Map<String, dynamic>> get _contenusFiltres {
    return _contenus.where((c) {
      final matchCategorie = _categorieSelectionnee == 'Tous' ||
          c['categorie'] == _categorieSelectionnee;
      final matchRecherche = _recherche.isEmpty ||
          (c['titre'] as String? ?? '').toLowerCase().contains(_recherche.toLowerCase()) ||
          (c['categorie'] as String? ?? '').toLowerCase().contains(_recherche.toLowerCase());
      return matchCategorie && matchRecherche;
    }).toList();
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
            // ── NAVBAR ──
            CESIZenNavBar(isMobile: isMobile, activePage: 'Contenus'),

            // ── HERO ──
            _ContenuHero(isMobile: isMobile),

            // ── CONTENU PRINCIPAL ──
            _ContenuBody(
              isMobile: isMobile,
              loading: _loading,
              categories: _categories,
              categorieSelectionnee: _categorieSelectionnee,
              contenusFiltres: _contenusFiltres,
              totalContenus: _contenus.length,
              searchController: _searchController,
              onCategorieChanged: (cat) => setState(() => _categorieSelectionnee = cat),
              onRechercheChanged: (val) => setState(() => _recherche = val),
            ),

            // ── FOOTER ──
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
class _ContenuHero extends StatelessWidget {
  final bool isMobile;
  const _ContenuHero({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fil d'ariane
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('Accueil', style: TextStyle(color: kGrey, fontSize: 13)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.chevron_right, size: 16, color: kGrey),
            ),
            Text('Contenus', style: TextStyle(color: kGreen, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 20),
          const Text(
            'Nos contenus',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: kText, height: 1.3),
          ),
          const SizedBox(height: 12),
          const Text(
            'Découvrez nos articles sur le bien-être mental, le sommeil, les relations et la gestion du stress.',
            style: TextStyle(fontSize: 15, color: kGrey, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CORPS DE LA PAGE
// ─────────────────────────────────────────────
class _ContenuBody extends StatelessWidget {
  final bool isMobile;
  final bool loading;
  final List<String> categories;
  final String categorieSelectionnee;
  final List<Map<String, dynamic>> contenusFiltres;
  final int totalContenus;
  final TextEditingController searchController;
  final Function(String) onCategorieChanged;
  final Function(String) onRechercheChanged;

  const _ContenuBody({
    required this.isMobile,
    required this.loading,
    required this.categories,
    required this.categorieSelectionnee,
    required this.contenusFiltres,
    required this.totalContenus,
    required this.searchController,
    required this.onCategorieChanged,
    required this.onRechercheChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Barre de recherche ──
          _SearchBar(
            controller: searchController,
            onChanged: onRechercheChanged,
          ),
          const SizedBox(height: 24),

          // ── Onglets catégories ──
          if (loading)
            const SizedBox()
          else
            _CategorieOnglets(
              categories: categories,
              categorieSelectionnee: categorieSelectionnee,
              onChanged: onCategorieChanged,
              isMobile: isMobile,
            ),
          const SizedBox(height: 12),

          // ── Compteur résultats ──
          if (!loading)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                '${contenusFiltres.length} article${contenusFiltres.length > 1 ? 's' : ''} trouvé${contenusFiltres.length > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 13, color: kGrey),
              ),
            ),

          // ── Grille de contenus ──
          if (loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(60),
              child: CircularProgressIndicator(color: kGreen),
            ))
          else if (contenusFiltres.isEmpty)
            _EmptyState()
          else
            _ContenuGrille(
              contenus: contenusFiltres,
              isMobile: isMobile,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BARRE DE RECHERCHE
// ─────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kLightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: kText),
        decoration: InputDecoration(
          hintText: 'Rechercher un article, un thème...',
          hintStyle: const TextStyle(color: kGrey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: kGrey, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: kGrey, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ONGLETS CATÉGORIES
// ─────────────────────────────────────────────
class _CategorieOnglets extends StatelessWidget {
  final List<String> categories;
  final String categorieSelectionnee;
  final Function(String) onChanged;
  final bool isMobile;

  const _CategorieOnglets({
    required this.categories,
    required this.categorieSelectionnee,
    required this.onChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == categorieSelectionnee;
          final color = cat == 'Tous' ? kGreen : getCategorieColor(cat);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : kGrey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GRILLE DE CONTENUS
// ─────────────────────────────────────────────
class _ContenuGrille extends StatelessWidget {
  final List<Map<String, dynamic>> contenus;
  final bool isMobile;

  const _ContenuGrille({required this.contenus, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final int colonnes = isMobile ? 1 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colonnes,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: isMobile ? 2.5 : 0.99,
      ),
      itemCount: contenus.length,
      itemBuilder: (context, index) {
        return _ContenuCard(
          contenu: contenus[index],
          onTap: () => _showContenuPopup(context, contenus[index]),
        );
      },
    );
  }

  // ── Popup détail du contenu ──────────────────
  void _showContenuPopup(BuildContext context, Map<String, dynamic> contenu) {
    final categorie = contenu['categorie'] as String? ?? '';
    final tagColor = getCategorieColor(categorie);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image ──
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    // Image depuis la base
                    contenu['image_url'] != null
                        ? Image.network(
                            contenu['image_url'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _ImagePlaceholder(categorie: categorie),
                          )
                        : _ImagePlaceholder(categorie: categorie),

                    // Bouton fermer
                    Positioned(
                      top: 12, right: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),

                    // Tag catégorie sur l'image
                    Positioned(
                      bottom: 12, left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: tagColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(categorie,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Contenu scrollable ──
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        contenu['titre'] ?? '',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText, height: 1.3),
                      ),
                      const SizedBox(height: 8),

                      // Date
                      if (contenu['date_creation'] != null) ...[
                        Row(children: [
                          const Icon(Icons.calendar_today_outlined, size: 13, color: kGrey),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(contenu['date_creation']),
                            style: const TextStyle(fontSize: 12, color: kGrey),
                          ),
                        ]),
                        const SizedBox(height: 16),
                      ],

                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),

                      // Texte complet
                      Text(
                        contenu['texte'] ?? '',
                        style: const TextStyle(fontSize: 14, color: kText, height: 1.7),
                      ),
                      const SizedBox(height: 24),

                      // Bouton fermer
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreen, foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// ─────────────────────────────────────────────
// CARTE CONTENU
// ─────────────────────────────────────────────
class _ContenuCard extends StatefulWidget {
  final Map<String, dynamic> contenu;
  final VoidCallback onTap;

  const _ContenuCard({required this.contenu, required this.onTap});

  @override
  State<_ContenuCard> createState() => _ContenuCardState();
}

class _ContenuCardState extends State<_ContenuCard> {
  bool _estFavori = false;
  bool _chargementFavori = false;

  @override
  void initState() {
    super.initState();
    _verifierFavori();
  }

  Future<void> _verifierFavori() async {
    if (!AuthService.isLoggedIn) return;
    try {
      final favori = await SupabaseService.isFavori(
        AuthService.idUtilisateur!,
        widget.contenu['id_contenu'],
      );
      if (mounted) setState(() => _estFavori = favori);
    } catch (e) {
      print('❌ Erreur vérification favori : $e');
    }
  }

  Future<void> _toggleFavori() async {
    if (!AuthService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Connectez-vous pour ajouter des favoris.'),
        backgroundColor: kGrey,
      ));
      return;
    }

    setState(() => _chargementFavori = true);
    try {
      if (_estFavori) {
        await SupabaseService.removeFavori(AuthService.idUtilisateur!, widget.contenu['id_contenu']);
      } else {
        await SupabaseService.addFavori(AuthService.idUtilisateur!, widget.contenu['id_contenu']);
      }
      if (mounted) setState(() {
        _estFavori = !_estFavori;
        _chargementFavori = false;
      });
    } catch (e) {
      print('❌ Erreur toggle favori : $e');
      if (mounted) setState(() => _chargementFavori = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorie = widget.contenu['categorie'] as String? ?? '';
    final tagColor = getCategorieColor(categorie);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + bouton cœur ──
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(children: [
                widget.contenu['image_url'] != null
                    ? Image.network(
                        widget.contenu['image_url'],
                        height: 160, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ImagePlaceholder(categorie: categorie),
                      )
                    : _ImagePlaceholder(categorie: categorie),

                // Bouton cœur
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavori,
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4)],
                      ),
                      child: _chargementFavori
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(strokeWidth: 2, color: kGreen),
                            )
                          : Icon(
                              _estFavori ? Icons.favorite : Icons.favorite_border,
                              color: _estFavori ? const Color(0xFFEF4444) : kGrey,
                              size: 18,
                            ),
                    ),
                  ),
                ),
              ]),
            ),

            // ── Infos ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(categorie,
                          style: TextStyle(color: tagColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.contenu['titre'] ?? '',
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kText, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        (widget.contenu['texte'] ?? '').length > 80
                            ? '${(widget.contenu['texte'] as String).substring(0, 80)}...'
                            : widget.contenu['texte'] ?? '',
                        style: const TextStyle(fontSize: 12, color: kGrey, height: 1.5),
                        maxLines: 3, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Lire l\'article',
                          style: TextStyle(color: tagColor, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 13, color: tagColor),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// IMAGE PLACEHOLDER
// ─────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  final String categorie;
  const _ImagePlaceholder({required this.categorie});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160, width: double.infinity,
      color: const Color(0xFFD1D5DB),
      child: Center(
        // TODO: Remplacer par une vraie image uploadée dans Supabase Storage
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.image, size: 36, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 6),
          Text('Photo $categorie',
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ÉTAT VIDE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(28)),
            child: const Icon(Icons.search_off, color: kGreen, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Aucun article trouvé',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 8),
          const Text('Essayez un autre thème ou modifiez votre recherche.',
              style: TextStyle(fontSize: 13, color: kGrey)),
        ],
      ),
    );
  }
}