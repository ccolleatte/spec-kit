# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**Spec Kit** is a toolkit for implementing Spec-Driven Development (SDD) – a methodology emphasizing clear specifications before implementation. The **Specify CLI** bootstraps projects with the necessary directory structures, templates, and AI agent integrations to support this workflow.

The codebase is written in Python and uses Typer for the CLI framework. It supports 17 different AI agents (Claude Code, GitHub Copilot, Cursor, Gemini, Qwen, etc.).

## Architecture Summary

### Core Structure

```
src/specify_cli/__init__.py  (1210 lines - monolithic but well-organized)
├── Configuration: AGENT_CONFIG dictionary (17 agents)
├── Utilities: check_tool(), is_git_repo(), download_template_from_github()
├── UI Components: StepTracker class, select_with_arrows() interactive menu
└── CLI Commands: init, check (via Typer)

templates/              (Agent-agnostic templates for projects)
├── spec-template.md, plan-template.md, tasks-template.md
├── checklist-template.md, constitution.md
└── commands/          (Prompts for 8 slash commands per agent)
```

### Design Pattern: Single-Purpose Monolith

- **Single file** (`__init__.py`) simplifies maintenance and onboarding
- **Configuration-driven agents** via `AGENT_CONFIG` dict – adding a new agent requires only a config entry
- **Progressive disclosure**: CLI validates only what's needed at each step

### Two Main Commands

1. **`specify init [project-name]`** – Orchestrates:
   - Interactive agent selection (17 AI tools supported)
   - Template download from GitHub releases (version-specific)
   - Project structure setup (.specify/, templates, scripts, VS Code settings)
   - Optional Git repository initialization
   - Comprehensive success/error reporting via Rich UI

2. **`specify check`** – Validates that all prerequisites are installed:
   - Python 3.11+, Git, uv, and relevant AI agent CLIs
   - Provides installation URLs for missing tools

### Workflow Orchestration

**`.claude/skills/speckit-orchestrator/`** – Sequential skillchain automation:

The orchestrator automates the manual 3-phase workflow (`specify → plan → tasks`) into a single command:

```bash
python .claude/skills/speckit-orchestrator/orchestrator.py "Feature description"
```

**Key capabilities:**
- **Dependency validation**: Checks `spec.md` exists before running `plan`, `plan.md` exists before running `tasks`
- **Fail-fast behavior**: Stops immediately if a phase fails (no cascade of errors)
- **Multiple modes**: `auto` (full pipeline), `specify-plan` (partial), `plan-tasks` (resume)
- **Verbose logging**: Optional `-v` flag for debugging

**Structure:**
```
.claude/skills/speckit-orchestrator/
├── orchestrator.py      # Main orchestration logic (200-250 lines)
├── SKILL.md            # Full documentation (300-400 lines)
└── README.md           # Quick start guide (50-80 lines)
```

**Integration with spec-kit:**
- Calls native `specify` CLI commands (not reimplementing logic)
- Respects existing `.specify/` directory structure
- Works with all 17 supported AI agents

**Testing:**
```bash
# Unit tests
uv run pytest tests/unit/test_orchestrator.py -v

# E2E test
cd spec-kit/specs/test-feature
python ../../.claude/skills/speckit-orchestrator/orchestrator.py "Test feature" --mode auto
```

**Documentation:** See `.claude/skills/speckit-orchestrator/SKILL.md` for full details.

---

## Development Workflow

### Setup & Prerequisites

```bash
# One-time setup
python -m venv venv           # Create virtual environment (optional)
uv sync                       # Install dependencies and CLI in editable mode

# Verify it works
uv run specify --help         # Should show all commands
uv run specify check          # Verify prerequisites
```

### TDD Workflow (STRICT)

Spec-kit suit une approche TDD stricte pour toute nouvelle fonctionnalité :

**1. Write test first** : Créer test pytest qui définit comportement attendu

```bash
# Créer tests/test_nouvelle_feature.py
uv run pytest tests/test_nouvelle_feature.py  # Doit échouer
```

