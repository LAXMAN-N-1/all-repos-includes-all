from __future__ import annotations

from datetime import UTC, datetime
from enum import Enum
from typing import Optional, TYPE_CHECKING

import sqlalchemy as sa
from sqlmodel import Field, Relationship, SQLModel

if TYPE_CHECKING:
    from app.models.user import User


class UserIdentityStatus(str, Enum):
    ACTIVE = "active"
    DISABLED = "disabled"
    CONFLICT = "conflict"


class UserIdentity(SQLModel, table=True):
    __tablename__ = "user_identities"
    __table_args__ = (
        sa.UniqueConstraint("provider", "external_subject", name="uq_user_identities_provider_subject"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    provider: str = Field(index=True, min_length=1, max_length=64)
    external_subject: str = Field(index=True, min_length=1, max_length=255)
    user_id: int = Field(foreign_key="users.id", index=True)
    email_snapshot: Optional[str] = Field(default=None, max_length=320)
    status: UserIdentityStatus = Field(default=UserIdentityStatus.ACTIVE, index=True)
    linked_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)
    last_seen_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC))

    user: User = Relationship()


class UserIdentityLinkAudit(SQLModel, table=True):
    __tablename__ = "user_identity_link_audit"

    id: Optional[int] = Field(default=None, primary_key=True)
    provider: str = Field(index=True, min_length=1, max_length=64)
    external_subject: Optional[str] = Field(default=None, index=True, max_length=255)
    email_snapshot: Optional[str] = Field(default=None, index=True, max_length=320)
    user_id: Optional[int] = Field(default=None, foreign_key="users.id", index=True)
    event_type: str = Field(index=True, min_length=1, max_length=64)
    detail_code: str = Field(min_length=1, max_length=128)
    success: bool = Field(default=False, index=True)
    ip_address: Optional[str] = Field(default=None, max_length=64)
    user_agent: Optional[str] = Field(default=None, max_length=512)
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)
