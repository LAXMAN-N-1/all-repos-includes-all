from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class VendorStats(BaseModel):
    active_bids: int
    won_contracts: int
    monthly_revenue: float


class RevenuePoint(BaseModel):
    month: str
    revenue: float


class CategoryBid(BaseModel):
    category: str
    count: int


class NotificationModel(BaseModel):
    id: int
    category: str
    type: str
    title: str
    message: str
    time: str
    urgent: Optional[bool] = False
    orderId: Optional[str] = None

    # BaseModel audit fields
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    deleted_at: Optional[datetime] = None

    inactive: Optional[bool] = None
    created_by: Optional[str] = None
    modified_by: Optional[str] = None

    class Config:
        from_attributes = True


class VendorDashboardResponse(BaseModel):
    stats: VendorStats
    revenue_chart: List[RevenuePoint]
    bid_categories: List[CategoryBid]
    notifications: List[NotificationModel]

    class Config:
        from_attributes = True
