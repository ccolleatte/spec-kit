"""
Unit tests for spec-kit orchestrator.

Tests:
- File existence validation
- Pipeline execution (auto, specify-plan, plan-tasks modes)
- Dependency validation (fail-fast if files missing)
- Error handling (command not found, timeout, API errors)
"""

import pytest
from pathlib import Path
from unittest.mock import Mock, patch, call
import sys

# Add orchestrator to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / ".claude/skills/speckit-orchestrator"))

from orchestrator import SpecKitOrchestrator


class TestFileValidation:
    """Test file existence validation."""

    def test_validate_file_exists_when_file_present(self, tmp_path, monkeypatch):
        """File exists → validation returns True."""
        monkeypatch.chdir(tmp_path)
        (tmp_path / "spec.md").touch()

        orchestrator = SpecKitOrchestrator()
        assert orchestrator._validate_file_exists("spec.md") is True

    def test_validate_file_exists_when_file_missing(self, tmp_path, monkeypatch):
        """File missing → validation returns False."""
        monkeypatch.chdir(tmp_path)

        orchestrator = SpecKitOrchestrator()
        assert orchestrator._validate_file_exists("spec.md") is False

    def test_validate_file_exists_verbose_logging(self, tmp_path, monkeypatch, capsys):
        """Verbose mode → logs validation status."""
        monkeypatch.chdir(tmp_path)
        (tmp_path / "plan.md").touch()

        orchestrator = SpecKitOrchestrator(verbose=True)
        orchestrator._validate_file_exists("plan.md")

        captured = capsys.readouterr()
        assert "[validate] plan.md: exists" in captured.out


