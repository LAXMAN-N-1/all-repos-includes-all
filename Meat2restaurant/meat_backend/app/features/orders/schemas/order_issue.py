from typing import Optional
from datetime import datetime
from pydantic import BaseModel


class OrderIssueBase(BaseModel):
    order_id: int
    customer_id: int
    issue_type: str = "other"
    priority: str = "medium"
    description: str


class OrderIssueCreate(OrderIssueBase):
    assigned_to_id: Optional[int] = None


class OrderIssueUpdate(BaseModel):
    issue_type: Optional[str] = None
    priority: Optional[str] = None
    status: Optional[str] = None
    description: Optional[str] = None
    resolution: Optional[str] = None
    assigned_to_id: Optional[int] = None
    refund_amount: Optional[float] = None


class OrderIssueOut(OrderIssueBase):
    id: int
    status: str
    resolution: Optional[str] = None
    assigned_to_id: Optional[int] = None
    resolved_at: Optional[datetime] = None
    refund_amount: float = 0.0
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
