"""Tests for Trivy workflow generation in specify init."""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "src"))
from specify_cli import generate_trivy_workflow


class TestGenerateTrivyWorkflow:

    def test_creates_workflow_file(self, tmp_path):
        generate_trivy_workflow(tmp_path)
        assert (tmp_path / ".github" / "workflows" / "trivy-security.yml").exists()

    def test_workflow_content_has_trivy_action(self, tmp_path):
        generate_trivy_workflow(tmp_path)
        content = (tmp_path / ".github" / "workflows" / "trivy-security.yml").read_text()
        assert "aquasecurity/trivy-action" in content

    def test_workflow_scans_on_push_and_pr(self, tmp_path):
        generate_trivy_workflow(tmp_path)
        content = (tmp_path / ".github" / "workflows" / "trivy-security.yml").read_text()
        assert "push:" in content
        assert "pull_request:" in content

    def test_creates_parent_dirs(self, tmp_path):
        assert not (tmp_path / ".github").exists()
        generate_trivy_workflow(tmp_path)
        assert (tmp_path / ".github" / "workflows").is_dir()

    def test_idempotent(self, tmp_path):
        generate_trivy_workflow(tmp_path)
        generate_trivy_workflow(tmp_path)  # no exception
