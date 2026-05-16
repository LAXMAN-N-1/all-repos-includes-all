from sqlalchemy.orm import Session, joinedload
from fastapi import HTTPException, status
from typing import List, Optional
from app.models.user_m import User
from app.schemas.user_schema import UserCreate, UserUpdate
from app.utils.password_utils import hash_password

class UserService:
    def __init__(self, db: Session):
        self.db = db

    def get_users(self, organization_id: int, skip: int = 0, limit: int = 100) -> List[User]:
        return self.db.query(User).options(
            joinedload(User.role),
            joinedload(User.branch)
        ).filter(
            User.organization_id == organization_id,
            User.inactive == False
        ).offset(skip).limit(limit).all()

    def get_user(self, user_id: int, organization_id: int) -> User:
        user = self.db.query(User).options(
            joinedload(User.role),
            joinedload(User.branch)
        ).filter(
            User.id == user_id,
            User.organization_id == organization_id,
            User.inactive == False
        ).first()
        if not user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        return user

    def create_user(self, user_create: UserCreate, organization_id: int, created_by: str) -> User:
        # Check uniqueness
        if self.db.query(User).filter(User.username == user_create.username).first():
             raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already exists")
        
        if self.db.query(User).filter(User.email == user_create.email).first():
             raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already exists")

        new_user = User(
            organization_id=organization_id,
            branch_id=user_create.branch_id,
            department_id=user_create.department_id,
            role_id=user_create.role_id,
            username=user_create.username,
            email=user_create.email,
            password_hash=hash_password(user_create.password),
            first_name=user_create.first_name,
            last_name=user_create.last_name,
            phone=user_create.phone,
            created_by=created_by
        )
        self.db.add(new_user)
        self.db.commit()
        self.db.refresh(new_user)
        return new_user

    def update_user(self, user_id: int, user_update: UserUpdate, organization_id: int, modified_by: str) -> User:
        user = self.get_user(user_id, organization_id)
        
        for key, value in user_update.dict(exclude_unset=True).items():
            setattr(user, key, value)
            
        user.modified_by = modified_by
        self.db.commit()
        self.db.refresh(user)
        return user

    def delete_user(self, user_id: int, organization_id: int, modified_by: str):
        user = self.get_user(user_id, organization_id)
        user.inactive = True
        user.modified_by = modified_by
        self.db.commit()
