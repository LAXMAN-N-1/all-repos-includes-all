"""add partial composite index for order_realtime_outbox dispatch poller

Revision ID: d5e6f7a8b9c0
Revises: c4d5e6f7a8b9
Create Date: 2026-04-20 02:00:00.000000

The realtime outbox dispatcher (``app.services.order_realtime_outbox_service``)
polls this table on a loop with::

    WHERE status IN ('pending','failed')
      AND attempt_count < max_attempts
      AND coalesce(next_attempt_at, '1970-01-01') <= now
    ORDER BY created_at, id
    LIMIT N

Production slow-query log showed this at ~1.2s. The existing single-column
indexes on ``status`` / ``next_attempt_at`` / ``created_at`` force PG to
pick one and then sort the rest; the ``coalesce()`` wrapper defeats
``ix_next_attempt_at`` even when chosen.

Add a partial composite index that matches the hot path exactly:

    CREATE INDEX ... ON order_realtime_outbox (created_at, id)
        WHERE status IN ('pending','failed');

- Small footprint (pending/failed rows only, not the fully-processed
  majority).
- ORDER BY ``created_at, id`` uses the index directly — no sort needed.
- Values in the WHERE's ``status IN (...)`` match the partial predicate
  literally so the planner can narrow on index lookup.

Built ``CONCURRENTLY`` inside an ``autocommit_block`` so the DDL does not
take an ACCESS EXCLUSIVE lock on the live table — required because the
outbox dispatcher is active.
"""
from typing import Sequence, Union

from alembic import op


revision: str = "d5e6f7a8b9c0"
down_revision: Union[str, None] = "c4d5e6f7a8b9"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


INDEX_NAME = "ix_order_realtime_outbox_dispatch"


def upgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name != "postgresql":
        # SQLite doesn't support partial indexes with this syntax; dev DBs
        # won't have enough rows for it to matter either way.
        return

    # CONCURRENTLY requires the statement to run outside a transaction.
    with op.get_context().autocommit_block():
        op.execute(
            f"""
            CREATE INDEX CONCURRENTLY IF NOT EXISTS {INDEX_NAME}
            ON order_realtime_outbox (created_at, id)
            WHERE status IN ('pending', 'failed')
            """
        )


def downgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name != "postgresql":
        return
    with op.get_context().autocommit_block():
        op.execute(f"DROP INDEX CONCURRENTLY IF EXISTS {INDEX_NAME}")
