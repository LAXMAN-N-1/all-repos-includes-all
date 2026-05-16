
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.user import User, UserRole
from app.auth.jwt import decode_token, verify_token_type

# OAuth2 scheme for Swagger UI authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/token")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> User:
    """
    Dependency to extract and verify current user from JWT token.
    Uses OAuth2PasswordBearer for Swagger UI integration.
    Validates token and returns authenticated user.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    payload = decode_token(token)
    
    # Verify token exists and is access token
    if not verify_token_type(payload, "access"):
        raise credentials_exception
    
    # Extract user ID
    user_id: str = payload.get("sub")
    if user_id is None:
        raise credentials_exception
    
    # Query user from database
    user = db.query(User).filter(
        User.id == user_id,
        User.inactive == False
    ).first()
    
    if user is None:
        raise credentials_exception
    
    # Check if user is active
    # Check if user is active
    if user.inactive:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is disabled"
        )
    
    return user

def require_role(allowed_roles: List[UserRole]):
    """
    Dependency factory to check if user has required role.
    
    Usage:
        @router.get("/admin", dependencies=[Depends(require_role([UserRole.HQ_ADMIN]))])
    """
    async def role_checker(
        current_user: User = Depends(get_current_user)
    ) -> User:
        if current_user.role.code not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions. Required roles: {[r.value for r in allowed_roles]}"
            )
        return current_user
    
    return role_checker

def require_permission(permission_code: str):
    """
    Dependency factory to check if user has specific permission.
    
    Usage:
        @router.post("/orders", dependencies=[Depends(require_permission("order.create"))])
    """
    async def permission_checker(
        current_user: User = Depends(get_current_user),
        db: Session = Depends(get_db)
    ) -> User:
        from app.models.role import Role
        from app.models.permission import Permission, role_permissions
        
        # Get user's role with permissions
        role = db.query(Role).filter(
            Role.code == current_user.role.code
        ).first()
        
        if not role:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User role not found"
            )
        
        # Check if role has the required permission
        has_permission = db.query(Permission).join(
            role_permissions,
            role_permissions.c.permission_id == Permission.id
        ).filter(
            role_permissions.c.role_id == role.id,
            Permission.code == permission_code
        ).first()
        
        if not has_permission:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Permission denied: {permission_code}"
            )
        
        return current_user
    
    return permission_checker

# Convenience dependencies for common roles
def get_current_hq_admin(
    current_user: User = Depends(require_role([UserRole.HQ_ADMIN]))
) -> User:
    return current_user

def get_current_store_admin(
    current_user: User = Depends(require_role([UserRole.STORE_ADMIN, UserRole.HQ_ADMIN]))
) -> User:
    return current_user

def get_current_pharmacist(
    current_user: User = Depends(require_role([UserRole.PHARMACIST]))
) -> User:
    return current_user


def get_current_tenant(
    current_user: User = Depends(get_current_user)
) -> "Organization":
    """
    Dependency to get the current tenant (Organization) from the authenticated user.
    Enforces subscription checks.
    """
    if not current_user.organization:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User does not belong to any organization"
        )
    
    # Check subscription status
    if current_user.organization.subscription_status == "SUSPENDED":
        raise HTTPException(
            status_code=status.HTTP_402_PAYMENT_REQUIRED,
            detail="Organization subscription is suspended"
        )
        
    return current_user.organization


def require_module(module_name: str):
    """
    Dependency factory to check if a specific module is enabled for the tenant.
    
    Usage:
        @router.get("/lab-results", dependencies=[Depends(require_module("LAB"))])
    """
    async def module_checker(
        tenant = Depends(get_current_tenant),
        db: Session = Depends(get_db)
    ):
        from app.models.saas_config import OrganizationModule, Module
        
        # Check if module exists and is enabled for org
        org_module = db.query(OrganizationModule).join(Module).filter(
            OrganizationModule.organization_id == tenant.id,
            Module.name == module_name,
            OrganizationModule.is_enabled == True
        ).first()
        
        if not org_module:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Module '{{module_name}}' is not enabled for your organization"
            )
            
        return tenant
    
    return module_checker
