# Spec-Kit Orchestrator - Quick Start

**Orchestration séquentielle spec-kit : specify → plan → tasks**

---

## Installation

Aucune installation requise si spec-kit est déjà installé.

**Prérequis** :
- Python 3.10+
- spec-kit CLI (`pip install spec-kit`)
- Git repository initialisé

---

## Usage basique

### Pipeline complet (3 phases)

```bash
cd spec-kit/specs/your-feature
python ../../.claude/skills/speckit-orchestrator/orchestrator.py \
  "Real-time chat with message history"
```

**Résultat** :
- ✅ `spec.md` généré
- ✅ `plan.md` généré
- ✅ `tasks.md` généré

---

### Pipeline partiel

**Spec + Plan uniquement** :
```bash
python orchestrator.py "API rate limiting" --mode specify-plan
```

**Plan + Tasks uniquement** (si spec.md existe déjà) :
```bash
python orchestrator.py "API rate limiting" --mode plan-tasks
```

---

## Options

| Option | Description | Exemple |
|--------|-------------|---------|
| `--mode auto` | Pipeline complet (default) | `--mode auto` |
| `--mode specify-plan` | Spec + Plan uniquement | `--mode specify-plan` |
| `--mode plan-tasks` | Plan + Tasks uniquement | `--mode plan-tasks` |
| `-v, --verbose` | Logs détaillés | `-v` |
| `--timeout N` | Timeout en secondes (default: 300) | `--timeout 600` |

---

## Exemples

### User authentication feature

```bash
python orchestrator.py "User authentication with JWT tokens and refresh flow"
```

**Output** :
```
[INFO] [PIPELINE] Starting auto mode: specify → plan → tasks
[INFO] [PHASE] Running specify...
[INFO] [OK] Phase specify completed
[INFO] [PHASE] Running plan...
[INFO] [OK] Phase plan completed
[INFO] [PHASE] Running tasks...
[INFO] [OK] Phase tasks completed

✅ SUCCESS: Pipeline completed: specify → plan → tasks
```

---

### Validation architecture (sans tasks)

```bash
python orchestrator.py \
  "Real-time notifications with WebSocket fallback to SSE" \
  --mode specify-plan
```

**Workflow** :
1. Génère `spec.md` + `plan.md`
2. Revue manuelle architecture
3. Si validé → Reprise : `python orchestrator.py "..." --mode plan-tasks`

---

## Troubleshooting

### `Command not found: specify`

**Solution** :
```bash
pip install spec-kit
# OU
uv pip install spec-kit
```

---

### `spec.md not found - run specify first`

**Cause** : Mode `plan-tasks` sans spec.md existant

**Solution** : Utiliser mode `auto` ou créer spec.md d'abord
```bash
python orchestrator.py "Feature X" --mode auto
```

---

### `Command timeout (300s)`

**Solution** : Augmenter timeout
```bash
python orchestrator.py "Complex feature" --timeout 600
```

---

## Workflow recommandé

1. **Créer feature branch** :
   ```bash
   git checkout -b feature/real-time-chat
   cd specs && mkdir 004-real-time-chat && cd 004-real-time-chat
   ```

2. **Orchestrer spec-kit** :
   ```bash
   python ../../.claude/skills/speckit-orchestrator/orchestrator.py \
     "Real-time chat with message history"
   ```

3. **Vérifier résultats** :
   ```bash
   ls  # spec.md, plan.md, tasks.md
   ```

4. **Commit** :
   ```bash
   git add spec.md plan.md tasks.md
   git commit -m "feat: Add spec-kit files for real-time chat"
   ```

---

## Documentation complète

Voir [SKILL.md](./SKILL.md) pour :
- Validation des dépendances
- Gestion d'erreurs détaillée
- Modes avancés
- Intégration CI/CD
- Roadmap

---

**Version** : 1.0.0
**License** : MIT
