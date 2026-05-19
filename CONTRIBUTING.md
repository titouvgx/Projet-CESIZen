# Guide de contribution — CESIZen

Merci de contribuer au projet CESIZen. Ce document décrit les conventions et le workflow à respecter pour maintenir un historique Git propre et cohérent.

---

## Workflow Git

Le projet suit un modèle à trois niveaux de branches :

| Branche | Rôle |
|---|---|
| `master` | Production — code stable et déployé |
| `develop` | Intégration — accumulation des features avant mise en prod |
| `feat/*`, `fix/*`, etc. | Développement — une branche par tâche |

**Flux standard :**

```
feat/ma-feature  →  develop  →  master
```

1. Crée ta branche depuis `develop` (jamais depuis `master` directement).
2. Travaille sur ta branche jusqu'à ce que la feature soit prête.
3. Ouvre une Pull Request vers `develop`.
4. Une fois `develop` validée, elle est mergée dans `master` pour une release.

---

## Convention de nommage des branches

Le nom d'une branche doit suivre le format : `<type>/<description-courte-en-kebab-case>`

| Préfixe | Usage |
|---|---|
| `feat/` | Nouvelle fonctionnalité |
| `fix/` | Correction de bug |
| `docs/` | Documentation uniquement |
| `chore/` | Maintenance, dépendances, config CI/CD |

**Exemples valides :**

```
feat/diagnostic-holmes-rahe
fix/login-popup-overflow
docs/update-readme
chore/upgrade-flutter-3-22
```

---

## Convention de commits

Chaque message de commit doit suivre le format [Conventional Commits](https://www.conventionalcommits.org/) :

```
<type>: <description courte à l'impératif, en minuscules>
```

| Type | Usage |
|---|---|
| `feat:` | Ajout d'une nouvelle fonctionnalité |
| `fix:` | Correction d'un bug |
| `docs:` | Modification de documentation |
| `chore:` | Tâche de maintenance sans impact fonctionnel |
| `refactor:` | Refactorisation sans ajout de fonctionnalité ni correction de bug |
| `test:` | Ajout ou modification de tests |
| `style:` | Formatage, espaces, point-virgules (aucun changement logique) |

**Exemples valides :**

```
feat: ajouter le questionnaire Holmes et Rahe
fix: corriger l'overflow du popup de connexion sur mobile
docs: ajouter la section contribution au README
chore: mettre à jour flutter_dotenv vers 5.2.1
```

**Règles :**
- Description en minuscules, sans point final.
- Pas de majuscule après le `:`.
- Maximum 72 caractères sur la première ligne.
- Utiliser le corps du commit (ligne vide + paragraphe) pour expliquer le *pourquoi* si nécessaire.

---

## Création d'une branche et soumission d'une PR

```bash
# 1. Se placer sur develop à jour
git checkout develop
git pull origin develop

# 2. Créer ta branche
git checkout -b feat/ma-nouvelle-feature

# 3. Développer, commiter
git add <fichiers>
git commit -m "feat: description de la feature"

# 4. Pousser la branche
git push origin feat/ma-nouvelle-feature

# 5. Ouvrir une Pull Request vers develop sur GitHub
```

---

## Checklist avant d'ouvrir une PR

- [ ] Le code compile sans erreur (`flutter analyze`)
- [ ] Les tests existants passent (`flutter test`)
- [ ] Le fichier `.env` n'est pas inclus dans les commits
- [ ] Les messages de commit respectent la convention
- [ ] La branche est à jour avec `develop`
