"""
Unit tests for .vscode/settings.json merge handling (specify_cli).

Covers:
- Deep merge behavior of merge_json_files (regression guard)
- Invalid existing JSON: visible warning without verbose + .bak backup
- Exception fallback in handle_vscode_settings: visible warning + .bak backup
"""

import json
import sys

from pathlib import Path


# Add CLI source to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "src"))

from specify_cli import handle_vscode_settings, merge_json_files


class TestMergeJsonFiles:
    """Test merge_json_files deep merge and invalid-JSON handling."""

    def test_deep_merge_adds_keys_merges_nested_replaces_lists(self, tmp_path):
        """Valid merge: new keys added, nested dicts merged, lists replaced."""
        existing = tmp_path / "settings.json"
        existing.write_text(
            json.dumps({"a": 1, "nested": {"x": 1, "keep": True}, "list": [1, 2]}),
            encoding="utf-8",
        )

        merged = merge_json_files(existing, {"b": 2, "nested": {"y": 2}, "list": [3]})

        assert merged == {
            "a": 1,
            "b": 2,
            "nested": {"x": 1, "y": 2, "keep": True},
            "list": [3],
        }

    def test_invalid_existing_json_warns_visibly_without_verbose(self, tmp_path, capsys):
        """Invalid existing JSON → new content returned + warning even with verbose=False."""
        existing = tmp_path / "settings.json"
        existing.write_text("{ not valid json", encoding="utf-8")
        new_content = {"fresh": True}

        result = merge_json_files(existing, new_content, verbose=False)

        assert result == new_content
        out = capsys.readouterr().out
        assert "Warning" in out


class TestHandleVscodeSettings:
    """Test handle_vscode_settings backup and warning behavior."""

    def _make_paths(self, tmp_path):
        vscode_dir = tmp_path / ".vscode"
        vscode_dir.mkdir()
        dest_file = vscode_dir / "settings.json"
        sub_item = tmp_path / "template-settings.json"
        return sub_item, dest_file

    def test_valid_merge_writes_merged_content_and_bak(self, tmp_path):
        """Existing valid settings → merged output written + .bak preserves original."""
        sub_item, dest_file = self._make_paths(tmp_path)
        original = {"user": {"keep": 1}, "shared": "old"}
        dest_file.write_text(json.dumps(original), encoding="utf-8")
        sub_item.write_text(json.dumps({"shared": "new", "added": 2}), encoding="utf-8")

        handle_vscode_settings(sub_item, dest_file, ".vscode/settings.json")

        written = json.loads(dest_file.read_text(encoding="utf-8"))
        assert written == {"user": {"keep": 1}, "shared": "new", "added": 2}
        bak = dest_file.with_suffix(".json.bak")
        assert bak.exists()
        assert json.loads(bak.read_text(encoding="utf-8")) == original

    def test_invalid_existing_json_warns_and_backs_up_under_tracker(self, tmp_path, capsys):
        """Corrupt existing settings → replaced, but warning visible under tracker + .bak kept."""
        sub_item, dest_file = self._make_paths(tmp_path)
        dest_file.write_text("{ corrupt", encoding="utf-8")
        sub_item.write_text(json.dumps({"fresh": True}), encoding="utf-8")

        # tracker active + verbose=False = the silent-by-default mode of `specify init`
        handle_vscode_settings(
            sub_item, dest_file, ".vscode/settings.json", verbose=False, tracker=object()
        )

        assert json.loads(dest_file.read_text(encoding="utf-8")) == {"fresh": True}
        bak = dest_file.with_suffix(".json.bak")
        assert bak.exists()
        assert bak.read_text(encoding="utf-8") == "{ corrupt"
        out = capsys.readouterr().out
        assert "Warning" in out

    def test_exception_fallback_copies_with_bak_and_warning(self, tmp_path, capsys):
        """Unparseable template settings → fallback copy + .bak of original + visible warning."""
        sub_item, dest_file = self._make_paths(tmp_path)
        original = json.dumps({"user": "config"})
        dest_file.write_text(original, encoding="utf-8")
        sub_item.write_text("not json at all", encoding="utf-8")

        handle_vscode_settings(
            sub_item, dest_file, ".vscode/settings.json", verbose=False, tracker=object()
        )

        # Fallback = raw copy of the template file
        assert dest_file.read_text(encoding="utf-8") == "not json at all"
        bak = dest_file.with_suffix(".json.bak")
        assert bak.exists()
        assert bak.read_text(encoding="utf-8") == original
        out = capsys.readouterr().out
        assert "Warning" in out

    def test_no_existing_dest_copies_without_bak(self, tmp_path):
        """No existing settings → plain copy, no .bak created."""
        sub_item, dest_file = self._make_paths(tmp_path)
        sub_item.write_text(json.dumps({"fresh": True}), encoding="utf-8")

        handle_vscode_settings(sub_item, dest_file, ".vscode/settings.json")

        assert json.loads(dest_file.read_text(encoding="utf-8")) == {"fresh": True}
        assert not dest_file.with_suffix(".json.bak").exists()
