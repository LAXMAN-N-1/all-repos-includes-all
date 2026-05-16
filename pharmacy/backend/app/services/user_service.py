from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from typing import Optional, List, Tuple, TYPE_CHECKING
from typing import Optional, List, Tuple, TYPE_CHECKING
from app.models.user import User, UserRole, user_stores
from app.models.role import Role
from app.models.store import Store
from app.models.audit_log import AuditActionType
from app.auth.password import get_password_hash, verify_password
from app.schemas.user_schema import (
    UserCreate, UserUpdate, UserFilters, UserPasswordUpdate
)

if TYPE_CHECKING:
    from app.services.audit_service import AuditService


class UserService:
    """Service for user management operations"""
    
    def __init__(self, db: Session, audit_service: "AuditService"):
        self.db = db
        self.audit_service = audit_service
    
    def create_user(self, data: UserCreate, created_by: int) -> User:
        """Create a new user with optional store assignments"""
        # Check for duplicate email
        existing = self.db.query(User).filter(User.email == data.email).first()
        if existing:
            raise ValueError(f"User with email {data.email} already exists")
        
        # Create user
        user = User(
            organization_id=1,
            email=data.email,
            password_hash=get_password_hash(data.password),
            full_name=data.full_name,
            phone=data.phone,
            role_id=data.role_id,
            inactive=data.inactive,
            created_by=created_by
        )
        self.db.add(user)
        self.db.flush()  # Get the user ID
        
        # Assign stores if provided
        if data.store_ids:
            stores = self.db.query(Store).filter(
                Store.id.in_(data.store_ids),
                Store.inactive == False
            ).all()
            user.assigned_stores = stores
        
        self.db.commit()
        self.db.refresh(user)
        
        # Log the action
        self.audit_service.log_action(
            user_id=created_by,
            action=AuditActionType.CREATE,
            entity_type="User",
            entity_id=user.id,
            new_values={"email": user.email, "role": user.role.code},
            organization_id=user.organization_id
        )
        
        return user
    
    def get_user(self, user_id: int) -> Optional[User]:
        """Get a single user by ID"""
        return self.db.query(User).filter(
            User.id == user_id,
            User.inactive == False
        ).first()
    
    def get_user_by_email(self, email: str) -> Optional[User]:
        """Get a user by email"""
        return self.db.query(User).filter(
            User.email == email,
            User.inactive == False
        ).first()
    
    def get_users(
        self,
        filters: UserFilters,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[User], int]:
        """Get paginated list of users with filters"""
        query = self.db.query(User).filter(User.inactive == False)
        
        # Apply filters
        # Default filter by organization_id = 1
        query = query.filter(User.organization_id == 1)
        
        if filters.role:
            query = query.join(Role).filter(Role.code == filters.role.value)
        
        if filters.inactive is not None:
            query = query.filter(User.inactive == filters.inactive)
        
        if filters.store_id:
            query = query.join(user_stores).filter(
                user_stores.c.store_id == filters.store_id
            )
        
        if filters.search:
            search_term = f"%{filters.search}%"
            query = query.filter(
                or_(
                    User.full_name.ilike(search_term),
                    User.email.ilike(search_term)
                )
            )
        
        # Get total count
        total = query.count()
        
        # Apply pagination
        offset = (page - 1) * page_size
        users = query.order_by(User.created_at.desc()).offset(offset).limit(page_size).all()
        
        return users, total
    
    def update_user(
        self,
        user_id: int,
        data: UserUpdate,
        modified_by: int
    ) -> Optional[User]:
        """Update a user"""
        user = self.get_user(user_id)
        if not user:
            return None
        
        old_values = {"full_name": user.full_name, "role": user.role.code if user.role else None}
        
        # Update fields
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(user, field, value)
        
        user.modified_by = modified_by
        self.db.commit()
        self.db.refresh(user)
        
        # Log the action
        self.audit_service.log_action(
            user_id=modified_by,
            action=AuditActionType.UPDATE,
            entity_type="User",
            entity_id=user.id,
            old_values=old_values,
            new_values=update_data,
            organization_id=user.organization_id
        )
        
        return user
    
    def update_password(
        self,
        user_id: int,
        data: UserPasswordUpdate,
        modified_by: int
    ) -> bool:
        """Update user password"""
        user = self.get_user(user_id)
        if not user:
            return False
        
        # Verify current password
        if not verify_password(data.current_password, user.password_hash):
            raise ValueError("Current password is incorrect")
        
        user.password_hash = get_password_hash(data.new_password)
        user.modified_by = modified_by
        self.db.commit()
        
        # Log the action
        self.audit_service.log_action(
            user_id=modified_by,
            action=AuditActionType.UPDATE,
            entity_type="User",
            entity_id=user.id,
            description="Password updated",
            organization_id=user.organization_id
        )
        
        return True
    
    def delete_user(self, user_id: int, deleted_by: int) -> bool:
        """Soft delete a user"""
        user = self.get_user(user_id)
        if not user:
            return False
        
        user.soft_delete(deleted_by)
        self.db.commit()
        
        # Log the action
        self.audit_service.log_action(
            user_id=deleted_by,
            action=AuditActionType.DELETE,
            entity_type="User",
            entity_id=user.id,
            organization_id=user.organization_id
        )
        
        return True
    
    def assign_stores(
        self,
        user_id: int,
        store_ids: List[int],
        modified_by: int
    ) -> Optional[User]:
        """Assign stores to a user"""
        user = self.get_user(user_id)
        if not user:
            return None
        
        old_store_ids = [str(s.id) for s in user.assigned_stores]
        
        # Get stores
        stores = self.db.query(Store).filter(
            Store.id.in_(store_ids),
            Store.inactive == False
        ).all()
        
        user.assigned_stores = stores
        user.modified_by = modified_by
        self.db.commit()
        self.db.refresh(user)
        
        # Log the action
        self.audit_service.log_action(
            user_id=modified_by,
            action=AuditActionType.UPDATE,
            entity_type="User",
            entity_id=user.id,
            old_values={"store_ids": old_store_ids},
            new_values={"store_ids": [str(s.id) for s in stores]},
            description="Store assignments updated",
            organization_id=user.organization_id
        )
        
        return user

    
