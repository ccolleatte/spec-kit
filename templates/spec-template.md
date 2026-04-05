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

### Test traceability *(mandatory — gate before Phase 3)*

<!--
  GATE: This section MUST be filled before proceeding to plan.md (Phase 3).
  Each acceptance scenario above must map to at least one test.
  Format: GWT reference → test file path → test type (contract/integration/unit)

  This ensures TDD: tests are DESIGNED at spec time, WRITTEN before implementation.
-->

| Scenario | Test file | Type | Status |
|----------|-----------|------|--------|
| US1-S1 (Given..When..Then..) | `tests/contract/test_[name].py` | contract | pending |
| US1-S2 (Given..When..Then..) | `tests/integration/test_[name].py` | integration | pending |
| US2-S1 (Given..When..Then..) | `tests/unit/test_[name].py` | unit | pending |

### Security traceability *(mandatory for features exposing endpoints or data — gate before Phase 3)*

<!--
  GATE: This section MUST be filled before proceeding to plan.md (Phase 3).
  Each endpoint/data surface must map to a threat model + mitigation + rate limit.
  Skip allowed only if feature is non-exposed (local batch, internal utility) — document reason.
-->

| Endpoint / surface | Threat (STRIDE) | Mitigation | Rate limit | Status |
|--------------------|-----------------|------------|------------|--------|
| POST /api/[name]   | [S/T/R/I/D/E]   | [auth method + input validation] | [N req/min per IP] | pending |
| GET /api/[name]    | [S/T/R/I/D/E]   | [auth method + access control] | [N req/min per user] | pending |

**Skip reason (if non-exposed)**: [justification — e.g., "local CLI script, no HTTP surface"]

### UX traceability *(mandatory for user-facing features — gate before Phase 3)*

<!--
  GATE: This section MUST be filled before proceeding to plan.md (Phase 3).
  Each user journey must map to friction analysis + WCAG verification plan.
  Skip allowed only if feature is non user-facing (API/backend/batch) — document reason.
-->

| User story | Friction analysis | WCAG target | A11y verification | Status |
|------------|-------------------|-------------|-------------------|--------|
| US1 | [doc path or inline summary / N/A] | AA / AAA | axe-devtools + manual keyboard | pending |
| US2 | [doc path or inline summary / N/A] | AA / AAA | axe-devtools + manual keyboard | pending |

**Skip reason (if non user-facing)**: [justification — e.g., "API-only endpoint consumed by backend workers"]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- What happens when [boundary condition]?
- How does system handle [error scenario]?

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

### Security Requirements *(mandatory for features exposing endpoints or handling user data)*

<!--
  Features exposing endpoints or data = any API route, auth flow, data persistence, external integration.
  If feature is 100% internal (local batch, one-shot script, pure UI with no backend) → mark "N/A (non exposé)" + justification.
-->

- **SEC-001**: STRIDE threat model — list identified threats (Spoofing / Tampering / Repudiation / Info Disclosure / DoS / Elevation) + mitigation per threat
- **SEC-002**: OWASP Top 10 coverage — injection / auth / exposure / XXE / access control / misconfig / XSS / deserialization / known vulns / logging
- **SEC-003**: Rate limiting defined per public endpoint (window + quota per IP/user)
- **SEC-004**: Auth scope — least privilege principle (who can call what, with which credentials)
- **SEC-005**: Secrets management — no hardcoded fallbacks, fail loud if required env vars missing
- **SEC-006**: Input validation — Zod/equivalent schema on all public endpoints, size limits, sanitization

*Example of non-exposed marker:*

- **SEC-000**: N/A — this feature is a local batch script with no HTTP surface. [Justification: runs on developer machine via CLI, no network exposure.]

### UX Requirements *(mandatory for user-facing features)*

<!--
  User-facing features = features touching UI (forms, navigation, onboarding, auth, dashboards, settings).
  If feature is API-only / backend infra / batch → mark "N/A (non user-facing)" + justification.
-->

