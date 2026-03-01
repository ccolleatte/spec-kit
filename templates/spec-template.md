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
