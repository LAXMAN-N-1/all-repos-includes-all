from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from typing import Optional

class OAuth2LoginRequest(BaseModel):
    """OAuth2 password flow login (for Swagger UI)"""
    username: EmailStr  # OAuth2 spec requires 'username' field
    password: str = Field(..., min_length=8)

class LoginRequest(BaseModel):
    """Login credentials"""
    email: EmailStr
    password: str = Field(..., min_length=8)

class RegisterRequest(BaseModel):
    """Customer registration"""
    email: EmailStr
    password: str = Field(..., min_length=8)
    full_name: str = Field(..., min_length=2, max_length=255)
    phone: str = Field(..., min_length=10, max_length=20)

class TokenResponse(BaseModel):
    """JWT token response"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    user: Optional[dict] = None

class RefreshTokenRequest(BaseModel):
    """Refresh token request"""
    refresh_token: str

class UserResponse(BaseModel):
    """User response"""
    id: int
    email: Optional[str] = None
    full_name: Optional[str] = None
    role: str
    is_active: bool
    
    class Config:
        from_attributes = True

class OTPRequest(BaseModel):
    phone_number: str = Field(..., description="Mobile number with or without country code", min_length=10)

class OTPVerify(BaseModel):
    phone_number: str
    otp: str = Field(..., min_length=4, max_length=6)
    device_id: Optional[str] = None # For device linking