from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.utils.jwt_utils import decode_access_token
from app.utils.permission_utils import check_permission
from app.models.user_m import User

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> User:
    token = credentials.credentials
    print(f"🔑 DEBUG: Decoding token: {token[:20]}...")
    payload = decode_access_token(token)
    print(f"🔑 DEBUG: Payload: {payload}")
    
    if payload is None:
        print("❌ DEBUG: Payload is None")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token"
        )
    
    user_id = payload.get("sub")
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload"
        )
    
    print(f"👤 DEBUG: Fetching user ID: {user_id}")
    # Eager load role to prevent lazy loading issues
    from sqlalchemy.orm import joinedload
    user = db.query(User).options(joinedload(User.role)).filter(
        User.id == user_id,
        User.inactive == False
    ).first()
    
    if user is None:
        print(f"❌ DEBUG: User {user_id} not found")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive"
        )
    
    print(f"✅ DEBUG: Found user: {user.username}, Role: {user.role.code}")
    return user

async def get_current_active_user(
    current_user: User = Depends(get_current_user)
) -> User:
    if current_user.inactive:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    return current_user


# NEW: Permission checker dependency
class PermissionChecker:
    def __init__(self, required_permissions: List[str]):
        self.required_permissions = required_permissions
    
    def __call__(
        self,
        current_user: User = Depends(get_current_active_user),
        db: Session = Depends(get_db)
    ):
        # SuperAdmin bypass (optional)
        if current_user.role.code == "SUPERADMIN":
            return current_user
        
        for permission_code in self.required_permissions:
            if not check_permission(db, current_user.role_id, permission_code):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Missing required permission: {permission_code}"
                )
        
        return current_user