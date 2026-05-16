"""
Consumer Authentication Schemas
================================
Pydantic schemas for consumer registration and login.
"""

from typing import Optional
from pydantic import BaseModel, EmailStr, field_validator
from datetime import datetime


# --------------------------
# Registration (Email + Password)
# --------------------------
class ConsumerRegisterRequest(BaseModel):
    """Consumer registration with email/password"""
    email: EmailStr
    password: str
    first_name: str
    last_name: str
    phone: Optional[str] = None
    
    @field_validator('password')
    @classmethod
    def password_min_length(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v


# --------------------------
# Login (Email + Password)
# --------------------------
class ConsumerLoginRequest(BaseModel):
    """Consumer login with email/password"""
    email: EmailStr
    password: str


# --------------------------
# OTP Request (Phone)
# --------------------------
class ConsumerOTPRequest(BaseModel):
    """Request OTP for phone login"""
    phone: str
    
    @field_validator('phone')
    @classmethod
    def validate_phone(cls, v):
        # Remove any spaces or dashes
        phone = v.replace(" ", "").replace("-", "")
        if not phone.isdigit() or len(phone) != 10:
            raise ValueError('Phone must be a 10-digit number')
        return phone


class ConsumerOTPVerify(BaseModel):
    """Verify OTP for phone login"""
    phone: str
    otp: str
    
    @field_validator('otp')
    @classmethod
    def validate_otp(cls, v):
        if not v.isdigit() or len(v) != 6:
            raise ValueError('OTP must be a 6-digit number')
        return v


# --------------------------
# Auth User Response
# --------------------------
class ConsumerAuthUser(BaseModel):
    """Consumer user info in auth response"""
    id: int
    email: EmailStr
    username: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: Optional[str] = None
    role_id: int
    role_code: str

    # Extended BaseModel fields
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    inactive: Optional[bool] = None

    class Config:
        from_attributes = True


# --------------------------
# Auth Response
# --------------------------
class ConsumerAuthResponse(BaseModel):
    """Response after successful consumer auth"""
    access_token: str
    token_type: str = "bearer"
    user: ConsumerAuthUser
