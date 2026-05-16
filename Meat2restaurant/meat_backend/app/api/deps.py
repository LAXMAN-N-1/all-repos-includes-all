from typing import Generator, Optional, Any
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from pydantic import ValidationError
from sqlalchemy.orm import Session

from app.core import security
from app.core.config import settings
from app.db.session import SessionLocal
from app.db.deps import get_db

reusable_oauth2 = OAuth2PasswordBearer(
    tokenUrl=f"{settings.API_V1_STR}/auth/login"
)


def get_current_user(
    db: Session = Depends(get_db), token: str = Depends(reusable_oauth2)
) -> Any:
    from app import schemas, models
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        token_data = schemas.token.TokenPayload(**payload)
    except (JWTError, ValidationError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Check identity type from token
    if token_data.type == "staff":
        user = db.query(models.User).filter(models.User.id == int(token_data.sub)).first()
        if not user:
            raise HTTPException(status_code=404, detail="Staff user not found")
        # Add a dynamic attribute to identify type easily in endpoints
        user.identity_type = "staff"
        return user
    else:
        customer = db.query(models.Customer).filter(models.Customer.id == int(token_data.sub)).first()
        if not customer:
            raise HTTPException(status_code=404, detail="B2B Customer not found")
        customer.identity_type = "partner"
        return customer


def get_current_active_user(
    current_user: Any = Depends(get_current_user),
) -> Any:
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive account")
    return current_user


def get_current_active_superuser(
    current_user: Any = Depends(get_current_user),
) -> Any:
    if getattr(current_user, "identity_type", None) != "staff":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="B2B Partners cannot access administrative features"
        )
    if not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="The user doesn't have enough privileges"
        )
    return current_user


def get_current_active_staff(
    current_user: Any = Depends(get_current_user),
) -> Any:
    """
    Dependency for endpoints that require staff or admin access (not B2B partners).
    """
    if getattr(current_user, "identity_type", None) != "staff":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="B2B Partners cannot access this feature. Staff/Admin access required."
        )
    return current_user
