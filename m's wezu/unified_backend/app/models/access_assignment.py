from __future__ import annotations

from datetime import UTC, datetime
from typing import Optional

import sqlalchemy as sa
from sqlmodel import Field, SQLModel


class StationStaffAssignment(SQLModel, table=True):
    __tablename__ = "station_staff_assignments"
    __table_args__ = (
        sa.UniqueConstraint("user_id", "station_id", name="uq_station_staff_user_station"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    dealer_id: int = Field(foreign_key="dealer_profiles.id", index=True)
    station_id: int = Field(foreign_key="stations.id", index=True)
    user_id: int = Field(foreign_key="users.id", index=True)
    assigned_by_user_id: Optional[int] = Field(default=None, foreign_key="users.id", index=True)
    is_active: bool = Field(default=True, index=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC))


class WarehouseUserAssignment(SQLModel, table=True):
    __tablename__ = "warehouse_user_assignments"
    __table_args__ = (
        sa.UniqueConstraint("user_id", "warehouse_id", name="uq_warehouse_user_assignment"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    warehouse_id: int = Field(foreign_key="warehouses.id", index=True)
    user_id: int = Field(foreign_key="users.id", index=True)
    assigned_by_user_id: Optional[int] = Field(default=None, foreign_key="users.id", index=True)
    is_active: bool = Field(default=True, index=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC), index=True)
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