- **UX-001**: Target WCAG compliance level (AA minimum, AAA for critical paths)
- **UX-002**: Friction analysis — identify cognitive / interaction / emotional / time / technical / accessibility friction points per user journey
- **UX-003**: Responsive breakpoints supported (320 / 768 / 1024 / 1440)
- **UX-004**: Loading states defined (skeleton, spinner, error boundary)
- **UX-005**: Error handling UX — all error messages localized + actionable
- **UX-006**: Keyboard navigation complete (all interactive elements reachable, `focus-visible` states)

*Example of non user-facing marker:*

- **UX-000**: N/A — this feature is API-only (no user interface). [Justification: internal service endpoint consumed by backend workers only.]

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

## Spécifications négatives *(ce qui NE DOIT PAS changer)*

<!--
  Lean Swarm integration: Définir explicitement les contrats immuables avant d'implémenter.
  Ces contraintes bornent la zone d'impact et préviennent les régressions en production.
-->

- **Contrats publics existants** : [liste des API/interfaces qui ne doivent pas changer]
- **Breaking changes API interdits** : [endpoints concernés, ex: GET /api/users, POST /api/auth]
- **Performance ceilings** : [seuils à maintenir, ex: p95 < 200ms, bundle < 200kb]
- **Schema DB intact** : [tables protégées, ex: User, Session, Assessment — no column removal]
- **Tests existants non cassés** : [test files critiques, ex: auth.test.ts, assessment.router.test.ts]

---

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

## Architecture Exploration Triggers *(Constitution Principle VIII)*

<!--
  This section determines if Phase 3.5 (Architecture Exploration) is required.
  Check all applicable triggers below. If ≥1 mandatory trigger is checked, Phase 3.5 is REQUIRED.
  If only recommended triggers are checked, Phase 3.5 is RECOMMENDED but can be skipped with justification.
-->

### Mandatory Triggers (≥1 → Phase 3.5 REQUIRED)

- [ ] **High User Story Count**: Feature has ≥5 user stories
- [ ] **Violates Simplicity First**: Introduces new patterns, abstractions, or significant architectural changes (Constitution Principle V)
- [ ] **Many Dependencies**: Introduces ≥3 new npm/pip dependencies not in boilerplate
- [ ] **Scale Requirements**: Explicitly mentions >10k concurrent users, >100k requests/day, or similar scale concerns
- [ ] **Extension Candidate**: Feature is candidate for AI/Python extension, Mobile extension, or Microservices migration

### Recommended Triggers (≥1 → Phase 3.5 RECOMMENDED)

- [ ] **Medium User Story Count**: Feature has 3-4 user stories
- [ ] **Non-obvious Architecture**: Multiple valid implementation approaches exist (e.g., polling vs WebSockets, monolith vs services)
- [ ] **Cross-cutting Concerns**: Feature touches authentication, authorization, real-time, caching, or search systems
- [ ] **Performance Sensitive**: Feature has explicit performance requirements (latency, throughput)

### Skip Conditions (Phase 3.5 NOT needed)

- [ ] **Simple Feature**: <3 user stories
- [ ] **Obvious Architecture**: Bugfix, CSS-only, standard CRUD, or obvious tech choice (e.g., "add email field to form")
- [ ] **Spike/Prototype**: Exploration already completed in separate spike
- [ ] **User Explicitly Skips**: User requested skip (document reason below)

**Skip Justification** (if applicable):
[Explain why Phase 3.5 is being skipped despite triggers]

---

**Phase 3.5 Decision**: [REQUIRED / RECOMMENDED / SKIP] (auto-determined by triggers above)

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

### Spécifications négatives (résumé agent)

<!--
  Synthèse de §Spécifications négatives pour consultation rapide par les agents.
  Dupliquer ici les contraintes critiques de la section ci-dessus.
-->

- **NOT** : [Explicit exclusion — e.g., "Must not modify existing User schema"]
- **NOT** : [Explicit exclusion — e.g., "Must not bypass role validation middleware"]

### Gate HITL

<!--
  Decisions that require human validation before implementation.
  Agent must STOP and ask when encountering these.
-->

- **ASK** : [Decision requiring human input — e.g., "Caching strategy: agent must ask before choosing TTL"]
- **ASK** : [Decision requiring human input — e.g., "Schema migration: agent must confirm before altering tables"]
