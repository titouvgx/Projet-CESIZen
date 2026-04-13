# 🌿 CESIZen — Guide d'installation locale

> Plateforme de santé mentale — Flutter Web + Supabase

---

## 📋 Prérequis

Avant de commencer, assure-toi d'avoir installé :

| Outil | Version minimum | Lien |
|---|---|---|
| Flutter SDK | 3.19+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.3+ *(inclus avec Flutter)* | — |
| Git | 2.40+ | [git-scm.com](https://git-scm.com) |
| Chrome | Dernière version | [google.com/chrome](https://google.com/chrome) |
| VS Code *(recommandé)* | 1.85+ | [code.visualstudio.com](https://code.visualstudio.com) |

---

## 🚀 Installation

### 1. Vérifier Flutter

```bash
flutter doctor
```

Tous les éléments doivent être cochés ✓. Si Flutter n'est pas installé, suis le guide officiel sur [flutter.dev](https://flutter.dev/docs/get-started/install).

---

### 2. Activer le support Web

```bash
flutter config --enable-web
flutter devices   # Chrome doit apparaître dans la liste
```

---

### 3. Cloner le projet

```bash
git clone https://github.com/titouvgx/Projet-CESIZen.git
cd Projet-CESIZen
```

---

### 4. Installer les dépendances

```bash
flutter pub get
```

---

### 5. Créer le fichier `.env`

Crée un fichier `.env` à la **racine du projet** (au même niveau que `pubspec.yaml`) :

```env
SUPABASE_URL=https://kfelnflvpsymrkdredpo.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtmZWxuZmx2cHN5bXJrZHJlZHBvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM4MzY3NTksImV4cCI6MjA4OTQxMjc1OX0.-GANEZDBRpQ_MI0IYSlcYRE0Z2eDBU91q59ECitIY6U
```

> ⚠️ Ce fichier est exclu du dépôt Git (`.gitignore`). Ne le partage jamais publiquement.

---

### 6. Lancer l'application

```bash
flutter run -d chrome
```

L'application s'ouvre automatiquement dans Chrome sur `http://localhost:<PORT>`.

---

## 🗂️ Structure du projet

```
Projet-CESIZen/
├── lib/
│   ├── main.dart                  # Point d'entrée — init Supabase
│   ├── home_page.dart             # Page d'accueil
│   ├── diagnosticpage.dart        # Diagnostic Holmes et Rahe
│   ├── questionnaire_page.dart    # Questionnaire interactif
│   ├── contenu_page.dart          # Articles et contenus
│   ├── espace_page.dart           # Espace personnel utilisateur
│   ├── admin_page.dart            # Tableau de bord admin
│   ├── aide_page.dart             # Page de contact
│   ├── login_popup.dart           # Popup connexion / inscription
│   ├── auth_service.dart          # Gestion de l'authentification
│   ├── variables.dart             # Constantes et couleurs
│   ├── widgets.dart               # Navbar et Footer partagés
│   └── services/
│       └── supabase_service.dart  # Toutes les requêtes Supabase
├── assets/
│   └── images/                    # Logos et images
├── test/                          # Tests unitaires et fonctionnels
├── .env                           # ⚠️ Non versionné — à créer manuellement
├── .gitignore
└── pubspec.yaml
```

---

## 👤 Comptes de test

| Rôle | Email | Mot de passe |
|---|---|---|
| Administrateur | admin@cesizen.fr | *(fourni séparément)* |
| Citoyen connecté | test@cesizen.fr | *(fourni séparément)* |

Pour créer un nouveau compte admin manuellement :

1. Va dans **Supabase → Authentication → Users → Add user**
2. Copie l'UUID généré
3. Exécute ce SQL dans l'éditeur Supabase :

```sql
INSERT INTO utilisateur (id_utilisateur, nom, email, role)
VALUES ('UUID_COPIE', 'Nom Admin', 'admin@exemple.fr', 'Admin');
```

---

## 🧪 Lancer les tests

```bash
# Tous les tests
flutter test

# Avec détail
flutter test --reporter expanded

# Avec couverture
flutter test --coverage
```

---

## 🌐 Déploiement GitHub Pages

```bash
# 1. Build
flutter build web --base-href "/Projet-CESIZen/"

# 2. Aller dans le dossier de build
cd build/web

# 3. Pousser sur la branche gh-pages
git init
git add .
git commit -m "Deploy"
git branch -M gh-pages
git remote add origin https://github.com/titouvgx/Projet-CESIZen.git
git push -f origin gh-pages
```

> ⚠️ Pour le déploiement web, les clés Supabase doivent être hardcodées temporairement dans `main.dart` car GitHub Pages ne peut pas lire le fichier `.env` au runtime. Ne commite jamais ce `main.dart` modifié sur la branche `main`.

Site en ligne : **https://titouvgx.github.io/Projet-CESIZen/**

---

## 🛠️ Commandes utiles

```bash
# Nettoyer le cache
flutter clean && flutter pub get

# Vérifier l'environnement complet
flutter doctor -v

# Analyser le code
flutter analyze

# Mettre à jour Flutter
flutter upgrade
```

---

## ❓ Problèmes courants

| Problème | Solution |
|---|---|
| Écran blanc au lancement | Vérifier le fichier `.env` et relancer `flutter pub get` |
| `flutter` non reconnu | Ajouter le dossier `bin/` de Flutter au PATH système |
| Erreur connexion Supabase | Vérifier URL et ANON KEY dans Supabase → Settings → API |
| GitHub Pages affiche 404 | Rebuilder avec `--base-href "/Projet-CESIZen/"` (respecter la casse) |
| Chrome non détecté | Lancer `flutter config --enable-web` puis redémarrer le terminal |

---

## 🔗 Ressources

- 📁 Dépôt GitHub : https://github.com/titouvgx/Projet-CESIZen
- 🌍 Application en ligne : https://titouvgx.github.io/Projet-CESIZen/
- 📖 Documentation Flutter : https://docs.flutter.dev
- 📖 Documentation Supabase : https://supabase.com/docs
- 🗄️ Console Supabase : https://supabase.com/dashboard
