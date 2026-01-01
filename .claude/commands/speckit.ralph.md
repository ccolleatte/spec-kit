---
description: Iterative spec refinement via Ralph Wiggum test-driven clarification loop (max 3 iterations)
handoffs:
  - label: Proceed to Technical Plan
    agent: speckit.plan
    prompt: The spec has been iteratively refined through Ralph Wiggum. Create a comprehensive technical plan based on the updated specification.
---

## Executive Summary for Claude

**Ralph Wiggum Loop**: You will orchestrate 3 execution phases until convergence or max iterations:

1. **Phase A (Claude)**: Generate BDD test scenarios from spec → Save to `.ralph/scenarios-N.md`
2. **Phase B (Claude)**: Analyze scenarios vs spec to find ambiguities → Save to `.ralph/ambiguities-N.md`
3. **Phase C (Claude)**: Generate clarification questions from ambiguities → Save to `.ralph/questions-N.md`
4. **Phase D (Script)**: User answers questions interactively → Script saves answers + counts convergence
5. **Phase E (Claude)**: Update spec.md with answers → Preserve formatting, add Ralph Clarifications section
6. **Phase F (Loop Control)**: Check convergence (ambiguities < 2) → If not converged and iterations < 3, return to Phase A

**Your role**: Execute phases A-C, E-F iteratively. The PowerShell/Bash script handles Phase D (user interaction).

---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Overview

**Ralph Wiggum** is an iterative spec refinement workflow that improves spec quality through autonomous test scenario generation, ambiguity detection, and focused clarification questions.

**Use Ralph when:**
- Spec from `/speckit.clarify` may have lingering ambiguities
- You want autonomous, scenario-driven spec improvement
- You want convergence validation before `/speckit.plan`

**Do NOT use Ralph when:**
- Spec is already well-defined and clear
- You prefer manual review of remaining gaps

**When to expect Ralph to be most valuable:**
- Early-stage specs with vague acceptance criteria
- Complex domain specs with many interdependencies
- Team disagreement on requirements (scenarios surface conflicts)

---

## Execution Steps

### 1. Initialize Context

Run `.specify/scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly` from repo root (combined `-Json -PathsOnly` mode). Parse JSON payload:
- `FEATURE_DIR`
- `FEATURE_SPEC`
- If JSON parsing fails, abort and instruct user to re-run `/speckit.specify`

### 2. Load Spec & Session State

- Read current `spec.md` (from `FEATURE_SPEC` path)
- Read or create `.ralph-session.json` in `FEATURE_DIR`:
  - If exists: Resume from `current_iteration + 1`
  - If missing: Initialize with `current_iteration=0`, `max_iterations=3`, `convergence_threshold=2`

### 3. Ralph Loop (Iteration N / 3)

Repeat **Steps 3a-3f** for each iteration until convergence or max reached:

#### 3a. Generate Test Scenarios

**Prompt Claude:**

```
You are Ralph Wiggum, an iterative spec refinement assistant.

Load this specification:

{SPEC_CONTENT}

Generate 5-10 concrete BDD test scenarios from this spec.

Requirements:
- Format: Given/When/Then (Gherkin-style)
- Concrete: Use specific data, not placeholders ("user 'alice@example.com'" not "user 'someone'")
- Realistic: Represent actual usage patterns
- Balanced: 50% happy paths, 30% edge cases, 20% error cases
- Specific: No vague steps ("user does something" → "user clicks 'Save' button")

Examples of GOOD scenarios:
```
Given a user is logged in as admin
When they upload a 15MB image file
Then the system should reject it with error "File exceeds 10MB limit"
```

Examples of BAD scenarios:
```
Given a user exists
When something happens
Then the result is as expected
```

Output: Markdown list of scenarios. ONLY output scenarios, no explanation.
```

**Expected output**: `FEATURE_DIR/.ralph/scenarios-{N}.md` with 5-10 BDD scenarios

#### 3b. Detect Ambiguities

**Prompt Claude:**

```
Analyze these scenarios against the specification:

Scenarios:
{SCENARIOS_CONTENT}

Specification:
{SPEC_CONTENT}

Identify ambiguities where:
1. A scenario conflicts with spec OR spec is unclear about the scenario
2. Spec mentions a requirement but no scenario tests it
3. A term is used inconsistently
4. Edge case handling is undefined
5. Business rule is vague or missing metrics

Format: Each ambiguity as bullet point:
- [CATEGORY] Ambiguity description → Reference scenario/spec section

Categories: edge-case, missing-requirement, unclear-criteria, conflicting-statement, undefined-behavior

Output: ONLY the ambiguity list, no explanation.
```

**Expected output**: `FEATURE_DIR/.ralph/ambiguities-{N}.md` with categorized ambiguities

#### 3c. Generate Clarification Questions

**Prompt Claude:**

```
Based on these ambiguities:

{AMBIGUITIES_CONTENT}

Generate 3-5 prioritized clarification questions.

Each question MUST be answerable with EITHER:
- Multiple choice: 2-5 distinct options (prefer this)
- Short answer: <=5 words

Prioritization: High-impact questions first (architectural, data model, security)

Format: Markdown list:

### Q1: [Category] Question Text?

Recommended: Option [X] - brief reasoning

| Option | Description |
|--------|-------------|
| A | Option A |
| B | Option B |
| C | Option C |

### Q2: [Short answer] Question?

Suggested: Your answer - brief reasoning

Output: ONLY questions with options/suggestions. No explanation.
```

**Expected output**: `FEATURE_DIR/.ralph/questions-{N}.md` with 3-5 questions

#### 3d. Capture User Answers (Interactive)

