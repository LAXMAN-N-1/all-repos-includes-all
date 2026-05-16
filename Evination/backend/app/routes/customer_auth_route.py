from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.customer_auth_schema import CustomerSignupRequest, CustomerLoginRequest, TokenResponse
from app.services.customer_auth_service import CustomerAuthService

router = APIRouter(prefix="/customer/auth", tags=["Customer Auth"])

@router.post("/signup", response_model=TokenResponse)
async def customer_signup(request: CustomerSignupRequest, db: Session = Depends(get_db)):
    auth_service = CustomerAuthService(db)
    return auth_service.signup(
        first_name=request.first_name,
        last_name=request.last_name,
        email=request.email,
        password=request.password,
        phone=request.phone,
        location=request.location
    )

@router.post("/login", response_model=TokenResponse)
async def customer_login(request: CustomerLoginRequest, db: Session = Depends(get_db)):
    auth_service = CustomerAuthService(db)
    return auth_service.login(request.email, request.password)

from app.schemas.customer_auth_schema import CustomerProfileResponse
from app.dependencies import get_current_active_user
from app.models.user_m import User

@router.get("/me", response_model=CustomerProfileResponse)
async def get_current_customer(current_user: User = Depends(get_current_active_user)):
    return CustomerProfileResponse(
        id=current_user.id,
        username=current_user.username,
        email=current_user.email,
        first_name=current_user.first_name,
        last_name=current_user.last_name,
        phone=current_user.phone,
        role=current_user.role.code if current_user.role else "CUSTOMER",
        profilePhoto=current_user.avatar_url,
        location=current_user.location,
        isActive=not current_user.inactive,
        isVerified=current_user.is_verified,
        createdAt=current_user.created_at
    )
