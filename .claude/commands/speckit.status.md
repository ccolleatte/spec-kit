---
description: Display the current spec-kit workflow status for the active feature, showing completed and pending steps.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). If a feature name is provided, use it instead of auto-detecting from branch.

## Outline

1. **Detect current feature**: Run `git branch --show-current` to get branch name. Extract feature identifier (e.g., `001-auth-system` → feature is `001-auth-system`).

2. **Locate specs directory**: Check for `.specify/specs/[feature]/` or `specs/[feature]/` directory.

3. **Check artifact existence**: For each step in the workflow, verify if the corresponding artifact exists:

   | Step | Artifact | Path |
   |------|----------|------|
   | Constitution | `constitution.md` | `.specify/memory/constitution.md` |
   | Specify | `spec.md` | `specs/[feature]/spec.md` |
   | Clarify | Markers in spec | Check `[NEEDS CLARIFICATION]` count in spec.md |
   | Checklist | `checklist.md` | `specs/[feature]/checklist.md` (optional) |
   | Plan | `plan.md` | `specs/[feature]/plan.md` |
   | Analyze | Validation done | Check for `[INCONSISTENCY]` markers or analyze report |
   | Tasks | `tasks.md` | `specs/[feature]/tasks.md` |
   | Tasks to Issues | GitHub issues | Optional - check if `taskstoissues` was run |
   | Implement | Source files | Check if implementation started based on tasks |
   | E2E | Test files | `specs/[feature]/e2e/` or test files (optional) |

4. **Generate status report**: Display a visual progress indicator.

## Output Format

Display the status in this exact format:

```
══════════════════════════════════════════════════════════════
 SPEC-KIT STATUS
══════════════════════════════════════════════════════════════

 Feature: [feature-name]
 Branch:  [branch-name]
 Path:    specs/[feature-name]/

──────────────────────────────────────────────────────────────
 WORKFLOW PROGRESS
──────────────────────────────────────────────────────────────

 SPECIFICATION PHASE
 ├── [✅|⬜] 1. Constitution     → .specify/memory/constitution.md
 ├── [✅|⬜] 2. Specify          → specs/[feature]/spec.md
 ├── [✅|⚠️|⬜] 3. Clarify       → [X] markers remaining
 └── [✅|⬜] 4. Checklist        → specs/[feature]/checklist.md [OPTIONAL]

 PLANNING PHASE
 ├── [✅|⬜] 5. Plan             → specs/[feature]/plan.md
 ├── [✅|⬜] 6. Vibe-Check       → [OPTIONAL]
 └── [✅|⬜] 7. Analyze          → Cross-artifact validation

 IMPLEMENTATION PHASE
 ├── [✅|⬜] 8. Tasks            → specs/[feature]/tasks.md
 ├── [✅|⬜] 9. Tasks to Issues  → GitHub Issues [OPTIONAL]
 ├── [✅|⬜] 10. Implement       → Source code
 └── [✅|⬜] 11. E2E Tests       → Test files [OPTIONAL]

──────────────────────────────────────────────────────────────
 CURRENT POSITION
──────────────────────────────────────────────────────────────

 You are at step [N]: [STEP NAME]

 ➡️  Next recommended action: /speckit.[next-command]

 [If warnings exist:]
 ⚠️  WARNINGS:
 - [Warning 1]
 - [Warning 2]

══════════════════════════════════════════════════════════════
```

## Status Legend

- ✅ = Completed (artifact exists and is valid)
- ⚠️ = Partial (artifact exists but has issues, e.g., NEEDS CLARIFICATION markers)
- ⬜ = Not started (artifact does not exist)
- ⏭️ = Skipped (optional step explicitly skipped)

## Detection Rules

1. **Constitution**: Check if `.specify/memory/constitution.md` exists and is non-empty.

2. **Specify**: Check if `specs/[feature]/spec.md` exists.

3. **Clarify**:
   - ✅ if spec.md exists AND has 0 `[NEEDS CLARIFICATION]` markers
   - ⚠️ if spec.md exists AND has >0 `[NEEDS CLARIFICATION]` markers
   - ⬜ if spec.md does not exist

4. **Checklist**: Check if `specs/[feature]/checklist.md` exists (optional step).

5. **Plan**: Check if `specs/[feature]/plan.md` exists.

6. **Vibe-Check**: Optional - no artifact to check, mark as ⏭️ by default.

7. **Analyze**:
   - ✅ if plan.md exists AND no `[INCONSISTENCY]` markers found
   - ⚠️ if inconsistencies were flagged
   - ⬜ if plan.md does not exist

8. **Tasks**: Check if `specs/[feature]/tasks.md` exists.

9. **Tasks to Issues**: Check if GitHub issues were created (optional).

10. **Implement**: Check if any source files were modified after tasks.md creation.

11. **E2E**: Check for test files in `specs/[feature]/e2e/` or project test directory (optional).

## Next Action Logic

Based on the first incomplete required step, recommend:

| Current State | Recommended Action |
|---------------|-------------------|
| No spec.md | `/speckit.specify` |
| spec.md has NEEDS CLARIFICATION | `/speckit.clarify` |
| spec.md complete, no plan.md | `/speckit.plan` |
| plan.md exists, no tasks.md | `/speckit.tasks` |
| tasks.md exists | `/speckit.implement` |
| All complete | "Feature complete! Consider `/speckit.e2e` for test generation." |
