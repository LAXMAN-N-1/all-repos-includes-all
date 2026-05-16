"""added some fields in event table

Revision ID: 70ec2eee52e8
Revises: 549e7f2d2237
Create Date: 2025-12-15 12:42:52.363894
"""
from typing import Sequence, Union
from sqlalchemy import inspect

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '70ec2eee52e8'
down_revision: Union[str, None] = '549e7f2d2237'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)
    existing_columns = [c["name"] for c in inspector.get_columns("events")]

    # ---------- theme ----------
    if "theme" not in existing_columns:
        op.add_column(
            "events",
            sa.Column("theme", sa.String(length=100), nullable=True)
        )

    # ---------- required_services ----------
    if "required_services" not in existing_columns:
        op.add_column(
            "events",
            sa.Column("required_services", sa.JSON(), nullable=True)
        )

        op.execute(
            "UPDATE events SET required_services = JSON_ARRAY() "
            "WHERE required_services IS NULL"
        )

        op.alter_column(
            "events",
            "required_services",
            existing_type=sa.JSON(),
            nullable=False
        )

    # ---------- bidding_status (as simple string, no native ENUM) ----------
    if "bidding_status" not in existing_columns:
        op.add_column(
            "events",
            sa.Column(
                "bidding_status",
                sa.String(length=50),
                nullable=False,
                server_default="open"
            )
        )

    # ---------- other columns ----------
    for col_name, col in [
        ("bidding_deadline", sa.Column("bidding_deadline", sa.DateTime())),
        ("selected_vendor_id", sa.Column("selected_vendor_id", sa.Integer())),
        ("selected_bid_id", sa.Column("selected_bid_id", sa.Integer())),
        ("vendor_selected_at", sa.Column("vendor_selected_at", sa.DateTime())),
    ]:
        if col_name not in existing_columns:
            op.add_column("events", col)

    # ---------- foreign keys ----------
    existing_fks = [fk["name"] for fk in inspector.get_foreign_keys("events")]

    if "fk_events_selected_vendor" not in existing_fks:
        op.create_foreign_key(
            "fk_events_selected_vendor",
            "events",
            "vendors",
            ["selected_vendor_id"],
            ["id"],
        )

    if "fk_events_selected_bid" not in existing_fks:
        op.create_foreign_key(
            "fk_events_selected_bid",
            "events",
            "vendor_bids",
            ["selected_bid_id"],
            ["id"],
        )


def downgrade() -> None:
    op.drop_constraint('fk_events_selected_bid', 'events', type_='foreignkey')
    op.drop_constraint('fk_events_selected_vendor', 'events', type_='foreignkey')

    op.drop_column('events', 'vendor_selected_at')
    op.drop_column('events', 'selected_bid_id')
    op.drop_column('events', 'selected_vendor_id')
    op.drop_column('events', 'bidding_deadline')
    op.drop_column('events', 'bidding_status')
    op.drop_column('events', 'required_services')
    op.drop_column('events', 'theme')
