# Diagnostic — CESIZen

Guide pour vérifier que l'application fonctionne correctement et identifier les problèmes courants.

---

## Vérifier que l'app se lance correctement

### Checklist de démarrage

```
[ ] Les variables d'environnement sont définies dans le shell
[ ] flutter doctor ne rapporte aucune erreur critique
[ ] flutter pub get s'est terminé sans erreur
[ ] L'app s'ouvre dans Chrome sans écran blanc
[ ] La console du navigateur ne montre pas d'erreur rouge
[ ] La page d'accueil s'affiche correctement
[ ] Le login fonctionne avec un compte de test
```

### Lancement nominal

```bash
# Depuis la racine du dépôt
source .env                      # Linux/Mac
# ou : set SUPABASE_URL=... (Windows)

cd cesizen
flutter pub get
flutter run -d chrome \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

Résultat attendu dans le terminal :
```
Launching lib/main.dart on Chrome in debug mode...
...
🟢 INFO  Application démarrée
```

---

## Erreurs fréquentes et leur signification

### `Exception: SUPABASE_URL et SUPABASE_ANON_KEY doivent être définis via --dart-define`

**Cause :** les variables d'environnement ne sont pas passées au moment du `flutter run` ou `flutter build`.

**Solution :**
```bash
# Vérifier que les variables sont bien définies dans le shell
echo $SUPABASE_URL         # Linux/Mac
echo %SUPABASE_URL%        # Windows cmd
echo $env:SUPABASE_URL     # PowerShell

# Si vides : charger le .env
source .env                # Linux/Mac
```

---

### Écran blanc au lancement

**Causes possibles :**

1. Variables `--dart-define` absentes → voir erreur ci-dessus
2. URL Supabase incorrecte → vérifier la valeur de `SUPABASE_URL`
3. Clé `anon` incorrecte ou expirée → vérifier dans le dashboard Supabase

**Diagnostic :**
```bash
# Ouvrir les DevTools Chrome (F12) → onglet Console
# Chercher les erreurs en rouge
```

---

### `SocketException` ou `ClientException`

**Cause :** pas de connexion réseau, ou URL Supabase inaccessible.

**Diagnostic :**
```bash
# Vérifier la connectivité
curl https://votre-projet.supabase.co/rest/v1/    # Linux/Mac
# Doit retourner une réponse JSON (même une erreur 401 est un bon signe)
```

**Solution :** vérifier la connexion internet, puis que l'URL Supabase est correcte.

---

### `PostgrestException: relation "xxx" does not exist`

**Cause :** la table n'existe pas dans la base Supabase, ou le nom est incorrect (casse, faute de frappe).

**Diagnostic :** aller dans **Supabase Dashboard → Table Editor** et vérifier que la table existe.

---

### `PostgrestException: new row violates row-level security policy`

**Cause :** la Row Level Security (RLS) bloque l'opération. L'utilisateur n'a pas les droits sur cette opération.

**Solution :** vérifier les RLS policies dans **Supabase Dashboard → Authentication → Policies** pour la table concernée.

---

### `AuthException: Invalid login credentials`

**Cause :** email ou mot de passe incorrect. L'app traduit ce message en "Email ou mot de passe incorrect."

**Côté utilisateur :** message générique affiché, aucun détail technique.
**Côté dev :** le message Supabase brut est loggé en `debug` (visible seulement en développement).

---

### `AuthException: Email not confirmed`

**Cause :** l'utilisateur s'est inscrit mais n'a pas confirmé son email.

**Solution :** vérifier la boîte mail, ou désactiver la confirmation d'email dans **Supabase Dashboard → Authentication → Settings → Email confirmations**.

---

### `flutter analyze` rapporte des erreurs

```bash
cd cesizen
flutter analyze
```

Toutes les erreurs doivent être résolues avant de commiter ou déployer.

---

## Distinguer une erreur réseau d'une erreur Supabase

| Symptôme | Type d'erreur | Où chercher |
|---|---|---|
| `SocketException`, `ClientException`, timeout | Réseau | Connexion internet, pare-feu, URL Supabase |
| `PostgrestException` | Base de données Supabase | Table, RLS, format des données |
| `AuthException` | Authentification Supabase | Identifiants, confirmation email, rate limit |
| `Exception: SUPABASE_URL...` | Configuration locale | Variables `--dart-define` manquantes |
| Écran blanc sans exception | Initialisation Flutter | Console navigateur, DevTools |

### Lire les logs AppLogger

En mode développement, les logs s'affichent dans le terminal Flutter avec les préfixes :

```
🔵 DEBUG [SupabaseService]  — détails techniques, messages Supabase bruts
🟢 INFO  [SupabaseService]  — opérations réussies
🟡 WARN  [AuthService]      — échecs d'authentification (sans détail)
🔴 ERROR [SupabaseService]  — erreurs inattendues
```

En production (`flutter build web`), seuls `WARN` et `ERROR` apparaissent, sans le détail de l'exception.

---

## Vérifier les variables d'environnement

### Avant `flutter run`

```bash
# Linux/Mac
echo "URL  : $SUPABASE_URL"
echo "KEY  : ${SUPABASE_ANON_KEY:0:20}..."   # Affiche seulement les 20 premiers caractères

# Windows cmd
echo URL  : %SUPABASE_URL%
echo KEY  : (vérifier qu'elle commence par eyJ)

# PowerShell
Write-Host "URL : $env:SUPABASE_URL"
Write-Host "KEY : $($env:SUPABASE_ANON_KEY.Substring(0, [Math]::Min(20, $env:SUPABASE_ANON_KEY.Length)))..."
```

### Valeurs attendues

| Variable | Format attendu |
|---|---|
| `SUPABASE_URL` | `https://xxxxxxxxxxxxxxxxxxxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Commence par `eyJhbGci...` (JWT encodé en base64) |

### Tester la connexion Supabase directement

```bash
# Tester que l'URL répond (doit retourner JSON ou 401)
curl -s -o /dev/null -w "%{http_code}" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  "$SUPABASE_URL/rest/v1/"
# Code attendu : 200 ou 401 (pas 0 ni 5xx)
```

---

## Commandes utiles pour diagnostiquer

```bash
# Depuis cesizen/

# Vérifier l'environnement Flutter complet
flutter doctor -v

# Lister les devices disponibles (Chrome doit apparaître)
flutter devices

# Analyser le code source
flutter analyze

# Lancer les tests
flutter test --reporter expanded

# Nettoyer le cache Flutter (résout souvent les erreurs de build bizarres)
flutter clean && flutter pub get

# Voir les logs en temps réel pendant le run
# (ils apparaissent directement dans le terminal)
flutter run -d chrome \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --verbose   # ajouter pour des logs Flutter très détaillés

# Vérifier la version de Flutter
flutter --version
```

---

## Accès au dashboard Supabase pour diagnostiquer

| Ce qu'on cherche | Où dans le dashboard |
|---|---|
| Logs des requêtes API | Logs → API |
| Logs d'authentification | Logs → Auth |
| État des tables | Table Editor |
| RLS policies actives | Authentication → Policies |
| Clés API (URL, anon key) | Settings → API |
| Utilisateurs enregistrés | Authentication → Users |
| Éditeur SQL | SQL Editor |
