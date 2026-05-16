"""add order approval workflow fields

Revision ID: 3c8d1a2b4e7f
Revises: 2b7c4d1e9f0a
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision = "3c8d1a2b4e7f"
down_revision = "2b7c4d1e9f0a"
branch_labels = None
depends_on = None


def _column_names(inspector: inspect, table_name: str) -> set[str]:
    if not inspector.has_table(table_name):
        return set()
    return {column["name"] for column in inspector.get_columns(table_name)}


def _index_names(inspector: inspect, table_name: str) -> set[str]:
    if not inspector.has_table(table_name):
        return set()
    return {idx["name"] for idx in inspector.get_indexes(table_name)}


def upgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)

    table_name = "logistics_orders"
    if not inspector.has_table(table_name):
        return

    columns = _column_names(inspector, table_name)
    if "source_warehouse_id" not in columns:
        op.add_column(table_name, sa.Column("source_warehouse_id", sa.Integer(), nullable=True))
        op.create_foreign_key(
            "fk_logistics_orders_source_warehouse_id",
            table_name,
            "warehouses",
            ["source_warehouse_id"],
            ["id"],
        )
    if "created_by_user_id" not in columns:
        op.add_column(table_name, sa.Column("created_by_user_id", sa.Integer(), nullable=True))
        op.create_foreign_key(
            "fk_logistics_orders_created_by_user_id",
            table_name,
            "users",
            ["created_by_user_id"],
            ["id"],
        )
    if "created_by_role" not in columns:
        op.add_column(table_name, sa.Column("created_by_role", sa.String(), nullable=True))
    if "approval_status" not in columns:
        op.add_column(
            table_name,
            sa.Column(
                "approval_status",
                sa.String(),
                nullable=False,
                server_default="approved",
            ),
        )
    if "approved_by_user_id" not in columns:
        op.add_column(table_name, sa.Column("approved_by_user_id", sa.Integer(), nullable=True))
        op.create_foreign_key(
            "fk_logistics_orders_approved_by_user_id",
            table_name,
            "users",
            ["approved_by_user_id"],
            ["id"],
        )
    if "approved_at" not in columns:
        op.add_column(table_name, sa.Column("approved_at", sa.DateTime(timezone=True), nullable=True))
    if "approval_notes" not in columns:
        op.add_column(table_name, sa.Column("approval_notes", sa.String(), nullable=True))

    idx = _index_names(inspector, table_name)
    candidates = (
        ("ix_logistics_orders_source_warehouse_id", ["source_warehouse_id"]),
        ("ix_logistics_orders_created_by_user_id", ["created_by_user_id"]),
        ("ix_logistics_orders_created_by_role", ["created_by_role"]),
        ("ix_logistics_orders_approval_status", ["approval_status"]),
        ("ix_logistics_orders_approved_by_user_id", ["approved_by_user_id"]),
    )
    for index_name, columns in candidates:
        if index_name not in idx:
            op.create_index(index_name, table_name, columns, unique=False)


def downgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)

    table_name = "logistics_orders"
    if not inspector.has_table(table_name):
        return

    idx = _index_names(inspector, table_name)
    for index_name in (
        "ix_logistics_orders_approved_by_user_id",
        "ix_logistics_orders_approval_status",
        "ix_logistics_orders_created_by_role",
        "ix_logistics_orders_created_by_user_id",
        "ix_logistics_orders_source_warehouse_id",
    ):
        if index_name in idx:
            op.drop_index(index_name, table_name=table_name)

    columns = _column_names(inspector, table_name)
    if "approval_notes" in columns:
        op.drop_column(table_name, "approval_notes")
    if "approved_at" in columns:
        op.drop_column(table_name, "approved_at")
    if "approved_by_user_id" in columns:
        op.drop_constraint("fk_logistics_orders_approved_by_user_id", table_name, type_="foreignkey")
        op.drop_column(table_name, "approved_by_user_id")
    if "approval_status" in columns:
        op.drop_column(table_name, "approval_status")
    if "created_by_role" in columns:
        op.drop_column(table_name, "created_by_role")
    if "created_by_user_id" in columns:
        op.drop_constraint("fk_logistics_orders_created_by_user_id", table_name, type_="foreignkey")
        op.drop_column(table_name, "created_by_user_id")
    if "source_warehouse_id" in columns:
        op.drop_constraint("fk_logistics_orders_source_warehouse_id", table_name, type_="foreignkey")
        op.drop_column(table_name, "source_warehouse_id")
