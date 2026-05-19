# CESIZen

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.19%2B-02569B?logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)
![License](https://img.shields.io/badge/license-MIT-green)

CESIZen est une plateforme web de soutien à la santé mentale destinée aux étudiants CESI.
Elle propose un diagnostic de stress interactif (Holmes et Rahe), des ressources bien-être et un espace personnel de suivi.
Le frontend est compilé en HTML/CSS/JS statique (Flutter Web) et s'appuie sur Supabase pour l'authentification et la base de données.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Navigateur Web                   │
│                   (Chrome / autre)                  │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP
          ┌────────────▼────────────┐
          │     Flutter Web App     │
          │  (HTML/CSS/JS statique) │
          │  GitHub Pages (prod)    │
          │  localhost:8080 (dev)   │
          └────────────┬────────────┘
                       │ HTTPS — API REST / Realtime
          ┌────────────▼────────────┐
          │         Supabase        │
          │  ┌─────────────────┐   │
          │  │  Auth (JWT)     │   │
          │  ├─────────────────┤   │
          │  │  PostgreSQL     │   │
          │  │  (RLS activé)   │   │
          │  ├─────────────────┤   │
          │  │  API REST auto  │   │
          │  └─────────────────┘   │
          └─────────────────────────┘
               Cloud — supabase.com
```

Voir [docs/architecture.md](docs/architecture.md) pour la description détaillée de chaque composant.

---

## Prérequis

| Outil | Version minimum | Lien |
|---|---|---|
| Flutter SDK | 3.19+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.3+ *(inclus avec Flutter)* | — |
| Git | 2.40+ | [git-scm.com](https://git-scm.com) |
| Chrome | Dernière version | [google.com/chrome](https://google.com/chrome) |
| VS Code *(recommandé)* | 1.85+ | [code.visualstudio.com](https://code.visualstudio.com) |

---

## Installation

### 1. Vérifier Flutter

```bash
flutter doctor
```

Tous les éléments doivent être cochés ✓.

---

### 2. Activer le support Web

```bash
flutter config --enable-web
flutter devices   # Chrome doit apparaître dans la liste
```

---

### 3. Cloner le dépôt

```bash
git clone https://github.com/titouvgx/Projet-CESIZen.git
cd Projet-CESIZen/cesizen
```

---

### 4. Installer les dépendances

```bash
flutter pub get
```

---

### 5. Créer le fichier `.env`

Copier le fichier d'exemple et renseigner les valeurs :

```bash
cp ../.env.example .env
```

Puis éditer `.env` avec les clés Supabase du projet (voir [Variables d'environnement](#variables-denvironnement) ci-dessous).

> Le fichier `.env.example` à la racine du dépôt contient les commentaires pour trouver chaque valeur dans le dashboard Supabase.

---

### 6. Lancer l'application

```bash
flutter run -d chrome
```

L'application s'ouvre dans Chrome sur `http://localhost:8080`.

---

## Variables d'environnement

Le fichier `.env` doit être placé dans `cesizen/` (au même niveau que `pubspec.yaml`).
Il est déclaré comme asset Flutter et lu au démarrage via `flutter_dotenv`.

| Variable | Description | Où la trouver |
|---|---|---|
| `SUPABASE_URL` | URL unique du projet Supabase | Supabase Dashboard → Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Clé publique anonyme (safe côté client) | Supabase Dashboard → Settings → API → anon / public |

Exemple de fichier `.env` :

```env
SUPABASE_URL=https://xxxxxxxxxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

> Ne jamais commiter le fichier `.env`. Il est listé dans `.gitignore`.
> Voir `.env.example` à la racine pour un modèle commenté.

---

## Ports utilisés

| Port | Service | Contexte |
|---|---|---|
| `8080` | Flutter Web (dev) | `flutter run -d chrome` en local |
| `443` | Supabase API | Toujours HTTPS en production et en dev |

---

## Comptes de test

| Rôle | Email | Mot de passe |
|---|---|---|
| Administrateur | admin@cesizen.fr | *(fourni séparément)* |
| Citoyen connecté | test@cesizen.fr | *(fourni séparément)* |

Pour créer un compte admin manuellement :

1. Aller dans **Supabase → Authentication → Users → Add user**
2. Copier l'UUID généré
3. Exécuter dans l'éditeur SQL Supabase :

```sql
INSERT INTO utilisateur (id_utilisateur, nom, email, role)
VALUES ('UUID_COPIE', 'Nom Admin', 'admin@exemple.fr', 'Admin');
```

---

## Déploiement GitHub Pages

> Attention : GitHub Pages ne peut pas lire le fichier `.env` au runtime. Les clés Supabase doivent être intégrées directement pour le build de déploiement. Ne jamais pousser ce `main.dart` modifié sur `master` ou `develop`.

```bash
# 1. Depuis le dossier cesizen/, build pour le web
flutter build web --base-href "/Projet-CESIZen/"

# 2. Aller dans le dossier de sortie
cd build/web

# 3. Pousser sur la branche gh-pages
git init
git add .
git commit -m "chore: deploy to GitHub Pages"
git branch -M gh-pages
git remote add origin https://github.com/titouvgx/Projet-CESIZen.git
git push -f origin gh-pages
```

Site en ligne : **https://titouvgx.github.io/Projet-CESIZen/**

Voir [docs/preparation-deploiement.md](docs/preparation-deploiement.md) pour la checklist complète avant déploiement.

---

## Commandes utiles

```bash
# Lancer les tests
flutter test

# Lancer les tests avec détail
flutter test --reporter expanded

# Lancer les tests avec couverture
flutter test --coverage

# Analyser le code (linting)
flutter analyze

# Nettoyer le cache et réinstaller les dépendances
flutter clean && flutter pub get

# Mettre à jour Flutter
flutter upgrade

# Vérifier l'environnement complet
flutter doctor -v
```

---

## Structure du projet

```
Projet-CESIZen/
├── cesizen/                       # Application Flutter
│   ├── lib/
│   │   ├── main.dart              # Point d'entrée — init Supabase
│   │   ├── home_page.dart         # Page d'accueil
│   │   ├── diagnosticpage.dart    # Diagnostic Holmes et Rahe
│   │   ├── questionnaire_page.dart
│   │   ├── contenu_page.dart      # Articles et contenus
│   │   ├── espace_page.dart       # Espace personnel
│   │   ├── admin_page.dart        # Tableau de bord admin
│   │   ├── aide_page.dart         # Page de contact
│   │   ├── login_popup.dart
│   │   ├── auth_service.dart
│   │   ├── variables.dart
│   │   ├── widgets.dart
│   │   └── services/
│   │       └── supabase_service.dart
│   ├── assets/images/
│   ├── .env                       # Non versionné — à créer manuellement
│   └── pubspec.yaml
├── docs/
│   ├── architecture.md
│   └── preparation-deploiement.md
├── .env.example                   # Modèle de configuration
├── .gitignore
├── CHANGELOG.md
├── CONTRIBUTING.md
└── README.md
```

---

## Contribution

Lire [CONTRIBUTING.md](CONTRIBUTING.md) avant d'ouvrir une Pull Request.

---

## Changelog

L'historique des versions est disponible dans [CHANGELOG.md](CHANGELOG.md).

---

## Ressources

- Dépôt GitHub : https://github.com/titouvgx/Projet-CESIZen
- Application en ligne : https://titouvgx.github.io/Projet-CESIZen/
- Documentation Flutter : https://docs.flutter.dev
- Documentation Supabase : https://supabase.com/docs
- Console Supabase : https://supabase.com/dashboard
