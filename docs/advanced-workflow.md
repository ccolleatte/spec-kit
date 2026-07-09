# Advanced Spec-Driven Development Workflow

> [!NOTE]
> This guide presents the **complete, rigorous workflow** for Spec-Driven Development using Spec Kit. For a quick introduction, see the [Quick Start Guide](./quickstart.md).

## Overview: From MVP to Production-Ready

Spec-Driven Development offers two paths:

| Aspect | Quick Start (MVP) | Advanced Workflow (Recommended) |
|--------|------|---------|
| **Phases** | 6 steps | 9-11 steps (with validation) |
| **Time Investment** | ~15-30 minutes | ~1-2 hours |
| **Validation Gates** | Minimal | Comprehensive (checklist, vibe-check, analyze) |
| **Architectural Review** | None | Yes (vibe-check challenges decisions) |
| **Plan Validation** | Direct to tasks | Cross-artifact consistency check (analyze) |
| **GitHub Integration** | Manual | Automated (taskstoissues) |
| **Test Generation** | Manual | Automated (e2e) |
| **Best For** | Exploratory features, spikes | Production features, complex systems |

## The Advanced Workflow: Step by Step

The complete workflow inverts traditional development by placing **specifications and validation at the center**, with code generation as the final step.

```
┌─────────────────────────────────────────────────────┐
│ VISION PHASE [OPTIONAL - Multi-epic projects]       │
├─────────────────────────────────────────────────────┤
│ 0a. Roadmap (value milestones, not tech phases)     │
│ 0b. Backlog Epics (prioritized idea reservoir)      │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ SPECIFICATION PHASE (Where creativity happens)      │
├─────────────────────────────────────────────────────┤
│ 1. Constitution [OPTIONAL]                          │
│ 2. Specify                                          │
│ 3. Clarify (iterate 2-3x)                          │
│ 4. Checklist [OPTIONAL - Early Validation]         │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ PLANNING PHASE (Technical translation)              │
├─────────────────────────────────────────────────────┤
│ 5. Plan                                             │
│ 6. Vibe-Check [OPTIONAL - Architectural Review]    │
│ 7. Analyze (cross-artifact validation) ★ KEY STEP  │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ IMPLEMENTATION PHASE (Code generation)              │
├─────────────────────────────────────────────────────┤
│ 8. Tasks                                            │
│ 9. Tasks to Issues [OPTIONAL - GitHub sync]        │
│ 10. Implement                                       │
│ 11. E2E Tests [OPTIONAL - Post-implementation]    │
└─────────────────────────────────────────────────────┘
```

---

## Glossary: Plan vs Plan Mode

> [!IMPORTANT]
> Spec-Kit and Claude Code both use planning concepts but at different levels. Understanding the distinction prevents confusion.

| Term | Context | Level | Persistence | Who Controls |
|------|---------|-------|-------------|--------------|
| **Spec-Kit "Plan"** | `/speckit.plan` → `plan.md` | **Strategic** (feature) | Versioned in `.specify/specs/` | You + AI dialogue |
| **Spec-Kit "Stages"** | Sections in `plan.md` | **Strategic** | Part of plan.md | You + AI dialogue |
| **Spec-Kit "Phases"** | Sections in `tasks.md` | **Tactical** (execution) | Part of tasks.md | Generated from plan |
| **Claude Code "Plan Mode"** | Internal reasoning | **Micro** (single task) | Ephemeral (session) | Claude autonomous |

**How they work together:**

```
MACRO (Spec-Kit)                          MICRO (Claude Code)
─────────────────                         ──────────────────
spec.md (WHAT)
    ↓
plan.md (STRATEGY)
  ├── Stage 0: Research
  ├── Stage 1: Design
  └── Stage 2: Contracts
    ↓
tasks.md (EXECUTION)
  ├── Phase 1: Setup
  ├── Phase 2: Core
  └── Phase 3: Features
    ↓
For EACH task in tasks.md:              ← Claude enters Plan Mode
                                           ├── Step 1: Explore
                                           ├── Step 2: Design
                                           └── Step 3: Implement
```

**Key insight**: These are **complementary**, not competing. Use Spec-Kit for feature-level strategy, let Claude Code handle task-level tactics.

---

### Phase 0: Vision / Roadmap [Optional — Multi-Epic Projects]

