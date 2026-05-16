from __future__ import annotations

from datetime import date, datetime
from typing import Optional

import sqlalchemy as sa
from sqlmodel import Field, SQLModel


class StationDailyMetric(SQLModel, table=True):
    __tablename__ = "station_daily_metrics"
    # UniqueConstraint lives in the DB as the unique INDEX
    # ``ix_station_daily_metrics_station_date`` created by
    # f1e2d3c4b5a6_unified_new_tables. Do not redeclare it here — a second
    # UniqueConstraint would try to create a duplicate unique index in dev
    # ``create_all`` runs.

    id: Optional[int] = Field(default=None, primary_key=True)
    station_id: int = Field(foreign_key="stations.id", index=True)
    # DB column is ``date`` (f1e2d3c4b5a6_unified_new_tables); the Python
    # attribute stays ``metric_date`` to avoid shadowing ``datetime.date``.
    metric_date: date = Field(
        sa_column=sa.Column("date", sa.Date(), nullable=False, index=True),
    )
    rentals_started: int = Field(default=0)
    rentals_completed: int = Field(default=0)
    average_duration_minutes: Optional[float] = None
    refreshed_at: datetime = Field(default_factory=datetime.utcnow, index=True)
