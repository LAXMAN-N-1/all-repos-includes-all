"""
Schema silent-duplicate audit.

Finds five shapes of silent schema bugs without touching any data:

1. Same-table FK duplicates — two or more columns in one table that
   both FK the same parent (e.g. rentals.battery_id + rentals.batt_id
   both → batteries.id). Classic half-rename footprint.

2. Cross-model concept duplicates — two SQLModel classes whose
   column-name sets overlap heavily (Jaccard ≥ 0.7). Usually two PRs
   landing in parallel and never noticing each other.

3. Near-miss column names within one table — pairs of columns where
   one is a strict substring/prefix of the other, or Levenshtein
   distance ≤ 2, suggesting a botched rename.

4. Ghost columns — columns present in the live DB that no SQLModel
   declares. Previous raw-SQL migrations or hotfixes left them
   behind; they silently diverge because no code reads them.

5a. Undeclared-FK columns — columns named ``<known_table_singular>_id``
    that have no ForeignKey constraint. Nothing enforces referential
    integrity; orphan rows accumulate.

5b. Orphan-row counts — for each undeclared-FK column, count rows
    whose value is not present in the parent table (requires DB).

Usage
-----
    export DATABASE_URL=postgresql+psycopg2://user:pass@host:5432/db
    python3 scripts/schema_audit.py                 # full audit
    python3 scripts/schema_audit.py --database-url <URL>
    python3 scripts/schema_audit.py --no-db         # model-only passes
    python3 scripts/schema_audit.py --json          # machine-readable

Read-only. Safe to run against production. Does no writes, no DDL.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Any

# Ensure we can import the app package when run as a script.
_HERE = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.dirname(_HERE)
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)


@dataclass
class Finding:
    severity: str  # HIGH / MED / LOW
    shape: str     # which pass emitted it (1..5)
    table: str | None
    message: str
    detail: dict[str, Any] = field(default_factory=dict)


# ── Pass helpers ────────────────────────────────────────────────────────────

def _levenshtein(a: str, b: str) -> int:
    if a == b:
        return 0
    if not a:
        return len(b)
    if not b:
        return len(a)
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, 1):
        curr = [i]
        for j, cb in enumerate(b, 1):
            cost = 0 if ca == cb else 1
            curr.append(min(curr[-1] + 1, prev[j] + 1, prev[j - 1] + cost))
        prev = curr
    return prev[-1]


def _fk_target(col) -> tuple[str, str] | None:
    """Return (table, column) the column points to, or None."""
    for fk in col.foreign_keys:
        target = fk.column
        if target is not None and target.table is not None:
            return (target.table.name, target.name)
    return None


def _singularize(name: str) -> str:
    """Rough plural→singular for table names used to match FK columns."""
    if name.endswith("ies") and len(name) > 3:
        return name[:-3] + "y"
    if name.endswith("ses") and len(name) > 3:
        return name[:-2]  # statuses → status
    if name.endswith("s") and not name.endswith("ss") and len(name) > 1:
        return name[:-1]
    return name


def _stem(name: str) -> str:
    if name.endswith("_id"):
        return name[:-3]
    if name.endswith("_at"):
        return name[:-3]
    if name.endswith("_date"):
        return name[:-5]
    return name


def _similar_name_pair(a: str, b: str) -> bool:
    sa = _stem(a)
    sb = _stem(b)
    if sa == sb:
        return True
    if min(len(sa), len(sb)) < 4:
        return False
    if sa in sb or sb in sa:
        return True
    return _levenshtein(sa, sb) <= 2


# ── Passes ──────────────────────────────────────────────────────────────────

def pass_1_same_table_fk_duplicates(metadata) -> list[Finding]:
    findings: list[Finding] = []
    for table in metadata.tables.values():
        buckets: dict[tuple[str, str], list[str]] = defaultdict(list)
        for col in table.columns:
            tgt = _fk_target(col)
            if tgt:
                buckets[tgt].append(col.name)
        for tgt, cols in buckets.items():
            if len(cols) > 1:
                suspicious_pairs: list[list[str]] = []
                for i in range(len(cols)):
                    for j in range(i + 1, len(cols)):
                        if _similar_name_pair(cols[i], cols[j]):
                            suspicious_pairs.append(sorted([cols[i], cols[j]]))
                if not suspicious_pairs:
                    continue
                findings.append(Finding(
                    severity="HIGH",
                    shape="1",
                    table=table.name,
                    message=(
                        f"{table.name}: columns {sorted(cols)} all FK → "
                        f"{tgt[0]}.{tgt[1]} — suspected half-rename"
                    ),
                    detail={
                        "columns": sorted(cols),
                        "target": f"{tgt[0]}.{tgt[1]}",
                        "suspicious_pairs": suspicious_pairs,
                    },
                ))
    return findings


def pass_2_concept_duplicates(metadata, min_jaccard: float = 0.70) -> list[Finding]:
    findings: list[Finding] = []
    tables = list(metadata.tables.values())
    # Skip tiny tables (≤2 cols) — they match everything by accident.
    col_sets = {t.name: {c.name for c in t.columns} for t in tables if len(t.columns) > 2}
    names = sorted(col_sets)
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            a, b = names[i], names[j]
            sa, sb = col_sets[a], col_sets[b]
            inter = len(sa & sb)
            union = len(sa | sb)
            if union == 0:
                continue
            jacc = inter / union
            if jacc >= min_jaccard:
                findings.append(Finding(
                    severity="MED",
                    shape="2",
                    table=None,
                    message=(
                        f"tables {a!r} and {b!r} share {jacc:.0%} of columns "
                        f"({inter} of {union}) — suspected concept duplicate"
                    ),
                    detail={
                        "tables": [a, b],
                        "jaccard": round(jacc, 2),
                        "shared_columns": sorted(sa & sb),
                    },
                ))
    return findings


def pass_3_near_miss_columns(metadata) -> list[Finding]:
    findings: list[Finding] = []
    # Columns that legitimately come in pairs — don't flag them.
    legitimate_pairs = {
        ("from_location_id", "to_location_id"),
        ("start_time", "end_time"),
        ("start_date", "end_date"),
        ("valid_from", "valid_until"),
        ("effective_from", "effective_until"),
        ("created_at", "updated_at"),
        ("lower_bound", "upper_bound"),
        ("min_volume", "max_volume"),
        ("pickup_address", "dropoff_address"),
    }
    for table in metadata.tables.values():
        cols = [c.name for c in table.columns]
        for i in range(len(cols)):
            for j in range(i + 1, len(cols)):
                a, b = cols[i], cols[j]
                pair = tuple(sorted((a, b)))
                if pair in legitimate_pairs:
                    continue
                suffixes = ("_id", "_at", "_date")
                suffix_a = next((s for s in suffixes if a.endswith(s)), None)
                suffix_b = next((s for s in suffixes if b.endswith(s)), None)
                # Strict prefix/substring relationship where both columns share
                # the same suffix class (to avoid generic id vs *_id noise).
                if (
                    a != b
                    and suffix_a is not None
                    and suffix_a == suffix_b
                ):
                    shorter, longer = sorted((a, b), key=len)
                    shorter_stem = shorter[: -len(suffix_a)]
                    if len(shorter_stem) >= 4 and shorter_stem in longer:
                        findings.append(Finding(
                            severity="HIGH",
                            shape="3",
                            table=table.name,
                            message=f"{table.name}: columns {a!r} and {b!r} — one is a substring of the other",
                            detail={"columns": [a, b]},
                        ))
                        continue
                # Levenshtein ≤ 2 on stems, but only when suffix class matches.
                if (
                    suffix_a is not None
                    and suffix_a == suffix_b
                    and abs(len(a) - len(b)) <= 3
                ):
                    stem_a = a[: -len(suffix_a)]
                    stem_b = b[: -len(suffix_b)]
                    if min(len(stem_a), len(stem_b)) >= 4 and _levenshtein(stem_a, stem_b) <= 2:
                        findings.append(Finding(
                            severity="MED",
                            shape="3",
                            table=table.name,
                            message=f"{table.name}: columns {a!r} and {b!r} differ by ≤2 chars",
                            detail={"columns": [a, b]},
                        ))
                        continue
                # Detect compact typo-like variants in same prefix family:
                # battery_id vs batt_id, delivery_order_id vs order_id.
                if suffix_a == "_id" and suffix_b == "_id":
                    stem_a = a[:-3]
                    stem_b = b[:-3]
                    if (
                        min(len(stem_a), len(stem_b)) >= 4
                        and (stem_a in stem_b or stem_b in stem_a)
                        and not re.fullmatch(r".*_\d+", stem_a)
                        and not re.fullmatch(r".*_\d+", stem_b)
                    ):
                        findings.append(Finding(
                            severity="HIGH",
                            shape="3",
                            table=table.name,
                            message=f"{table.name}: columns {a!r} and {b!r} — one is a substring of the other",
                            detail={"columns": [a, b]},
                        ))
                        continue
    return findings


def pass_4_ghost_columns(metadata, inspector) -> list[Finding]:
    findings: list[Finding] = []
    db_tables = set(inspector.get_table_names())
    for table_name in sorted(db_tables):
        if table_name not in metadata.tables:
            continue  # drift detector already handles missing-model side
        db_cols = {c["name"] for c in inspector.get_columns(table_name)}
        model_cols = {c.name for c in metadata.tables[table_name].columns}
        ghosts = db_cols - model_cols
        if ghosts:
            findings.append(Finding(
                severity="MED",
                shape="4",
                table=table_name,
                message=(
                    f"{table_name}: {len(ghosts)} column(s) in DB but no model "
                    f"declares them — {sorted(ghosts)}"
                ),
                detail={"ghost_columns": sorted(ghosts)},
            ))
    return findings


def pass_5a_undeclared_fks(metadata) -> list[Finding]:
    findings: list[Finding] = []
    singular_to_table = {_singularize(t): t for t in metadata.tables}
    for table in metadata.tables.values():
        for col in table.columns:
            name = col.name
            if not name.endswith("_id") or name == "id":
                continue
            if col.foreign_keys:
                continue  # already declared
            stem = name[:-3]  # "battery" from "battery_id"
            if stem in singular_to_table:
                target = singular_to_table[stem]
                if target == table.name:
                    continue  # self-reference, probably parent_id-style
                findings.append(Finding(
                    severity="MED",
                    shape="5a",
                    table=table.name,
                    message=(
                        f"{table.name}.{name}: looks like FK → {target}.id "
                        f"but no ForeignKey declared"
                    ),
                    detail={"column": name, "implied_target": f"{target}.id"},
                ))
    return findings


def pass_5b_orphan_rows(findings_5a: list[Finding], conn) -> list[Finding]:
    """For each undeclared-FK finding, count orphan rows."""
    from sqlalchemy import text
    out: list[Finding] = []
    for f in findings_5a:
        table = f.table
        col = f.detail["column"]
        target_table = f.detail["implied_target"].split(".")[0]
        try:
            q = text(
                f'SELECT COUNT(*) FROM "{table}" c '
                f'WHERE c."{col}" IS NOT NULL '
                f'  AND NOT EXISTS ('
                f'    SELECT 1 FROM "{target_table}" p '
                f'    WHERE CAST(p.id AS TEXT) = CAST(c."{col}" AS TEXT)'
                f'  )'
            )
            orphan_count = conn.execute(q).scalar() or 0
        except Exception as exc:
            # Keep subsequent checks running even if one table/column pair fails.
            try:
                conn.rollback()
            except Exception:
                pass
            out.append(Finding(
                severity="LOW",
                shape="5b",
                table=table,
                message=f"{table}.{col}: orphan check skipped ({exc.__class__.__name__})",
                detail={"error": str(exc)[:200]},
            ))
            continue
        if orphan_count > 0:
            out.append(Finding(
                severity="HIGH",
                shape="5b",
                table=table,
                message=(
                    f"{table}.{col}: {orphan_count} row(s) have values not "
                    f"present in {target_table}.id — orphan data"
                ),
                detail={"column": col, "orphan_count": int(orphan_count)},
            ))
    return out


# ── Driver ──────────────────────────────────────────────────────────────────

def _prepare_runtime_env(database_url: str | None) -> None:
    """
    Prepare minimal env so app.core.config.settings can be constructed in a
    standalone script context.
    """
    if database_url:
        os.environ["DATABASE_URL"] = database_url.strip()
    # settings requires these fields even though schema_audit does not use them.
    os.environ.setdefault("REDIS_URL", "redis://localhost:6379/0")
    os.environ.setdefault("SECRET_KEY", "schema-audit-runtime-secret")


def run_audit(use_db: bool = True, database_url: str | None = None) -> list[Finding]:
    import app.models.all  # noqa: F401  register every SQLModel
    from sqlmodel import SQLModel

    metadata = SQLModel.metadata
    findings: list[Finding] = []

    findings += pass_1_same_table_fk_duplicates(metadata)
    findings += pass_2_concept_duplicates(metadata)
    findings += pass_3_near_miss_columns(metadata)
    findings_5a = pass_5a_undeclared_fks(metadata)
    findings += findings_5a

    if use_db:
        _prepare_runtime_env(database_url)
        from app.core.config import settings
        from sqlalchemy import inspect
        from app.core.database import engine

        if not (settings.DATABASE_URL or "").strip():
            raise RuntimeError(
                "DATABASE_URL is not set. Pass --database-url or export DATABASE_URL."
            )

        inspector = inspect(engine)
        findings += pass_4_ghost_columns(metadata, inspector)
        with engine.connect() as conn:
            findings += pass_5b_orphan_rows(findings_5a, conn)

    severity_order = {"HIGH": 0, "MED": 1, "LOW": 2}
    findings.sort(key=lambda f: (severity_order.get(f.severity, 9), f.shape, f.table or ""))
    return findings


def format_text(findings: list[Finding]) -> str:
    if not findings:
        return "SCHEMA AUDIT: clean — no silent duplicates detected.\n"
    lines = [f"SCHEMA AUDIT: {len(findings)} finding(s)\n" + "=" * 72]
    for f in findings:
        lines.append(f"[{f.severity:<4}] shape {f.shape}  {f.message}")
    # Bucket summary
    by_sev: dict[str, int] = defaultdict(int)
    by_shape: dict[str, int] = defaultdict(int)
    for f in findings:
        by_sev[f.severity] += 1
        by_shape[f.shape] += 1
    lines.append("=" * 72)
    lines.append(
        "Summary: " + ", ".join(f"{k}={v}" for k, v in sorted(by_sev.items()))
        + " | by shape: " + ", ".join(f"{k}={v}" for k, v in sorted(by_shape.items()))
    )
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--database-url",
        dest="database_url",
        help="Override DATABASE_URL for this run (uses settings.DATABASE_URL internally).",
    )
    parser.add_argument("--no-db", action="store_true",
                        help="Skip DB-backed passes (ghost columns, orphan rows).")
    parser.add_argument("--json", action="store_true",
                        help="Emit JSON instead of text.")
    parser.add_argument("--fail-on-high", action="store_true",
                        help="Exit non-zero if any HIGH findings exist.")
    args = parser.parse_args()

    findings = run_audit(use_db=not args.no_db, database_url=args.database_url)

    if args.json:
        print(json.dumps([
            {
                "severity": f.severity,
                "shape": f.shape,
                "table": f.table,
                "message": f.message,
                "detail": f.detail,
            }
            for f in findings
        ], indent=2, default=str))
    else:
        print(format_text(findings))

    if args.fail_on_high and any(f.severity == "HIGH" for f in findings):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
