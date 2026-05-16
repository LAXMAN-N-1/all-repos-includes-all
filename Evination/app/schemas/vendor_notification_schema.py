from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class VendorNotificationBase(BaseModel):
    notification_type: str
    title: str
    message: str

    priority: str = "normal"
    category: Optional[str] = None

    action_url: Optional[str] = None
    action_text: Optional[str] = None

    expires_at: Optional[datetime] = None

class VendorNotificationCreate(VendorNotificationBase):
    vendor_id: int
    event_id: Optional[int] = None

class VendorNotificationResponse(VendorNotificationBase):
    id: int
    vendor_id: int
    event_id: Optional[int]

    is_read: bool
    read_at: Optional[datetime]

    created_at: datetime

    class Config:
        from_attributes = True

class VendorNotificationListItem(BaseModel):
    id: int
    title: str
    message: str

    notification_type: str
    priority: str
    category: Optional[str]

    is_read: bool
    created_at: datetime

    action_url: Optional[str]
    action_text: Optional[str]

    class Config:
        from_attributes = True

class VendorNotificationReadUpdate(BaseModel):
    is_read: bool = True
