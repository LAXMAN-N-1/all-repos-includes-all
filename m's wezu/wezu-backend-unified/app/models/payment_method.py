from datetime import datetime
from typing import Optional

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB
from sqlmodel import Field, SQLModel


class PaymentMethod(SQLModel, table=True):
    __tablename__ = "payment_methods"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="users.id", index=True)

    provider: str = Field(default="razorpay", index=True)
    # The DB column is ``type`` (see f1e2d3c4b5a6_unified_new_tables); the
    # Python attribute stays ``method_type`` because ``type`` shadows the
    # Python builtin and is awkward to reference via the ORM.
    method_type: str = Field(
        sa_column=sa.Column("type", sa.String(), nullable=False),
    )
    provider_token: str = Field(index=True)
    last4: Optional[str] = None
    brand: Optional[str] = None
    # DB column is ``metadata``; the Python attribute must avoid that name
    # because SQLAlchemy reserves ``MappedClass.metadata`` for MetaData.
    metadata_json: Optional[dict] = Field(
        default=None,
        sa_column=sa.Column("metadata", JSONB(), nullable=True),
    )

    is_default: bool = Field(default=False)
    status: str = Field(default="active", index=True)  # active, deleted

    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