**What**: Establish value milestones and a prioritized epic backlog before diving into individual specs.

**When to use**: Projects with 3+ planned epics, or when stakeholders need a "what can users do after this?" view.

**Skip if**: Single-feature project, spike, or exploration.

**Artifacts**:

| File | Purpose | Template |
|------|---------|----------|
| `_docs/product/roadmap-valeur.md` | Value milestones (v0.5, v1.0...) with user capabilities | `roadmap-valeur-template.md` |
| `_docs/product/backlog-epics.md` | Prioritized epic reservoir (ideas, effort, value) | `backlog-epics-template.md` |

**Key principles**:
- Milestones answer "what can a user do?" — not "what phase is the code in?"
- Each spec (epic) is attached to a milestone
- Tasks are internal to the dev/AI — never exposed at this level
- The PO validates a 1-page milestone summary, not 90 atomic tasks

**Vocabulary**:

| Term | Level | Audience |
|------|-------|----------|
| Milestone (v0.5, v1.0) | Product value | PO + stakeholders |
| Epic (= Spec) | Functional scope | PO + dev |
| Technical phase (B1.2, Admin-0) | Implementation lot | Dev only |
| Task (T0.1, T10.4) | Atomic execution unit | Dev + AI |

**Integration with `/pm`**:
- `/pm roadmap` reads `roadmap-valeur.md` and displays the milestone timeline
- `/pm view` includes a ROADMAP section at the top of the dashboard
- The standard banner shows the current milestone: `📊 v1.0 │ Phase 5/5 │ ...`

#### Governance: 3-Streams Model [Optional — Strategic Projects]

For projects with ongoing development beyond a single epic, the 3-streams model separates execution from planning from vision:

| Stream | Allocation | Question | Frequency |
|--------|-----------|----------|-----------|
| S1 Production | 70% | "Are we building it right?" | Continuous |
| S2 Architecture/Spec | 20% | "Are we preparing the next phase well?" | 1x/week |
| S3 Product Vision | 10% | "Are we building the right thing?" | 1x/2 weeks |

**Gates** (Prince2-style transitions):

| Gate | From → To | Key criteria |
|------|-----------|-------------|
| GATE-V | S3 → S2 | Value articulated, effort estimated, no conflict |
| GATE-S | S2 → S1 | Spec >= 0.8, plan exists, quality gates passed |
| GATE-R | S1 → Shipped | Tests pass, review done, changelog updated |

**Artifacts**:

| File | Purpose | Template |
|------|---------|----------|
| `_docs/product/gouvernance-3-streams.md` | Stream definitions, gates, session format | `gouvernance-streams-template.md` |
| `_docs/product/sessions/session-YYYY-MM-DD.md` | S3 session minutes | `session-s3-template.md` |

**When to use**: 3+ epics planned, project lifespan > 3 months, need to separate "doing things right" from "doing the right things".

**Integration with `/pm`**:
- `/pm vision` launches a ritualized S3 session (review → questions → trade-offs → deliverables)
- `/pm streams` shows the state of all 3 streams
- Dashboard banner includes the current stream: `📊 v1.0 │ S1 Production │ ...`

#### Deliverables by Audience

Every artifact produced by the spec-kit workflow has a specific audience. This matrix prevents exposing the wrong level of detail to the wrong stakeholder.

| Deliverable | Audience | Level | When produced | Template |
|-------------|----------|-------|---------------|----------|
| **Roadmap-valeur** | PO, stakeholders, investors | Strategic | Phase 0, updated at each GATE-R | `roadmap-valeur-template.md` |
| **Backlog epics** | PO, product team | Strategic | Phase 0, updated at each S3 session | `backlog-epics-template.md` |
| **Session S3 minutes** | PO, team leads | Strategic | Every 2 weeks (S3 session) | `session-s3-template.md` |
| **Constitution** | All team, new joiners | Permanent | Phase 1 (once) | `constitution-template.md` |
| **Spec (= Epic)** | PO (summary), dev (full) | Tactical | Phase 2-3 (per epic) | `spec-template.md` |
| **ADR** | Architect, dev, future agents | Permanent | When structural decision | `adr-template.md` |
| **Plan** | Lead dev, architect | Tactical | Phase 5 (per epic) | `plan-template.md` |
| **Tasks** | Dev + AI only | Operational | Phase 8 (per epic) | `tasks-template.md` |
| **STATE.md** | Dev, session resume | Operational | Auto (ongoing) | `state-template.md` |
| **Governance 3-streams** | PO, team leads | Strategic | Phase 0 (once) | `gouvernance-streams-template.md` |
| **Checklist** | QA, dev | Operational | Per gate | `checklist-template.md` |

