#!/usr/bin/env python3
"""
Skillchain orchestrator for spec-kit sequential workflow.
Orchestrates: specify -> plan -> tasks pipeline.

Usage:
    python orchestrator.py "Feature description" [--mode auto|specify-plan|plan-tasks] [-v]

Examples:
    # Full pipeline
    python orchestrator.py "Real-time chat with message history"

    # Partial pipeline (specify + plan only)
    python orchestrator.py "API rate limiting" --mode specify-plan

    # Resume from plan phase
    python orchestrator.py "API rate limiting" --mode plan-tasks
"""

import subprocess
import sys
from pathlib import Path
from typing import Tuple, Optional


class SpecKitOrchestrator:
    """Orchestrates spec-kit sequential phases with dependency validation."""

    def __init__(self, verbose: bool = False):
        """
        Initialize orchestrator.

        Args:
            verbose: Enable detailed logging
        """
        self.verbose = verbose
        self.current_phase = None

    def run_pipeline(
        self,
        description: str,
        mode: str = "auto"
    ) -> Tuple[bool, str]:
        """
        Run spec-kit pipeline with automatic phase chaining.

        Args:
            description: Feature description (user prompt)
            mode: Pipeline mode - "auto" (full), "specify-plan", "plan-tasks"

        Returns:
            (success: bool, message: str)
        """
        phases = {
            "auto": ["specify", "plan", "tasks"],
            "specify-plan": ["specify", "plan"],
            "plan-tasks": ["plan", "tasks"]
        }

        pipeline = phases.get(mode, phases["auto"])
        self._log(f"[PIPELINE] Starting {mode} mode: {' -> '.join(pipeline)}")

        for phase in pipeline:
            self.current_phase = phase
            self._log(f"\n[PHASE] Running {phase}...")

            success, message = self._run_phase(phase, description)

            if not success:
                self._log(f"[FAIL] Phase {phase} failed: {message}", error=True)
                return False, f"Pipeline stopped at {phase}: {message}"

            self._log(f"[OK] Phase {phase} completed")

            # Post-tasks TDD gate: validate test tasks exist
            if phase == "tasks":
                tdd_ok, tdd_msg = self._validate_tdd_gate()
                if not tdd_ok:
                    self._log(f"[TDD GATE] {tdd_msg}", error=True)
                    # Warning only, not blocking — tasks.md is still valid
                    # but user should add test tasks before implementation

        return True, f"Pipeline completed: {' -> '.join(pipeline)}"

    def _run_phase(self, phase: str, description: str) -> Tuple[bool, str]:
        """
        Execute a single phase with dependency validation.

        Args:
            phase: Phase name ("specify", "plan", "tasks")
            description: Feature description

        Returns:
            (success: bool, message: str)
        """
        # Phase 1: Specify
        if phase == "specify":
            return self._run_specify(description)

        # Phase 2: Plan
        elif phase == "plan":
            # Validate: spec.md must exist
            if not self._validate_file_exists("spec.md"):
                return False, "spec.md not found - run specify first"
            return self._run_plan(description)

        # Phase 3: Tasks
        elif phase == "tasks":
            # Validate: plan.md must exist
            if not self._validate_file_exists("plan.md"):
                return False, "plan.md not found - run plan first"
            return self._run_tasks()

        return False, f"Unknown phase: {phase}"

    def _run_specify(self, description: str) -> Tuple[bool, str]:
        """
        Run specify phase (spec generation).

        Args:
            description: Feature description

        Returns:
            (success: bool, message: str)
        """
        self._log(f"  [specify] Generating spec for: {description}")

        # Note: This assumes spec-kit CLI is available
        # Adjust command based on actual spec-kit installation
        cmd = ["specify", "init", ".", description]

        return self._execute_command(cmd, phase="specify")

    def _run_plan(self, description: str) -> Tuple[bool, str]:
        """
        Run plan phase (technical plan generation).

        Args:
            description: Feature description

        Returns:
            (success: bool, message: str)
        """
        self._log(f"  [plan] Generating technical plan for: {description}")

        # Note: Adjust command based on actual spec-kit plan command
        cmd = ["specify", "plan", description]

        return self._execute_command(cmd, phase="plan")

    def _run_tasks(self) -> Tuple[bool, str]:
        """
        Run tasks phase (task breakdown generation).

        Returns:
            (success: bool, message: str)
        """
        self._log("  [tasks] Generating task breakdown")

        # Note: Adjust command based on actual spec-kit tasks command
        cmd = ["specify", "tasks"]

        return self._execute_command(cmd, phase="tasks")

    def _execute_command(
        self,
        cmd: list,
        phase: str,
        timeout: int = 300
    ) -> Tuple[bool, str]:
        """
        Execute shell command with error handling.

        Args:
            cmd: Command and arguments as list
            phase: Phase name (for logging)
            timeout: Command timeout in seconds (default: 5 min)

        Returns:
            (success: bool, message: str)
        """
        try:
            self._log(f"    [exec] Running: {' '.join(cmd)}")

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=timeout,
                cwd=Path.cwd()  # Run in current directory
            )

            if result.returncode == 0:
                output = result.stdout.strip()
                self._log(f"    [success] {output}")
                return True, output
            else:
                error = result.stderr.strip() or "Command failed"
                self._log(f"    [error] {error}", error=True)
                return False, error

        except subprocess.TimeoutExpired:
            msg = f"Command timeout ({timeout}s)"
            self._log(f"    [timeout] {msg}", error=True)
            return False, msg

        except FileNotFoundError:
            msg = f"Command not found: {cmd[0]} - is spec-kit installed?"
            self._log(f"    [error] {msg}", error=True)
            return False, msg

        except Exception as e:
            msg = f"Unexpected error: {str(e)}"
            self._log(f"    [error] {msg}", error=True)
            return False, msg

    def _validate_tdd_gate(self) -> Tuple[bool, str]:
        """
        Post-tasks TDD gate: verify tasks.md contains test tasks
        that reference acceptance scenarios (US-S format).

        Returns:
            (success: bool, message: str)
        """
        tasks_path = Path.cwd() / "tasks.md"
        if not tasks_path.exists():
            return False, "tasks.md not found"

        content = tasks_path.read_text(encoding="utf-8")

        # Check for test task indicators
        has_test_tasks = any(
            marker in content
            for marker in ["TDD approach", "test for", "Test for", "contract test", "integration test", "unit test"]
        )
        has_scenario_refs = any(
            marker in content
            for marker in ["[US1-S", "[US2-S", "[US3-S", "[US1]", "[US2]", "[US3]"]
        )

        if not has_test_tasks:
            self._log(
                "  [TDD GATE] WARNING: tasks.md contains no test tasks. "
                "TDD requires tests BEFORE implementation. "
                "Re-run with test tasks or add them manually.",
                error=True
            )
            return False, "No test tasks found in tasks.md — TDD gate failed"

        if not has_scenario_refs:
            self._log(
                "  [TDD GATE] INFO: tasks.md has test tasks but no scenario "
                "references (US-S format). Consider linking tests to spec.md "
                "acceptance scenarios for traceability."
            )

        self._log("  [TDD GATE] PASS: test tasks found in tasks.md")
        return True, "TDD gate passed"

    def _validate_file_exists(self, filename: str) -> bool:
        """
        Check if file exists in current spec branch directory.

        Args:
            filename: Filename to check (e.g., "spec.md", "plan.md")

        Returns:
            True if file exists, False otherwise
        """
        file_path = Path.cwd() / filename
        exists = file_path.exists()

        if self.verbose:
            status = "exists" if exists else "missing"
            self._log(f"  [validate] {filename}: {status}")

        return exists

    def _log(self, message: str, error: bool = False):
        """
        Log progress message.

        Args:
            message: Message to log
            error: Whether this is an error message
        """
        if self.verbose or error:
            prefix = "[ERROR]" if error else "[INFO]"
            output = sys.stderr if error else sys.stdout
            print(f"{prefix} {message}", file=output)


