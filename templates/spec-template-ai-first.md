# Feature Specification (AI-First): [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`  
**Created**: [DATE]  
**Status**: Draft  
**Template**: `spec-template-ai-first.md` — optimisé pour la génération de code par agent
**Input**: User description: "$ARGUMENTS"

<!--
  TEMPLATE AI-FIRST — Usage
  
  Ce template étend spec-template.md avec des sections destinées à guider
  les agents de génération de code (Claude Code, Copilot, Cursor…).
  
  Sections additionnelles vs spec-template.md :
  - §Generatable Entities  : entités structurées extractables pour la génération
  - §Code Generation Hints : contraintes et anti-patterns pour l'agent
  - §Verification Targets  : critères binaires vérifiables par commande
  
  Les sections partagées (User Scenarios, Requirements, Security, UX…)
  restent identiques à spec-template.md.
-->

## User Scenarios & Testing *(mandatory)*

<!--
  User stories prioritized as user journeys. Each must be independently testable.
  Assign priorities P1, P2, P3…
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [How this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Independent Test**: [How this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### Edge Cases

- What happens when [boundary condition]?
- How does system handle [error scenario]?

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST [specific capability]
- **FR-002**: System MUST [specific capability]
- **FR-003**: Users MUST be able to [key interaction]

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation details]
- **[Entity 2]**: [What it represents, relationships to other entities]

---

## Generatable Entities *(AI-First section)*

<!--
  Décrire les entités que l'agent peut générer directement depuis cette spec.
  Format structuré : chaque entité est parseable par un agent sans ambiguïté.
  
  Objectif : réduire la distance sémantique entre la spec et le code produit.
  Source : Lahiri (Microsoft Research) — "AI-generated code is plausible by
  construction, not correct by construction."
-->

### Data Models

<!--
  Lister les structures de données avec leurs champs et contraintes.
  L'agent les utilise pour générer schémas DB, types TypeScript, modèles Pydantic.
-->

```
Entity: [NomEntité]
Fields:
  - [champ]: [type] | required | [contrainte: min/max/pattern/enum]
  - [champ]: [type] | optional | default=[valeur]
Relationships:
  - belongs_to: [AutreEntité] via [clé]
  - has_many: [AutreEntité]
Invariants:
  - [règle métier non exprimable en type: ex "date_fin > date_debut"]
```

### API Contracts

<!--
  Décrire les endpoints/procédures avec leur signature complète.
  L'agent les utilise pour générer routes tRPC, FastAPI endpoints, handlers.
-->

```
Endpoint: [METHOD /path ou trpc.procedure]
Input:
  - [param]: [type] | [required/optional] | [validation]
Output:
  - success: [shape du résultat]
  - error: [codes d'erreur possibles]
Auth: [public | authenticated | role:admin]
Side effects: [mutations DB, events émis, cache invalidé]
```

### Test Scenarios (machine-parseable)

<!--
  Scénarios BDD sous forme strictement parseable.
  Un agent peut les convertir en tests pytest/jest sans interprétation.
-->

```gherkin
Scenario: [nom du scénario]
  Given [précondition vérifiable par code]
  When [action appelable: endpoint, fonction, événement]
  Then [assertion sur état ou réponse: HTTP 200, db.count() == N, ...]
  And [assertion supplémentaire]
```

---

## Code Generation Hints *(AI-First section)*

<!--
  Instructions normatives pour l'agent en charge de l'implémentation.
  Distinguer : préférences (SHOULD) et contraintes dures (MUST/MUST NOT).
  
  Ces hints réduisent les décisions implicites de l'agent — chaque décision
  non contrainte ici est une décision que l'agent prend seul.
-->

### Abstractions préférées

- **PATTERN** : [Pattern architectural requis — ex: "Repository pattern pour l'accès DB"]
- **PATTERN** : [ex: "Server Actions Next.js 15 — pas de route API séparée pour mutations"]
- **LAYER** : [Où mettre la logique — ex: "Business logic dans services/, pas dans routes/"]

### Anti-patterns à éviter

- **AVOID** : [ex: "N+1 queries — utiliser include/joinedload"]
- **AVOID** : [ex: "any cast TypeScript — signatures honnêtes obligatoires"]
- **AVOID** : [ex: "Logique métier dans les composants React"]

### Contraintes de génération

- **MUST** : [ex: "Chaque endpoint public doit avoir un rate limiter Upstash"]
- **MUST** : [ex: "Validation Zod sur tous les inputs avant traitement"]
- **MUST NOT** : [ex: "Ne pas modifier le schéma User existant"]
- **MUST NOT** : [ex: "Ne pas introduire de dépendance externe sans validation dans research-context.md"]

### Fichiers de référence à consulter

<!--
  L'agent doit lire ces fichiers avant de générer du code.
  Format: chemin | raison de lecture
-->

| Fichier | Raison |
|---------|--------|
| [chemin/vers/fichier.ts] | [ex: "Pattern auth existant à reproduire"] |
| [chemin/vers/schema.prisma] | [ex: "Schéma DB — ne pas en déduire la structure"] |
| [chemin/vers/service.py] | [ex: "Interface du service adjacent à étendre"] |

---

## Verification Targets *(AI-First section)*

<!--
  Critères de complétion vérifiables par commande — binaires (pass/fail).
  L'agent les utilise pour s'auto-vérifier avant de déclarer la tâche terminée.
  
  Source : règle "critères binaires > critères spectraux" — learnings.md Bloc 1.
  Un critère non exprimable en commande shell est un critère flou.
-->

| # | Critère | Commande de vérification | Pass condition |
|---|---------|--------------------------|----------------|
| V1 | Types valides | `npx tsc --noEmit` | Exit code 0 |
| V2 | Tests passent | `uv run pytest tests/[module]/ -v` | 0 failed |
| V3 | [Critère métier] | `[commande]` | [condition exacte] |
| V4 | [Critère API] | `curl -s [endpoint] \| jq '.status'` | `"ok"` |

<!--
  Exemples de critères métier :
  - Entité créée : `python -c "from db import count_X; assert count_X() == 1"`
  - Endpoint accessible : `curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/x` → 200
  - Migration appliquée : `prisma migrate status` → "Database schema is up to date"
-->

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: [Measurable metric]
- **SC-002**: [Measurable metric]
- **SC-003**: [User satisfaction metric]

## Maybe-Later

| Feature | Condition de réintroduction |
|---------|----------------------------|
| [Feature exclue] | [Trigger : après X users / après Y mois / jamais] |

---

## Security Requirements *(conditional)*

| ID | Requirement | Status |
|----|-------------|--------|
| SEC-001 | STRIDE threat model completed for each endpoint | [ ] |
| SEC-002 | OWASP Top 10 reviewed against feature scope | [ ] |
| SEC-003 | Rate limiting configured on all public endpoints | [ ] |
| SEC-004 | Zero secrets hardcoded (fail loud if env var missing) | [ ] |
| SEC-005 | Zod/schema validation on all public inputs | [ ] |
| SEC-006 | Least privilege: RLS policies restrictive by default | [ ] |

### Security traceability

| Endpoint/Surface | Threat (STRIDE) | Mitigation | Rate limit |
|------------------|-----------------|------------|------------|
| [POST /api/xxx] | [Spoofing, Tampering] | [Auth + Zod validation] | [10/min] |

**Skip justification** : [If N/A]

---

## UX Requirements *(conditional)*

| ID | Requirement | Status |
|----|-------------|--------|
| UX-001 | Friction points identified and mitigated | [ ] |
| UX-002 | WCAG AA compliance verified | [ ] |
| UX-003 | Accessibility (a11y) verification per user story | [ ] |
| UX-004 | Error states designed | [ ] |
| UX-005 | Loading/empty states designed | [ ] |
| UX-006 | Design tokens mapped to components | [ ] |

**Skip justification** : [If N/A]

---

## Architecture Decisions *(conditional)*

| Decision | ADR ref | Status |
|----------|---------|--------|
| [e.g., "Vault for key storage"] | [ADR-005] | [ACCEPTED] |

**Skip justification** : [If N/A]

---

## Test Traceability *(mandatory)*

| User Story | Test type | Test location | Acceptance criteria verified |
|------------|-----------|---------------|---------------------------|
| [US-1 (P1)] | [Integration] | [tests/integration/test_xxx.py] | [Given/When/Then #1, #2] |

### Test strategy summary

- **Unit tests** : [What is unit-tested]
- **Integration tests** : [What is integration-tested]
- **E2E tests** : [If applicable]

---

## Agent Decision Anchors *(for implementation agents)*

### Contraintes architecturales

- **SCOPE** : [What is explicitly in scope]
- **BOUNDARY** : [Interface boundaries that must not be bypassed]
- **PATTERN** : [Required architectural pattern]

### Spécifications négatives

- **NOT** : [Explicit exclusion]
- **NOT** : [Explicit exclusion]

### Gate HITL

- **ASK** : [Decision requiring human input]
- **ASK** : [Decision requiring human input]

---

<!--
  DIFFÉRENCES vs spec-template.md :
  
  Sections ajoutées :
  - §Generatable Entities  (Data Models + API Contracts + Test Scenarios BDD)
  - §Code Generation Hints (Abstractions préférées + Anti-patterns + Contraintes + Refs)
  - §Verification Targets  (critères binaires vérifiables par commande)
  
  Sections identiques : User Scenarios, Requirements, Success Criteria,
  Maybe-Later, Security, UX, Architecture Decisions, Test Traceability,
  Agent Decision Anchors.
  
  Quand utiliser ce template vs spec-template.md :
  - spec-template.md        → feature standard, spec lisible par humains
  - spec-template-ai-first.md → feature avec génération de code intensive,
    plusieurs entités à générer, agent en mode autonome
-->
