# Index général — spec-kit

Inventaire des fichiers par module. Peut être désynchronisé — vérifier si doute.
Lire en premier lors d'une exploration codebase.

---

## Core CLI

| Fichier | Rôle | ~Lignes |
|---------|------|---------|
| `src/specify_cli/__init__.py` | Monolithe CLI — commandes `init` et `check` | 1210 |

### Composants principaux de `__init__.py`

| Composant | Lignes approx. | Rôle |
|-----------|---------------|------|
| `AGENT_CONFIG` | ~60-130 | Dictionnaire 17 agents (claude, copilot, cursor, gemini, qwen…) |
| `StepTracker` | ~169-252 | UI — progression hiérarchique des étapes |
| `select_with_arrows()` | ~274-367 | Menu interactif clavier (agent selection) |
| `init()` | ~866-1161 | Commande principale — download, extract, setup, git init |
| `check()` | — | Validation prérequis (Python 3.11+, git, uv, CLI agents) |
| `check_tool()` | — | Vérifie si un CLI est installé |
| `download_template_from_github()` | — | Fetch .zip depuis GitHub releases |
| `merge_json_files()` | — | Deep merge JSON (VS Code settings) |

## templates/

| Fichier/Dossier | Rôle |
|----------------|------|
| `spec-template.md` | Template spec.md projet |
| `plan-template.md` | Template plan.md projet |
| `tasks-template.md` | Template tasks.md projet |
| `checklist-template.md` | Template checklist |
| `constitution.md` | Constitution SDD |
| `ux-checklist.md` | Checklist UX/WCAG AA (6 catégories) |
| `design.md` | Design tokens (couleur, typo, espacement, a11y) — format Google Stitch open spec. À placer à la racine du projet. Référencé par T010 et ux-checklist.md. |
| `commands/` | 8 prompts slash commands × 17 agents |

## .claude/skills/speckit-orchestrator/

| Fichier | Rôle | ~Lignes |
|---------|------|---------|
| `orchestrator.py` | Pipeline `specify → plan → tasks` automatisé | 200-250 |
| `SKILL.md` | Documentation complète du skill | 300-400 |
| `README.md` | Guide de démarrage rapide | 50-80 |

**Modes** : `auto` (pipeline complet) · `specify-plan` · `plan-tasks` (reprise)

## .specify/ (généré par `specify init`)

| Fichier | Rôle |
|---------|------|
| `spec.md` | Spécification feature |
| `plan.md` | Plan d'implémentation |
| `tasks.md` | Tasks avec statuts |
| `STATE.md` | État courant (phase, prochaine étape) |
| `memory/` | Mémoire inter-sessions |
| `scripts/` | Scripts automation |

## tests/

| Fichier | Contenu |
|---------|---------|
| `tests/unit/test_*.py` | Tests unitaires CLI (pytest) |

## Docs

| Fichier | Taille | Contenu |
|---------|--------|---------|
| `README.md` | ~38K | Guide principal, agents supportés, workflow |
| `spec-driven.md` | ~25K | Méthodologie SDD complète |
| `AGENTS.md` | ~16K | Intégrations agents (17) |
| `CLAUDE.md` | — | Instructions Claude Code |
| `CONTRIBUTING.md` | — | Guide contribution |
| `CHANGELOG.md` | — | Historique versions |

## Outils de développement

```bash
uv run specify --help       # CLI principal
uv run specify init .       # Init projet courant
uv run specify check        # Vérification prérequis
uv run pytest               # Tests unitaires
uv run ruff check src/      # Linting
```

---

*Dernière mise à jour : 2026-07-09*
