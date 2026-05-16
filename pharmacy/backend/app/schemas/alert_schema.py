from pydantic import BaseModel
from typing import Optional, Any
from datetime import datetime
from app.models.notification import AlertSeverity

class AlertBase(BaseModel):
    title: str
    message: str
    severity: AlertSeverity
    icon_name: str = "warning"
    color_hex: str = "#FF0000"
    organization_id: Optional[int] = None
    store_id: Optional[int] = None

class AlertCreate(AlertBase):
    pass

class AlertResponse(AlertBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True
