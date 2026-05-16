from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import Optional, List, Tuple, TYPE_CHECKING
from typing import Optional, List, Tuple, TYPE_CHECKING
from app.models.store import Store
from app.models.user import User, user_stores
from app.models.audit_log import AuditActionType
from app.schemas.store_schema import StoreCreate, StoreUpdate, StoreFilters

if TYPE_CHECKING:
    from app.services.audit_service import AuditService


class StoreService:
    """Service for store management operations"""
    
    def __init__(self, db: Session, audit_service: "AuditService"):
        self.db = db
        self.audit_service = audit_service
    
    def create_store(self, data: StoreCreate, created_by: int) -> Store:
        """Create a new store"""
        # Check for duplicate code
        existing_code = self.db.query(Store).filter(Store.code == data.code).first()
        if existing_code:
            raise ValueError(f"Store with code {data.code} already exists")
        
        # Check for duplicate license number
        existing_license = self.db.query(Store).filter(
            Store.license_number == data.license_number
        ).first()
        if existing_license:
            raise ValueError(f"Store with license number {data.license_number} already exists")
        
        # Create store
        store = Store(
            organization_id=1,
            name=data.name,
            code=data.code,
            address=data.address,
            city=data.city,
            state=data.state,
            postal_code=data.postal_code,
            phone=data.phone,
            email=data.email,
            operating_hours={k: (v.model_dump() if hasattr(v, 'model_dump') else v) for k, v in data.operating_hours.items()} if data.operating_hours else None,
            license_number=data.license_number,
            license_expiry=data.license_expiry,
            inactive=data.inactive,
            created_by=created_by
        )
        self.db.add(store)
        self.db.commit()
        self.db.refresh(store)
        
        # Log the action
        self.audit_service.log_action(
            user_id=created_by,
            action=AuditActionType.CREATE,
            entity_type="Store",
            entity_id=store.id,
            new_values={"name": store.name, "code": store.code},
            organization_id=store.organization_id
        )
        
        return store
    
    def get_store(self, store_id: int) -> Optional[Store]:
        """Get a single store by ID"""
        return self.db.query(Store).filter(
            Store.id == store_id,
            Store.inactive == False
        ).first()
    
    def get_store_by_code(self, code: str) -> Optional[Store]:
        """Get a store by code"""
        return self.db.query(Store).filter(
            Store.code == code,
            Store.inactive == False
        ).first()
    
    def get_stores(
        self,
        filters: StoreFilters,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Store], int]:
        """Get paginated list of stores with filters"""
        query = self.db.query(Store).filter(Store.inactive == False)
        
        # Apply filters
        # Default filter by organization_id = 1
        query = query.filter(Store.organization_id == 1)
        
        if filters.city:
            query = query.filter(Store.city.ilike(f"%{filters.city}%"))
        
        if filters.state:
            query = query.filter(Store.state.ilike(f"%{filters.state}%"))
        
        if filters.inactive is not None:
            query = query.filter(Store.inactive == filters.inactive)
        
        if filters.search:
            search_term = f"%{filters.search}%"
            query = query.filter(
                or_(
                    Store.name.ilike(search_term),
                    Store.code.ilike(search_term)
                )
            )
        
        # Get total count
        total = query.count()
        
        # Apply pagination
        offset = (page - 1) * page_size
        stores = query.order_by(Store.created_at.desc()).offset(offset).limit(page_size).all()
        
        return stores, total
    
    def update_store(
        self,
        store_id: int,
        data: StoreUpdate,
        modified_by: int
    ) -> Optional[Store]:
        """Update a store"""
        store = self.get_store(store_id)
        if not store:
            return None
        
        old_values = {"name": store.name, "inactive": store.inactive}
        
        # Update fields
        update_data = data.model_dump(exclude_unset=True, mode='json')
        for field, value in update_data.items():
            if field == "operating_hours" and value:
                # Convert to dict for JSON storage
                setattr(store, field, {k: v.model_dump() if hasattr(v, 'model_dump') else v for k, v in value.items()})
            else:
                setattr(store, field, value)
        
        store.modified_by = modified_by
        self.db.commit()
        self.db.refresh(store)
        
        # Log the action
        self.audit_service.log_action(
            user_id=modified_by,
            action=AuditActionType.UPDATE,
            entity_type="Store",
            entity_id=store.id,
            old_values=old_values,
            new_values=update_data,
            organization_id=store.organization_id,
            store_id=store.id
        )
        
        return store
    
    def delete_store(self, store_id: int, deleted_by: int) -> bool:
        """Soft delete a store"""
        store = self.get_store(store_id)
        if not store:
            return False
        
        store.soft_delete(deleted_by)
        self.db.commit()
        
        # Log the action
        self.audit_service.log_action(
            user_id=deleted_by,
            action=AuditActionType.DELETE,
            entity_type="Store",
            entity_id=store.id,
            organization_id=store.organization_id,
            store_id=store.id
        )
        
        return True
    
    def get_store_users(self, store_id: int) -> List[User]:
        """Get all users assigned to a store"""
        store = self.get_store(store_id)
        if not store:
            return []
        
        return self.db.query(User).join(user_stores).filter(
            user_stores.c.store_id == store_id,
            User.inactive == False
        ).all()
    
    def get_user_count(self, store_id: int) -> int:
        """Get count of users assigned to a store"""
        return self.db.query(User).join(user_stores).filter(
            user_stores.c.store_id == store_id,
            User.inactive == False
        ).count()
    
