from datetime import timedelta
from typing import Any, Optional, Union
from fastapi import APIRouter, Depends, HTTPException, status, Form, Body, Request
from sqlalchemy.orm import Session

from app import models, schemas
from app.api import deps
from app.core import security
from app.core.config import settings

router = APIRouter()

@router.post("/login", response_model=schemas.Token)
async def login(
    request: Request,
    db: Session = Depends(deps.get_db),
    username: Optional[str] = Form(None),
    password: Optional[str] = Form(None),
    identity_type: Optional[str] = Form(None)
) -> Any:
    """
    Unified login for Staff and Partners. 
    Supports both JSON and Form-data.
    """
    import logging
    logger = logging.getLogger("wezu_auth")

    # 0. Extract credentials
    content_type = request.headers.get("Content-Type", "")
    if "application/json" in content_type:
        try:
            body = await request.json()
            username = username or body.get("username")
            password = password or body.get("password")
            identity_type = identity_type or body.get("identity_type")
        except:
            pass

    if not username or not password:
         raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username and password are required"
        )

    logger.info(f"Login attempt for: {username} (type: {identity_type or 'any'})")

    # 1. Check for Staff if no identity_type or identity_type == 'staff'
    if not identity_type or identity_type == "staff":
        # Search by email
        staff = db.query(models.User).filter(models.User.email == username).first()
        
        # Support Driver OTP Login (Mobile: 9154345918 / OTP: 9640)
        is_driver_otp = (username == "9154345918" and password == "9640")
        
        if staff:
            if security.verify_password(password, staff.hashed_password) or is_driver_otp:
                if not staff.is_active:
                    logger.warning(f"Inactive staff account: {username}")
                    raise HTTPException(status_code=400, detail="Inactive staff account")
                
                access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
                return {
                    "access_token": security.create_access_token(
                        data={"sub": str(staff.id), "type": "staff"}, 
                        expires_delta=access_token_expires
                    ),
                    "token_type": "bearer",
                    "user": {
                        "id": staff.id,
                        "full_name": staff.full_name,
                        "email": staff.email,
                        "role": staff.role,
                        "identity_type": "staff",
                        "permissions": staff.permissions or []
                    }
                }
            else:
                logger.warning(f"Invalid password for staff user: {username}")
        elif is_driver_otp:
            # Special case for driver OTP bypass even if staff not found by email
            # This might be needed if they log in with phone but we don't have a phone field in User
            # However, we need a staff ID to create a token.
            logger.error(f"Driver OTP bypass attempted for {username} but no staff record found.")

    # 2. Check for Partner if no identity_type or identity_type == 'partner'
    if not identity_type or identity_type == "partner":
        # Search by email OR phone
        from sqlalchemy import or_
        partner = db.query(models.Customer).filter(
            or_(models.Customer.email == username, models.Customer.phone == username)
        ).first()

        if partner:
            if security.verify_password(password, partner.hashed_password):
                if not partner.is_active:
                    logger.warning(f"Inactive partner account: {username}")
                    raise HTTPException(status_code=400, detail="Inactive partner account")
                
                access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
                return {
                    "access_token": security.create_access_token(
                        data={"sub": str(partner.id), "type": "partner"}, 
                        expires_delta=access_token_expires
                    ),
                    "token_type": "bearer",
                    "user": {
                        "id": partner.id,
                        "full_name": partner.name,
                        "email": partner.email,
                        "role": "partner",
                        "identity_type": "partner",
                        "is_verified": partner.is_verified,
                        "status": partner.status
                    }
                }
            else:
                logger.warning(f"Invalid password for partner user: {username}")

    logger.warning(f"Login failed for: {username}")
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail="Incorrect email, phone or password",
    )


@router.get("/me", response_model=Union[schemas.User, schemas.Customer])
def read_user_me(
    current_user: Any = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get current user.
    """
    return current_user


@router.post("/register", response_model=schemas.Customer)
def register(
    *,
    db: Session = Depends(deps.get_db),
    user_in: schemas.CustomerRegister,
) -> Any:
    """
    Public registration creates a CUSTOMER directly.
    Account is auto-activated — no admin approval needed.
    """
    # Check if email already taken in customers table
    if db.query(models.Customer).filter(models.Customer.email == user_in.email).first():
        raise HTTPException(status_code=400, detail="Account already registered with this email.")

    c_type = getattr(user_in, 'customer_type', None)
    c_type_val = c_type.value if hasattr(c_type, 'value') else (c_type or "direct")
    billing_cycle = getattr(user_in, 'billing_cycle', None)
    billing_cycle_val = billing_cycle.value if hasattr(billing_cycle, 'value') else (billing_cycle or "weekly")

    customer = models.Customer(
        name=user_in.name,
        email=user_in.email,
        phone=getattr(user_in, 'phone', None) or '',
        address=getattr(user_in, 'address', None) or '',
        business_name=getattr(user_in, 'business_name', None) or user_in.name,
        tax_id=getattr(user_in, 'tax_id', None) or '',
        business_description=getattr(user_in, 'business_description', None) or '',
        hashed_password=security.get_password_hash(user_in.password),
        customer_type=c_type_val,
        billing_cycle=billing_cycle_val,
        is_verified=True,
        is_active=True,
        status="active"
    )
    db.add(customer)
    db.commit()
    db.refresh(customer)
    return customer
