# app/routes/vendor_auth_route.py

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.dependencies import get_db
from app.models.user_m import User
from app.models.role_m import Role
from app.models.vendor_m import Vendor
from app.schemas.vendor_auth_schema import (
    VendorRegisterRequest,
    VendorLoginRequest,
    VendorAuthResponse,
    VendorAuthUser,
)
from app.utils.password_utils import hash_password, verify_password
from app.utils.jwt_utils import create_access_token


router = APIRouter(prefix="/auth/vendor", tags=["Vendor Auth"])

@router.post("/token", response_model=VendorAuthResponse)
def login_vendor_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    """
    OAuth2 compatible token login for Vendors
    """
    # Treat username as email
    email = form_data.username
    
    user = db.query(User).filter(User.email == email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Ensure user is vendor
    role = db.query(Role).filter(Role.id == user.role_id).first()
    if not role or role.code != "VENDOR":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not a vendor account",
        )

    token_data = {
        "sub": str(user.id),
        "username": user.username,
        "email": user.email,
        "role_id": user.role_id,
    }
    access_token = create_access_token(token_data)

    return VendorAuthResponse(
        access_token=access_token,
        token_type="bearer",
        user=VendorAuthUser.model_validate(user),
    )


def get_vendor_role(db: Session) -> Role:
    role = db.query(Role).filter(Role.code == "VENDOR").first()
    if not role:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Vendor role not configured in system",
        )
    return role


@router.post("/register", response_model=VendorAuthResponse)
def register_vendor(payload: VendorRegisterRequest, db: Session = Depends(get_db)):
    # Check if email already exists
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )
    
    # Validate offered services
    if not payload.offered_services:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="At least one service must be selected",
        )
    
    from app.models.service_m import Service
    from sqlalchemy import func
    
    service_count = db.query(func.count(Service.id)).filter(
        Service.id.in_(payload.offered_services),
        Service.is_active == True,
        Service.inactive == False
    ).scalar()
    
    if service_count != len(payload.offered_services):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="One or more selected services are invalid",
        )

    vendor_role = get_vendor_role(db)
    
    # Generate unique username from email
    base_username = payload.email.split("@")[0]
    username = base_username
    counter = 1
    while db.query(User).filter(User.username == username).first():
        username = f"{base_username}{counter}"
        counter += 1

    # Create User
    user = User(
        username=username,
        email=payload.email,
        password_hash=hash_password(payload.password),
        role_id=vendor_role.id,
        created_by="vendor_self",
        inactive=False,  # BaseModel field
    )
    db.add(user)
    db.flush()  # flush to get user.id before committing

    # Create Vendor profile
    vendor = Vendor(
        user_id=user.id,
        company_name=payload.company_name,
        business_type=payload.business_type,
        phone=payload.phone,
        address=payload.address,
        city=payload.city,
        state=payload.state,
        zip_code=payload.zip_code,
        offered_services=payload.offered_services,  # Store services
        service_areas=payload.service_areas,  # Store service areas
        status="pending",
        created_by="vendor_self",
        inactive=False,  # BaseModel field
    )
    db.add(vendor)
    db.commit()
    db.refresh(user)

    token_data = {
        "sub": str(user.id),
        "username": user.username,
        "email": user.email,
        "role_id": user.role_id,
    }
    access_token = create_access_token(token_data)

    return VendorAuthResponse(
        access_token=access_token,
        token_type="bearer",
        user=VendorAuthUser.model_validate(user),  # includes BaseModel fields if schema allows
    )


@router.post("/login", response_model=VendorAuthResponse)
def login_vendor(payload: VendorLoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
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

    # Ensure user is vendor
    role = db.query(Role).filter(Role.id == user.role_id).first()
    if not role or role.code != "VENDOR":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not a vendor account",
        )

    token_data = {
        "sub": str(user.id),
        "username": user.username,
        "email": user.email,
        "role_id": user.role_id,
    }
    access_token = create_access_token(token_data)

    return VendorAuthResponse(
        access_token=access_token,
        token_type="bearer",
        user=VendorAuthUser.model_validate(user),  # includes BaseModel fields if schema allows
    )
