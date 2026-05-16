from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta, datetime
from app.database import get_db
from app.models.user import User, UserRole
from app.models.role import Role
from app.auth.password import verify_password, get_password_hash
from app.auth.jwt import create_access_token, create_refresh_token, decode_token, verify_token_type
from app.schemas.auth import (
    LoginRequest, RegisterRequest, TokenResponse, 
    RefreshTokenRequest, UserResponse
)
from app.config import settings

router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])

@router.post("/token", response_model=TokenResponse)
async def login_for_swagger(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    """
    OAuth2 compatible token endpoint for Swagger UI.
    Uses OAuth2PasswordRequestForm with username/password fields.
    This endpoint is specifically for Swagger UI authentication.
    """
    # Find user by email (username field in OAuth2)
    user = db.query(User).filter(
        User.email == form_data.username,
        User.inactive == False
    ).first()
    
    # Verify user exists and password is correct
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Check if user account is active
    if user.inactive:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is disabled. Please contact support."
        )
    
    # Prepare token payload
    token_data = {
        "sub": str(user.id),
        "email": user.email,
        "role": user.role.code,
        "org_id": user.organization_id
    }
    
    # Create tokens
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data=token_data,
        expires_delta=access_token_expires
    )
    
    refresh_token = create_refresh_token(data={"sub": str(user.id)})
    
    # Update last login
    user.last_login_at = datetime.utcnow()
    db.commit()
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user={
            "id": str(user.id),
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role.code
        }
    )

@router.post("/login", response_model=TokenResponse)
async def login(
    credentials: LoginRequest,
    db: Session = Depends(get_db)
):
    """
    Authenticate user and return JWT tokens.
    This is the standard JSON-based login endpoint.
    Returns access token (short-lived) and refresh token (long-lived).
    """
    # Find user by email
    user = db.query(User).filter(
        User.email == credentials.email,
        User.inactive == False
    ).first()
    
    # Verify user exists and password is correct
    if not user or not verify_password(credentials.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Check if user account is active
    if user.inactive:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is disabled. Please contact support."
        )
    
    # Prepare token payload
    token_data = {
        "sub": str(user.id),
        "email": user.email,
        "role": user.role.code,
        "org_id": user.organization_id
    }
    
    # Create tokens
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data=token_data,
        expires_delta=access_token_expires
    )
    
    refresh_token = create_refresh_token(data={"sub": str(user.id)})
    
    # Update last login
    user.last_login_at = datetime.utcnow()
    db.commit()
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user={
            "id": str(user.id),
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role.code
        }
    )
    
    
@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(
    user_data: RegisterRequest,
    db: Session = Depends(get_db)
):
    """
    Register new customer account.
    Creates a new user with CUSTOMER role.
    """
    # Check if email already exists
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Validate organization exists
    from app.models.organization import Organization
    org = db.query(Organization).filter(
        Organization.id == 1,  # Default organization for customers
        Organization.inactive == False
    ).first()
    
    if not org:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid organization"
        )
    
    
    # Lookup CUSTOMER role
    customer_role = db.query(Role).filter(Role.code == "CUSTOMER").first()
    if not customer_role:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="System configuration error: Customer role not found"
        )

    # Create new customer user
    new_user = User(
        email=user_data.email,
        password_hash=get_password_hash(user_data.password),
        full_name=user_data.full_name,
        phone=user_data.phone,
        organization_id=1,  # Default organization for customers
        role_id=customer_role.id,
        inactive=False
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return UserResponse(
        id=new_user.id,
        email=new_user.email,
        full_name=new_user.full_name,
        role=new_user.role.code,
        inactive=new_user.inactive
    )



@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    token_request: RefreshTokenRequest,
    db: Session = Depends(get_db)
):
    """
    Refresh access token using refresh token.
    Returns new access token while keeping the same refresh token.
    """
    payload = decode_token(token_request.refresh_token)
    
    if not verify_token_type(payload, "refresh"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )
    
    user_id = payload.get("sub")
    user = db.query(User).filter(
        User.id == user_id,
        User.inactive == False
    ).first()
    
    if not user or user.inactive:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive"
        )
    
    # Create new access token
    token_data = {
        "sub": str(user.id),
        "email": user.email,
        "role": user.role.code,
        "org_id": user.organization_id
    }
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data=token_data,
        expires_delta=access_token_expires
    )
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=token_request.refresh_token,
        token_type="bearer",
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
    )

@router.post("/logout")
async def logout(
    token_request: RefreshTokenRequest,
    db: Session = Depends(get_db)
):
    """
    Logout user by invalidating refresh token.
    In production, implement token blacklisting with Redis.
    """
    # TODO: Add refresh token to blacklist (Redis)
    return {"message": "Successfully logged out"}

# --- Mobile OTP Auth ---
from app.schemas.auth import OTPRequest, OTPVerify

@router.post("/otp/send")
async def send_otp(request: OTPRequest):
    """
    Send OTP to mobile number.
    DEMO: Returns success. Use '9640' to verify.
    """
    # In real app: Calls SMS provider (Twilio, Gupshup, etc.)
    return {"message": "OTP sent successfully", "demo_otp": "9640"}

@router.post("/otp/verify", response_model=TokenResponse)
async def verify_otp(
    request: OTPVerify,
    db: Session = Depends(get_db)
):
    """
    Verify OTP and login/signup user.
    """
    if request.otp != "9640":
         raise HTTPException(status_code=400, detail="Invalid OTP")

    # Check if user exists
    user = db.query(User).filter(User.phone == request.phone_number).first()
    
    if not user:
        # SIGN UP (Auto-create)
        customer_role = db.query(Role).filter(Role.code == "CUSTOMER").first()
        if not customer_role:
             # Fallback to defaults or error
             customer_role = db.query(Role).filter(Role.id == 2).first() # Assuming 2 is some role

        user = User(
            phone=request.phone_number,
            organization_id=1, # Default
            role_id=customer_role.id if customer_role else 1, # Fallback
            full_name="New Customer", # Can be updated later
            email=None, 
            password_hash=None,
            phone_verified=True,
            inactive=False
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    
    # Generate Token
    token_data = {
        "sub": str(user.id),
        "email": user.email if user.email else "",
        "phone": user.phone,
        "role": user.role.code,
        "org_id": user.organization_id
    }
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(data=token_data, expires_delta=access_token_expires)
    refresh_token = create_refresh_token(data={"sub": str(user.id)})
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user={
            "id": str(user.id),
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role.code
        }
    )

