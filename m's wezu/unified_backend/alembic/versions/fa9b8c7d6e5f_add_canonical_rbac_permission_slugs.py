"""Add canonical RBAC permission slugs and backfill coarse-grained mappings.

Revision ID: fa9b8c7d6e5f
Revises: f9a8b7c6d5e4
Create Date: 2026-04-21 12:30:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "fa9b8c7d6e5f"
down_revision: Union[str, None] = "f9a8b7c6d5e4"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


CANONICAL_RBAC_PERMISSIONS: list[tuple[str, str, str, str, str, str]] = [
    ("rbac:roles:read", "rbac", "RBAC", "roles_read", "global", "View roles"),
    ("rbac:roles:write", "rbac", "RBAC", "roles_write", "global", "Manage roles"),
    ("rbac:permissions:read", "rbac", "RBAC", "permissions_read", "global", "View permissions"),
    ("rbac:permissions:write", "rbac", "RBAC", "permissions_write", "global", "Manage permissions"),
    ("rbac:assignments:read", "rbac", "RBAC", "assignments_read", "global", "View role assignments"),
    ("rbac:assignments:write", "rbac", "RBAC", "assignments_write", "global", "Manage role assignments"),
    ("rbac:menus:read", "rbac", "RBAC", "menus_read", "global", "View RBAC menus"),
    ("rbac:menus:write", "rbac", "RBAC", "menus_write", "global", "Manage RBAC menus"),
    ("rbac:role_rights:read", "rbac", "RBAC", "role_rights_read", "global", "View role-right bindings"),
    ("rbac:role_rights:write", "rbac", "RBAC", "role_rights_write", "global", "Manage role-right bindings"),
    ("rbac:access_paths:read", "rbac", "RBAC", "access_paths_read", "global", "View access paths"),
    ("rbac:access_paths:write", "rbac", "RBAC", "access_paths_write", "global", "Manage access paths"),
]


def upgrade() -> None:
    bind = op.get_bind()
    metadata = sa.MetaData()
    permissions = sa.Table("permissions", metadata, autoload_with=bind)
    role_permissions = sa.Table("role_permissions", metadata, autoload_with=bind)

    for slug, module, resource_type, action, scope, description in CANONICAL_RBAC_PERMISSIONS:
        existing = bind.execute(
            sa.select(permissions.c.id).where(permissions.c.slug == slug)
        ).first()
        if existing:
            continue
        bind.execute(
            permissions.insert().values(
                slug=slug,
                module=module,
                resource_type=resource_type,
                action=action,
                scope=scope,
                description=description,
            )
        )

    permission_rows = bind.execute(
        sa.select(permissions.c.id, permissions.c.slug)
    ).fetchall()
    permission_by_slug = {row.slug: row.id for row in permission_rows}

    read_targets = [
        "rbac:roles:read",
        "rbac:permissions:read",
        "rbac:assignments:read",
        "rbac:menus:read",
        "rbac:role_rights:read",
        "rbac:access_paths:read",
    ]
    write_targets = [
        "rbac:roles:write",
        "rbac:permissions:write",
        "rbac:assignments:write",
        "rbac:menus:write",
        "rbac:role_rights:write",
        "rbac:access_paths:write",
    ]
    coarse_to_canonical = {
        "rbac:read": read_targets,
        "rbac:write": write_targets,
        "rbac:manage": read_targets + write_targets,
    }

    for coarse_slug, target_slugs in coarse_to_canonical.items():
        coarse_permission_id = permission_by_slug.get(coarse_slug)
        if coarse_permission_id is None:
            continue
        role_ids = bind.execute(
            sa.select(role_permissions.c.role_id).where(
                role_permissions.c.permission_id == coarse_permission_id
            )
        ).fetchall()
        for role_row in role_ids:
            role_id = role_row.role_id
            for target_slug in target_slugs:
                target_permission_id = permission_by_slug.get(target_slug)
                if target_permission_id is None:
                    continue
                exists = bind.execute(
                    sa.select(role_permissions.c.role_id).where(
                        role_permissions.c.role_id == role_id,
                        role_permissions.c.permission_id == target_permission_id,
                    )
                ).first()
                if exists:
                    continue
                bind.execute(
                    role_permissions.insert().values(
                        role_id=role_id,
                        permission_id=target_permission_id,
                    )
                )


def downgrade() -> None:
    # Intentional no-op: these permissions are now part of the canonical RBAC contract.
    pass