**2. Confirm test fails** : Vérifier baseline (test rouge)
- Le test doit échouer pour la bonne raison
- Valide que le test détecte bien l'absence de feature

**3. Iterate code** : Implémenter jusqu'à test pass

```bash
# Edit src/specify_cli/__init__.py
uv run pytest tests/test_nouvelle_feature.py -v  # Itérer jusqu'au vert
```

**4. Never modify test during iteration** : Anti-pattern strict
- ❌ Ne JAMAIS modifier le test pour le faire passer
- ✅ Seulement modifier l'implémentation

**5. Validate** : Run full test suite

```bash
uv run pytest -v              # Tous les tests passent
uv run ruff check src/        # Code quality OK
```

**Référence** : Voir `C:\dev\CLAUDE.md` lignes 477-482 pour workflow standard workspace

### Running Tests

The project uses Python testing framework (pytest):

```bash
# Run all tests
uv run pytest

# Run specific test file
uv run pytest tests/test_cli.py

# Run with verbose output
uv run pytest -v

# Run specific test
uv run pytest tests/test_cli.py::test_init_basic -v
```

### Linting & Code Quality

```bash
# Check code style (ruff)
uv run ruff check src/

# Format code
uv run ruff format src/

# Type checking (if mypy is available)
uv run mypy src/
```

### Local Testing of Template Changes

The released CLI pulls from GitHub releases. To test local changes:

```bash
# 1. Generate release packages locally
./.github/workflows/scripts/create-release-packages.sh v1.0.0

# 2. Copy the package into a test project
cp -r .genreleases/sdd-copilot-package-sh/. /path/to/test-project/

# 3. Test the integration in your AI agent
```

### Building & Releasing

```bash
# Build wheel (Hatchling)
uv build

# The version in pyproject.toml controls releases
# Increment `version = "0.0.X"` in pyproject.toml before releasing
```

## Key Components & Their Roles

### 1. **AGENT_CONFIG** (Lines ~60-130)

Dictionary mapping CLI tool names to agent metadata:

```python
AGENT_CONFIG = {
    "claude": {
        "name": "Claude Code",
        "folder": ".claude/",
        "install_url": "https://claude.ai/code",
        "requires_cli": True,
    },
    # ... 16 more agents ...
}
```

**Adding a new agent:**
1. Add entry to `AGENT_CONFIG` using the actual CLI tool name
2. Update `--ai` help text in `init()` command
3. Update README supported agents table
4. Create agent-specific templates in `templates/commands/`

### 2. **StepTracker** (Lines ~169-252)

UI component for displaying hierarchical step progress:

```python
tracker = StepTracker("Project Initialization")
tracker.add_step("Validating arguments", status="done")
tracker.add_step("Downloading template", status="running")
```

Used to visually track the multi-phase initialization process.

### 3. **select_with_arrows()** (Lines ~274-367)

Interactive menu using arrow keys, Enter, and Esc. Powers agent selection and confirmation dialogs.

### 4. **init() Command** (Lines ~866-1161)

Main orchestration function. Key operations:

- **Argument validation**: Resolve project name from positional arg, `--here` flag, or '.'
- **Agent selection**: Interactive or `--ai` parameter
- **Template download**: GitHub API with progress tracking
- **Extraction & merge**: Unzip and deep-merge JSON configs (VS Code)
- **Git initialization**: Optional `git init && git add . && git commit`
- **Error handling**: Rollback directories on failure

### 5. **Core Utilities**

| Function | Purpose |
|----------|---------|
| `check_tool(tool)` | Verify CLI installed; special handling for Claude (checks `claude` command) |
| `is_git_repo(path)` | Detect if path is a Git repository |
| `download_template_from_github()` | Fetch .zip from GitHub releases with version matching |
| `download_and_extract_template()` | Orchestrate download, extraction, flatten nested dirs |
| `handle_vscode_settings()` | Merge VS Code settings.json files |
| `merge_json_files(dict1, dict2)` | Deep recursive merge (used for settings) |
| `ensure_executable_scripts(path)` | `chmod +x` all `.sh` scripts (POSIX) |
| `run_command(cmd)` | Execute subprocess with error handling |