**Key rule**: Tasks and technical plans are NEVER exposed to PO/stakeholders. The PO validates a 1-page spec summary with acceptance criteria, not 90 atomic tasks. The roadmap-valeur is the primary stakeholder communication tool.

**PO deliverables summary** (what the PO sees and validates):

1. `roadmap-valeur.md` — "Where are we going and where are we now?"
2. `backlog-epics.md` — "What could we build next?"
3. `session-s3-template.md` — "What did we decide in the last vision review?"
4. `spec.md` §User Scenarios (summary only) — "What will users be able to do?"
5. `spec.md` §Success Criteria — "How do we know it worked?"

---

### Phase 1: Constitution [Optional but Recommended]

**What**: Establish the ground rules and principles for your project.

**When to use**: At the start of a new project to ensure all team members align on architectural principles.

**Command**:
```bash
/speckit.constitution
```

**Example**:
```markdown
/speckit.constitution This is a production SaaS platform. All features must follow:
- Test-First Development (tests before code)
- Security-First design (validate all inputs)
- Simplicity over cleverness (3-project maximum)
- Database: PostgreSQL, API: REST + GraphQL
```

**Artifacts created**:
- `.specify/memory/constitution.md` - Your project's immutable principles

**Duration**: 5-10 minutes

---

### Phase 2: Specify

**What**: Transform your feature idea into a complete, structured specification.

**When to use**: Always. This is the foundation of SDD.

**Command**:
```bash
/speckit.specify
```

**Example** (feature description):
```markdown
/speckit.specify Build a real-time notification system that alerts users of important
events. Users should receive desktop notifications, in-app alerts, and emails based on
their preferences. Notifications should be grouped and deduplicated.
```

**Artifacts created**:
- `specs/[branch-name]/spec.md` - Complete feature specification
- Git branch automatically created with semantic naming

**Output includes**:
- Feature description with user stories
- Acceptance criteria for each story
- Non-functional requirements
- Flagged ambiguities (marks them as `[NEEDS CLARIFICATION]`)

**Duration**: 10-15 minutes

---

### Phase 3: Clarify (Iterate 2-3x)

**What**: Interactively resolve ambiguities and refine the specification.

**When to use**: Immediately after specify, then before each major phase.

**Command**:
```bash
/speckit.clarify
```

**Example** (1st iteration):
```markdown
/speckit.clarify Focus on notification preferences. What channels should users
be able to enable/disable individually? Should there be a "quiet hours" feature?
```

**What happens**:
- AI asks targeted clarification questions
- You provide domain context
- Specification auto-updates with new details
- Ambiguity markers removed as clarifications are resolved

**Iteration pattern**:
- **After Specify**: Clarify scope, user stories, acceptance criteria
- **After Plan**: Clarify technical decisions, trade-offs, architecture
- **Optional - After Analyze**: Clarify consistency issues if analysis reveals contradictions

**Best practice**: Do 2-3 clarity rounds. You'll know you're done when:
- ✅ No `[NEEDS CLARIFICATION]` markers remain
- ✅ Acceptance criteria are measurable and testable
- ✅ Technical decisions have documented rationale

**Duration**: 15-30 minutes per round

---

### Phase 4: Checklist [Optional - Early Validation]

**What**: Validate that your specification is complete and coherent **before** planning.

**When to use**: After the 2-3 clarify rounds, before /speckit.plan.

**Command**:
```bash
/speckit.checklist
```

**What it validates**:
- ✅ All user stories have acceptance criteria
- ✅ No contradictions between requirements
- ✅ Non-functional requirements are clear
- ✅ Scope is bounded (not scope creep)
- ✅ Edge cases are covered
- ✅ Existing systems integration is defined

**Output**:
- Checklist of completeness criteria
- Identified gaps for you to address
- Confirmation that spec is "ready for planning"

**Duration**: 5-10 minutes

**Pro tip**: This step catches ~40% of specification issues before they become expensive planning/implementation problems.

