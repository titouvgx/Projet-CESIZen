# Architecture — CESIZen

---

## Schéma des composants

```
┌──────────────────────────────────────────────────────────────────┐
│                         Utilisateur final                        │
│                    (navigateur Chrome / autre)                   │
└────────────────────────────┬─────────────────────────────────────┘
                             │ HTTP/HTTPS
                ┌────────────▼─────────────┐
                │      Flutter Web App     │
                │                          │
                │  Dart compilé en JS/HTML │
                │  ┌────────────────────┐  │
                │  │     Routing        │  │
                │  │  (pages & widgets) │  │
                │  ├────────────────────┤  │
                │  │   AuthService      │  │
                │  │ (session Supabase) │  │
                │  ├────────────────────┤  │
                │  │  SupabaseService   │  │
                │  │ (toutes requêtes)  │  │
                │  └────────────────────┘  │
                │                          │
                │  Dev  : localhost:8080   │
                │  Prod : GitHub Pages     │
                └────────────┬─────────────┘
                             │ HTTPS — PostgREST / GoTrue
                             │ (JWT dans chaque requête)
                ┌────────────▼─────────────┐
                │         Supabase         │  Cloud — supabase.com
                │                          │
                │  ┌────────────────────┐  │
                │  │  Auth (GoTrue)     │  │
                │  │  • Inscription     │  │
                │  │  • Connexion JWT   │  │
                │  │  • Sessions        │  │
                │  └────────┬───────────┘  │
                │           │              │
                │  ┌────────▼───────────┐  │
                │  │  PostgreSQL        │  │
                │  │  • utilisateur     │  │
                │  │  • contenu         │  │
                │  │  • diagnostic      │  │
                │  │  (RLS activé)      │  │
                │  └────────┬───────────┘  │
                │           │              │
                │  ┌────────▼───────────┐  │
                │  │  API REST auto     │  │
                │  │  (PostgREST)       │  │
                │  │  /rest/v1/...      │  │
                │  └────────────────────┘  │
                └──────────────────────────┘
```

---

## Description des composants

### Flutter Web App

| Propriété | Valeur |
|---|---|
| Framework | Flutter 3.19+ / Dart 3.3+ |
| Mode | Web (compilé HTML + CSS + JS statique) |
| Pas de serveur backend | Le build est un dossier de fichiers statiques |
| Config injectée via | `--dart-define` au moment du build → `String.fromEnvironment()` |
| Authentification | Délégée à Supabase Auth (JWT stocké en mémoire) |

**Fichiers clés :**

| Fichier | Rôle |
|---|---|
| `lib/main.dart` | Initialisation Supabase + point d'entrée de l'app |
| `lib/auth_service.dart` | Inscription, connexion, restauration de session |
| `lib/services/supabase_service.dart` | Toutes les requêtes vers la base de données |
| `lib/variables.dart` | Constantes globales (couleurs, textes) |
| `lib/widgets.dart` | Composants partagés (Navbar, Footer) |
| `scripts/run_local.sh` | Lance l'app en dev avec injection des variables (Linux/Mac) |
| `scripts/run_local.bat` | Lance l'app en dev avec injection des variables (Windows) |
| `scripts/build_web.sh` | Build de production avec injection des variables |

---

### Variables de build vs variables d'exécution

Flutter Web est un **build statique** : une fois compilé, le JavaScript résultant est servi tel quel par un serveur web (GitHub Pages, Nginx, etc.). Il n'y a aucun processus serveur qui pourrait lire des variables d'environnement au moment de l'exécution.

```
Développement / CI
        │
        │  source .env   (charge SUPABASE_URL, SUPABASE_ANON_KEY dans le shell)
        ▼
flutter build web --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=yyy
        │
        │  String.fromEnvironment('SUPABASE_URL')  ──► valeur compilée dans le JS
        ▼
   cesizen/build/web/   (fichiers statiques prêts à déployer)
        │
        ▼
   Serveur web / navigateur
   (aucune variable d'environnement accessible ici)
```

**Conséquence :** les valeurs sont figées dans le JavaScript au moment du build. Changer les clés Supabase implique de rebuilder et redéployer l'application.

---

### Supabase Auth (GoTrue)

| Propriété | Valeur |
|---|---|
| Protocole | HTTPS uniquement |
| Tokens | JWT (expiration configurable dans le dashboard) |
| Stockage session | Mémoire browser (géré par `supabase_flutter`) |
| Rôles applicatifs | `Admin` / `Citoyen` — stockés dans la table `utilisateur` |

Les rôles ne sont pas des rôles PostgreSQL natifs : la table `utilisateur` contient une colonne `role` de type texte, lue par l'application après connexion.

---

### PostgreSQL (via PostgREST)

| Propriété | Valeur |
|---|---|
| Hébergement | Supabase Cloud (mutualisé) |
| Accès | API REST auto-générée — pas de connexion directe |
| Sécurité | Row Level Security (RLS) activé sur les tables sensibles |
| URL d'accès | `https://<ref>.supabase.co/rest/v1/<table>` |

**Tables principales :**

| Table | Contenu |
|---|---|
| `utilisateur` | Profils utilisateurs + colonne `role` |
| `contenu` | Articles et ressources bien-être |
| `diagnostic` | Résultats des questionnaires Holmes et Rahe |

---

### GitHub Pages (production)

| Propriété | Valeur |
|---|---|
| Type | Hébergement statique (aucun serveur Node/PHP) |
| URL | https://titouvgx.github.io/Projet-CESIZen/ |
| Branche source | `gh-pages` |
| Base href | `/Projet-CESIZen/` (obligatoire dans le build GitHub Pages) |
| Variables d'env | Compilées dans le JS via `--dart-define` au moment du build |

---

## Ports et URLs

| Contexte | URL | Port |
|---|---|---|
| Dev local | `http://localhost:8080` | 8080 |
| Production | `https://titouvgx.github.io/Projet-CESIZen/` | 443 |
| Supabase API REST | `https://<ref>.supabase.co/rest/v1/` | 443 |
| Supabase Auth | `https://<ref>.supabase.co/auth/v1/` | 443 |

---

## Ce qui est dans le code vs dans la configuration

| Élément | Emplacement | Versionné | Moment de résolution |
|---|---|---|---|
| `SUPABASE_URL` | Variable shell → `--dart-define` → JS compilé | Non (`.env`) | Build |
| `SUPABASE_ANON_KEY` | Variable shell → `--dart-define` → JS compilé | Non (`.env`) | Build |
| Modèle de config | `.env.example` (racine dépôt) | Oui | — |
| Scripts de build/run | `scripts/` (racine dépôt) | Oui | — |
| Rôles utilisateurs | Table `utilisateur` en base | N/A | Runtime |
| Couleurs / constantes | `lib/variables.dart` | Oui | Build |
| Assets (images) | `assets/images/` | Oui | Build |
