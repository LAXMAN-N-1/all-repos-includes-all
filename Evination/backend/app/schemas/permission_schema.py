from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class PermissionBase(BaseModel):
    code: str
    name: str
    module: str
    action: str
    description: Optional[str] = None

class PermissionCreate(PermissionBase):
    pass

class PermissionResponse(PermissionBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

class RolePermissionResponse(BaseModel):
    permission_code: str
    permission_name: str
    module: str
    action: str
    
    class Config:
        from_attributes = True
