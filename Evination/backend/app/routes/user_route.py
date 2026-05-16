from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.user_schema import UserCreate, UserUpdate, UserResponse
from app.models.user_m import User
from app.dependencies import get_current_active_user, PermissionChecker
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["Users"])

@router.post(
    "/",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["user.create"]))]
)
async def create_user(
    user: UserCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    user_service = UserService(db)
    return user_service.create_user(user, current_user.organization_id, current_user.username)

@router.get(
    "/",
    response_model=List[UserResponse],
    dependencies=[Depends(PermissionChecker(["user.view"]))]
)
async def get_users(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    user_service = UserService(db)
    return user_service.get_users(current_user.organization_id, skip, limit)

@router.get(
    "/{user_id}",
    response_model=UserResponse,
    dependencies=[Depends(PermissionChecker(["user.view"]))]
)
async def get_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    user_service = UserService(db)
    return user_service.get_user(user_id, current_user.organization_id)

@router.put(
    "/{user_id}",
    response_model=UserResponse,
    dependencies=[Depends(PermissionChecker(["user.update"]))]
)
async def update_user(
    user_id: int,
    user_update: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    user_service = UserService(db)
    return user_service.update_user(user_id, user_update, current_user.organization_id, current_user.username)

@router.delete(
    "/{user_id}",
    dependencies=[Depends(PermissionChecker(["user.delete"]))]
)
async def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    user_service = UserService(db)
    user_service.delete_user(user_id, current_user.organization_id, current_user.username)
    return {"message": "User deleted successfully"}