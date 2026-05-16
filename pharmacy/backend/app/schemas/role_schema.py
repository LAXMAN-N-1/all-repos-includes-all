from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


# ============= Request Schemas =============

class RoleCreate(BaseModel):
    """Schema for creating a new role"""
    name: str = Field(..., min_length=1, max_length=100)
    code: str = Field(..., min_length=1, max_length=50)
    description: Optional[str] = None
    permission_ids: Optional[List[int]] = Field(default_factory=list)


class RoleUpdate(BaseModel):
    """Schema for updating a role"""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = None


class RolePermissionAssign(BaseModel):
    """Schema for assigning permissions to a role"""
    permission_ids: List[int]


# ============= Response Schemas =============

class PermissionResponse(BaseModel):
    """Schema for permission response"""
    id: int
    name: str
    code: str
    resource: str
    action: str
    description: Optional[str] = None

    class Config:
        from_attributes = True


class RoleResponse(BaseModel):
    """Schema for role response"""
    id: int
    name: str
    code: str
    description: Optional[str] = None
    is_system_role: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class RoleDetailResponse(RoleResponse):
    """Detailed role response with permissions"""
    permissions: List[PermissionResponse] = []


class RoleListResponse(BaseModel):
    """Schema for role list"""
    items: List[RoleResponse]
    total: int


class PermissionListResponse(BaseModel):
    """Schema for permission list"""
    items: List[PermissionResponse]
    total: int
