from datetime import datetime, timedelta, UTC
from typing import Optional

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import UniqueConstraint
from sqlmodel import Field, SQLModel


class IdempotencyKey(SQLModel, table=True):
    __tablename__ = "idempotency_keys"
    __table_args__ = (
        UniqueConstraint(
            "user_id",
            "idempotency_key",
            "request_method",
            "request_path",
            name="uq_idempotency_user_scope",
        ),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="users.id", index=True)
    idempotency_key: str = Field(index=True)
    request_method: str
    request_path: str
    request_fingerprint: str
    response_status_code: int
    response_payload: Optional[dict] = Field(
        default=None,
        sa_column=sa.Column(JSONB(), nullable=False),
    )
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    expires_at: datetime = Field(
        default_factory=lambda: datetime.now(UTC) + timedelta(hours=48),
        index=True,
    )
