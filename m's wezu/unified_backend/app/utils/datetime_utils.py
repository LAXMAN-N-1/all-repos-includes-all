from __future__ import annotations

from datetime import UTC, datetime
from typing import Optional


def utcnow() -> datetime:
    """Return current UTC time as timezone-aware datetime."""
    return datetime.now(UTC)


def utcnow_naive() -> datetime:
    """Return current UTC time as timezone-naive datetime."""
    return datetime.now(UTC).replace(tzinfo=None)


def ensure_utc_aware(value: Optional[datetime]) -> Optional[datetime]:
    """
    Normalize datetimes from mixed DB drivers/schemas to UTC-aware values.

    Some legacy rows are stored as naive timestamps. Comparing them to aware
    UTC values raises `TypeError: can't compare offset-naive and offset-aware`.
    """
    if value is None:
        return None
    if value.tzinfo is None:
        return value.replace(tzinfo=UTC)
    return value.astimezone(UTC)


def ensure_utc_naive(value: Optional[datetime]) -> Optional[datetime]:
    """Normalize mixed datetimes to naive UTC values."""
    normalized = ensure_utc_aware(value)
    if normalized is None:
        return None
    return normalized.replace(tzinfo=None)
