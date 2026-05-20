# Préparation au déploiement — CESIZen

Ce document décrit ce qu'il faut vérifier et corriger avant chaque déploiement de CESIZen sur GitHub Pages.

---

## Prérequis techniques

| Outil | Version requise | Vérification |
|---|---|---|
| Flutter SDK | 3.19+ | `flutter --version` |
| Dart SDK | 3.3+ | `dart --version` |
| Support Web activé | — | `flutter config --enable-web` |
| Chrome installé | Dernière version | `flutter devices` (Chrome visible) |
| Git configuré | 2.40+ | `git --version` |
| Accès au dépôt GitHub | — | `git remote -v` |

---

## Variables d'environnement nécessaires

| Variable | Obligatoire | Où la trouver |
|---|---|---|
| `SUPABASE_URL` | Oui | Supabase Dashboard → Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Oui | Supabase Dashboard → Settings → API → anon / public |

### Méthode d'injection : `--dart-define`

Flutter Web compile en JavaScript statique. Le navigateur n'a pas accès aux variables d'environnement système au moment de l'exécution. La seule façon propre d'injecter des valeurs de configuration est de les passer au **moment du build** via `--dart-define`, qui les compile directement dans le JavaScript via `String.fromEnvironment()`.

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

Les constantes sont alors disponibles dans le code Dart :

```dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
```

### Pourquoi `flutter_dotenv` ne suffit pas ici

`flutter_dotenv` charge un fichier `.env` comme un **asset** Flutter (fichier statique bundlé dans le build). Cela fonctionne pour les applications mobiles natives où l'accès aux fichiers est possible à l'exécution. En Flutter Web, l'asset `.env` serait servi publiquement en clair via le serveur web — ce qui n'apporte aucune sécurité supplémentaire par rapport à du code hardcodé. La méthode `--dart-define` est la solution recommandée pour Flutter Web.

### Charger le `.env` avant de lancer les scripts

Créer un fichier `.env` à la racine à partir du modèle :

```bash
cp .env.example .env
# Editer .env avec les vraies valeurs
```

Puis l'injecter dans l'environnement shell avant d'appeler les scripts :

```bash
# Linux / Mac
source .env && ./scripts/run_local.sh

# Windows cmd
set SUPABASE_URL=https://xxx.supabase.co
set SUPABASE_ANON_KEY=eyJ...
scripts\run_local.bat

# Windows PowerShell
$env:SUPABASE_URL="https://xxx.supabase.co"
$env:SUPABASE_ANON_KEY="eyJ..."
scripts\run_local.bat
```

---

## Points d'attention avant de déployer

### 1. Variables d'environnement définies dans le shell de build

Les variables `SUPABASE_URL` et `SUPABASE_ANON_KEY` doivent être présentes dans l'environnement au moment où `flutter build web` est exécuté. Si elles sont vides, l'application lève une exception au démarrage.

**Vérification :**
```bash
echo $SUPABASE_URL       # Linux/Mac
echo %SUPABASE_URL%      # Windows cmd
echo $env:SUPABASE_URL   # PowerShell
```

---

### 2. Fichier `.env` non versionné

Le fichier `.env` est dans `.gitignore`. C'est le comportement attendu.
Tout collaborateur qui clone le dépôt doit le créer manuellement à partir de `.env.example`.

---

### 3. `base-href` selon la cible de déploiement

| Cible | `--base-href` |
|---|---|
| GitHub Pages (`/Projet-CESIZen/`) | `--base-href "/Projet-CESIZen/"` |
| Docker / serveur à la racine | `--base-href "/"` |

Le script `scripts/build_web.sh` utilise `--base-href "/"`, adapté au déploiement Docker.
Pour GitHub Pages, ajuster la valeur manuellement.

---

### 4. RLS Supabase

Vérifier que les Row Level Security policies sont actives sur toutes les tables avant de déployer. Un accès non restreint expose les données à tout porteur de la clé `anon`.

---

## Commandes de vérification avant de déployer

Exécuter depuis `cesizen/` :

