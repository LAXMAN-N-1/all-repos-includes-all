from __future__ import annotations

from datetime import UTC, datetime
from typing import Any, Optional

import sqlalchemy as sa
from sqlalchemy import Column, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB
from sqlmodel import Field, SQLModel


class BatteryCustodyEvent(SQLModel, table=True):
    __tablename__ = "battery_custody_events"

    id: Optional[int] = Field(default=None, primary_key=True)
    tenant_id: Optional[int] = Field(default=None, foreign_key="tenants.id", index=True)

    order_id: Optional[str] = Field(default=None, foreign_key="logistics_orders.id", index=True)
    rental_id: Optional[int] = Field(default=None, foreign_key="rentals.id", index=True)

    battery_id: str = Field(index=True)
    battery_pk: Optional[int] = Field(default=None, foreign_key="batteries.id", index=True)

    event_type: str = Field(index=True)
    actor_id: Optional[int] = Field(default=None, foreign_key="users.id", index=True)
    actor_role: Optional[str] = Field(default=None, index=True)

    dealer_id: Optional[int] = Field(default=None, foreign_key="dealer_profiles.id", index=True)
    warehouse_id: Optional[int] = Field(default=None, foreign_key="warehouses.id", index=True)
    admin_id: Optional[int] = Field(default=None, foreign_key="users.id", index=True)
    warehouse_operator_id: Optional[int] = Field(default=None, foreign_key="users.id", index=True)
    driver_id: Optional[int] = Field(default=None, foreign_key="users.id", index=True)
    station_id: Optional[int] = Field(default=None, foreign_key="stations.id", index=True)
    customer_id: Optional[int] = Field(default=None, foreign_key="users.id", index=True)

    from_location_type: Optional[str] = Field(default=None, index=True)
    from_location_id: Optional[int] = Field(default=None, index=True)
    to_location_type: Optional[str] = Field(default=None, index=True)
    to_location_id: Optional[int] = Field(default=None, index=True)

    metadata_json: Optional[dict[str, Any]] = Field(
        default=None,
        sa_column=sa.Column(JSONB().with_variant(sa.JSON(), "sqlite"), nullable=True),
    )

    occurred_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)
    is_active: bool = Field(default=True, index=True)
    deleted_at: Optional[datetime] = None


class DealerMainInventoryBattery(SQLModel, table=True):
    __tablename__ = "dealer_main_inventory_batteries"
    __table_args__ = (
        UniqueConstraint("dealer_id", "battery_id", name="uq_dealer_main_inventory_battery"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    tenant_id: Optional[int] = Field(default=None, foreign_key="tenants.id", index=True)
    dealer_id: int = Field(foreign_key="dealer_profiles.id", index=True)

    battery_id: str = Field(index=True)
    battery_pk: Optional[int] = Field(default=None, foreign_key="batteries.id", index=True)

    status: str = Field(default="IN_STOCK", index=True)
    assigned_station_id: Optional[int] = Field(default=None, foreign_key="stations.id", index=True)
    station_assignment_status: Optional[str] = Field(default=None, index=True)

    is_active: bool = Field(default=True, index=True)
    deleted_at: Optional[datetime] = None
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)


class StationInventoryBattery(SQLModel, table=True):
    __tablename__ = "station_inventory_batteries"
    __table_args__ = (
        UniqueConstraint("station_id", "battery_id", name="uq_station_inventory_battery"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    tenant_id: Optional[int] = Field(default=None, foreign_key="tenants.id", index=True)

    station_id: int = Field(foreign_key="stations.id", index=True)
    source_dealer_id: Optional[int] = Field(default=None, foreign_key="dealer_profiles.id", index=True)

    battery_id: str = Field(index=True)
    battery_pk: Optional[int] = Field(default=None, foreign_key="batteries.id", index=True)

    status: str = Field(default="IN_STOCK", index=True)
    is_active: bool = Field(default=True, index=True)
    deleted_at: Optional[datetime] = None

    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)
