from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta
from app.database import get_db
from app.schemas.auth_schema import LoginRequest, LoginResponse
from app.models.user_m import User
from app.models.menu_m import Menu
from app.models.role_right_m import RoleRight
from app.utils.password_utils import verify_password
from app.utils.jwt_utils import create_access_token
from app.utils.permission_utils import get_user_permissions
from app.config import settings

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/token", response_model=LoginResponse)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    """
    OAuth2 compatible token login, get an access token for future requests.
    Note: In OAuth2, the field is called 'username' but we accept email here.
    """
    # 1. VALIDATE USER (treat username field as email for consistency)
    user = db.query(User).filter(
        User.email == form_data.username,  # Accept email in username field
        User.inactive == False
    ).first()

    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # 2. GENERATE JWT TOKEN
    access_token = create_access_token(
        data={
            "sub": str(user.id),
            "username": user.username,
            "email": user.email,
            "role_id": user.role_id,
        },
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    # 3. FETCH DATA (Same as login)
    role_rights = db.query(RoleRight).filter(
        RoleRight.role_id == user.role_id,
        RoleRight.can_view == True,
        RoleRight.inactive == False
    ).all()

    menu_ids = [rr.menu_id for rr in role_rights]
    
    menus = db.query(Menu).filter(
        Menu.id.in_(menu_ids),
        Menu.inactive == False
    ).order_by(Menu.sort_order).all()

    menus_out = [{
        "id": m.id,
        "name": m.name,
        "route": m.route,
        "code": m.code,
        "icon": m.icon,
    } for m in menus]

    rights_out = [{
        "menu_id": rr.menu_id,
        "can_view": rr.can_view,
        "can_create": rr.can_create,
        "can_edit": rr.can_edit,
        "can_delete": rr.can_delete,
    } for rr in role_rights]

    permissions = get_user_permissions(db, user.role_id)

    return LoginResponse(
        access_token=access_token,
        token_type="bearer",
        user={
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "first_name": user.first_name,
            "last_name": user.last_name,
            "role_code": user.role.code
        },
        menus=menus_out,
        rights=rights_out,
        permissions=permissions
    )


@router.post("/login", response_model=LoginResponse)
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    """
    Login endpoint - Returns JWT token with user info, menus, rights, and permissions
    """
    
    # ============================
    # 1. VALIDATE USER (by email)
    # ============================
    user = db.query(User).filter(
        User.email == request.email,
        User.inactive == False
    ).first()

    if not user or not verify_password(request.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )

    # ============================
    # 2. GENERATE JWT TOKEN
    # ============================
    access_token = create_access_token(
        data={
            "sub": str(user.id),
            "username": user.username,
            "email": user.email,
            "role_id": user.role_id,
        },
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    # ============================
    # 3. FETCH UI MENUS (role_rights)
    # ============================
    role_rights = db.query(RoleRight).filter(
        RoleRight.role_id == user.role_id,
        RoleRight.can_view == True,
        RoleRight.inactive == False
    ).all()

    menu_ids = [rr.menu_id for rr in role_rights]
    
    menus = db.query(Menu).filter(
        Menu.id.in_(menu_ids),
        Menu.inactive == False
    ).order_by(Menu.sort_order).all()

    menus_out = [{
        "id": m.id,
        "name": m.name,
        "route": m.route,
        "code": m.code,
        "icon": m.icon,
    } for m in menus]

    rights_out = [{
        "menu_id": rr.menu_id,
        "can_view": rr.can_view,
        "can_create": rr.can_create,
        "can_edit": rr.can_edit,
        "can_delete": rr.can_delete,
    } for rr in role_rights]

    # ============================
    # 4. FETCH BACKEND PERMISSIONS
    # ============================
    permissions = get_user_permissions(db, user.role_id)

    # ============================
    # 5. RETURN COMPLETE RESPONSE
    # ============================
    return LoginResponse(
        access_token=access_token,
        token_type="bearer",
        user={
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "first_name": user.first_name,
            "last_name": user.last_name,
            "role_code": user.role.code
        },
        menus=menus_out,
        rights=rights_out,
        permissions=permissions
    )


__all__ = ["router"]