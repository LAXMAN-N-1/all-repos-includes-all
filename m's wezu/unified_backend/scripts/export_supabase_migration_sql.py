#!/usr/bin/env python3
from __future__ import annotations

import argparse
import ast
import re
import subprocess
import sys
from datetime import UTC, datetime
from pathlib import Path
from typing import Optional

from python_runtime import format_runtime_hint, select_python

ROOT = Path(__file__).resolve().parents[1]
ALEMBIC_VERSIONS_DIR = ROOT / "alembic" / "versions"
DEFAULT_OUTPUT_DIR = ROOT / "supabase" / "migrations"


def _slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "_", value.strip().lower())
    return slug.strip("_") or "migration"


def _extract_assignment(tree: ast.AST, name: str) -> Optional[ast.AST]:
    for node in getattr(tree, "body", []):
        if isinstance(node, ast.Assign):
            for target in node.targets:
                if isinstance(target, ast.Name) and target.id == name:
                    return node.value
        if isinstance(node, ast.AnnAssign):
            if isinstance(node.target, ast.Name) and node.target.id == name:
                return node.value
    return None


def _literal_to_revisions(value: Optional[ast.AST]) -> list[str]:
    if value is None:
        return []
    literal = ast.literal_eval(value)
    if literal is None:
        return []
    if isinstance(literal, str):
        return [literal]
    if isinstance(literal, (list, tuple, set)):
        revisions = [str(item) for item in literal if item]
        return revisions
    raise ValueError(f"Unsupported revision literal: {literal!r}")


def _load_revision_metadata() -> dict[str, dict[str, object]]:
    metadata: dict[str, dict[str, object]] = {}
    for path in sorted(ALEMBIC_VERSIONS_DIR.glob("*.py")):
        tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
        rev_value = _extract_assignment(tree, "revision")
        if rev_value is None:
            continue
        revision_values = _literal_to_revisions(rev_value)
        if len(revision_values) != 1:
            continue
        revision = revision_values[0]
        down_value = _extract_assignment(tree, "down_revision")
        down_revisions = _literal_to_revisions(down_value)
        metadata[revision] = {
            "path": path,
            "down_revisions": down_revisions,
        }
    return metadata


def _resolve_start_revision(
    *,
    end_revision: str,
    explicit_start: Optional[str],
    metadata: dict[str, dict[str, object]],
) -> str:
    if explicit_start:
        return explicit_start
    end_meta = metadata.get(end_revision)
    if not end_meta:
        raise ValueError(f"Unknown end revision: {end_revision}")
    down_revisions = list(end_meta["down_revisions"])  # type: ignore[arg-type]
    if not down_revisions:
        raise ValueError(
            f"Revision {end_revision} has no down_revision. "
            "Pass --start explicitly for base/full-chain export."
        )
    if len(down_revisions) > 1:
        raise ValueError(
            f"Revision {end_revision} has multiple down revisions {down_revisions}. "
            "Pass --start explicitly."
        )
    return down_revisions[0]


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Export an Alembic revision range to a Supabase SQL migration file.",
    )
    parser.add_argument(
        "--end",
        required=True,
        help="Target Alembic revision ID to export.",
    )
    parser.add_argument(
        "--start",
        help=(
            "Starting Alembic revision ID. "
            "If omitted, uses end revision's single down_revision."
        ),
    )
    parser.add_argument(
        "--name",
        required=True,
        help="Human-readable migration name for output file slug.",
    )
    parser.add_argument(
        "--output-dir",
        default=str(DEFAULT_OUTPUT_DIR),
        help="Output directory for generated Supabase SQL migration files.",
    )
    args = parser.parse_args()

    metadata = _load_revision_metadata()
    if args.end not in metadata:
        print(f"error: end revision {args.end!r} not found in alembic/versions", file=sys.stderr)
        return 1

    try:
        start_revision = _resolve_start_revision(
            end_revision=args.end,
            explicit_start=args.start,
            metadata=metadata,
        )
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    try:
        interpreter = select_python(required_module="alembic")
    except RuntimeError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    print(format_runtime_hint(interpreter), file=sys.stderr)

    command = [
        interpreter,
        "-c",
        (
            "from alembic.config import main as alembic_main;"
            "import sys;"
            "raise SystemExit(alembic_main(argv=sys.argv[1:]))"
        ),
        "upgrade",
        f"{start_revision}:{args.end}",
        "--sql",
    ]
    proc = subprocess.run(
        command,
        cwd=str(ROOT),
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        sys.stderr.write(proc.stderr)
        return proc.returncode

    output_dir = Path(args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now(UTC).strftime("%Y%m%d%H%M%S")
    filename = f"{timestamp}_{_slugify(args.name)}_{args.end}.sql"
    output_path = output_dir / filename

    header = (
        f"-- generated_at_utc: {datetime.now(UTC).isoformat()}\n"
        f"-- source_alembic_start: {start_revision}\n"
        f"-- source_alembic_end: {args.end}\n"
        f"-- source_command: {' '.join(command)}\n\n"
    )
    output_path.write_text(header + proc.stdout, encoding="utf-8")
    print(str(output_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