def main():
    """CLI entry point for orchestrator."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Spec-kit sequential orchestrator - Automates specify -> plan -> tasks workflow",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Full pipeline (specify -> plan -> tasks)
  %(prog)s "Real-time chat with message history"

  # Partial pipeline (specify -> plan only)
  %(prog)s "API rate limiting" --mode specify-plan

  # Resume from plan phase
  %(prog)s "API rate limiting" --mode plan-tasks

  # Verbose output for debugging
  %(prog)s "Feature X" -v
"""
    )

    parser.add_argument(
        "description",
        help="Feature description (user prompt)"
    )

    parser.add_argument(
        "--mode",
        choices=["auto", "specify-plan", "plan-tasks"],
        default="auto",
        help="Pipeline mode (default: auto = full pipeline)"
    )

    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable verbose logging"
    )

    parser.add_argument(
        "--timeout",
        type=int,
        default=300,
        help="Command timeout in seconds (default: 300)"
    )

    args = parser.parse_args()

    # Run orchestrator
    orchestrator = SpecKitOrchestrator(verbose=args.verbose)
    success, message = orchestrator.run_pipeline(
        args.description,
        args.mode
    )

    # Print result
    if success:
        print(f"\n✅ SUCCESS: {message}")
        sys.exit(0)
    else:
        print(f"\n❌ FAILED: {message}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