---

### Phase 5: Plan

**What**: Create a comprehensive technical implementation plan aligned with your specification.

**When to use**: Always. After spec/clarify/checklist, before analyze.

**Command**:
```bash
/speckit.plan
```

**Example** (tech stack context):
```markdown
/speckit.plan
- Frontend: React with Zustand for state
- Backend: Node.js with Express, PostgreSQL
- Real-time: WebSockets (Socket.io)
- Notifications: Bull job queue + Redis
- Email: SendGrid for transactional emails
```

**Artifacts created**:
- `specs/[branch-name]/plan.md` - Technical implementation strategy
- Supporting documents:
  - `data-model.md` - Database schemas
  - `contracts/` - API specs, event schemas
  - `research.md` - Technology comparisons
  - `quickstart.md` - Key validation scenarios

**Plan includes**:
- Phase breakdown (what to build when)
- Technical architecture decisions
- Technology rationale (why each choice)
- Data model with relationships
- API contracts (REST/GraphQL/WebSocket)
- Test strategy
- Deployment approach

**Duration**: 20-30 minutes

---

### Phase 6: Vibe-Check [Optional - Metacognitive Validation]

**What**: Have an AI agent challenge your architectural decisions to prevent over-engineering.

**When to use**: After plan, if you're uncertain about complexity or want an architectural review.

**Command** (via MCP):
This leverages the `vibe-check` metacognitive oversight server.

**Example scenario**:
```
You've planned a microservices architecture (5 services + API Gateway).
The feature is for MVP with expected <1000 concurrent users.

vibe-check will likely respond:
"Over-engineering for Phase 0. Consider monolith first.
Plan for service extraction in Phase 2 when metrics show bottlenecks.
This will save 2-3 weeks of development time."
```

**When vibe-check adds value**:
- ✅ Large/complex plans (>15 tasks, >5 files modified)
- ✅ Architectural decisions affecting multiple systems
- ✅ Technology choices with scaling implications
- ✅ Unknown unknowns (exploring unfamiliar domains)

**When skip vibe-check**:
- ❌ Simple features (CRUD add-on)
- ❌ Plans you're already confident about
- ❌ Time constraints (adds 5-10 minutes)

**Output**:
- Risk assessment of current plan
- Simplification suggestions if applicable
- Confirmation that complexity is justified

**Duration**: 5-10 minutes

---

### Phase 7: Analyze [Key Step ★ - Cross-Artifact Validation]

**What**: Validate that spec, plan, and other artifacts are consistent and complete.

**When to use**: Always. After plan (or vibe-check if used), before tasks.

**Command**:
```bash
/speckit.analyze
```

**What it checks**:
- ✅ **Specification completeness**: Are all user stories covered by plan?
- ✅ **Planning consistency**: Do architectural decisions trace back to requirements?
- ✅ **Bidirectional traceability**: Can you follow requirements → design → implementation
- ✅ **Technology alignment**: Do chosen technologies actually solve stated requirements?
- ✅ **Contract completeness**: Are all API/event schemas defined?
- ✅ **Phase coherence**: Are phases logically sequenced with clear deliverables?
- ✅ **Risk identification**: Flags impossible phases or unresolved dependencies

**Example output** (if issues found):
```
⚠️ INCONSISTENCY: Spec says "real-time updates under 100ms"
   Plan uses polling (30s interval)
   → Recommendation: Use WebSockets instead

✅ COVERAGE: 100% of user stories have implementation phases

🔴 MISSING: Email notification template not defined
   → Add to contracts/email-schemas.md
```

**Why this is critical**:
- Catches misalignment **before** code generation (saves days of rework)
- Ensures specifications actually **guide** implementation
- Makes "spec-driven" more than a buzzword

**Duration**: 5-10 minutes

---

### Phase 8: Tasks

**What**: Break down the plan into executable, dependency-ordered tasks.

**When to use**: Always. After analyze, before implementation.

**Command**:
```bash
/speckit.tasks
```

**What it generates**:
- `specs/[branch-name]/tasks.md` - Actionable task list
- Dependency ordering (A must happen before B)
- Parallelization markers `[P]` for safe parallel work
- Task descriptions with:
  - Expected inputs/outputs
  - Success criteria
  - File paths affected
  - Time estimates

