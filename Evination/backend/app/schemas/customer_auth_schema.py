from pydantic import BaseModel, EmailStr
from typing import Optional

class CustomerSignupRequest(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    password: str
    phone: Optional[str] = None
    location: Optional[str] = None

class CustomerLoginRequest(BaseModel):
    email: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user_id: int
    username: str
    role: str

from datetime import datetime

class CustomerProfileResponse(BaseModel):
    id: int
    username: str
    email: EmailStr
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: Optional[str] = None
    role: str
    profilePhoto: Optional[str] = None
    location: Optional[str] = None
    isActive: bool
    isVerified: bool
    createdAt: datetime
