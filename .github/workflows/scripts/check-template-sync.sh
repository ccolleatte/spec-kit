#!/usr/bin/env bash
# check-template-sync.sh — guard against templates/ ↔ .specify/ drift.
#
# templates/ + memory/ are the release-packaging source (create-release-packages.sh);
# .specify/ is the local dogfood tree read by .claude/commands/speckit.*.md.
# The shared file pairs below must stay byte-identical: they diverged once
# (272 lines, TDD gates lost on one side — audit 2026-07-09) and this guard
# blocks the commit that would reintroduce the drift.
#
# Usage: .github/workflows/scripts/check-template-sync.sh
# Exit 0 = all pairs identical, exit 1 = at least one pair diverged.

set -u

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
cd "$REPO_ROOT" || exit 1

PAIRS=(
  "templates/spec-template.md:.specify/templates/spec-template.md"
  "templates/plan-template.md:.specify/templates/plan-template.md"
  "templates/tasks-template.md:.specify/templates/tasks-template.md"
  "templates/checklist-template.md:.specify/templates/checklist-template.md"
  "memory/constitution.md:.specify/memory/constitution.md"
)

status=0
for pair in "${PAIRS[@]}"; do
  src="${pair%%:*}"
  dst="${pair##*:}"
  if [ ! -f "$src" ] || [ ! -f "$dst" ]; then
    echo "[template-sync] MISSING: $src or $dst does not exist" >&2
    status=1
    continue
  fi
  if ! diff -q "$src" "$dst" >/dev/null 2>&1; then
    echo "[template-sync] DIVERGE: $src <> $dst" >&2
    status=1
  fi
done

if [ "$status" -ne 0 ]; then
  echo "[template-sync] Shared template pairs must stay identical." >&2
  echo "[template-sync] Fix: apply the edit to BOTH sides, or copy the intended version over the other." >&2
  exit 1
fi

echo "[template-sync] OK: 5 pairs identical"
exit 0