class TestPipelineExecution:
    """Test pipeline execution across different modes."""

    def test_run_pipeline_auto_mode_success(self, mocker):
        """Auto mode → all 3 phases execute sequentially."""
        orchestrator = SpecKitOrchestrator(verbose=True)

        # Mock phase executions (all succeed)
        mocker.patch.object(
            orchestrator,
            '_run_specify',
            return_value=(True, "spec.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_run_plan',
            return_value=(True, "plan.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_run_tasks',
            return_value=(True, "tasks.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_validate_file_exists',
            return_value=True
        )

        # Run pipeline
        success, message = orchestrator.run_pipeline(
            "Test feature",
            mode="auto"
        )

        # Verify
        assert success is True
        assert "specify → plan → tasks" in message
        assert orchestrator._run_specify.call_count == 1
        assert orchestrator._run_plan.call_count == 1
        assert orchestrator._run_tasks.call_count == 1

    def test_run_pipeline_specify_plan_mode(self, mocker):
        """Specify-plan mode → only 2 phases execute."""
        orchestrator = SpecKitOrchestrator()

        # Mock phase executions
        mocker.patch.object(
            orchestrator,
            '_run_specify',
            return_value=(True, "spec.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_run_plan',
            return_value=(True, "plan.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_run_tasks',
            return_value=(True, "tasks.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_validate_file_exists',
            return_value=True
        )

        # Run pipeline
        success, message = orchestrator.run_pipeline(
            "Test feature",
            mode="specify-plan"
        )

        # Verify
        assert success is True
        assert "specify → plan" in message
        assert orchestrator._run_specify.call_count == 1
        assert orchestrator._run_plan.call_count == 1
        assert orchestrator._run_tasks.call_count == 0  # Not executed

    def test_run_pipeline_plan_tasks_mode(self, mocker):
        """Plan-tasks mode → only 2 phases execute (skip specify)."""
        orchestrator = SpecKitOrchestrator()

        # Mock phase executions
        mocker.patch.object(
            orchestrator,
            '_run_specify',
            return_value=(True, "spec.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_run_plan',
            return_value=(True, "plan.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_run_tasks',
            return_value=(True, "tasks.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_validate_file_exists',
            return_value=True
        )

        # Run pipeline
        success, message = orchestrator.run_pipeline(
            "Test feature",
            mode="plan-tasks"
        )

        # Verify
        assert success is True
        assert "plan → tasks" in message
        assert orchestrator._run_specify.call_count == 0  # Not executed
        assert orchestrator._run_plan.call_count == 1
        assert orchestrator._run_tasks.call_count == 1


class TestDependencyValidation:
    """Test dependency validation (fail-fast)."""

    def test_run_pipeline_fails_when_spec_missing_for_plan(self, mocker):
        """Plan phase → fails if spec.md missing."""
        orchestrator = SpecKitOrchestrator()

        # Mock specify succeeds, but spec.md validation fails for plan
        mocker.patch.object(
            orchestrator,
            '_run_specify',
            return_value=(True, "spec.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_validate_file_exists',
            return_value=False  # spec.md missing
        )

        # Run pipeline
        success, message = orchestrator.run_pipeline(
            "Test feature",
            mode="auto"
        )

        # Verify
        assert success is False
        assert "plan" in message
        assert "spec.md not found" in message

    def test_run_pipeline_fails_when_plan_missing_for_tasks(self, mocker):
        """Tasks phase → fails if plan.md missing."""
        orchestrator = SpecKitOrchestrator()

        # Mock specify + plan succeed, but plan.md validation fails for tasks
        mocker.patch.object(
            orchestrator,
            '_run_specify',
            return_value=(True, "spec.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_run_plan',
            return_value=(True, "plan.md created")
        )

        # First validation (for plan) succeeds, second (for tasks) fails
        mocker.patch.object(
            orchestrator,
            '_validate_file_exists',
            side_effect=[True, False]  # spec.md exists, plan.md missing
        )

        # Run pipeline
        success, message = orchestrator.run_pipeline(
            "Test feature",
            mode="auto"
        )

        # Verify
        assert success is False
        assert "tasks" in message
        assert "plan.md not found" in message

    def test_run_pipeline_plan_tasks_fails_without_spec(self, mocker):
        """Plan-tasks mode → fails if spec.md doesn't exist."""
        orchestrator = SpecKitOrchestrator()

        # Mock validation: spec.md missing
        mocker.patch.object(
            orchestrator,
            '_validate_file_exists',
            return_value=False
        )

        # Run pipeline
        success, message = orchestrator.run_pipeline(
            "Test feature",
            mode="plan-tasks"
        )

        # Verify
        assert success is False
        assert "spec.md not found" in message


class TestErrorHandling:
    """Test error handling (API errors, timeouts, command not found)."""

    def test_run_pipeline_stops_at_phase_failure(self, mocker):
        """Pipeline stops when phase fails (fail-fast)."""
        orchestrator = SpecKitOrchestrator()

        # Mock specify success, plan failure
        mocker.patch.object(
            orchestrator,
            '_run_specify',
            return_value=(True, "spec.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_run_plan',
            return_value=(False, "API error: Rate limit exceeded")
        )
        mocker.patch.object(
            orchestrator,
            '_run_tasks',
            return_value=(True, "tasks.md created")
        )
        mocker.patch.object(
            orchestrator,
            '_validate_file_exists',
            return_value=True
        )

        # Run pipeline
        success, message = orchestrator.run_pipeline(
            "Test feature",
            mode="auto"
        )

        # Verify
        assert success is False
        assert "plan" in message
        assert "API error" in message
        assert orchestrator._run_tasks.call_count == 0  # Not executed (fail-fast)

    def test_execute_command_timeout(self, mocker):
        """Command timeout → returns failure."""
        import subprocess

        orchestrator = SpecKitOrchestrator()

        # Mock subprocess to raise TimeoutExpired
        mocker.patch(
            'subprocess.run',
            side_effect=subprocess.TimeoutExpired(cmd="specify", timeout=300)
        )

        # Execute command
        success, message = orchestrator._execute_command(
            ["specify", "init"],
            phase="specify",
            timeout=300
        )

        # Verify
        assert success is False
        assert "timeout" in message.lower()

    def test_execute_command_not_found(self, mocker):
        """Command not found → returns failure with helpful message."""
        orchestrator = SpecKitOrchestrator()

        # Mock subprocess to raise FileNotFoundError
        mocker.patch(
            'subprocess.run',
            side_effect=FileNotFoundError("specify not found")
        )

        # Execute command
        success, message = orchestrator._execute_command(
            ["specify", "init"],
            phase="specify"
        )

        # Verify
        assert success is False
        assert "Command not found" in message
        assert "spec-kit installed" in message

    def test_execute_command_success(self, mocker):
        """Command success → returns success with output."""
        orchestrator = SpecKitOrchestrator()

        # Mock subprocess to return success
        mock_result = Mock()
        mock_result.returncode = 0
        mock_result.stdout = "spec.md created successfully"
        mock_result.stderr = ""

        mocker.patch('subprocess.run', return_value=mock_result)

        # Execute command
        success, message = orchestrator._execute_command(
            ["specify", "init", ".", "Test feature"],
            phase="specify"
        )

        # Verify
        assert success is True
        assert "spec.md created" in message


class TestLogging:
    """Test logging behavior (verbose mode)."""

    def test_verbose_logging_enabled(self, capsys):
        """Verbose mode → logs all messages."""
        orchestrator = SpecKitOrchestrator(verbose=True)

        orchestrator._log("Test message", error=False)

        captured = capsys.readouterr()
        assert "[INFO] Test message" in captured.out

    def test_error_logging_always_enabled(self, capsys):
        """Error messages → always logged (even without verbose)."""
        orchestrator = SpecKitOrchestrator(verbose=False)

        orchestrator._log("Error message", error=True)

        captured = capsys.readouterr()
        assert "[ERROR] Error message" in captured.err

    def test_non_verbose_logging_disabled(self, capsys):
        """Non-verbose mode → info messages not logged."""
        orchestrator = SpecKitOrchestrator(verbose=False)

        orchestrator._log("Info message", error=False)

        captured = capsys.readouterr()
        assert captured.out == ""


# Pytest configuration
@pytest.fixture
def mock_subprocess_success(mocker):
    """Mock subprocess.run to return success."""
    mock_result = Mock()
    mock_result.returncode = 0
    mock_result.stdout = "Success"
    mock_result.stderr = ""
    return mocker.patch('subprocess.run', return_value=mock_result)


@pytest.fixture
def mock_subprocess_failure(mocker):
    """Mock subprocess.run to return failure."""
    mock_result = Mock()
    mock_result.returncode = 1
    mock_result.stdout = ""
    mock_result.stderr = "Command failed"
    return mocker.patch('subprocess.run', return_value=mock_result)
