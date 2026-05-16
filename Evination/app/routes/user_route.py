from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.user_schema import UserCreate, UserUpdate, UserResponse
from app.models.user_m import User
from app.utils.password_utils import hash_password
from app.dependencies import get_current_active_user, PermissionChecker

router = APIRouter(prefix="/users", tags=["Users"])

@router.post(
    "/",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["user.create"]))]  # NEW
)
async def create_user(
    user: UserCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_user = db.query(User).filter(User.username == user.username).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Username already exists")
    
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already exists")
    
    # Validate branch_id if provided
    branch_id = user.branch_id
    if branch_id:
        from app.models.branch_m import Branch
        branch = db.query(Branch).filter(Branch.id == branch_id).first()
        if not branch:
            raise HTTPException(status_code=400, detail=f"Branch with ID {branch_id} does not exist")
    
    # Validate department_id if provided
    department_id = user.department_id
    if department_id:
        from app.models.department_m import Department
        department = db.query(Department).filter(Department.id == department_id).first()
        if not department:
            raise HTTPException(status_code=400, detail=f"Department with ID {department_id} does not exist")
    
    new_user = User(
        organization_id=current_user.organization_id,
        branch_id=branch_id,
        department_id=department_id,
        role_id=user.role_id,
        username=user.username,
        email=user.email,
        password_hash=hash_password(user.password),
        first_name=user.first_name,
        last_name=user.last_name,
        phone=user.phone,
        created_by=current_user.username
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.get(
    "/",
    response_model=List[UserResponse],
    dependencies=[Depends(PermissionChecker(["user.view"]))]  # NEW
)
async def get_users(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    users = db.query(User).filter(
        User.organization_id == current_user.organization_id,
        User.inactive == False
    ).offset(skip).limit(limit).all()
    return users

@router.get(
    "/{user_id}",
    response_model=UserResponse,
    dependencies=[Depends(PermissionChecker(["user.view"]))]  # NEW
)
async def get_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    user = db.query(User).filter(
        User.id == user_id,
        User.organization_id == current_user.organization_id,
        User.inactive == False
    ).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.put(
    "/{user_id}",
    response_model=UserResponse,
    dependencies=[Depends(PermissionChecker(["user.update"]))]  # NEW
)
async def update_user(
    user_id: int,
    user_update: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    user = db.query(User).filter(
        User.id == user_id,
        User.organization_id == current_user.organization_id
    ).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    for key, value in user_update.dict(exclude_unset=True).items():
        setattr(user, key, value)
    
    user.modified_by = current_user.username
    db.commit()
    db.refresh(user)
    return user

@router.delete(
    "/{user_id}",
    dependencies=[Depends(PermissionChecker(["user.delete"]))]  # NEW
)
async def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    user = db.query(User).filter(
        User.id == user_id,
        User.organization_id == current_user.organization_id
    ).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.inactive = True
    user.modified_by = current_user.username
    db.commit()
    
    return {"message": "User deleted successfully"}