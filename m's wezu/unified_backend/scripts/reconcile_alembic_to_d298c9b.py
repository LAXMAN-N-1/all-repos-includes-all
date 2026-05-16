#!/usr/bin/env python3
from __future__ import annotations

import argparse
from sqlalchemy import create_engine, inspect, text

from app.core.config import settings


TARGET_REVISION = "c4f6e7f8a9d0"  # baseline head
CURRENT_HEAD_REVISION = "d1e2f3a4b5c7"
LEGACY_REVISION = "e6f7a8b9c0d1"  # removed timezone patch revision


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Legacy one-off alembic_version reconciler. "
            "Safe mode is default; destructive rewrites require --force."
        )
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Allow destructive rewrite of alembic_version.",
    )
    args = parser.parse_args()

    engine = create_engine(str(settings.DATABASE_URL))

    with engine.begin() as conn:
        inspector = inspect(conn)
        if not inspector.has_table("alembic_version"):
            print(
                "alembic_version table not found. "
                "Assuming fresh database; no reconcile action performed."
            )
            return 0

        rows = conn.execute(text("SELECT version_num FROM alembic_version")).fetchall()
        revisions = sorted({str(r[0]).strip() for r in rows if r and r[0]})
        print(f"current revisions: {revisions or ['<empty>']}")

        if revisions == [TARGET_REVISION]:
            print(f"already aligned to baseline head ({TARGET_REVISION})")
            return 0

        if revisions == [CURRENT_HEAD_REVISION]:
            print(f"already aligned to current head ({CURRENT_HEAD_REVISION})")
            return 0

        if not args.force:
            print(
                "reconcile required but --force was not provided. "
                "No changes made."
            )
            return 1

        if LEGACY_REVISION in revisions:
            print(
                f"found legacy revision {LEGACY_REVISION}; "
                f"realigning to baseline head {TARGET_REVISION}"
            )
        else:
            print(f"realigning alembic_version to {TARGET_REVISION}")

        conn.execute(text("DELETE FROM alembic_version"))
        conn.execute(
            text("INSERT INTO alembic_version (version_num) VALUES (:revision)"),
            {"revision": TARGET_REVISION},
        )

    with engine.begin() as verify_conn:
        rows = verify_conn.execute(text("SELECT version_num FROM alembic_version")).fetchall()
        after = sorted({str(r[0]).strip() for r in rows if r and r[0]})
        print(f"updated revisions: {after}")
        if after != [TARGET_REVISION]:
            print("failed to align alembic_version")
            return 1

    print("migration state repaired successfully")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
