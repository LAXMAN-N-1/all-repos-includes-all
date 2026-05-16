from typing import Optional, List
from pydantic import BaseModel, EmailStr
from typing import Annotated
from datetime import datetime


# --------------------------
# Registration
# --------------------------
class VendorRegisterRequest(BaseModel):
    # Account info
    email: EmailStr
    password: Annotated[str, 8]

    # Vendor profile info
    company_name: str
    business_type: str
    phone: str
    address: str
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None


# --------------------------
# Login
# --------------------------
class VendorLoginRequest(BaseModel):
    email: EmailStr
    password: str


# --------------------------
# Authenticated User Response
# (Extended with BaseModel fields)
# --------------------------
class VendorAuthUser(BaseModel):
    id: int
    email: EmailStr
    username: str
    role_id: int

    # Extended BaseModel fields
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    deleted_at: Optional[datetime] = None

    inactive: Optional[bool] = None

    created_by: Optional[str] = None
    modified_by: Optional[str] = None

    class Config:
        from_attributes = True


from .menu_schema import MenuResponse
from .role_right_schema import RoleRightResponse

# --------------------------
# Auth Response
# --------------------------
class VendorAuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: VendorAuthUser
    menus: List[MenuResponse] = []
    rights: List[RoleRightResponse] = []
    permissions: List[str] = []
