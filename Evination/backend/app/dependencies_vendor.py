from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from app.database import get_db
from app.utils.jwt_utils import decode_access_token
from app.models.user_m import User
from app.models.vendor_m import Vendor

security = HTTPBearer()


async def get_current_vendor(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> Vendor:

    token = credentials.credentials
    payload = decode_access_token(token)

    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token"
        )

    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload"
        )

    # verify user exists
    user = db.query(User).filter(
        User.id == user_id,
        User.inactive == False
    ).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )

    # verify vendor record exists
    vendor = db.query(Vendor).filter(
        Vendor.user_id == user.id
    ).first()

    if not vendor:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Vendor profile not found"
        )

    return vendor


async def get_current_approved_vendor(
    vendor: Vendor = Depends(get_current_vendor)
):
    if vendor.status != "approved":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Vendor not approved yet"
        )
    return vendor
