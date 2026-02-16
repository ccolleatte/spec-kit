# Spec-Kit Sequential Orchestrator

**Orchestrateur skillchain pour workflow spec-kit : specify → plan → tasks**

---

```yaml
---
name: speckit-orchestrator
description: "Orchestrateur séquentiel spec-kit : specify → plan → tasks avec validation dépendances"
version: "1.0.0"
author: Claude Code
created: 2026-02-16
tags: [orchestration, spec-kit, workflow, automation, sequential]
triggers:
  - "speckit auto"
  - "orchestrate spec-kit"
  - "run full spec pipeline"
  - "automate spec workflow"
argument-hint: "<description> [--mode auto|specify-plan|plan-tasks] [-v]"
model: sonnet
type: orchestrator
complexity: medium
license: MIT

modes:
  - auto          # Full pipeline (specify → plan → tasks)
  - specify-plan  # Partial (specify → plan)
  - plan-tasks    # Partial (plan → tasks)

invokes_skills:
  - "specify"  # spec-kit specify command
  - "plan"     # spec-kit plan command
  - "tasks"    # spec-kit tasks command

dependencies:
  tools: ["python3", "spec-kit"]
  minimum_versions:
    python: "3.10"
    spec-kit: "1.0.0"
  graceful_degradation: false  # Hard dependency on spec-kit

allowed-tools:
  - "Bash"
  - "Read"
  - "Write"
  - "Glob"

validation:
  pre_execution:
    - "spec-kit CLI installed"
    - "Git repository initialized"
  dependency_checks:
    - "spec.md exists (for plan phase)"
    - "plan.md exists (for tasks phase)"
---
```

---

## Vue d'ensemble

L'orchestrateur spec-kit automatise le workflow séquentiel de Spec-Driven Development en enchaînant automatiquement les 3 phases principales :

```
specify → plan → tasks
```

**Problème résolu** : Éliminer la friction des 3 invocations manuelles séquentielles et prévenir les oublis de phases.

**Bénéfices** :
- ✅ **Réduction friction** : 1 commande au lieu de 3 (-67% interactions)
- ✅ **Validation automatique** : Dépendances vérifiées entre phases
- ✅ **Fail-fast** : Arrêt immédiat si phase échoue
- ✅ **Logs progressifs** : Visibilité en temps réel sur chaque phase

---

## Workflow orchestré

### Mode `auto` (Pipeline complet)

```bash
python orchestrator.py "Real-time chat with message history"
```

**Exécution** :
1. **Phase 1 - Specify** : Génère `spec.md` avec spécification fonctionnelle
2. ✓ **Validation** : `spec.md` existe
3. **Phase 2 - Plan** : Génère `plan.md` avec architecture technique
4. ✓ **Validation** : `plan.md` existe
5. **Phase 3 - Tasks** : Génère `tasks.md` avec breakdown tâches exécutables

**Résultat** :
- Feature branch complète créée
- 3 fichiers générés : `spec.md`, `plan.md`, `tasks.md`
- Prêt pour implémentation

---

### Mode `specify-plan` (Pipeline partiel)

```bash
python orchestrator.py "API rate limiting" --mode specify-plan
```

**Exécution** :
1. **Phase 1 - Specify** : Génère `spec.md`
2. ✓ **Validation** : `spec.md` existe
3. **Phase 2 - Plan** : Génère `plan.md`
4. ✗ **Phase 3 skipped** : `tasks.md` NON généré

**Cas d'usage** :
- Validation architecture avant breakdown tâches
- Revue spec + plan avant engagement temps implémentation
- Itération sur architecture technique

---

### Mode `plan-tasks` (Reprise pipeline)

```bash
python orchestrator.py "API rate limiting" --mode plan-tasks
```

**Précondition** : `spec.md` doit déjà exister (phase specify déjà effectuée)

**Exécution** :
1. ✓ **Validation** : `spec.md` existe
2. **Phase 2 - Plan** : Génère `plan.md`
3. ✓ **Validation** : `plan.md` existe
4. **Phase 3 - Tasks** : Génère `tasks.md`

