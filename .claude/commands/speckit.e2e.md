---
description: "Génère tests E2E Playwright + seed data Prisma + factories depuis spécifications"
handoffs:
  - label: "Créer tâches d'implémentation"
    agent: speckit.tasks
    prompt: "Générer tasks.md incluant exécution tests E2E"
    send: false
---

## User Input
```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Given the specification and plan provided, do this:

### 1. Setup & Prerequisites

Run `.specify/scripts/powershell/setup-e2e.ps1 -Json` from repo root and parse JSON for:
- `FEATURE_SPEC`: Path to spec.md
- `IMPL_PLAN`: Path to plan.md
- `DATA_MODEL`: Path to data-model.md (optional)
- `SPECS_DIR`: Feature directory
- `E2E_DIR`: Output directory for tests
- `BRANCH`: Current feature branch

All paths are absolute.

### 2. Read Design Artifacts

Read the following files to understand the feature:

**spec.md** (required):
- Extract user stories avec priorités (P1, P2, P3)
- Extract scénarios acceptation (Given-When-Then)
- Extract user roles mentionnés

**plan.md** (required):
- Extract tech stack (frontend, backend, database)
- Detect test framework preference (Playwright vs Cypress)
- Detect ORM (Prisma, TypeORM, etc.)

**data-model.md** (optional mais recommandé):
- Extract entities (User, Article, Source, etc.)
- Extract fields et types
- Extract constraints (unique, required)

**constitution.md** (optional):
- Extract project constraints
- Extract quality thresholds

### 3. Invoke E2E Test Generator Skill

Execute the skill with absolute paths:

```bash
python C:\dev\.claude\skills\test-e2e-generator\skill.py \
  --spec-path "$FEATURE_SPEC" \
  --plan-path "$IMPL_PLAN" \
  --data-model-path "$DATA_MODEL" \
  --constitution-path "$CONSTITUTION_PATH" \
  --output-dir "$E2E_DIR" \
  --framework "$DETECTED_FRAMEWORK" \
  --verbose
```

Where:
- `$DETECTED_FRAMEWORK` = "playwright" (default) or "cypress" (si mentionné dans plan.md)
- `$E2E_DIR` = `$SPECS_DIR/../tests/e2e` ou `$SPECS_DIR/../../08-tests/e2e` (selon structure projet)

### 4. Verify Generation Results

Check that these files were created:

**Seed Script**:
- `prisma/seed-test.ts` exists
- Contains 3 layers (reference data, base fixtures, factory info)
- Script is valid TypeScript

**Factories**:
- `tests/factories/*.factory.ts` exists
- 1 factory per entity from data-model.md
- Each factory has `create()`, `delete()`, `createMany()` methods

**E2E Tests**:
- `tests/e2e/*.spec.ts` exists
- 1 test file per user story or per scenario
- Tests use Playwright or Cypress syntax
- Tests reference factories for data isolation

**Config**:
- `playwright.config.ts` or `cypress.config.js` exists
- Config has correct baseURL (from plan.md or default)

### 5. Update Project Configuration

**package.json** - Add scripts if not present:

```json
{
  "scripts": {
    "db:seed:test": "ts-node prisma/seed-test.ts",
    "db:reset:test": "prisma migrate reset --skip-seed && npm run db:seed:test",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:debug": "playwright test --debug"
  }
}
```

**Dependencies** - Verify présence (warn if missing):
- `@playwright/test` or `cypress` (selon framework)
- `@faker-js/faker` (pour factories)
- `ts-node` (pour seed script)

### 6. Create Traceability Map

Generate `.speckit/e2e/traceability.json`:

```json
{
  "generated_at": "2025-12-23T10:00:00Z",
  "spec_version": "sha256_hash_of_spec.md",
  "scenarios": [
    {
      "id": "US1-SC1",
      "user_story": "User authentication",
      "test_file": "tests/e2e/user-authentication.spec.ts",
      "status": "generated"
    }
  ],
  "entities": [
    {
      "name": "User",
      "factory": "tests/factories/user.factory.ts",
      "seed_references": 2
    }
  ],
  "coverage": {
    "scenarios_total": 12,
    "scenarios_covered": 12,
    "percentage": 100
  }
}
```

### 7. Report Generation Summary

Display structured output:

```
✅ E2E Test Suite Generated

📊 Summary:
  - Scenarios: 12 detected, 12 tests generated (100%)
  - Entities: 4 detected, 4 factories generated
  - Framework: Playwright
  - Seed script: prisma/seed-test.ts (3 layers)

📁 Files Created:
  - tests/e2e/*.spec.ts (12 files)
  - tests/factories/*.factory.ts (4 files)
  - prisma/seed-test.ts
  - playwright.config.ts
  - .speckit/e2e/traceability.json

🔧 Next Steps:
  1. Review generated tests in tests/e2e/
  2. Install dependencies: npm install --save-dev @playwright/test @faker-js/faker
  3. Seed database: npm run db:seed:test
  4. Run tests: npm run test:e2e

📋 Handoff to /speckit.tasks to create implementation tasks including test execution.
```

### 8. Optional Handoff

If user wants, offer handoff to `/speckit.tasks` to generate tasks.md including:
- Test execution tasks
- Seed data setup tasks
- Test refinement tasks

Context for generation: {ARGS}
