from typing import Any, List

from fastapi import APIRouter, Body, Depends, HTTPException, status
from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session

from app import models, schemas
from app.api import deps
from app.core import security

router = APIRouter()


@router.get("", response_model=List[schemas.User])
def read_users(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: Any = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Retrieve staff users.
    """
    users = db.query(models.User).offset(skip).limit(limit).all()
    return users


@router.post("", response_model=schemas.User)
def create_user(
    *,
    db: Session = Depends(deps.get_db),
    user_in: schemas.UserCreate,
    current_user: Any = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Create new internal staff user (Admin Only).
    """
    user = db.query(models.User).filter(models.User.email == user_in.email).first()
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this email already exists in the system.",
        )
    
    user = models.User(
        email=user_in.email,
        hashed_password=security.get_password_hash(user_in.password),
        full_name=user_in.full_name,
        is_active=user_in.is_active,
        is_superuser=user_in.is_superuser,
        role=user_in.role,
        permissions=user_in.permissions
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@router.put("/me", response_model=Any)
def update_user_me(
    *,
    db: Session = Depends(deps.get_db),
    password: str = Body(None),
    full_name: str = Body(None),
    current_user: Any = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update own profile. Works for both Staff and Partners (returns generic schema).
    """
    if password:
         current_user.hashed_password = security.get_password_hash(password)
    if full_name:
         # For Customer, the field is 'name'. For User, it's 'full_name'.
         if hasattr(current_user, "full_name"):
            current_user.full_name = full_name
         elif hasattr(current_user, "name"):
            current_user.name = full_name
    
    db.add(current_user)
    db.commit()
    db.refresh(current_user)
    
    if getattr(current_user, "identity_type", None) == "staff":
        return schemas.User.from_orm(current_user)
    return schemas.Customer.from_orm(current_user)


@router.get("/me", response_model=Any)
def read_user_me(
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get current logged-in profile.
    """
    if getattr(current_user, "identity_type", None) == "staff":
        # Return as User schema
        return schemas.User.from_orm(current_user)
    else:
        # Return as Customer schema
        return schemas.Customer.from_orm(current_user)


@router.get("/{user_id}", response_model=schemas.User)
def read_user_by_id(
    user_id: int,
    current_user: Any = Depends(deps.get_current_active_superuser),
    db: Session = Depends(deps.get_db),
) -> Any:
    """
    Get a specific staff user by id (Admin Only).
    """
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.put("/{user_id}", response_model=schemas.User)
def update_user(
    *,
    db: Session = Depends(deps.get_db),
    user_id: int,
    user_in: schemas.UserUpdate,
    current_user: Any = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Update a staff user (Admin Only).
    """
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    update_data = user_in.dict(exclude_unset=True)
    if "password" in update_data:
        user.hashed_password = security.get_password_hash(update_data["password"])
        del update_data["password"]
    
    for field, value in update_data.items():
        setattr(user, field, value)
    
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@router.delete("/{user_id}", response_model=schemas.User)
def delete_user(
    *,
    db: Session = Depends(deps.get_db),
    user_id: int,
    current_user: Any = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Delete a staff user.
    """
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if user.id == current_user.id:
        raise HTTPException(status_code=400, detail="Users cannot delete themselves")
    
    # Protect Original Super Admin
    if user.email == "laxmanlaxman1629@gmail.com":
        raise HTTPException(status_code=403, detail="Cannot delete the Original Super Admin.")

    db.delete(user)
    db.commit()
    return user
