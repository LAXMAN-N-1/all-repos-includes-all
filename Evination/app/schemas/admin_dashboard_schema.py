from pydantic import BaseModel
from typing import List, Optional, Any
from datetime import datetime

class FinancialStatsResponse(BaseModel):
    total_revenue: float
    total_orders_value: float
    currency: str = "INR"

class ActivityItem(BaseModel):
    id: str
    type: str  # "event", "order", "vendor"
    description: str
    timestamp: datetime
    metadata: Optional[dict] = None

class ActivityFeedResponse(BaseModel):
    activities: List[ActivityItem]
