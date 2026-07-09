---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
handoffs: 
  - label: Create Tasks
    agent: speckit.tasks
    prompt: Break the plan into tasks
    send: true
  - label: Create Checklist
    agent: speckit.checklist
    prompt: Create a checklist for the following domain...
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Setup**: Run `.specify/scripts/powershell/setup-plan.ps1 -Json` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Load context**: Read FEATURE_SPEC and `.specify/memory/constitution.md`. Load IMPL_PLAN template (already copied).

3. **Execute plan workflow**: Follow the structure in IMPL_PLAN template to:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section from constitution
   - Evaluate gates (ERROR if violations unjustified)
   - Stage 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Stage 1: Generate data-model.md, contracts/, quickstart.md
   - Stage 1: Update agent context by running the agent script
   - Re-evaluate Constitution Check post-design

4. **Stop and report**: Command ends after Stage 2 planning. Report branch, IMPL_PLAN path, and generated artifacts.

## Stages

### Stage 0: Outline & Research

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:

   ```text
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

### Phase 1: Design & Contracts

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Agent context update**:
   - Run `.specify/scripts/powershell/update-agent-context.ps1 -AgentType claude`
   - These scripts detect which AI agent is in use
   - Update the appropriate agent-specific context file
   - Add only new technology from current plan
   - Preserve manual additions between markers

**Output**: data-model.md, /contracts/*, quickstart.md, agent-specific file

## Gate délibératif *(Lean Swarm — exception, pas règle)*

> **Contexte** : Ce gate couvre ~30% des cas de plan. La majorité des plans (features standard, CRUD, bugfix, refactoring localisé) n'en ont pas besoin.

**Activer uniquement si LES DEUX conditions sont vraies simultanément** :

- `blast_radius = system` : changement transversal (auth, modèle de données, API publique, > 5 modules touchés)
- ET `réversibilité faible` : migration de données, suppression d'endpoint, changement de schéma DB, refactoring architectural majeur

**Ne PAS activer pour** : CRUD standard, ajout d'endpoint, refactoring local, features UI, bugfix ciblé.

**Format du débat (si activé)** :
```
ADVOCATE  : [argument principal pour l'approche proposée]
CHALLENGER: [risque principal, alternative moins risquée]
DÉCISION  : [approche retenue + rationale]
```

Référence : `.lean-swarm/lenses/deliberative.md` (si Lean Swarm installé dans le projet)

---

## Key rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications
