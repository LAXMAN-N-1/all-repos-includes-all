from __future__ import annotations

from pathlib import Path

import app.db.migration_graph_guard as guard


def _write_migration(path: Path, body: str) -> None:
    path.write_text(body.strip() + "\n", encoding="utf-8")


def test_parse_revision_file_supports_annotated_assignments(tmp_path: Path) -> None:
    migration = tmp_path / "a1b2_test.py"
    _write_migration(
        migration,
        """
        from typing import Sequence, Union

        revision: str = "a1b2"
        down_revision: Union[str, None] = ("prev1", "prev2")
        branch_labels: Union[str, Sequence[str], None] = None
        depends_on: Union[str, Sequence[str], None] = None
        """,
    )

    parsed = guard._parse_revision_file(migration)
    assert parsed is not None
    assert parsed.revision == "a1b2"
    assert parsed.down_revisions == ("prev1", "prev2")


def test_parse_revision_file_supports_plain_assignments(tmp_path: Path) -> None:
    migration = tmp_path / "c3d4_test.py"
    _write_migration(
        migration,
        """
        revision = "c3d4"
        down_revision = "prev3"
        branch_labels = None
        depends_on = None
        """,
    )

    parsed = guard._parse_revision_file(migration)
    assert parsed is not None
    assert parsed.revision == "c3d4"
    assert parsed.down_revisions == ("prev3",)


def test_validate_migration_graph_does_not_flag_annotated_files_unparseable(
    tmp_path: Path, monkeypatch
) -> None:
    _write_migration(
        tmp_path / "1111_root.py",
        """
        from typing import Union
        revision: str = "1111"
        down_revision: Union[str, None] = None
        """,
    )
    _write_migration(
        tmp_path / "2222_child.py",
        """
        revision = "2222"
        down_revision = "1111"
        """,
    )

    monkeypatch.setattr(guard, "_collect_db_revisions", lambda: tuple())

    report = guard.validate_migration_graph(
        versions_dir=tmp_path,
        require_single_head=True,
        require_db_at_head=False,
    )

    assert report.valid is True
    assert report.heads == ("2222",)
    assert not any("unparseable migration metadata" in issue for issue in report.issues)