```bash
# 1. Vérifier l'environnement Flutter
flutter doctor

# 2. Réinstaller les dépendances proprement
flutter clean && flutter pub get

# 3. Analyser le code (aucune erreur ne doit rester)
flutter analyze

# 4. Lancer les tests
flutter test

# 5. Vérifier que l'app démarre correctement en local
source ../.env && ../scripts/run_local.sh
# → ouvrir http://localhost:8080 et tester login + pages principales
```

---

## Ce qui bloque actuellement un déploiement propre

| Point | Sévérité | Statut |
|---|---|---|
| Clés Supabase hardcodées dans `main.dart` | Moyen | **Résolu** — migration vers `String.fromEnvironment` effectuée |
| Pas de CI/CD automatisé | Faible | Le déploiement reste manuel via les scripts |
| Comptes de test avec mots de passe non documentés | Faible | Documenter dans un canal sécurisé hors Git |

---

## Processus de déploiement complet

```bash
# Depuis la racine du dépôt

# 1. Se placer sur master à jour
git checkout master
git pull origin master

# 2. Charger les variables d'environnement
source .env          # Linux/Mac
# ou : set SUPABASE_URL=... && set SUPABASE_ANON_KEY=...  (Windows)

# 3. Vérifications depuis cesizen/
cd cesizen
flutter clean && flutter pub get
flutter analyze
flutter test
cd ..

# 4. Build via le script (base-href à ajuster selon la cible)
./scripts/build_web.sh
# Pour GitHub Pages, relancer avec :
# cd cesizen && flutter build web --base-href "/Projet-CESIZen/" \
#   --dart-define=SUPABASE_URL=${SUPABASE_URL} \
#   --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}

# 5. Déployer sur gh-pages
cd cesizen/build/web
git init
git add .
git commit -m "chore: deploy $(date +%Y-%m-%d)"
git branch -M gh-pages
git remote add origin https://github.com/titouvgx/Projet-CESIZen.git
git push -f origin gh-pages
```

> Vérifier le déploiement sur https://titouvgx.github.io/Projet-CESIZen/ après quelques minutes.

---

## Déploiement Docker

### Architecture conteneurisée

```
   Shell / CI
      │
      │  source .env   (SUPABASE_URL, SUPABASE_ANON_KEY dans l'env)
      ▼
docker compose build
      │
      │  ARG → --dart-define → String.fromEnvironment() → JS compilé
      ▼
┌─────────────────────────────────────┐
│         Image cesizen:latest        │
│                                     │
│  ┌──────────────────────────────┐   │
│  │  Stage 1 (builder)           │   │
│  │  Flutter 3.29.3              │   │
│  │  flutter build web           │   │
│  │  → /app/cesizen/build/web/   │   │
│  └──────────────┬───────────────┘   │
│                 │ COPY              │
│  ┌──────────────▼───────────────┐   │
│  │  Stage 2 (nginx:alpine)      │   │
│  │  Sert /usr/share/nginx/html  │   │
│  │  Port 80                     │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
      │
      │  En prod : nginx-proxy (port 443, HTTPS, Certbot)
      │  En dev  : accès direct port 80
      ▼
   Navigateur
```

---

### Prérequis Docker

| Outil | Version requise | Vérification |
|---|---|---|
| Docker Engine | 24+ | `docker --version` |
| Docker Compose | 2.20+ (plugin) | `docker compose version` |
| Variables d'env | SUPABASE_URL, SUPABASE_ANON_KEY | `echo $SUPABASE_URL` |

---

### Builder et lancer en local (dev)

```bash
# Depuis la racine du dépôt
source .env           # charge SUPABASE_URL et SUPABASE_ANON_KEY

# Via le script dédié
./scripts/build_docker.sh

# Ou manuellement
docker compose build --no-cache
docker compose up -d

# Vérifier que le conteneur tourne
docker compose ps
docker compose logs cesizen

# Ouvrir l'app
# http://localhost:80
```

Arrêter le conteneur :
```bash
docker compose down
```

---

### Déployer sur VPS (production avec HTTPS)

#### 1. Préparer le VPS

