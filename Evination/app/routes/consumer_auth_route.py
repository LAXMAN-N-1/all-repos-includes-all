"""
Consumer Authentication Routes
===============================
API endpoints for consumer registration and login.
Supports email/password and phone/OTP authentication.
"""

import random
import string
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user_m import User
from app.models.role_m import Role
from app.schemas.consumer_auth_schema import (
    ConsumerRegisterRequest,
    ConsumerLoginRequest,
    ConsumerOTPRequest,
    ConsumerOTPVerify,
    ConsumerAuthResponse,
    ConsumerAuthUser,
)
from app.utils.password_utils import hash_password, verify_password
from app.utils.jwt_utils import create_access_token


router = APIRouter(prefix="/auth/consumer", tags=["Consumer Auth"])


# In-memory OTP store (for MVP - use Redis in production)
_otp_store = {}


def get_consumer_role(db: Session) -> Role:
    """Get or validate consumer role exists"""
    role = db.query(Role).filter(Role.code == "CONSUMER").first()
    if not role:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Consumer role not configured in system",
        )
    return role


def generate_otp() -> str:
    """Generate a 6-digit OTP"""
    return ''.join(random.choices(string.digits, k=6))


def create_consumer_response(user: User) -> ConsumerAuthResponse:
    """Create auth response for consumer"""
    token_data = {
        "sub": str(user.id),
        "username": user.username,
        "email": user.email,
        "role_id": user.role_id,
    }
    access_token = create_access_token(token_data)
    
    return ConsumerAuthResponse(
        access_token=access_token,
        token_type="bearer",
        user=ConsumerAuthUser(
            id=user.id,
            email=user.email,
            username=user.username,
            first_name=user.first_name,
            last_name=user.last_name,
            phone=user.phone,
            role_id=user.role_id,
            role_code=user.role.code,
            created_at=user.created_at,
            updated_at=user.updated_at,
            inactive=user.inactive,
        )
    )


# --------------------------
# Register with Email/Password
# --------------------------
@router.post("/register", response_model=ConsumerAuthResponse)
def register_consumer(
    payload: ConsumerRegisterRequest, 
    db: Session = Depends(get_db)
):
    """
    Register a new consumer account with email and password.
    """
    # Check if email already exists
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )

    # Get consumer role
    consumer_role = get_consumer_role(db)
    
    # Generate username from email
    username = payload.email.split("@")[0]
    
    # Check if username exists, add numbers if needed
    base_username = username
    counter = 1
    while db.query(User).filter(User.username == username).first():
        username = f"{base_username}{counter}"
        counter += 1

    # Create User
    user = User(
        username=username,
        email=payload.email,
        password_hash=hash_password(payload.password),
        first_name=payload.first_name,
        last_name=payload.last_name,
        phone=payload.phone,
        role_id=consumer_role.id,
        created_by="consumer_self",
        inactive=False,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return create_consumer_response(user)


# --------------------------
# Login with Email/Password
# --------------------------
@router.post("/login", response_model=ConsumerAuthResponse)
def login_consumer(
    payload: ConsumerLoginRequest, 
    db: Session = Depends(get_db)
):
    """
    Login as consumer using email and password.
    """
    user = db.query(User).filter(
        User.email == payload.email,
        User.inactive == False
    ).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    if not verify_password(payload.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    # Ensure user is a consumer
    role = db.query(Role).filter(Role.id == user.role_id).first()
    if not role or role.code != "CONSUMER":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not a consumer account",
        )

    return create_consumer_response(user)


# --------------------------
# Request OTP (Phone Login)
# --------------------------
@router.post("/otp/request")
def request_otp(
    payload: ConsumerOTPRequest,
    db: Session = Depends(get_db)
):
    """
    Request OTP for phone-based login/registration.
    In production, this would send SMS via Twilio/MSG91.
    """
    phone = payload.phone.replace(" ", "").replace("-", "")
    
    # Generate OTP
    otp = generate_otp()
    
    # Store OTP (in production, use Redis with expiry)
    _otp_store[phone] = otp
    
    # In production: Send SMS here
    # sms_service.send_otp(phone, otp)
    
    return {
        "message": "OTP sent successfully",
        "phone": phone,
        # For development only - remove in production!
        "dev_otp": otp
    }


# --------------------------
# Verify OTP (Phone Login)
# --------------------------
@router.post("/otp/verify", response_model=ConsumerAuthResponse)
def verify_otp(
    payload: ConsumerOTPVerify,
    db: Session = Depends(get_db)
):
    """
    Verify OTP and login/register the consumer.
    If user doesn't exist, creates a new account.
    """
    phone = payload.phone.replace(" ", "").replace("-", "")
    
    # Verify OTP
    stored_otp = _otp_store.get(phone)
    if not stored_otp or stored_otp != payload.otp:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired OTP",
        )
    
    # Clear used OTP
    del _otp_store[phone]
    
    # Find or create user
    user = db.query(User).filter(
        User.phone == phone,
        User.inactive == False
    ).first()
    
    if not user:
        # Auto-register user with phone
        consumer_role = get_consumer_role(db)
        
        # Generate username from phone
        username = f"user_{phone[-4:]}"
        counter = 1
        while db.query(User).filter(User.username == username).first():
            username = f"user_{phone[-4:]}_{counter}"
            counter += 1
        
        user = User(
            username=username,
            email=f"{phone}@phone.local",  # Placeholder email
            password_hash=hash_password(generate_otp() + generate_otp()),  # Random password
            phone=phone,
            role_id=consumer_role.id,
            created_by="phone_otp",
            inactive=False,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    
    return create_consumer_response(user)


__all__ = ["router"]
