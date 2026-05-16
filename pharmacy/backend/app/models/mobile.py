from sqlalchemy import Column, String, Integer, ForeignKey, DateTime, Enum as SQLEnum, Boolean
from sqlalchemy.orm import relationship
import enum
from datetime import datetime
from app.models.base import BaseModel

class DevicePlatform(str, enum.Enum):
    ANDROID = "ANDROID"
    IOS = "IOS"
    WEB = "WEB"

class UserDevice(BaseModel):
    """
    Registered Mobile Devices for Push Notifications.
    """
    __tablename__ = "user_devices"

    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    device_id = Column(String(255), unique=True, nullable=False) # Unique Hardware ID / UUID
    fcm_token = Column(String(500)) # Firebase Cloud Messaging Token
    
    platform = Column(SQLEnum(DevicePlatform), nullable=False)
    app_version = Column(String(50))
    
    last_active_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)

    # Relationships
    user = relationship("User", backref="devices")
