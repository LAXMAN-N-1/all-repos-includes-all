from __future__ import annotations

from datetime import UTC, datetime
from typing import Optional, TYPE_CHECKING

import sqlalchemy as sa
from sqlmodel import Field, Relationship, SQLModel

if TYPE_CHECKING:
    from app.models.user import User


class Tenant(SQLModel, table=True):
    __tablename__ = "tenants"

    id: Optional[int] = Field(default=None, primary_key=True)
    slug: str = Field(index=True, unique=True, min_length=1, max_length=128)
    name: str = Field(min_length=1, max_length=255)
    is_active: bool = Field(default=True, index=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC))


class TenantMembership(SQLModel, table=True):
    __tablename__ = "tenant_memberships"
    __table_args__ = (
        sa.UniqueConstraint("tenant_id", "user_id", name="uq_tenant_memberships_tenant_user"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    tenant_id: int = Field(foreign_key="tenants.id", index=True)
    user_id: int = Field(foreign_key="users.id", index=True)
    status: str = Field(default="active", index=True, min_length=1, max_length=32)
    scope: str = Field(default="tenant_member", min_length=1, max_length=64)
    is_default: bool = Field(default=False, index=True)
    linked_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC))

    tenant: Tenant = Relationship()
    user: User = Relationship()