```bash
# Sur le VPS
git clone https://github.com/titouvgx/Projet-CESIZen.git
cd Projet-CESIZen

# Définir les variables d'environnement de façon permanente
echo "SUPABASE_URL=https://xxx.supabase.co"      >> /etc/environment
echo "SUPABASE_ANON_KEY=eyJ..."                  >> /etc/environment
source /etc/environment
```

#### 2. Obtenir le certificat Let's Encrypt (premier démarrage)

Remplacer `TON_DOMAINE.fr` dans `nginx/nginx.prod.conf` par votre domaine, puis :

```bash
# Démarrer d'abord sans SSL pour que certbot puisse répondre au challenge HTTP
docker compose -f docker-compose.prod.yml up -d nginx-proxy cesizen

# Obtenir le certificat
docker compose -f docker-compose.prod.yml run --rm certbot certonly \
  --webroot -w /var/www/certbot \
  -d TON_DOMAINE.fr -d www.TON_DOMAINE.fr \
  --email contact@TON_DOMAINE.fr \
  --agree-tos --non-interactive

# Relancer avec SSL actif
docker compose -f docker-compose.prod.yml restart nginx-proxy
```

#### 3. Déployer / redéployer

```bash
# Via le script (depuis le VPS, dans le dossier du projet)
./scripts/deploy_prod.sh

# Ou manuellement
git pull origin master
docker compose -f docker-compose.prod.yml up -d --build
```

Le renouvellement SSL est automatique : le service `certbot` vérifie et renouvelle toutes les 12h.

---

### Vérifier le bon fonctionnement

```bash
# Etat des conteneurs
docker compose -f docker-compose.prod.yml ps

# Logs en temps réel
docker compose -f docker-compose.prod.yml logs -f cesizen
docker compose -f docker-compose.prod.yml logs -f nginx-proxy

# Tester le redirect HTTP → HTTPS
curl -I http://TON_DOMAINE.fr

# Tester HTTPS
curl -I https://TON_DOMAINE.fr
```

---

### Points d'attention Docker

| Point | Détail |
|---|---|
| Les clés sont compilées dans l'image | Rebuilder l'image si les clés Supabase changent |
| L'image `cesizen:latest` contient les clés | Ne jamais pousser cette image sur un registry public |
| `.dockerignore` exclut `.env` | Le fichier local `.env` n'est jamais copié dans le build context |
| `nginx.prod.conf` est un template | Remplacer `TON_DOMAINE.fr` par le vrai domaine avant usage |

---

## Environnements de déploiement

### Environnement DEV (développement local)

| Propriété | Valeur |
|---|---|
| Outil | Flutter SDK + Chrome |
| Commande | `scripts/run_local.bat` (Windows) / `source .env && ./scripts/run_local.sh` (Linux/Mac) |
| URL | http://localhost:8080 |
| Usage | Développement quotidien — hot reload activé |

### Environnement TEST (intégration)

| Propriété | Valeur |
|---|---|
| Outil | Docker Compose + Nginx |
| Commande | `docker compose -f docker-compose.test.yml up -d --build` |
| Script | `scripts/test_env.bat` (Windows) / `./scripts/test_env.sh` (Linux/Mac) |
| URL | http://localhost:8090 |
| Usage | Validation avant mise en production, CI GitHub Actions (Job 4) |

### Environnement PROD (production)

| Propriété | Valeur |
|---|---|
| Outil | Docker Compose + Nginx + Certbot |
| Commande | `docker compose -f docker-compose.prod.yml up -d --build` |
| Script | `./scripts/deploy_prod.sh` |
| URL | https://tondomaine.fr |
| Usage | Environnement public accessible aux utilisateurs |

### Comparaison des 3 environnements

| | DEV | TEST | PROD |
|---|---|---|---|
| Port | 8080 | 8090 | 443 (HTTPS) |
| Nginx | Non (Flutter dev server) | Oui | Oui + reverse proxy |
| HTTPS | Non | Non | Oui (Let's Encrypt) |
| Docker | Non | Oui | Oui |
| Hot reload | Oui | Non | Non |
| CI GitHub Actions | Non | Oui (Job 4) | Manuel (`deploy_prod.sh`) |
