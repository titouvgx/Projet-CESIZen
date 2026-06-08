# CESIZen

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.41.1-02569B?logo=flutter)
![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker)
![Nginx](https://img.shields.io/badge/Nginx-alpine-009639?logo=nginx)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)
![CI/CD](https://img.shields.io/github/actions/workflow/status/titouvgx/Projet-CESIZen/ci-cd.yml?label=CI%2FCD&logo=github-actions)
![License](https://img.shields.io/badge/license-MIT-green)

CESIZen est une plateforme web de soutien à la santé mentale destinée aux étudiants CESI. Elle propose un diagnostic de stress interactif (Holmes et Rahe), des ressources bien-être et un espace personnel de suivi.

Le frontend est une application Flutter compilée en HTML/CSS/JS statique, servie par Nginx dans un conteneur Docker, et connectée à Supabase pour l'authentification et la base de données.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                          Navigateur Web                          │
└───────────────────────────────┬──────────────────────────────────┘
                                │ HTTP / HTTPS
                   ┌────────────▼────────────┐
                   │     Nginx (reverse       │
                   │      proxy / TLS)        │
                   │  ┌────────────────────┐  │
                   │  │  Rate limiting     │  │
                   │  │  CSP / HSTS        │  │
                   │  │  Gzip             │  │
                   │  │  SPA routing      │  │
                   │  └────────────────────┘  │
                   └────────────┬─────────────┘
                                │ HTTP interne
                   ┌────────────▼─────────────┐
                   │   Flutter Web (statique)  │
                   │   Dart compilé → JS/HTML  │
                   │   Servi par Nginx Alpine  │
                   └────────────┬──────────────┘
                                │ HTTPS — PostgREST / GoTrue (JWT)
                   ┌────────────▼─────────────┐
                   │         Supabase          │  Cloud — supabase.com
                   │  • Auth (GoTrue / JWT)    │
                   │  • PostgreSQL + RLS       │
                   │  • API REST (PostgREST)   │
                   └───────────────────────────┘
```

### Environnements

| Environnement | Composition Docker | Port exposé | TLS |
|---|---|---|---|
| Développement local | `docker-compose.yml` | `80` | Non |
| Test / CI | `docker-compose.test.yml` | `8090` | Non |
| Production | `docker-compose.prod.yml` | `80` + `443` | Let's Encrypt |

En production, un second conteneur **nginx-proxy** gère le TLS (Let's Encrypt via **Certbot**) et redirige le trafic vers le conteneur applicatif.

---

## Prérequis

### Avec Docker (recommandé)

| Outil | Version minimum |
|---|---|
| Docker | 24+ |
| Docker Compose | v2 (`compose` intégré au CLI) |
| Git | 2.40+ |

### Sans Docker (développement Flutter natif)

| Outil | Version minimum |
|---|---|
| Flutter SDK | 3.41.1 |
| Dart SDK | 3.3+ *(inclus avec Flutter)* |
| Chrome | Dernière version |
| Git | 2.40+ |

---

## Démarrage rapide — Docker

### 1. Cloner le dépôt

```bash
git clone https://github.com/titouvgx/Projet-CESIZen.git
cd Projet-CESIZen
```

### 2. Configurer les variables d'environnement

```bash
cp .env.example .env
```

Renseigner les valeurs dans `.env` :

```env
SUPABASE_URL=https://xxxxxxxxxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

> Ces valeurs se trouvent dans **Supabase Dashboard → Settings → API**.

### 3. Lancer l'application

```bash
docker compose up -d --build
```

L'application est disponible sur `http://localhost`.

---

## Démarrage rapide — Flutter natif

```bash
# Vérifier l'environnement Flutter
flutter doctor

# Activer le support Web
flutter config --enable-web

# Installer les dépendances
cd cesizen && flutter pub get

# Lancer en développement
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

L'application s'ouvre dans Chrome sur `http://localhost:8080`.

---

## Docker — Détail des configurations

### Build multi-stage (Dockerfile)

Le `Dockerfile` utilise un **build multi-stage** :

1. **Stage `builder`** — image Debian avec Flutter 3.41.1 : compile l'application en fichiers statiques via `flutter build web --dart-define=...`
2. **Stage final** — image `nginx:alpine` ultra-légère : sert les fichiers statiques produits par le stage précédent

Les clés Supabase sont injectées au moment du build via des `ARG` Docker (`--dart-define`) et compilées directement dans le JavaScript. Il n'y a aucune variable d'environnement accessible au runtime.

### docker-compose.yml — Développement local

```bash
docker compose up -d --build     # Démarrer
docker compose logs -f           # Suivre les logs
docker compose down              # Arrêter
```

Expose le port `80` directement, sans TLS.

### docker-compose.test.yml — Test d'intégration

```bash
docker compose -f docker-compose.test.yml up -d --build
# Application disponible sur http://localhost:8090
# Health check automatique (wget sur /localhost:80 toutes les 10s)
docker compose -f docker-compose.test.yml down
```

Utilisé par la CI GitHub Actions pour valider chaque build avant publication.

### docker-compose.prod.yml — Production avec TLS

```
┌──────────────────────────────────────┐
│  nginx-proxy (ports 80 + 443)        │
│  • Redirect HTTP → HTTPS             │
│  • TLS Let's Encrypt (Certbot)       │
│  • Proxy → conteneur cesizen         │
└──────────┬───────────────────────────┘
           │ HTTP interne
┌──────────▼───────────────────────────┐
│  cesizen (port 80 interne)           │
│  Flutter Web statique + Nginx        │
└──────────────────────────────────────┘
           + certbot (renouvellement auto toutes les 12h)
```

Avant de lancer en production, adapter `nginx/nginx.prod.conf` :

```nginx
server_name TON_DOMAINE.fr www.TON_DOMAINE.fr;
```

Puis démarrer :

```bash
docker compose -f docker-compose.prod.yml up -d --build
```

---

## Nginx — Sécurité

La configuration Nginx (`nginx/nginx.conf`) inclut :

| Fonctionnalité | Configuration |
|---|---|
| Rate limiting | 10 req/s par IP, burst 20 |
| Compression | Gzip sur JS, CSS, JSON, SVG, polices |
| SPA routing | `try_files $uri $uri/ /index.html` |
| CSP | `Content-Security-Policy` restrictif (Supabase + Google Fonts) |
| Headers sécurité | `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy` |
| HSTS | `Strict-Transport-Security` (prod uniquement) |
| Fichiers bloqués | `.env`, `.git`, `.sh`, `.bat` → 404 |
| Cache assets | 1 an, `Cache-Control: public, immutable` |

---

## Variables d'environnement

| Variable | Description | Où la trouver |
|---|---|---|
| `SUPABASE_URL` | URL unique du projet Supabase | Dashboard → Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Clé publique anonyme (safe côté client) | Dashboard → Settings → API → anon / public |

> Ne jamais commiter `.env`. Il est listé dans `.gitignore`. Voir `.env.example` pour le modèle.

---

## CI/CD — GitHub Actions

Le pipeline (`.github/workflows/ci-cd.yml`) s'exécute sur chaque **push** et **pull request** vers `master` :

```
[1] Tests Flutter
      flutter analyze --no-fatal-infos
      flutter test test/cahier_tests.dart
           │
           ▼
[2] Build Flutter Web
      flutter build web --dart-define=...
      Upload artifact (conservation 7 jours)
           │
           ▼
[3] Build Docker + Push GHCR
      docker build --push ghcr.io/titouvgx/cesizen:latest
      docker build --push ghcr.io/titouvgx/cesizen:<sha>
      Cache layers via GitHub Actions cache
           │
           ▼
[4] Test intégration
      docker compose -f docker-compose.test.yml up --build
      curl --fail http://localhost:8090
      docker compose down
           │
           ▼
[5] Résumé pipeline (always)
      Tableau récapitulatif dans GitHub Actions Summary
```

Le push de l'image Docker sur GHCR n'est effectué que sur les **push vers `master`** (pas sur les PRs).

### Image Docker (GHCR)

```bash
# Récupérer l'image depuis GitHub Container Registry
docker pull ghcr.io/titouvgx/cesizen:latest

# Lancer directement
docker run -p 80:80 ghcr.io/titouvgx/cesizen:latest
```

> L'image est construite avec les secrets Supabase injectés. Pour changer les clés, un nouveau build est nécessaire.

---

## Structure du projet

```
Projet-CESIZen/
├── Dockerfile                     # Build multi-stage Flutter + Nginx
├── docker-compose.yml             # Dev local (port 80)
├── docker-compose.test.yml        # Test CI (port 8090 + healthcheck)
├── docker-compose.prod.yml        # Production (TLS Let's Encrypt)
├── nginx/
│   ├── nginx.conf                 # Config dev (rate limit, CSP, SPA routing)
│   └── nginx.prod.conf            # Config prod (HTTPS, HSTS, proxy)
├── .github/
│   ├── workflows/
│   │   └── ci-cd.yml              # Pipeline 5 jobs (test → build → docker → integration → summary)
│   ├── ISSUE_TEMPLATE/            # Templates bug / feature / security
│   └── PULL_REQUEST_TEMPLATE.md
├── cesizen/                       # Application Flutter
│   ├── lib/
│   │   ├── main.dart              # Point d'entrée — init Supabase
│   │   ├── auth_service.dart      # Inscription, connexion, session
│   │   ├── home_page.dart
│   │   ├── diagnosticpage.dart    # Diagnostic Holmes et Rahe
│   │   ├── questionnaire_page.dart
│   │   ├── contenu_page.dart      # Articles bien-être
│   │   ├── espace_page.dart       # Espace personnel
│   │   ├── admin.dart             # Tableau de bord admin
│   │   ├── aide_page.dart
│   │   ├── login_popup.dart
│   │   ├── widgets.dart           # Navbar, Footer — composants partagés
│   │   ├── variables.dart         # Constantes globales
│   │   ├── services/
│   │   │   └── supabase_service.dart  # Toutes les requêtes DB
│   │   └── utils/
│   │       ├── cesizen_utils.dart
│   │       └── logger.dart
│   ├── test/
│   │   └── cahier_tests.dart
│   ├── assets/images/
│   └── pubspec.yaml
├── docs/
│   ├── architecture.md
│   ├── diagnostic.md
│   ├── securite.md
│   └── preparation-deploiement.md
├── .env.example                   # Modèle de configuration
├── .gitignore
├── CHANGELOG.md
├── CONTRIBUTING.md
└── README.md
```

---

## Ports

| Port | Service | Contexte |
|---|---|---|
| `80` | Flutter Web via Nginx | Dev local (`docker-compose.yml`) |
| `8080` | Flutter Web | `flutter run -d chrome` sans Docker |
| `8090` | Flutter Web via Nginx | Test CI (`docker-compose.test.yml`) |
| `80` + `443` | Nginx proxy TLS | Production (`docker-compose.prod.yml`) |

---

## Comptes de test

| Rôle | Email | Mot de passe |
|---|---|---|
| Administrateur | admin@cesizen.fr | *(fourni séparément)* |
| Citoyen | test@cesizen.fr | *(fourni séparément)* |

Pour créer un compte admin manuellement :

1. **Supabase → Authentication → Users → Add user**
2. Copier l'UUID généré
3. Exécuter dans l'éditeur SQL Supabase :

```sql
INSERT INTO utilisateur (id_utilisateur, nom, email, role)
VALUES ('UUID_COPIE', 'Nom Admin', 'admin@exemple.fr', 'Admin');
```

---

## Commandes utiles

```bash
# Docker
docker compose up -d --build          # Démarrer en dev
docker compose logs -f cesizen        # Suivre les logs
docker compose down                   # Arrêter
docker compose down --volumes         # Arrêter + supprimer volumes (prod)

# Flutter
flutter test test/cahier_tests.dart --reporter expanded   # Tests
flutter test --coverage                                    # Couverture
flutter analyze --no-fatal-infos                           # Linting
flutter clean && flutter pub get                           # Reset cache
flutter doctor -v                                          # Diagnostic env
```

---

## Contribution

Lire [CONTRIBUTING.md](CONTRIBUTING.md) avant d'ouvrir une Pull Request.

---

## Changelog

L'historique des versions est disponible dans [CHANGELOG.md](CHANGELOG.md).

---

## Ressources

- Depot GitHub : https://github.com/titouvgx/Projet-CESIZen
- Image Docker (GHCR) : https://github.com/titouvgx/Projet-CESIZen/pkgs/container/cesizen
- Documentation Flutter : https://docs.flutter.dev
- Documentation Supabase : https://supabase.com/docs
- Documentation Nginx : https://nginx.org/en/docs/
