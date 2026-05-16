from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class RoleBase(BaseModel):
    name: str
    code: str
    description: Optional[str] = None
    color: Optional[str] = "gray"

class RoleCreate(RoleBase):
    pass

class RoleUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    color: Optional[str] = None

from typing import List, Optional
from app.schemas.role_right_schema import RoleRightResponse

class RoleResponse(RoleBase):
    id: int
    created_at: datetime
    users_count: int = 0
    role_rights: List[RoleRightResponse] = []
    
    class Config:
        from_attributes = True