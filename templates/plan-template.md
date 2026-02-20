# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Workflow Chain

**REQUIRED SUB-SKILL Pattern**: Declare explicitly which skills are needed downstream during project execution to ensure proper tooling invocation and dependency management.

```yaml
workflow_chain:
  - skill: "/pm"
    phase: "Phase 0-2 (Spec/Clarify)"
    required: true
  - skill: "/review"
    phase: "Phase 5 (Implement)"
    context: "Pre-commit validation"
    required: true
  - skill: "/test-pilot"
    phase: "Phase 5 (Implement)"
    context: "TDD enforcement"
    required: false
```

### Common Patterns (choose one or customize)

**Pattern 1 - Standard Feature**:
```yaml
workflow_chain:
  - skill: "/pm"
    phase: "Phase 0-2"
    required: true
  - skill: "/test-pilot"
    phase: "Phase 5"
    context: "TDD enforcement"
    required: true
  - skill: "/precommit"
    phase: "Phase 5"
    context: "Pre-commit validation"
    required: true
```

**Pattern 2 - Security-Critical Feature**:
```yaml
workflow_chain:
  - skill: "/pm"
    phase: "Phase 0-2"
    required: true
  - skill: "/review"
    mode: "security"
    phase: "Phase 3 (Plan)"
    context: "Security audit before implementation"
    required: true
  - skill: "/test-pilot"
    phase: "Phase 5"
    context: "TDD + security tests"
    required: true
  - skill: "/pentest"
    phase: "Post-Phase 5"
    context: "Final security validation"
    required: false
```

**Pattern 3 - Refactoring**:
```yaml
workflow_chain:
  - skill: "/review"
    mode: "deep"
    phase: "Pre-refactoring"
    context: "Risk assessment"
    required: true
  - skill: "/test-pilot"
    phase: "During refactoring"
    context: "Regression prevention"
    required: true
  - skill: "/precommit"
    phase: "Post-refactoring"
    context: "Quality validation"
    required: true
```

### Validation

Validate workflow chain structure using:
```bash
_scripts/validation/validate-workflow-chain.ps1 -PlanFile "specs/[###-feature]/plan.md"
```

Or via `/pm validate-chain` command once in spec-kit workflow.

> [!NOTE]
> **ACTION REQUIRED**: Select one of the common patterns above or customize for your specific project needs. Delete unused pattern examples before finalizing the plan.

## Quality Gates

**REQUIRED**: Declare quality gates applicable to this feature's implementation.
These are checked by `validate-quality-gates.ps1` during development.

**Execution modes**:
- **Strict**: P0 only (BLOCKING if violations detected, exit code 1)
- **Warnings**: P0 + P1 checks (exit 0, fix-before-merge items noted)
- **Advisory**: P0 + P1 + P2 checks (informational, log to refactoring-debt.yaml)

```yaml
quality_gates:
  P0_blocking:
    - id: file-complexity
      rule: "No file exceeds 500 LOC (hard block at 800)"
      check: "complexity-guard.ps1"
      blocking: true

    - id: error-pattern-consistency
      rule: "No bare 'throw new Error()' in routers — use createError()"
      check: "grep 'throw new Error(' src/api/routers/"
      blocking: true  # Zero tolerance

    - id: typescript-zero-errors
      rule: "npx tsc --noEmit must pass before commit"
      check: "typecheck"
      blocking: true

  P1_warning:
    - id: dry-check
      rule: "No code block duplicated ≥3 times"
      check: "validate-quality-gates.ps1 -Mode Warnings (P1-1)"
      blocking: false  # Warning only

    - id: n-plus-one-queries
      rule: "Prisma queries use includes instead of loop queries"
      check: "validate-quality-gates.ps1 -Mode Warnings (P1-2)"
      blocking: false

    - id: unused-imports
      rule: "Remove unused imports (detected by linter)"
      check: "validate-quality-gates.ps1 -Mode Warnings (P1-3)"
      blocking: false

    - id: type-any-usage
      rule: "No explicit 'any' types in non-test files — use explicit types"
      check: "validate-quality-gates.ps1 -Mode Warnings (P1-4)"
      blocking: false

    - id: console-log-cleanup
      rule: "No console.log in lib/ (use logger)"
      check: "validate-quality-gates.ps1 -Mode Warnings (P0-3)"
      blocking: false

  P2_advisory:
    - id: cyclomatic-complexity
      rule: "Functions with >10 branches should be simplified"
      check: "validate-quality-gates.ps1 -Mode Advisory (P2-1)"
      blocking: false
      note: "Log in refactoring-debt.yaml for future sessions"
```

### Common Patterns for quality_gates

