"""add order_realtime_outbox fields

Revision ID: 0ccc880381a2
Revises: 8df773d90265
Create Date: 2026-04-15 21:17:39.213166

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '0ccc880381a2'
down_revision: Union[str, None] = '8df773d90265'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("order_realtime_outbox", sa.Column("status", sa.String(), server_default="pending", nullable=False))
    op.create_index(op.f("ix_order_realtime_outbox_status"), "order_realtime_outbox", ["status"], unique=False)
    
    op.add_column("order_realtime_outbox", sa.Column("attempt_count", sa.Integer(), server_default="0", nullable=False))
    op.add_column("order_realtime_outbox", sa.Column("max_attempts", sa.Integer(), server_default="10", nullable=False))
    op.add_column("order_realtime_outbox", sa.Column("last_error", sa.String(), nullable=True))
    
    op.add_column("order_realtime_outbox", sa.Column("idempotency_key", sa.String(), nullable=True))
    op.create_index(op.f("ix_order_realtime_outbox_idempotency_key"), "order_realtime_outbox", ["idempotency_key"], unique=False)
    
    op.add_column("order_realtime_outbox", sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False))
    
    op.add_column("order_realtime_outbox", sa.Column("next_attempt_at", sa.DateTime(timezone=True), nullable=True))
    op.create_index(op.f("ix_order_realtime_outbox_next_attempt_at"), "order_realtime_outbox", ["next_attempt_at"], unique=False)

def downgrade() -> None:
    op.drop_index(op.f("ix_order_realtime_outbox_next_attempt_at"), table_name="order_realtime_outbox")
    op.drop_column("order_realtime_outbox", "next_attempt_at")
    
    op.drop_column("order_realtime_outbox", "updated_at")
    
    op.drop_index(op.f("ix_order_realtime_outbox_idempotency_key"), table_name="order_realtime_outbox")
    op.drop_column("order_realtime_outbox", "idempotency_key")
    
    op.drop_column("order_realtime_outbox", "last_error")
    op.drop_column("order_realtime_outbox", "max_attempts")
    op.drop_column("order_realtime_outbox", "attempt_count")
    
    op.drop_index(op.f("ix_order_realtime_outbox_status"), table_name="order_realtime_outbox")
    op.drop_column("order_realtime_outbox", "status")
