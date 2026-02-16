"""
Simplified unit tests for spec-kit orchestrator (without pytest-mock).
Tests validation logic using monkeypatch instead of mocker.
"""

import pytest
from pathlib import Path
import sys

# Add orchestrator to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / ".claude/skills/speckit-orchestrator"))

from orchestrator import SpecKitOrchestrator


class TestFileValidation:
    """Test file existence validation."""

    def test_validate_file_exists_when_file_present(self, tmp_path, monkeypatch):
        """File exists -> validation returns True."""
        monkeypatch.chdir(tmp_path)
        (tmp_path / "spec.md").touch()

        orchestrator = SpecKitOrchestrator()
        assert orchestrator._validate_file_exists("spec.md") is True

    def test_validate_file_exists_when_file_missing(self, tmp_path, monkeypatch):
        """File missing -> validation returns False."""
        monkeypatch.chdir(tmp_path)

        orchestrator = SpecKitOrchestrator()
        assert orchestrator._validate_file_exists("spec.md") is False

    def test_validate_file_exists_verbose_logging(self, tmp_path, monkeypatch, capsys):
        """Verbose mode -> logs validation status."""
        monkeypatch.chdir(tmp_path)
        (tmp_path / "plan.md").touch()

        orchestrator = SpecKitOrchestrator(verbose=True)
        orchestrator._validate_file_exists("plan.md")

        captured = capsys.readouterr()
        assert "[validate] plan.md: exists" in captured.out


class TestLogging:
    """Test logging behavior (verbose mode)."""

    def test_verbose_logging_enabled(self, capsys):
        """Verbose mode -> logs all messages."""
        orchestrator = SpecKitOrchestrator(verbose=True)

        orchestrator._log("Test message", error=False)

        captured = capsys.readouterr()
        assert "[INFO] Test message" in captured.out

    def test_error_logging_always_enabled(self, capsys):
        """Error messages -> always logged (even without verbose)."""
        orchestrator = SpecKitOrchestrator(verbose=False)

        orchestrator._log("Error message", error=True)

        captured = capsys.readouterr()
        assert "[ERROR] Error message" in captured.err

    def test_non_verbose_logging_disabled(self, capsys):
        """Non-verbose mode -> info messages not logged."""
        orchestrator = SpecKitOrchestrator(verbose=False)

        orchestrator._log("Info message", error=False)

        captured = capsys.readouterr()
        assert captured.out == ""


class TestPipelineBasics:
    """Test basic pipeline construction and modes."""

    def test_orchestrator_initialization(self):
        """Orchestrator initializes with correct defaults."""
        orchestrator = SpecKitOrchestrator()

        assert orchestrator.verbose is False
        assert orchestrator.current_phase is None

    def test_orchestrator_verbose_initialization(self):
        """Orchestrator can be initialized with verbose mode."""
        orchestrator = SpecKitOrchestrator(verbose=True)

        assert orchestrator.verbose is True

    def test_validate_multiple_files(self, tmp_path, monkeypatch):
        """Test validation of multiple files."""
        monkeypatch.chdir(tmp_path)

        # Create spec.md and plan.md
        (tmp_path / "spec.md").touch()
        (tmp_path / "plan.md").touch()

        orchestrator = SpecKitOrchestrator()

        assert orchestrator._validate_file_exists("spec.md") is True
        assert orchestrator._validate_file_exists("plan.md") is True
        assert orchestrator._validate_file_exists("tasks.md") is False


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