**Example task structure**:
```markdown
## Task 1.1: Create notification data model [BLOCKING]
- Inputs: None (starts implementation)
- Outputs: `src/models/notification.ts`, tests passing
- Files: [backend], [database]
- Time: 1-2 hours

## Task 1.2: Create notification API contract [P]
- Inputs: Data model (Task 1.1)
- Outputs: `contracts/notification-api.md`
- Files: [backend]
- Time: 30 mins
```

**Duration**: 10-15 minutes

---

### Phase 9: Tasks to Issues [Optional - GitHub Integration]

**What**: Automatically convert tasks into GitHub issues with proper linking and ordering.

**When to use**: If your team uses GitHub Projects/Issues for tracking work.

**Command**:
```bash
/speckit.taskstoissues
```

**What it does**:
- Creates GitHub issues for each task
- Sets up dependency links (Issue A blocks Issue B)
- Adds labels (`type:backend`, `phase:1`, `priority:high`)
- Links to specification branch
- Populates issue descriptions with task details

**Advantages**:
- ✅ Single source of truth (Spec Kit + GitHub)
- ✅ Team visibility and assignment
- ✅ CI/CD integration (auto-close issues on PR merge)
- ✅ Metrics and burndown charts
- ✅ External contributor access

**Duration**: 5 minutes

---

### Phase 10: Implement

**What**: Execute the plan by generating and refining implementation code.

**When to use**: Always. After tasks (and optional taskstoissues), start coding.

**Command**:
```bash
/speckit.implement
```

**What happens**:
- Reads `tasks.md`
- Generates code following Test-First Development (tests before implementation)
- Creates files in order: contracts → tests → implementation
- Validates each task's success criteria
- Iterates until task is complete

