# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [single/web/mobile - determines source structure]
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

[Gates determined based on constitution file]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

## Architecture Decisions

> Document significant technical choices. "Provisional" patterns become permanent if undocumented.

| Decision | Rationale | Alternatives Rejected |
|----------|-----------|----------------------|
| [Pattern/Technology] | [Why chosen] | [What else considered and why rejected] |

*Minimum: 1 entry if non-standard pattern used. Reference ADR format if formal documentation needed.*

## Quality Gates *(pre-implementation checklist)*

<!--
  GATE: Before starting Phase 0 implementation, verify these gates are passed.
  These reference the conditional sections in spec.md.
-->

| Gate | Condition | Status | Reference |
|------|-----------|--------|-----------|
| Security Gate | Feature exposes endpoints or user data | [ ] Pass / [ ] N/A | spec.md §Security Requirements |
| UX Gate | Feature has user-facing interface | [ ] Pass / [ ] N/A | spec.md §UX Requirements |
| Architecture Gate | Feature involves structural choice | [ ] Pass / [ ] N/A | spec.md §Architecture Decisions |
| Lighthouse Gate | Feature has user-facing pages | [ ] Pass / [ ] N/A | Performance ≥ 90, Accessibility ≥ 90, Best Practices ≥ 90 |
| Test Traceability | All user stories mapped to tests | [ ] Pass | spec.md §Test Traceability |
| Spec↔Code Gate | Before Phase 4 (integration) — each acceptance criterion in spec.md has a corresponding test in the recette cahier (epic-*.md), and every Playwright selector is anchored on a `data-testid` or stable ARIA role | [ ] Pass / [ ] N/A | spec.md §Test Traceability + epic-*.md |

**Rule**: If a gate is marked "Pass", the corresponding spec.md section must be filled. If "N/A", the skip justification must be documented in spec.md.

## Test Strategy

<!--
  Summarize the testing approach for this feature.
  Derived from spec.md §Test Traceability — operational details for the implementer.
-->

### Test pyramid

| Layer | Scope | Tool | Target coverage |
|-------|-------|------|-----------------|
| Unit | Business logic (services, utils) | [vitest/pytest/cargo test] | >= 70% lines |
| Integration | API endpoints + DB | [supertest/httpx] | Critical paths |
| Contract | External API boundaries | [pact/manual] | All external calls |
| E2E | User journeys P1 | [playwright/cypress] | P1 stories minimum |

### Verify commands

```bash
# Run after each phase to validate
[npm test / pytest / cargo test]
[npx tsc --noEmit]  # TypeScript typecheck
[npx vitest run --coverage]  # Coverage report
```

### Done criteria per phase

| Phase | Done when |
|-------|-----------|
| Setup | Project compiles, CI green, dependencies locked |
| Foundational | Core models + migrations pass, auth scaffold works |
| User Story N | All acceptance criteria from spec.md verified, tests pass |
| Polish | Coverage >= thresholds, security checklist passed, docs updated |
