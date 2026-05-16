"""add immutable order traceability tables

Revision ID: 2b7c4d1e9f0a
Revises: c1d2e3f4a5b6, c3d4e5f6g7h8
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision = "2b7c4d1e9f0a"
down_revision = ("c1d2e3f4a5b6", "c3d4e5f6g7h8")
branch_labels = None
depends_on = None


def upgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)

    if not inspector.has_table("order_legs"):
        op.create_table(
            "order_legs",
            sa.Column("id", sa.Integer(), nullable=False),
            sa.Column("order_id", sa.String(), nullable=False),
            sa.Column("tenant_id", sa.Integer(), nullable=True),
            sa.Column("leg_sequence", sa.Integer(), nullable=False, server_default="1"),
            sa.Column("leg_type", sa.String(), nullable=False, server_default="dispatch"),
            sa.Column("source_location_type", sa.String(), nullable=False),
            sa.Column("source_location_id", sa.Integer(), nullable=True),
            sa.Column("destination_location_type", sa.String(), nullable=False),
            sa.Column("destination_location_id", sa.Integer(), nullable=True),
            sa.Column("created_by", sa.Integer(), nullable=True),
            sa.Column("notes", sa.String(), nullable=True),
            sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("CURRENT_TIMESTAMP")),
            sa.ForeignKeyConstraint(["order_id"], ["logistics_orders.id"]),
            sa.ForeignKeyConstraint(["tenant_id"], ["tenants.id"]),
            sa.ForeignKeyConstraint(["created_by"], ["users.id"]),
            sa.PrimaryKeyConstraint("id"),
            sa.UniqueConstraint("order_id", "leg_sequence", name="uq_order_legs_order_sequence"),
        )

    if not inspector.has_table("order_leg_batteries"):
        op.create_table(
            "order_leg_batteries",
            sa.Column("id", sa.Integer(), nullable=False),
            sa.Column("order_leg_id", sa.Integer(), nullable=False),
            sa.Column("order_id", sa.String(), nullable=False),
            sa.Column("tenant_id", sa.Integer(), nullable=True),
            sa.Column("battery_id", sa.String(), nullable=False),
            sa.Column("battery_pk", sa.Integer(), nullable=True),
            sa.Column("recorded_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("CURRENT_TIMESTAMP")),
            sa.ForeignKeyConstraint(["order_leg_id"], ["order_legs.id"]),
            sa.ForeignKeyConstraint(["order_id"], ["logistics_orders.id"]),
            sa.ForeignKeyConstraint(["tenant_id"], ["tenants.id"]),
            sa.ForeignKeyConstraint(["battery_pk"], ["batteries.id"]),
            sa.PrimaryKeyConstraint("id"),
            sa.UniqueConstraint("order_leg_id", "battery_id", name="uq_order_leg_battery"),
        )

    if not inspector.has_table("order_leg_events"):
        op.create_table(
            "order_leg_events",
            sa.Column("id", sa.Integer(), nullable=False),
            sa.Column("order_leg_id", sa.Integer(), nullable=False),
            sa.Column("order_id", sa.String(), nullable=False),
            sa.Column("tenant_id", sa.Integer(), nullable=True),
            sa.Column("event_type", sa.String(), nullable=False),
            sa.Column("from_status", sa.String(), nullable=True),
            sa.Column("to_status", sa.String(), nullable=True),
            sa.Column("actor_id", sa.Integer(), nullable=True),
            sa.Column("proof_ref", sa.String(), nullable=True),
            sa.Column("metadata_json", sa.JSON(), nullable=True),
            sa.Column("occurred_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("CURRENT_TIMESTAMP")),
            sa.ForeignKeyConstraint(["order_leg_id"], ["order_legs.id"]),
            sa.ForeignKeyConstraint(["order_id"], ["logistics_orders.id"]),
            sa.ForeignKeyConstraint(["tenant_id"], ["tenants.id"]),
            sa.ForeignKeyConstraint(["actor_id"], ["users.id"]),
            sa.PrimaryKeyConstraint("id"),
        )

    op.create_index("ix_order_legs_order_id", "order_legs", ["order_id"], unique=False, if_not_exists=True)
    op.create_index("ix_order_legs_tenant_id", "order_legs", ["tenant_id"], unique=False, if_not_exists=True)
    op.create_index("ix_order_legs_leg_type", "order_legs", ["leg_type"], unique=False, if_not_exists=True)
    op.create_index("ix_order_legs_source_location_type", "order_legs", ["source_location_type"], unique=False, if_not_exists=True)
    op.create_index("ix_order_legs_source_location_id", "order_legs", ["source_location_id"], unique=False, if_not_exists=True)
    op.create_index("ix_order_legs_destination_location_type", "order_legs", ["destination_location_type"], unique=False, if_not_exists=True)
    op.create_index("ix_order_legs_destination_location_id", "order_legs", ["destination_location_id"], unique=False, if_not_exists=True)
    op.create_index("ix_order_legs_created_at", "order_legs", ["created_at"], unique=False, if_not_exists=True)

    op.create_index("ix_order_leg_batteries_order_leg_id", "order_leg_batteries", ["order_leg_id"], unique=False, if_not_exists=True)
    op.create_index("ix_order_leg_batteries_order_id", "order_leg_batteries", ["order_id"], unique=False, if_not_exists=True)
    op.create_index("ix_order_leg_batteries_tenant_id", "order_leg_batteries", ["tenant_id"], unique=False, if_not_exists=True)
    op.create_index("ix_order_leg_batteries_battery_id", "order_leg_batteries", ["battery_id"], unique=False, if_not_exists=True)
    op.create_index("ix_order_leg_batteries_battery_pk", "order_leg_batteries", ["battery_pk"], unique=False, if_not_exists=True)
    op.create_index("ix_order_leg_batteries_recorded_at", "order_leg_batteries", ["recorded_at"], unique=False, if_not_exists=True)

    op.create_index("ix_order_leg_events_order_leg_id", "order_leg_events", ["order_leg_id"], unique=False, if_not_exists=True)
    op.create_index("ix_order_leg_events_order_id", "order_leg_events", ["order_id"], unique=False, if_not_exists=True)
    op.create_index("ix_order_leg_events_tenant_id", "order_leg_events", ["tenant_id"], unique=False, if_not_exists=True)
    op.create_index("ix_order_leg_events_event_type", "order_leg_events", ["event_type"], unique=False, if_not_exists=True)
    op.create_index("ix_order_leg_events_from_status", "order_leg_events", ["from_status"], unique=False, if_not_exists=True)
    op.create_index("ix_order_leg_events_to_status", "order_leg_events", ["to_status"], unique=False, if_not_exists=True)
    op.create_index("ix_order_leg_events_actor_id", "order_leg_events", ["actor_id"], unique=False, if_not_exists=True)
    op.create_index("ix_order_leg_events_occurred_at", "order_leg_events", ["occurred_at"], unique=False, if_not_exists=True)


def downgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)

    for index_name, table_name in (
        ("ix_order_leg_events_occurred_at", "order_leg_events"),
        ("ix_order_leg_events_actor_id", "order_leg_events"),
        ("ix_order_leg_events_to_status", "order_leg_events"),
        ("ix_order_leg_events_from_status", "order_leg_events"),
        ("ix_order_leg_events_event_type", "order_leg_events"),
        ("ix_order_leg_events_tenant_id", "order_leg_events"),
        ("ix_order_leg_events_order_id", "order_leg_events"),
        ("ix_order_leg_events_order_leg_id", "order_leg_events"),
        ("ix_order_leg_batteries_recorded_at", "order_leg_batteries"),
        ("ix_order_leg_batteries_battery_pk", "order_leg_batteries"),
        ("ix_order_leg_batteries_battery_id", "order_leg_batteries"),
        ("ix_order_leg_batteries_tenant_id", "order_leg_batteries"),
        ("ix_order_leg_batteries_order_id", "order_leg_batteries"),
        ("ix_order_leg_batteries_order_leg_id", "order_leg_batteries"),
        ("ix_order_legs_created_at", "order_legs"),
        ("ix_order_legs_destination_location_id", "order_legs"),
        ("ix_order_legs_destination_location_type", "order_legs"),
        ("ix_order_legs_source_location_id", "order_legs"),
        ("ix_order_legs_source_location_type", "order_legs"),
        ("ix_order_legs_leg_type", "order_legs"),
        ("ix_order_legs_tenant_id", "order_legs"),
        ("ix_order_legs_order_id", "order_legs"),
    ):
        if inspector.has_table(table_name):
            existing = {idx["name"] for idx in inspector.get_indexes(table_name)}
            if index_name in existing:
                op.drop_index(index_name, table_name=table_name)

    if inspector.has_table("order_leg_events"):
        op.drop_table("order_leg_events")
    if inspector.has_table("order_leg_batteries"):
        op.drop_table("order_leg_batteries")
    if inspector.has_table("order_legs"):
        op.drop_table("order_legs")
