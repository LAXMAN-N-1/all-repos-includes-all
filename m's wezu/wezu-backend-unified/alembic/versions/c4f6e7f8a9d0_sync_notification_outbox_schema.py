"""Sync notification_outbox schema drift missing columns

Revision ID: c4f6e7f8a9d0
Revises: b3e5d6f7a8c9
Create Date: 2026-04-20 03:49:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = "c4f6e7f8a9d0"
down_revision: Union[str, None] = "b3e5d6f7a8c9"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    op.execute("ALTER TABLE notification_outbox ADD COLUMN IF NOT EXISTS notification_id INTEGER")
    op.execute("ALTER TABLE notification_outbox ADD COLUMN IF NOT EXISTS channel VARCHAR")
    op.execute("ALTER TABLE notification_outbox ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE")
    op.execute("ALTER TABLE notification_outbox DROP CONSTRAINT IF EXISTS fk_notification_outbox_notification_id")
    op.execute("ALTER TABLE notification_outbox ADD CONSTRAINT fk_notification_outbox_notification_id FOREIGN KEY (notification_id) REFERENCES notifications(id)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_notification_outbox_notification_id ON notification_outbox (notification_id)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_notification_outbox_channel ON notification_outbox (channel)")
    op.execute("ALTER TABLE notification_outbox DROP COLUMN IF EXISTS title")
    op.execute("ALTER TABLE notification_outbox DROP COLUMN IF EXISTS body")
    op.execute("ALTER TABLE notification_outbox DROP COLUMN IF EXISTS sent_at")
    op.execute("ALTER TABLE notification_outbox DROP COLUMN IF EXISTS fcm_message_id")
    op.execute("ALTER TABLE notification_outbox DROP COLUMN IF EXISTS topic")

def downgrade() -> None:
    pass
