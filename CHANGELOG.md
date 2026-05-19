# Changelog — CESIZen

Toutes les modifications notables de ce projet sont documentées ici.

Le format suit [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/) et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

---

## [2.0.0] — 2025-06-01

### Ajout
- Version finale complète du projet CESIZen
- Support Flutter Web avec déploiement GitHub Pages
- Intégration complète Supabase (authentification, base de données, RLS)
- Tableau de bord administrateur avec gestion des contenus et utilisateurs
- Espace personnel utilisateur avec historique des diagnostics
- Chargement des variables d'environnement via `flutter_dotenv`

### Modifié
- Architecture refactorisée avec séparation claire des services (`supabase_service.dart`)
- Interface entièrement revue pour la version finale

---

## [1.2.0] — 2025-04-15

### Corrigé
- Correction des overflow sur mobile dans le popup de connexion
- Correction de l'affichage des articles sur petits écrans
- Optimisation des requêtes Supabase pour réduire la latence

### Modifié
- Amélioration de la gestion des erreurs d'authentification
- Nettoyage du code et suppression des dépendances inutilisées

---

## [1.1.0] — 2025-03-20

### Ajout
- Interface d'administration pour la gestion des contenus
- Gestion des rôles utilisateurs (Admin / Citoyen) côté Supabase
- Filtrage et recherche dans la liste des contenus

### Modifié
- Refonte de la navigation principale (Navbar)
- Amélioration de l'accessibilité des formulaires

---

## [1.0.0] — 2025-02-10

### Ajout
- Création initiale du projet CESIZen
- Application Flutter Web connectée à Supabase
- Page d'accueil avec présentation de la plateforme
- Diagnostic de stress Holmes et Rahe (questionnaire interactif)
- Page de contenus (articles et ressources bien-être)
- Système d'authentification (inscription / connexion)
- Page de contact et d'aide
- Déploiement initial sur GitHub Pages
