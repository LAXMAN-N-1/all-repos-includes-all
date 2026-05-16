from __future__ import annotations

from datetime import UTC, datetime
from typing import Optional

from sqlalchemy import Column, JSON, UniqueConstraint
from sqlmodel import Field, SQLModel


class OrderLeg(SQLModel, table=True):
    __tablename__ = "order_legs"
    __table_args__ = (
        UniqueConstraint("order_id", "leg_sequence", name="uq_order_legs_order_sequence"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    order_id: str = Field(foreign_key="logistics_orders.id", index=True)
    tenant_id: Optional[int] = Field(default=None, foreign_key="tenants.id", index=True)

    leg_sequence: int = Field(default=1, ge=1)
    leg_type: str = Field(default="dispatch", index=True)

    source_location_type: str = Field(index=True)
    source_location_id: Optional[int] = Field(default=None, index=True)
    destination_location_type: str = Field(index=True)
    destination_location_id: Optional[int] = Field(default=None, index=True)

    created_by: Optional[int] = Field(default=None, foreign_key="users.id")
    notes: Optional[str] = None
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)


class OrderLegBattery(SQLModel, table=True):
    __tablename__ = "order_leg_batteries"
    __table_args__ = (
        UniqueConstraint("order_leg_id", "battery_id", name="uq_order_leg_battery"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    order_leg_id: int = Field(foreign_key="order_legs.id", index=True)
    order_id: str = Field(foreign_key="logistics_orders.id", index=True)
    tenant_id: Optional[int] = Field(default=None, foreign_key="tenants.id", index=True)
    battery_id: str = Field(index=True)
    battery_pk: Optional[int] = Field(default=None, foreign_key="batteries.id", index=True)
    recorded_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)


class OrderLegEvent(SQLModel, table=True):
    __tablename__ = "order_leg_events"

    id: Optional[int] = Field(default=None, primary_key=True)
    order_leg_id: int = Field(foreign_key="order_legs.id", index=True)
    order_id: str = Field(foreign_key="logistics_orders.id", index=True)
    tenant_id: Optional[int] = Field(default=None, foreign_key="tenants.id", index=True)

    event_type: str = Field(index=True)
    from_status: Optional[str] = Field(default=None, index=True)
    to_status: Optional[str] = Field(default=None, index=True)
    actor_id: Optional[int] = Field(default=None, foreign_key="users.id", index=True)
    proof_ref: Optional[str] = None
    metadata_json: Optional[dict] = Field(default=None, sa_column=Column(JSON))
    occurred_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)