## Common Tasks

### Adding a New Agent

1. **Edit `src/specify_cli/__init__.py`**:
   - Add entry to `AGENT_CONFIG` (e.g., `"my-agent-cli": { ... }`)
   - Update `--ai` help text to include the new agent

2. **Update Documentation**:
   - Add row to "Supported AI Agents" table in `README.md`
   - Include installation URL and notes

3. **Create Agent Templates** (if format differs):
   - Add command templates in `templates/commands/` if needed
   - Reference `templates/commands/specify.md` as pattern

4. **Test**:
   - `uv run specify init test-project --ai my-agent-cli`
   - Verify directory structure is correct

### Modifying Templates

Templates in `templates/` are downloaded as part of each project initialization. Modify:
- `spec-template.md`, `plan-template.md`, `tasks-template.md` for core workflows
- `commands/*.md` for slash command prompts (used by each agent)

**After template changes**, test locally using the release package approach above.

### Fixing a Bug

1. Write a test (or add to existing test file)
2. Fix the bug in `src/specify_cli/__init__.py`
3. Run tests: `uv run pytest -v`
4. Test CLI manually: `uv run specify init test-proj --ai claude`
5. Update version in `pyproject.toml`
6. Add entry to `CHANGELOG.md`

### Adding a CLI Flag or Option

1. Add parameter to `init()` function with `typer.Option()` or `typer.Argument()`
2. Update `--ai` help text documentation string
3. Implement the logic using the new parameter
4. Add test case
5. Update `README.md` with new option documentation

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `typer` | Latest | CLI framework (FastAPI-style) |
| `rich` | Latest | Console rendering (colors, panels, progress) |
| `httpx[socks]` | Latest | HTTP client for GitHub API (with proxy support) |
| `platformdirs` | Latest | Cross-platform directory paths |
| `readchar` | Latest | Cross-platform keyboard input |
| `truststore>=0.10.4` | Specified | SSL/TLS certificate management (security) |

**Build**: Hatchling (modern Python packaging)

## Code Conventions

- **Line length**: Aim for 100-120 characters (practical limit for CLI code)
- **Naming**: snake_case for functions/variables, UPPER_CASE for constants
- **Imports**: Organize at top of file; use `from module import name`
- **Error messages**: Use Rich panels with context to help users understand what went wrong
- **Cross-platform**: Use `pathlib.Path` for file operations, `platformdirs` for system paths
- **Security**: Always use `httpx` with TLS verification enabled (via truststore); never use `verify=False`

## Important Notes

### Contributing

- Large changes (new templates, major CLI args) require **prior discussion** with maintainers (see CONTRIBUTING.md)
- Disclose any AI assistance used in pull requests
- Test changes against the Spec-Driven Development workflow end-to-end

### Spec-Driven Development Context

Spec Kit is the infrastructure for SDD. Understanding the methodology helps contextualize design decisions:

- **Specifications** drive development (not vice versa)
- **Templates** guide consistent quality across projects
- **Agent integrations** allow teams to use their preferred AI tooling
- See `spec-driven.md` for full methodology documentation

### Version Management

- **Version bumping**: Increment `version` in `pyproject.toml` for each release
- **Changelog**: Update `CHANGELOG.md` with all user-facing changes
- **Breaking changes**: Bump minor version; document migration path

## Testing AI Agent Integration

Each agent has its own command syntax. After changes, verify with actual agents:

```bash
# Initialize a test project for Claude Code
uv run specify init test-claude-project --ai claude

# Or GitHub Copilot
uv run specify init test-copilot-project --ai copilot

# Open the project folder in your agent to verify /speckit.* commands work
```

The `/speckit.*` commands (specify, plan, tasks, implement, clarify, analyze, checklist) are populated from `templates/commands/` and should work consistently across all agents.
