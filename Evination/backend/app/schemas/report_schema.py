from pydantic import BaseModel
from typing import List, Dict, Any

class DashboardStats(BaseModel):
    totalEvents: int
    activeEvents: int
    completedEvents: int
    totalBudget: float
    totalRefenue: float # Assuming we track this via Orders
    totalVendors: int
    pendingBids: int

class ChartDataPoint(BaseModel):
    label: str
    value: float

class DashboardCharts(BaseModel):
    eventsByStatus: List[ChartDataPoint]
    budgetVsActual: List[ChartDataPoint]
    monthlyRevenue: List[ChartDataPoint]
