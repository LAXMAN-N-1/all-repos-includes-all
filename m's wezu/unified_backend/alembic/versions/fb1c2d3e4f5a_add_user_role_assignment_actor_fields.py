"""add assignment actor fields to user_roles

Revision ID: fb1c2d3e4f5a
Revises: fa9b8c7d6e5f
Create Date: 2026-04-22 10:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
from alembic import context
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "fb1c2d3e4f5a"
down_revision: Union[str, Sequence[str], None] = "fa9b8c7d6e5f"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _has_column(inspector: sa.Inspector, table_name: str, column_name: str) -> bool:
    return any(col.get("name") == column_name for col in inspector.get_columns(table_name))


def _has_fk(inspector: sa.Inspector, table_name: str, constrained_columns: list[str], referred_table: str) -> bool:
    for fk in inspector.get_foreign_keys(table_name):
        if fk.get("referred_table") != referred_table:
            continue
        cols = fk.get("constrained_columns") or []
        if cols == constrained_columns:
            return True
    return False


def upgrade() -> None:
    if context.is_offline_mode():
        op.execute("ALTER TABLE user_roles ADD COLUMN IF NOT EXISTS assigned_by_user_id INTEGER")
        op.execute("ALTER TABLE user_roles ADD COLUMN IF NOT EXISTS assigned_by_subject VARCHAR(255)")
        op.execute(
            """
            DO $$
            BEGIN
              IF NOT EXISTS (
                SELECT 1
                FROM pg_constraint
                WHERE conname = 'fk_user_roles_assigned_by_user_id_users'
              ) THEN
                ALTER TABLE user_roles
                ADD CONSTRAINT fk_user_roles_assigned_by_user_id_users
                FOREIGN KEY (assigned_by_user_id) REFERENCES users(id);
              END IF;
            END
            $$;
            """
        )
        op.execute(
            "CREATE INDEX IF NOT EXISTS ix_user_roles_assigned_by_user_id ON user_roles (assigned_by_user_id)"
        )
        op.execute(
            "CREATE INDEX IF NOT EXISTS ix_user_roles_assigned_by_subject ON user_roles (assigned_by_subject)"
        )
        op.execute(
            """
            UPDATE user_roles ur
            SET assigned_by_user_id = u.id
            FROM admin_users au
            JOIN users u ON lower(u.email) = lower(au.email)
            WHERE ur.assigned_by = au.id
              AND ur.assigned_by_user_id IS NULL
            """
        )
        return

    conn = op.get_bind()
    inspector = sa.inspect(conn)
    dialect = conn.dialect.name

    if not _has_column(inspector, "user_roles", "assigned_by_user_id"):
        op.add_column("user_roles", sa.Column("assigned_by_user_id", sa.Integer(), nullable=True))

    if not _has_column(inspector, "user_roles", "assigned_by_subject"):
        op.add_column("user_roles", sa.Column("assigned_by_subject", sa.String(length=255), nullable=True))

    if dialect != "sqlite" and not _has_fk(inspector, "user_roles", ["assigned_by_user_id"], "users"):
        op.create_foreign_key(
            "fk_user_roles_assigned_by_user_id_users",
            "user_roles",
            "users",
            ["assigned_by_user_id"],
            ["id"],
        )

    op.execute(
        "CREATE INDEX IF NOT EXISTS ix_user_roles_assigned_by_user_id ON user_roles (assigned_by_user_id)"
    )
    op.execute(
        "CREATE INDEX IF NOT EXISTS ix_user_roles_assigned_by_subject ON user_roles (assigned_by_subject)"
    )

    if dialect == "postgresql":
        op.execute(
            """
            UPDATE user_roles ur
            SET assigned_by_user_id = u.id
            FROM admin_users au
            JOIN users u ON lower(u.email) = lower(au.email)
            WHERE ur.assigned_by = au.id
              AND ur.assigned_by_user_id IS NULL
            """
        )


def downgrade() -> None:
    if context.is_offline_mode():
        op.execute("DROP INDEX IF EXISTS ix_user_roles_assigned_by_subject")
        op.execute("DROP INDEX IF EXISTS ix_user_roles_assigned_by_user_id")
        op.execute(
            """
            DO $$
            BEGIN
              IF EXISTS (
                SELECT 1
                FROM pg_constraint
                WHERE conname = 'fk_user_roles_assigned_by_user_id_users'
              ) THEN
                ALTER TABLE user_roles
                DROP CONSTRAINT fk_user_roles_assigned_by_user_id_users;
              END IF;
            END
            $$;
            """
        )
        op.execute("ALTER TABLE user_roles DROP COLUMN IF EXISTS assigned_by_subject")
        op.execute("ALTER TABLE user_roles DROP COLUMN IF EXISTS assigned_by_user_id")
        return

    conn = op.get_bind()
    inspector = sa.inspect(conn)
    dialect = conn.dialect.name

    op.execute("DROP INDEX IF EXISTS ix_user_roles_assigned_by_subject")
    op.execute("DROP INDEX IF EXISTS ix_user_roles_assigned_by_user_id")

    if dialect != "sqlite":
        fk_names = {
            fk.get("name")
            for fk in inspector.get_foreign_keys("user_roles")
            if fk.get("referred_table") == "users"
            and (fk.get("constrained_columns") or []) == ["assigned_by_user_id"]
            and fk.get("name")
        }
        for fk_name in fk_names:
            op.drop_constraint(fk_name, "user_roles", type_="foreignkey")

    if _has_column(inspector, "user_roles", "assigned_by_subject"):
        op.drop_column("user_roles", "assigned_by_subject")
    if _has_column(inspector, "user_roles", "assigned_by_user_id"):
        op.drop_column("user_roles", "assigned_by_user_id")