**PowerShell script invoked:** `.specify/scripts/powershell/ralph-wiggum.ps1 -Iteration {N} -QuestionsFile {QUESTIONS_FILE} -ScenariosFile {SCENARIOS_FILE} -AmbiguitiesFile {AMBIGUITIES_FILE} -FeatureDir {FEATURE_DIR}`

**Script execution steps:**
1. Initialize or load session state (`.ralph-session.json`)
2. Display questions from file with formatting
3. Interactive prompt for each question:
   - For multiple choice: validate user selects A/B/C or types "yes"/"recommended"
   - For short answer: validate <=5 words
   - If invalid, re-prompt
4. Save answered Q&A to `FEATURE_DIR/.ralph/answers-{N}.md`
5. Count ambiguities in current spec.md (search for [NEEDS CLARIFICATION], TODO, TBD)
6. Update `.ralph-session.json` with iteration metrics
7. Check convergence:
   - If ambiguities < 2: status = CONVERGED
   - Else if iteration >= 3: status = MAX_ITERATIONS
   - Else: status = CONTINUE
8. Display convergence report with status + next steps
9. Exit with appropriate code: 0 (CONVERGED), 1 (CONTINUE), 2 (MAX_ITERATIONS)

**Expected output:**
- `FEATURE_DIR/.ralph/answers-{N}.md` (user answers)
- Updated `.ralph-session.json` (iteration state)
- Console report

#### 3e. Update Spec.md (Incremental)

**Prompt Claude:**

```
Update this specification with answers to clarification questions:

Current Spec:
{SPEC_CONTENT}

Clarification Q&A:
{ANSWERS_CONTENT}

Instructions:
1. Apply each answer to the most relevant spec section(s):
   - Functional requirement → Update Requirements section
   - Business rule → Add/update Rules or Constraints section
   - Edge case/error → Add to Edge Cases / Error Handling
   - Terminology → Normalize across spec, add glossary entry
   - Non-functional → Update Quality Attributes section
2. Preserve formatting: Do not reorder unrelated sections
3. Add or update `## Ralph Clarifications` section (if not present):
   - Create after Overview section
   - Add subsection `### Iteration {N}` with timestamp
   - List each Q&A as bullet point
4. For each Q&A integration, mark SPEC UPDATED: [section name]
5. NO contradictions: Replace contradictory earlier statements, don't duplicate
6. Keep changes minimal: Don't rewrite unrelated text

Output: Updated spec.md in full (all sections, not just changes).
```

**Expected output**: Updated `FEATURE_SPEC` file with Ralph Clarifications section + integrated answers

#### 3f. Check Convergence & Loop Control

1. Read updated spec.md
2. Count ambiguities (call PowerShell function or parse for [NEEDS CLARIFICATION], TODO, TBD markers)
3. Determine status:
   - If ambiguities < 2: **CONVERGED** → Stop loop, go to Step 4
   - If iteration >= 3: **MAX_ITERATIONS** → Stop loop, go to Step 4
   - Else: **CONTINUE** → Next iteration, go to Step 3a with new iteration number

### 4. Final Report

**Display convergence report:**

```markdown
=== Ralph Wiggum Refinement Complete ===

Status: [CONVERGED | MAX_ITERATIONS]
Iterations: {N} / 3

**Summary:**
- Total scenarios generated: {total_scenarios_count}
- Total ambiguities addressed: {total_ambiguities_addressed}
- Total questions asked: {total_questions_asked}
- Final ambiguity count: {final_ambiguity_count}

**Sections Updated:**
- [List of spec sections modified]

**Recommendations:**
- If CONVERGED: ✓ Ready for `/speckit.plan`
- If MAX_ITERATIONS: ⚠️ Review remaining ambiguities, proceed if acceptable, or run `/speckit.ralph` again

**Next Step:** Execute `/speckit.plan` to generate technical implementation plan.
```

---

## Behavior Rules

- If spec file missing, instruct user to run `/speckit.specify` first (do not create a new spec)
- If already converged on first check, respond: "Spec already meets convergence criteria. Ready for `/speckit.plan`" and suggest next command
- Never exceed 3 total iterations (hard limit for fail-fast approach)
- If max iterations reached with high ambiguity count, flag as "⚠️ Consider manual review before planning"
- Respect user early termination signals ("stop", "done", "skip to plan")
- Always preserve original spec formatting (headings, structure, emphasis)
- Never introduce new terminology without adding to glossary/conventions section

---

## Context & Tips

**Ralph is not a replacement for `/speckit.clarify`** — it's a refinement tool:
- Use `/speckit.clarify` first for initial Q&A (one focused pass)
- Then use `/speckit.ralph` for iterative scenario-driven improvement

**Why test scenarios improve specs:**
- Scenarios expose gaps that Q&A alone may miss
- Conflicts between spec and scenarios reveal ambiguities
- Multiple iterations allow convergence on stable spec
- Concrete examples ground discussions on vague requirements

**Common outcomes:**
- **Quick convergence (1 iteration):** Well-defined spec, Ralph validates coverage
- **Moderate (2 iterations):** Missing edge cases or business rules discovered and added
- **Max iterations (3):** Very complex domain or fundamental disagreement → manual review recommended

---

## Artifact Files

Ralph creates/updates these files in `FEATURE_DIR/.ralph/`:

| File | Purpose |
|------|---------|
| `scenarios-1.md` | Generated BDD scenarios iteration 1 |
| `ambiguities-1.md` | Detected ambiguities iteration 1 |
| `questions-1.md` | Clarification questions iteration 1 |
| `answers-1.md` | User answers iteration 1 |
| `.ralph-session.json` | State tracking (iterations, counts, convergence) |

All artifacts preserved for audit trail. User can review progress in `.ralph/` directory.
