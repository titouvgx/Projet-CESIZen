# Sécurité — CESIZen

---

## Points de vigilance du projet

| Domaine | Risque | Niveau |
|---|---|---|
| Clés Supabase dans le JS compilé | La `anon key` est visible dans le bundle JS publié | Faible — comportement normal et prévu par Supabase |
| Row Level Security (RLS) | Sans RLS, tout porteur de la `anon key` accède à toutes les données | Critique |
| JWT sessions | Token valide = accès total pour l'utilisateur concerné | À surveiller |
| CORS Supabase | Le dashboard Supabase contrôle les origines autorisées | À vérifier avant prod |
| Logs en production | Des logs verbeux peuvent exposer des données techniques | Mitigé par AppLogger |

---

## Ce qui est sécurisé et comment

### Clés de configuration

Les clés `SUPABASE_URL` et `SUPABASE_ANON_KEY` sont injectées via `--dart-define` au moment du build et compilées dans le JavaScript. Elles ne transitent jamais par un fichier de configuration versionné.

La `anon key` est **publique par design** dans l'architecture Supabase : elle n'est pas un secret. Elle identifie le projet mais ne donne accès qu'aux données autorisées par les Row Level Security policies.

La `service_role key` (clé admin) n'est jamais utilisée côté frontend.

---

### Authentification

- Gérée entièrement par Supabase Auth (GoTrue) — aucune logique de hachage de mot de passe dans l'application.
- Les sessions sont stockées en mémoire browser via `supabase_flutter` — elles ne persistent pas en `localStorage` par défaut.
- Les comptes supprimés (`date_suppression != null`) sont détectés à la connexion et déconnectés immédiatement.

---

### Messages d'erreur

`AuthService._traduireErreur()` filtre systématiquement les messages Supabase bruts. L'utilisateur ne voit jamais :
- Le code d'erreur technique Supabase
- Le message d'erreur interne
- Une stacktrace

Tous les messages affichés sont des chaînes génériques définies statiquement dans le code.

---

### Logging

`AppLogger` distingue deux comportements selon l'environnement de build :

| Niveau | Dev (`dart.vm.product = false`) | Prod (`dart.vm.product = true`) |
|---|---|---|
| `debug` | Affiché | Supprimé |
| `info` | Affiché | Supprimé |
| `warning` | Affiché | Affiché |
| `error` | Affiché avec exception | Affiché sans détail d'exception |

Les messages Supabase bruts (contenant les codes d'erreur internes) sont loggés au niveau `debug` — donc invisibles en production.

---

## Ce qui n'est pas encore sécurisé

### 1. Row Level Security — à vérifier

Les RLS policies doivent être activées et configurées sur chaque table dans le dashboard Supabase. Sans RLS, la `anon key` donne un accès complet à toutes les tables en lecture et écriture.

**Tables à sécuriser en priorité :**

| Table | Politique attendue |
|---|---|
| `utilisateur` | Un utilisateur ne peut lire/modifier que son propre profil |
| `diagnostic` | Lecture/écriture restreinte au propriétaire |
| `favori` | Lecture/écriture restreinte au propriétaire |
| `reponse` | Écriture restreinte au propriétaire du diagnostic |
| `contact_message` | Insert public, lecture restreinte aux admins |
| `contenu` | Lecture publique (publié), écriture restreinte aux admins |

---

### 2. CORS Supabase

Vérifier dans **Supabase Dashboard → Settings → API → CORS** que seules les origines légitimes sont autorisées :
- `http://localhost:8080` (développement local)
- `https://titouvgx.github.io` (production)

---

### 3. Pas de rate limiting applicatif

Supabase Auth applique un rate limiting natif sur les endpoints d'authentification. Il n'y a pas de protection supplémentaire côté application (CAPTCHA, délai artificiel).

---

### 4. Pas de validation d'entrée stricte côté client

Les formulaires (inscription, contact, modification de nom) valident uniquement le format de base. Une validation plus stricte (longueur max, caractères interdits, sanitisation) pourrait être ajoutée.

---

## Règles de logging

### Ce qu'il faut logger

| Quoi | Niveau | Contexte |
|---|---|---|
| Échec d'authentification (type seulement) | `warning` | AuthService |
| Erreur inattendue dans un service | `error` | AuthService / SupabaseService |
| Erreur de chargement de données | `error` | SupabaseService |
| Démarrage réussi, actions métier | `info` | — |

### Ce qu'il ne faut jamais logger

- Mots de passe (même hashés)
- Tokens JWT (même partiels)
- Clés API (`SUPABASE_URL`, `SUPABASE_ANON_KEY`)
- Adresses email complètes dans les logs de production
- Données personnelles (nom, contenu de messages)
- Messages d'erreur Supabase bruts en production

---

## Tableau : données sensibles et traitements

| Donnée | Stockage | Transit | Logging |
|---|---|---|---|
| Mot de passe | Jamais stocké (Supabase Auth gère le hash) | HTTPS uniquement | Jamais |
| Token JWT | Mémoire browser (supabase_flutter) | HTTPS — header Authorization | Jamais |
| `SUPABASE_ANON_KEY` | JS compilé (bundle statique) | Build only | Jamais |
| `SUPABASE_URL` | JS compilé (bundle statique) | Build only | Jamais |
| Email utilisateur | Base PostgreSQL Supabase | HTTPS | Jamais en prod |
| Profil utilisateur | Base PostgreSQL Supabase | HTTPS + JWT | Jamais en prod |
| Résultats diagnostics | Base PostgreSQL Supabase | HTTPS + JWT + RLS | Jamais |
| Messages de contact | Base PostgreSQL Supabase | HTTPS | Jamais |
