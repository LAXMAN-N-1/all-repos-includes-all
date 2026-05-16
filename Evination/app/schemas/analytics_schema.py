from pydantic import BaseModel
from typing import List, Optional, Any

# ==========================================
# 1. SHARED / COMMON SCHEMAS
# ==========================================
class StatItem(BaseModel):
    title: str
    value: str | int | float
    change_pct: str  # e.g., "+12%"
    subtext: str
    icon_name: str # string identifier for the icon
    color_code: str # "yellow", "green", etc.

class ChartDataPoint(BaseModel):
    label: str  # e.g., Month or Category name
    value: float
    secondary_value: Optional[float] = None # e.g., Target

# ==========================================
# 2. ADMIN DASHBOARD SCHEMAS
# ==========================================
class AdminStatsResponse(BaseModel):
    stats: List[StatItem]

class RevenueTrendItem(BaseModel):
    month: str
    revenue: float
    target: float

class CategoryRevenueItem(BaseModel):
    category: str
    revenue: float
    percentage: float

class AdminAnalyticsResponse(BaseModel):
    revenue_trends: List[RevenueTrendItem]
    revenue_by_category: List[CategoryRevenueItem]

class EventStatusItem(BaseModel):
    status: str
    count: int
    color: str

class UpcomingEventItem(BaseModel):
    id: int
    name: str
    date: str
    type: str
    status: str

# ==========================================
# 3. VENDOR DASHBOARD SCHEMAS
# ==========================================
class VendorStatsResponse(BaseModel):
    stats: List[StatItem]

class VendorChartsResponse(BaseModel):
    revenue_trend: List[ChartDataPoint]
    bids_by_category: List[ChartDataPoint]

class NotificationItem(BaseModel):
    id: int
    category: str # "orders", "bids", "payments", "urgent", "update"
    type: str # "urgent", "payment", "order", "bid", "update"
    title: str
    message: str
    time: str
    priority: str # "high", "normal", "low"
    order_id: Optional[str] = None

# ==========================================
# 4. CUSTOMER DASHBOARD SCHEMAS
# ==========================================
class CustomerFavoriteItem(BaseModel):
    title: str
    image_url: str
    rating: float
    bookings_count: int
    description: str

class CustomerSuggestedItem(BaseModel):
    title: str
    image_url: str
    badge_text: str
    description: str

class CustomerHistoryItem(BaseModel):
    title: str
    image_url: str
    date: str
    status: str
