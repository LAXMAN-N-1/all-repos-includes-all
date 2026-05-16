from typing import Optional
from pydantic import BaseModel

class Token(BaseModel):
    access_token: str
    token_type: str
    user: Optional[dict] = None # Return role + permissions

class TokenPayload(BaseModel):
    sub: Optional[str] = None
    exp: Optional[int] = None
    type: Optional[str] = "staff" # staff or partner

class OTPLogin(BaseModel):
    phone: str
    otp: str