**During implementation**:
- **Stay spec-aligned**: If code diverges from spec, update spec (don't change code to match old intent)
- **Test-first**: Write tests that define behavior, confirm they fail, then implement
- **Incremental**: Complete one task fully before moving to next
- **Documentation**: Update spec/plan if you discover issues

**Duration**: Varies by feature complexity (hours to days)

---

### Phase 11: E2E Tests [Optional - Post-Implementation]

**What**: Generate end-to-end tests that validate entire feature workflows.

**When to use**: After implementation, to ensure user journeys work end-to-end.

**Command**:
```bash
/speckit.e2e
```

**What it generates**:
- Playwright E2E test files
- Prisma seed data for test scenarios
- Test factories for repeated setup
- Coverage of:
  - Happy paths (user stories as written)
  - Edge cases (empty states, errors, boundaries)
  - User interactions (click → form → submit → verify)

**Example test** (generated from specification):
```typescript
// E2E: User receives notification when event occurs
test('notifies user of important event', async ({ page }) => {
  // Setup: Create user, event
  const user = await db.user.create({...});

  // Action: Trigger event
  await apiClient.events.create({trigger: 'IMPORTANT', userId: user.id});

  // Verify: Notification appears
  await page.goto(`/notifications`);
  await expect(page.locator('text=Important event')).toBeVisible();
});
```

**Duration**: 15-30 minutes

---

## Complete Example: Building a Notification System

This example walks through all 11 phases end-to-end.

### Step 1: Constitution (5 mins)

```bash
/speckit.constitution This is a backend service with strict API contracts.
All inputs validated. TDD mandatory. PostgreSQL + Redis + Node.js.
```

**Creates**: `.specify/memory/constitution.md`

### Step 2: Specify (10 mins)

```bash
/speckit.specify Build a notification service that:
- Sends messages across multiple channels (email, push, in-app)
- Groups notifications to avoid spam
- Allows users to manage preferences per channel per event type
- Supports templates with variable substitution
```

**Creates**: `specs/002-notifications/spec.md`

**Spec includes**:
- Feature overview
- User stories (6 stories covering different personas)
- Non-functional requirements (latency <5s, 99.9% delivery)
- Acceptance criteria (all measurable)

### Step 3-4: Clarify + Checklist (20 mins)

**Clarification round 1** - Scope:
```bash
/speckit.clarify Do we handle notification retries on delivery failure?
How many times? What's the backoff strategy?
```

Result: Adds retry policy (3 attempts, exponential backoff)

**Clarification round 2** - Edge cases:
```bash
/speckit.clarify What happens if user preferences change mid-send?
Should we respect new preferences or complete with old ones?
```

Result: Documents immediate preference application

**Checklist validation**:
```bash
/speckit.checklist
```

Confirms: ✅ 6 user stories complete, ✅ All requirements clear, ✅ No contradictions

### Step 5: Plan (20 mins)

```bash
/speckit.plan Backend: Node.js + Express
Database: PostgreSQL for notifications, preferences
Queue: Bull + Redis for async processing
Email: SendGrid
Push: Firebase Cloud Messaging
```

**Creates**:
- `specs/002-notifications/plan.md`
- `specs/002-notifications/data-model.md` (Notification, Preference, Template entities)
- `specs/002-notifications/contracts/notification-api.md` (POST /notifications, PATCH /preferences)
- `specs/002-notifications/research.md` (email service comparison, queue library comparison)

### Step 6: Vibe-Check (5 mins)

```
You proposed: Bull queue + Redis + Firebase + SendGrid
For Phase 0 with <500 users.

vibe-check response:
"Avoid Redis/Bull for Phase 0. Use simple polling with database.
Firebase + SendGrid are fine (managed services, not your problem).
Defer Bull to Phase 2 when throughput becomes bottleneck.
This saves ~5 days of infrastructure setup."

Recommendation: Keep SendGrid/Firebase, simplify queue.
```

Decision: Updated plan to use database polling instead of Bull.

### Step 7: Analyze (5 mins)

```bash
/speckit.analyze
```

**Output**:
```
✅ All user stories (6/6) have implementation phases
✅ API contracts defined for all channels
✅ Data model covers all requirement entities
✅ Tech choices justified by non-functional requirements
⚠️ Missing: Error handling spec for send failures
   → Add to plan.md / Complexity Tracking
```

Action: Add error handling details to plan.

### Step 8: Tasks (10 mins)

```bash
/speckit.tasks
```

**Creates**: `specs/002-notifications/tasks.md`

Generates ~20 tasks:
- **Phase 1** (Database): Create Notification model, Preference model
- **Phase 2** (API): Build POST /notifications, GET /preferences
- **Phase 3** (Delivery): Implement email sender, push sender
- **Phase 4** (Grouping): Implement deduplication logic
- **Phase 5** (Templates): Template engine, variable substitution

### Step 9: Taskstoissues (5 mins)

```bash
/speckit.taskstoissues
```

**Creates GitHub Issues**:
- #101: Create Notification model (backend)
- #102: Create Preference model (backend) - blocks #105
- #103: Build POST /notifications (backend) - blocks #107
- #104: Build GET /preferences (backend)
- ... (17 more issues)

All linked with dependencies, labels, and phase assignment.

### Step 10: Implement (2-3 days)

```bash
/speckit.implement
```

Team picks up issues in order. Example flow:

**Issue #101**: Create Notification model
1. Write tests for Notification schema (TDD red phase)
2. Create `src/models/notification.ts`
3. Run tests → pass ✅
4. PR created, reviewed, merged

**Issue #103**: Build POST /notifications
1. Write tests for endpoint (contracts first)
2. Implement endpoint handler
3. Integration tests pass ✅
4. E2E test for "user sends notification"

Process continues until all tasks complete.

### Step 11: E2E Tests (15 mins)

```bash
/speckit.e2e
```

**Generates tests**:
```typescript
// Test: Email notification delivery with preference respect
test('sends email only if user opted in', async () => {
  const user = await createUser();
  await setPreference(user.id, 'email', false); // Opt out email

  await api.notifications.send({
    userId: user.id,
    type: 'ORDER_SHIPPED'
  });

  // Verify no email sent
  expect(await emailService.lastSent()).toBeNull();

  // Verify in-app notif created (default channel)
  const notification = await db.notification.findFirst({
    where: {userId: user.id}
  });
  expect(notification).toBeDefined();
});
```

---

## Key Principles of Advanced Workflow

### 1. **Specifications Drive Everything**

Your spec is the source of truth. Code is generated from specifications, not the reverse. When requirements change:
- Update spec first
- Regenerate plan
- Re-run analyze
- Update tasks
- Re-implement affected tasks

This ensures code always reflects actual intent.

### 2. **Validation is Continuous, Not One-Time**

Traditional waterfall validates at the end (expensive). SDD validates at every phase:

```
specify ← validate (checklist)
  ↓
plan ← validate (vibe-check)
  ↓
analyze ← validate (cross-artifact)
  ↓
implement ← validate (test-first)
```

This catches misalignment early when it's cheap to fix.

### 3. **Specifications are Executable**

Your spec isn't just documentation—it's precise enough to generate working code. This means:
- ✅ Every user story has measurable acceptance criteria
- ✅ Every API is formally defined (contract)
- ✅ Every data entity is modeled
- ✅ Every non-functional requirement is quantified

If your spec can't generate code, it's not specific enough.

### 4. **Analyze is Your Quality Gate**

The `/speckit.analyze` phase is where traditional SDLC gaps are caught. It's worth the 5 minutes to:
- Ensure specs actually match plan
- Verify plan covers all requirements
- Identify missing details before coding
- Document assumptions and trade-offs

---

## When to Use Each Phase

| Scenario | Phases to Include |
|----------|-------------------|
| **Solo developer, learning SDD** | Specify → Clarify → Plan → Tasks → Implement |
| **Team feature (3+ devs)** | Constitution → Specify → Clarify → Checklist → Plan → Analyze → Tasks → Taskstoissues → Implement → E2E |
| **Complex system (microservices)** | Add Vibe-Check after Plan |
| **MVP/Spike** | Just Specify → Clarify → Tasks → Implement (skip validation phases) |
| **Production system** | All 11 phases (full rigor) |
| **Open source project** | Specify → Clarify → Checklist → Plan → Tasks → Taskstoissues → Implement |

---

## Timing Reference

| Phase | Time | Notes |
|-------|------|-------|
| Constitution | 5-10 min | One-time, per project |
| Specify | 10-15 min | Initial spec generation |
| Clarify (per round) | 10-15 min | Do 2-3 rounds typically |
| Checklist | 5-10 min | Early validation checkpoint |
| Plan | 20-30 min | Complete technical strategy |
| Vibe-Check | 5-10 min | Optional, architectural review |
| Analyze | 5-10 min | Cross-artifact consistency |
| Tasks | 10-15 min | Dependency-ordered task list |
| Taskstoissues | 5 min | Optional, GitHub sync |
| Implement | Hours-Days | Actual code generation |
| E2E Tests | 15-30 min | Optional, post-implementation |
| **Total (full)** | **~2-3 hours + implementation** | 30-40% of feature time |

---

## Troubleshooting

### "Analyze found inconsistencies—now what?"

1. Read the inconsistency report carefully
2. Determine root cause (wrong spec? bad plan? both?)
3. Fix the source (prefer fixing spec over plan, plan over implementation)
4. Re-run analyze to confirm resolution
5. Update tasks if plan changed

### "Vibe-check says I'm over-engineering. Should I trust it?"

Usually yes. Over-engineering is the #1 cause of slow delivery. Consider if:
- ✅ Vibe-check's suggestion is simpler and still meets requirements → Use it
- ❌ You have specific requirements only complex approach solves → Document reasoning, proceed

### "Should we skip validation phases to go faster?"

No. Every phase you skip costs 3-5x more in rework:
- Skip clarify → Re-plan after discovering requirements gaps
- Skip analyze → Debug spec-code misalignment during implementation
- Skip vibe-check → Spend weeks on architectural refactoring

Validation is the fastest path, not the slowest.

### "Can we update spec mid-implementation?"

Yes, it's the whole point of SDD:
1. Update spec with new requirements
2. Re-run plan (auto-updates based on new spec)
3. Re-run analyze (catches new inconsistencies)
4. Update tasks for affected phases
5. Continue implementation with new tasks

This is how SDD handles change without chaos.

---

## Next Steps

Ready to start? Follow this path:

1. **Pick a feature** - Something medium complexity (2-3 user stories)
2. **Run the full workflow** - Don't skip any phase
3. **Time each phase** - Understand your team's rhythm
4. **Iterate** - Use learnings from first feature to optimize process
5. **Teach the team** - Spec-Driven Development is a team sport

For deeper understanding, read:
- [Spec-Driven Development Methodology](../spec-driven.md)
- [Quick Start Guide](./quickstart.md) - For comparison with MVP path
- [Contributing Guide](../CONTRIBUTING.md) - For community participation