**Cas d'usage** :
- Reprise après validation manuelle spec
- Régénération plan + tasks suite à modifications spec
- Workflow itératif (specify manual → orchestrate rest)

---

## Validation des dépendances

L'orchestrateur **valide automatiquement** que chaque phase dispose des inputs nécessaires **AVANT exécution** :

| Phase | Dépendances requises | Validation |
|-------|---------------------|-----------|
| **specify** | Git repo initialisé | ✓ Pre-check |
| **plan** | `spec.md` existe | ✓ Bloque si absent |
| **tasks** | `plan.md` existe | ✓ Bloque si absent |

**Comportement fail-fast** :
- Si dépendance manquante → **Arrêt immédiat** (exit code 1)
- Message d'erreur explicite : `"spec.md not found - run specify first"`
- Phases suivantes **NON exécutées** (évite cascade d'erreurs)

---

## Gestion d'erreurs

### Scénario 1 : Phase échoue (erreur API)

```bash
$ python orchestrator.py "Feature X"

[INFO] [PIPELINE] Starting auto mode: specify → plan → tasks
[INFO] [PHASE] Running specify...
[INFO]   [specify] Generating spec for: Feature X
[INFO]     [exec] Running: specify init . Feature X
[INFO]     [success] spec.md created

[INFO] [PHASE] Running plan...
[INFO]   [plan] Generating technical plan for: Feature X
[INFO]     [exec] Running: specify plan Feature X
[ERROR]    [error] API error: Rate limit exceeded

[ERROR] [FAIL] Phase plan failed: API error: Rate limit exceeded

❌ FAILED: Pipeline stopped at plan: API error: Rate limit exceeded
```

**Comportement** :
- Phase 1 (specify) : ✅ Complétée (`spec.md` créé)
- Phase 2 (plan) : ❌ Échouée (erreur API)
- Phase 3 (tasks) : ⏸️ Non exécutée (arrêt fail-fast)
- Exit code : `1` (échec)

**Fichiers créés** : `spec.md` uniquement (phases suivantes non exécutées)

---

### Scénario 2 : Dépendance manquante

```bash
$ python orchestrator.py "Feature Y" --mode plan-tasks

[INFO] [PIPELINE] Starting plan-tasks mode: plan → tasks
[INFO] [PHASE] Running plan...
[INFO]   [validate] spec.md: missing

[ERROR] [FAIL] Phase plan failed: spec.md not found - run specify first

❌ FAILED: Pipeline stopped at plan: spec.md not found - run specify first
```

**Comportement** :
- Validation pré-phase : ❌ `spec.md` absent
- Pipeline arrêté **AVANT exécution** phase plan
- Exit code : `1` (échec)
- Aucun fichier créé

---

### Scénario 3 : Commande spec-kit non trouvée

```bash
$ python orchestrator.py "Feature Z"

[INFO] [PIPELINE] Starting auto mode: specify → plan → tasks
[INFO] [PHASE] Running specify...
[INFO]   [specify] Generating spec for: Feature Z
[INFO]     [exec] Running: specify init . Feature Z
[ERROR]    [error] Command not found: specify - is spec-kit installed?

[ERROR] [FAIL] Phase specify failed: Command not found: specify - is spec-kit installed?

❌ FAILED: Pipeline stopped at specify: Command not found: specify - is spec-kit installed?
```

**Comportement** :
- Détection pré-exécution : ❌ CLI `specify` non trouvé
- Message d'erreur clair : installation spec-kit requise
- Exit code : `1` (échec)

---

## Timeouts

**Default timeout** : 5 minutes par phase

**Configuration custom** :
```bash
python orchestrator.py "Feature X" --timeout 600  # 10 min timeout
```

**Cas d'usage** :
- Specs complexes avec clarification loops multiples
- Plans avec génération LLM lente
- Tasks avec breakdown détaillé (>100 tâches)

---

## Verbose Mode

**Activation** :
```bash
python orchestrator.py "Feature X" -v
```

**Output détaillé** :
```
[INFO] [PIPELINE] Starting auto mode: specify → plan → tasks

[INFO] [PHASE] Running specify...
[INFO]   [specify] Generating spec for: Feature X
[INFO]   [validate] spec.md: missing (before execution)
[INFO]     [exec] Running: specify init . Feature X
[INFO]     [success] spec.md created
[INFO]   [validate] spec.md: exists (after execution)
[INFO] [OK] Phase specify completed

[INFO] [PHASE] Running plan...
[INFO]   [plan] Generating technical plan for: Feature X
[INFO]   [validate] spec.md: exists
[INFO]   [validate] plan.md: missing (before execution)
[INFO]     [exec] Running: specify plan Feature X
[INFO]     [success] plan.md created
[INFO]   [validate] plan.md: exists (after execution)
[INFO] [OK] Phase plan completed

[INFO] [PHASE] Running tasks...
[INFO]   [tasks] Generating task breakdown
[INFO]   [validate] plan.md: exists
[INFO]   [validate] tasks.md: missing (before execution)
[INFO]     [exec] Running: specify tasks
[INFO]     [success] tasks.md created
[INFO]   [validate] tasks.md: exists (after execution)
[INFO] [OK] Phase tasks completed

✅ SUCCESS: Pipeline completed: specify → plan → tasks
```

**Bénéfices verbose** :
- Debugging phase failures
- Validation étapes exécutées
- Tracking fichiers créés
- Performance profiling (temps par phase)

---

## Exemples d'utilisation

### Exemple 1 : Feature complète (mode auto)

```bash
cd spec-kit
python .claude/skills/speckit-orchestrator/orchestrator.py \
  "User authentication with JWT tokens and refresh flow"
```

**Résultat** :
```
specs/001-user-authentication/
├── spec.md        # Spécification fonctionnelle complète
├── plan.md        # Architecture technique (JWT, refresh tokens, storage)
└── tasks.md       # Breakdown 15-20 tâches exécutables
```

---

### Exemple 2 : Validation architecture (mode specify-plan)

```bash
cd spec-kit
python .claude/skills/speckit-orchestrator/orchestrator.py \
  "Real-time notifications with WebSocket fallback to SSE" \
  --mode specify-plan
```

**Résultat** :
```
specs/002-realtime-notifications/
├── spec.md        # Spécification fonctionnelle
└── plan.md        # Architecture technique (WebSocket primary, SSE fallback)
```

**Workflow après validation** :
1. Revue manuelle `spec.md` + `plan.md`
2. Validation architecture avec équipe
3. Si approuvé → Reprise : `python orchestrator.py "..." --mode plan-tasks`

---

### Exemple 3 : Reprise après modifications (mode plan-tasks)

**Contexte** : `spec.md` créé manuellement ou modifié après review

```bash
cd specs/003-api-rate-limiting

# spec.md déjà existant (créé manuellement ou par specify antérieur)
ls spec.md  # ✓ Exists

# Générer plan + tasks à partir de spec existant
python ../../.claude/skills/speckit-orchestrator/orchestrator.py \
  "API rate limiting with Redis backend" \
  --mode plan-tasks
```

**Résultat** :
```
specs/003-api-rate-limiting/
├── spec.md        # Existant (non modifié)
├── plan.md        # ✓ Généré (architecture Redis)
└── tasks.md       # ✓ Généré (breakdown tâches)
```

---

## Intégration avec workflows existants

### Git workflow

**Avant orchestration** :
```bash
git checkout -b feature/real-time-chat
cd specs
mkdir 004-real-time-chat && cd 004-real-time-chat
```

**Orchestration** :
```bash
python ../../.claude/skills/speckit-orchestrator/orchestrator.py \
  "Real-time chat with message history and typing indicators"
```

**Après orchestration** :
```bash
git add spec.md plan.md tasks.md
git commit -m "feat: Add spec-kit files for real-time chat"
git push origin feature/real-time-chat
```

---

### CI/CD validation

**Pre-commit hook** (`.git/hooks/pre-commit`) :
```bash
#!/bin/bash

# Validate spec-kit files exist for feature branches
if [[ $(git branch --show-current) == feature/* ]]; then
  SPEC_DIR=$(git diff --cached --name-only | grep -E 'specs/[0-9]+-' | head -1 | xargs dirname)

  if [ -n "$SPEC_DIR" ]; then
    if [ ! -f "$SPEC_DIR/spec.md" ] || [ ! -f "$SPEC_DIR/plan.md" ] || [ ! -f "$SPEC_DIR/tasks.md" ]; then
      echo "❌ Missing spec-kit files in $SPEC_DIR"
      echo "Run: python .claude/skills/speckit-orchestrator/orchestrator.py '<description>'"
      exit 1
    fi
  fi
fi
```

---

## Troubleshooting

### Erreur : `Command not found: specify`

**Cause** : spec-kit CLI non installé ou non dans PATH

**Solution** :
```bash
# Vérifier installation
which specify

# Si absent, installer spec-kit
pip install spec-kit
# OU
uv pip install spec-kit
```

---

### Erreur : `spec.md not found - run specify first`

**Cause** : Mode `plan-tasks` invoqué sans `spec.md` existant

**Solutions** :
1. **Option A** : Utiliser mode `auto` (pipeline complet)
   ```bash
   python orchestrator.py "Feature X" --mode auto
   ```

2. **Option B** : Créer `spec.md` manuellement d'abord
   ```bash
   specify init . "Feature X"
   python orchestrator.py "Feature X" --mode plan-tasks
   ```

---

### Erreur : `plan.md not found - run plan first`

**Cause** : Mode `tasks` invoqué sans `plan.md` existant

**Solution** : Utiliser mode `specify-plan` ou `auto`
```bash
python orchestrator.py "Feature X" --mode specify-plan
python orchestrator.py "Feature X" --mode plan-tasks  # Après validation plan
```

---

### Timeout : `Command timeout (300s)`

**Cause** : Phase prend >5 min (LLM lent, clarification loops multiples)

**Solution** : Augmenter timeout
```bash
python orchestrator.py "Complex feature" --timeout 600  # 10 min
```

---

## Comparaison : Workflow manuel vs orchestré

### Workflow manuel (AVANT)

```bash
# Phase 1
cd spec-kit/specs
mkdir 005-feature && cd 005-feature
specify init . "Feature description"
# ⏱️ Attente génération spec.md

# Phase 2 (risque d'oubli)
specify plan "Feature description"
# ⏱️ Attente génération plan.md

# Phase 3 (risque d'oubli)
specify tasks
# ⏱️ Attente génération tasks.md
```

**Friction** :
- 3 commandes séquentielles à se rappeler
- Risque oubli phase (ex: créer spec mais oublier plan)
- Pas de validation dépendances (peut lancer tasks sans plan)
- Rework si phase précédente incomplète

---

### Workflow orchestré (APRÈS)

```bash
cd spec-kit/specs/005-feature
python ../../.claude/skills/speckit-orchestrator/orchestrator.py \
  "Feature description"
```

**Bénéfices** :
- ✅ 1 commande unique (-67% interactions)
- ✅ Validation automatique dépendances
- ✅ Fail-fast si erreur
- ✅ Logs progressifs temps réel

---

## Roadmap

### v1.1 (Planned)

- [ ] Support `--dry-run` mode (simulation sans exécution)
- [ ] Rollback automatique si phase échoue (delete fichiers partiels)
- [ ] Parallel execution phases indépendantes (future spec-kit API)
- [ ] Integration avec `/pm` skill (auto-invoke après tasks.md)

### v2.0 (Future)

- [ ] Support multi-spec orchestration (batch processing)
- [ ] Webhooks notifications (Slack, Discord) après completion
- [ ] Metrics tracking (temps moyen par phase, taux succès)
- [ ] Dashboard temps réel (progress bars, ETA)

---

## Références

- **Spec-Kit Documentation** : [https://github.com/yourusername/spec-kit](https://github.com/yourusername/spec-kit)
- **Skillchain Pattern** : `_docs/analyses/external/20260216-ai-design-components-analysis.md`
- **Spec-Driven Development** : `spec-kit/spec-driven.md`

---

**Version** : 1.0.0
**Dernière mise à jour** : 2026-02-16
**Auteur** : Claude Code (Sonnet 4.5)
**License** : MIT
