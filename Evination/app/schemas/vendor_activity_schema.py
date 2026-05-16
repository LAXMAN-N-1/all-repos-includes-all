# app/schemas/vendor_activity_schema.py

from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class ActivityItem(BaseModel):
    """Single activity item in the feed."""
    id: str  # Unique identifier like "bid-123" or "order-456"
    type: str  # login, bid_submitted, order_received, payment_received
    title: str
    description: Optional[str] = None
    timestamp: datetime
    icon: str  # Icon hint for frontend (e.g., "login", "bid", "order", "payment")
    metadata: Optional[dict] = None  # Additional context data


class ActivityFeedResponse(BaseModel):
    """Paginated activity feed response."""
    activities: List[ActivityItem]
    total: int
    skip: int
    limit: int