**Pattern TS-Backend (tRPC + Prisma)**:
```yaml
quality_gates:
  P0_blocking:
    - id: file-complexity
    - id: error-pattern-consistency
    - id: typescript-zero-errors
  P1_warning:
    - id: dry-check
    - id: console-log-cleanup
```

**Pattern Frontend (React + Vitest)**:
```yaml
quality_gates:
  P0_blocking:
    - id: file-complexity
    - id: typescript-zero-errors
  P1_warning:
    - id: props-type-coverage
      rule: "No 'Props & any' patterns — explicit prop types required"
```

> [!NOTE]
> **ACTION REQUIRED**: Select the pattern that matches your project stack and customize the gates. Delete unused patterns before finalizing the plan.

---

## Strategic View (Milestones)

> **Purpose**: High-level delivery milestones before diving into technical details. Use this section to align with stakeholders and validate scope.

| Milestone | Scope | Success Criteria | Dependencies |
|-----------|-------|------------------|--------------|
| **M0: Research** | Technology validation, spike | Research.md complete, risks identified | None |
| **M1: Foundation** | Data model, contracts, core APIs | Contracts validated, schema migrations ready | M0 |
| **M2: Core Feature** | Primary user stories implemented | Smoke tests pass, demo-ready | M1 |
| **M3: Polish** | Edge cases, error handling, UX | All acceptance criteria pass | M2 |

> [!TIP]
> **Challenge this section**: Before proceeding to Technical Context, discuss these milestones with your AI agent or team. Adjust scope if milestones seem too ambitious or too granular.

---

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

## Architecture Foundation (Phase 3.5)

<!--
  This section is populated ONLY if Phase 3.5 (Architecture Exploration) was executed.
  If Phase 3.5 was SKIPPED (per spec.md triggers), remove this section entirely.
-->

**Phase 3.5 Status**: [COMPLETED / SKIPPED / NOT APPLICABLE]

<!--
  If COMPLETED, fill out the sections below. If SKIPPED, provide justification.
-->

### Architecture Decision (if Phase 3.5 completed)

**Selected Variant**: [Baseline / Alt 1: [Name] / Alt 2: [Name]]

**Comité d'Architecture Vote**: [X]/8 experts (consensus achieved: [Yes/No])

**Deviation from Boilerplate**: [X]% complexity increase, +$[Y]/month cost

**Deviation Justification Score**: [X]/100 (threshold: ≥70 for justified deviation)

**Key Rationale** (1-2 sentences):
[Summarize why this architecture was selected over alternatives]

### Phase 3.5 Deliverables (reference links)

**Required Artifacts** (all present in `specs/[###-feature]/`):

- **Explorations**:
  - `explorations/baseline.md` - T3 Stack baseline analysis
  - `explorations/alt1.md` - [Alternative 1 name]
  - `explorations/alt2.md` - [Alternative 2 name] (if applicable)

- **Gap Analysis**: `gap-analysis.md` - Quantitative metrics comparing variants
  - Complexity Delta: [X]%
  - Cost Delta: $[Y]/month
  - Maintainability Score: [Z]/10
  - Migration Effort: [W] person-hours
  - Risk Score: [R]/10
  - TDD Feasibility: [T]/10

- **Debate Summary**: `architecture-comparison.md` - 8-expert panel discussion
  - Format: [SYNTHESIS / HYBRID / FULL] (based on feature complexity)
  - Consensus: [X]/8 experts
  - Key tensions surfaced: [List 1-2 productive disagreements]

- **Formal ADR**: `adr/[NNN]-architecture-selection.md` - Architecture Decision Record
  - Status: [PROPOSED / ACCEPTED]
  - Validation Gates: [X]/6 passed

### Constitutional Validation (Phase 3.5 Gate)

**flash skill check**: [PASS / WARN / FAIL]

- [ ] Constitution Principle V (Simplicity First): [Status]
- [ ] Constitution Principle VIII (Architecture Exploration): [Status]

**vibe-check risk assessment**: [X]/10 (threshold: <7 acceptable)

- Traits detected: [e.g., "none" or "premature_optimization, scope_creep"]
- Recommendation: [Proceed / Review / Simplify]

### Skip Justification (if Phase 3.5 skipped)

**Reason for Skip**: [From spec.md Architecture Exploration Triggers section]

**Validation**: [User approved skip: Yes/No]

---

## Constitution Check

*GATE: Must pass before Stage 0 research. Re-check after Stage 1 design.*

[Gates determined based on constitution file]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Stage 0 output (/speckit.plan command)
├── data-model.md        # Stage 1 output (/speckit.plan command)
├── quickstart.md        # Stage 1 output (/speckit.plan command)
├── contracts/           # Stage 1 output (/speckit.plan command)
└── tasks.md             # Stage 2 output (/speckit.tasks command - NOT created by /speckit.plan)
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
