# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`  
**Created**: [DATE]  
**Status**: Draft  
**Input**: User description: "$ARGUMENTS"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g., "Can be fully tested by [specific action] and delivers [specific value]"]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- What happens when [boundary condition]?
- How does system handle [error scenario]?

### Contraintes framework test (Playwright)

<!--
  Complete this section when writing the recette cahier (epic-*.md).
  Documents known Playwright edge cases to prevent test failures unrelated to the feature.
-->

| Contrainte | Pattern correct | Anti-pattern |
|-----------|----------------|--------------|
| Focus clavier avec hash router | `page.locator('body').click()` avant `keyboard.press('Tab')` | Tab direct → focus reste sur BODY |
| Strict mode locator | Un seul élément par sélecteur, ou `.first()` explicite | `getByRole('button', {name: /X/})` si plusieurs boutons matchent |
| Ancrage sélecteur | `data-testid` ou rôle ARIA (`getByRole`) | Sélecteur CSS fragile (`.btn-primary`) |
| Serveur de test | Lancer backend + frontend manuellement avant Playwright | `webServer` Playwright (peut timeout selon le projet) |
| DB locale | `npm run test:db:init` (ou équivalent) avant la première exécution | Assumer que la DB est dans l'état correct |

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: System MUST [specific capability, e.g., "allow users to create accounts"]
- **FR-002**: System MUST [specific capability, e.g., "validate email addresses"]  
- **FR-003**: Users MUST be able to [key interaction, e.g., "reset their password"]
- **FR-004**: System MUST [data requirement, e.g., "persist user preferences"]
- **FR-005**: System MUST [behavior, e.g., "log all security events"]

*Example of marking unclear requirements:*

- **FR-006**: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified - email/password, SSO, OAuth?]
- **FR-007**: System MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g., "Users can complete account creation in under 2 minutes"]
- **SC-002**: [Measurable metric, e.g., "System handles 1000 concurrent users without degradation"]
- **SC-003**: [User satisfaction metric, e.g., "90% of users successfully complete primary task on first attempt"]
- **SC-004**: [Business metric, e.g., "Reduce support tickets related to [X] by 50%"]

## Maybe-Later

Features exclues du scope actuel avec condition de réintroduction explicite.
Vide = pas de maybe-later identifié. `jamais` = explicitly-out.

| Feature | Condition de réintroduction |
|---------|----------------------------|
| [Feature exclue] | [Trigger : après X users / après Y mois / jamais] |

## Security Requirements *(conditional — mandatory if endpoints or user data)*

<!--
  GATE: If this feature exposes endpoints or manipulates user data,
  these requirements MUST be filled BEFORE Phase 3 (implementation).
  Skip with explicit justification if feature is 100% internal
  (batch local, script one-shot, pure UI sans backend).
  Reference: workflow-dev.md §Security Gate
-->

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

**Skip justification** : [If N/A — explain why: "100% internal batch, no endpoints, no user data"]

---

## UX Requirements *(conditional — mandatory if user-facing)*

<!--
  GATE: If this feature has a user-facing interface (form, auth, onboarding,
  nav, dashboard, settings), these requirements MUST be filled BEFORE Phase 3.
  Skip with explicit justification if API-only / backend / batch.
  Reference: workflow-dev.md §UX Gate
-->

| ID | Requirement | Status |
|----|-------------|--------|
| UX-001 | Friction points identified and mitigated | [ ] |
| UX-002 | WCAG AA compliance verified | [ ] |
| UX-003 | Accessibility (a11y) verification per user story | [ ] |
| UX-004 | Error states designed (not just happy path) | [ ] |
| UX-005 | Loading/empty states designed | [ ] |
| UX-006 | Design tokens mapped to components | [ ] |

### UX traceability

| User Story | Friction point | WCAG criteria | a11y verification |
|------------|---------------|---------------|-------------------|
| [US-1] | [e.g., "3-step form may lose users"] | [2.4.7 Focus visible] | [Keyboard nav tested] |

**Skip justification** : [If N/A — explain why: "API-only, no user interface"]

---

## Architecture Decisions *(conditional — if structural choices)*

<!--
  If this feature involves a structural choice (stack, auth method, data model,
  integration pattern), document it here and create a formal ADR via /decide.
  Skip if feature is incremental with no structural choice.
-->

| Decision | ADR ref | Status |
|----------|---------|--------|
| [e.g., "Vault for key storage"] | [ADR-005] | [ACCEPTED] |

**Skip justification** : [If N/A — "Incremental feature, no structural decision"]

---

## Test Traceability *(mandatory)*

<!--
  Map each user story to its test strategy. This section ensures
  no user story ships without explicit test coverage.
-->

| User Story | Test type | Test location | Acceptance criteria verified |
|------------|-----------|---------------|---------------------------|
| [US-1 (P1)] | [Integration] | [tests/integration/test_xxx.py] | [Given/When/Then #1, #2] |
| [US-2 (P2)] | [Contract + Unit] | [tests/contract/xxx, tests/unit/xxx] | [Given/When/Then #1] |

### Test strategy summary

- **Unit tests** : [What is unit-tested — e.g., "Business logic in services/"]
- **Integration tests** : [What is integration-tested — e.g., "API endpoints with real DB"]
- **Contract tests** : [What is contract-tested — e.g., "External API boundaries"]
- **E2E tests** : [If applicable — e.g., "Critical user journeys via Playwright"]

---

## Agent Decision Anchors *(for implementation agents)*

<!--
  This section is machine-readable. Keep entries short and specific.
  Agents consult this section when facing ambiguous decisions during implementation.
  Format: one constraint per line, beginning with the scope keyword.
-->

### Contraintes architecturales

- **SCOPE** : [What is explicitly in scope — e.g., "Only covers authenticated users, not public API"]
- **BOUNDARY** : [Interface boundaries that must not be bypassed — e.g., "All data access through repository layer"]
- **PATTERN** : [Required architectural pattern — e.g., "Event-driven for all state mutations"]

### Spécifications négatives

<!--
  What this feature must NOT do. Agents check here before extending scope.
-->

- **NOT** : [Explicit exclusion — e.g., "Must not modify existing User schema"]
- **NOT** : [Explicit exclusion — e.g., "Must not introduce synchronous calls to external APIs"]
- **NOT** : [Explicit exclusion — e.g., "Must not bypass role validation middleware"]

### Gate HITL

<!--
  Decisions that require human validation before implementation.
  Agent must STOP and ask when encountering these.
-->

- **ASK** : [Decision requiring human input — e.g., "Caching strategy: agent must ask before choosing TTL"]
- **ASK** : [Decision requiring human input — e.g., "Schema migration: agent must confirm before altering tables"]
