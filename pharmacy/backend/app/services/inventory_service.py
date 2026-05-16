from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from typing import Optional, List, Tuple, TYPE_CHECKING
from typing import Optional, List, Tuple, TYPE_CHECKING
from datetime import datetime, timedelta, date
from app.models.inventory import InventoryBatch
from app.models.medicine import Medicine
from app.models.audit_log import AuditActionType
from app.schemas.inventory_schema import (
    InventoryBatchCreate, InventoryBatchUpdate, StockAdjustment,
    InventoryBatchResponse, InventoryAlertItem, InventoryAlertResponse,
    InventoryFilters
)

if TYPE_CHECKING:
    from app.services.audit_service import AuditService


class InventoryService:
    """Service for inventory batch management and stock tracking"""
    
    def __init__(self, db: Session, audit_service: "AuditService"):
        self.db = db
        self.audit_service = audit_service
    
    def create_batch(self, data: InventoryBatchCreate, user_id: int) -> InventoryBatch:
        """Create a new inventory batch"""
        batch = InventoryBatch(
            store_id=data.store_id,
            medicine_id=data.medicine_id,
            product_name=data.product_name,
            batch_number=data.batch_number,
            expiry_date=data.expiry_date,
            manufacture_date=data.manufacture_date,
            quantity=data.quantity,
            cost_price=data.cost_price,
            selling_price=data.selling_price,
            mrp=data.mrp,
            reorder_level=data.reorder_level,
            supplier_invoice=data.supplier_invoice,
            supplier_batch=data.supplier_batch,
            rack_location=data.rack_location,
            created_by=user_id
        )
        self.db.add(batch)
        self.db.commit()
        self.db.refresh(batch)
        
        # Log the action
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.CREATE,
            entity_type="InventoryBatch",
            entity_id=batch.id,
            new_values={"batch_number": batch.batch_number, "quantity": batch.quantity},
            store_id=batch.store_id
        )
        
        return batch
    
    def get_batch(self, batch_id: int) -> Optional[InventoryBatch]:
        """Get a single inventory batch by ID"""
        return self.db.query(InventoryBatch).filter(
            InventoryBatch.id == batch_id,
            InventoryBatch.inactive == False
        ).first()
    
    def get_batches(
        self,
        filters: InventoryFilters,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[InventoryBatch], int]:
        """Get paginated list of inventory batches with filters"""
        query = self.db.query(InventoryBatch).filter(InventoryBatch.inactive == False)
        
        # Apply filters
        if filters.store_id:
            query = query.filter(InventoryBatch.store_id == filters.store_id)
        
        if filters.medicine_id:
            query = query.filter(InventoryBatch.medicine_id == filters.medicine_id)
        
        if filters.product_name:
            query = query.filter(
                InventoryBatch.product_name.ilike(f"%{filters.product_name}%")
            )
        
        if filters.batch_number:
            query = query.filter(InventoryBatch.batch_number == filters.batch_number)
        
        if filters.low_stock_only:
            query = query.filter(InventoryBatch.quantity <= InventoryBatch.reorder_level)
        
        if filters.expiring_within_days:
            expiry_threshold = date.today() + timedelta(days=filters.expiring_within_days)
            query = query.filter(
                InventoryBatch.expiry_date <= expiry_threshold,
                InventoryBatch.expiry_date > date.today()
            )
        
        if filters.expired_only:
            query = query.filter(InventoryBatch.expiry_date < date.today())
        
        # Get total count
        total = query.count()
        
        # Apply pagination
        offset = (page - 1) * page_size
        batches = query.order_by(InventoryBatch.expiry_date.asc()).offset(offset).limit(page_size).all()
        
        return batches, total
    
    def update_batch(
        self,
        batch_id: int,
        data: InventoryBatchUpdate,
        user_id: int
    ) -> Optional[InventoryBatch]:
        """Update an inventory batch"""
        batch = self.get_batch(batch_id)
        if not batch:
            return None
        
        old_values = {"quantity": batch.quantity, "selling_price": batch.selling_price}
        
        # Update fields
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(batch, field, value)
        
        batch.modified_by = user_id
        self.db.commit()
        self.db.refresh(batch)
        
        # Log the action
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="InventoryBatch",
            entity_id=batch.id,
            old_values=old_values,
            new_values=update_data,
            store_id=batch.store_id
        )
        
        return batch
    
    def delete_batch(self, batch_id: int, user_id: int) -> bool:
        """Soft delete an inventory batch"""
        batch = self.get_batch(batch_id)
        if not batch:
            return False
        
        batch.soft_delete(user_id)
        self.db.commit()
        
        # Log the action
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.DELETE,
            entity_type="InventoryBatch",
            entity_id=batch.id,
            store_id=batch.store_id
        )
        
        return True
    
    def adjust_stock(
        self,
        data: StockAdjustment,
        user_id: int
    ) -> Optional[InventoryBatch]:
        """Adjust stock quantity with audit logging"""
        batch = self.get_batch(data.batch_id)
        if not batch:
            return None
        
        old_quantity = batch.quantity
        new_quantity = old_quantity + data.adjustment_quantity
        
        if new_quantity < 0:
            raise ValueError("Stock cannot be negative")
        
        batch.quantity = new_quantity
        batch.modified_by = user_id
        self.db.commit()
        self.db.refresh(batch)
        
        # Log the adjustment
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="InventoryBatch",
            entity_id=batch.id,
            old_values={"quantity": old_quantity},
            new_values={"quantity": new_quantity, "adjustment": data.adjustment_quantity},
            description=f"Stock adjustment: {data.reason}",
            store_id=batch.store_id
        )
        
        return batch
    
    def get_low_stock_items(self, store_id: Optional[int] = None) -> List[InventoryBatch]:
        """Get items below reorder level"""
        query = self.db.query(InventoryBatch).filter(
            InventoryBatch.inactive == False,
            InventoryBatch.quantity <= InventoryBatch.reorder_level
        )
        
        if store_id:
            query = query.filter(InventoryBatch.store_id == store_id)
        
        return query.all()
    
    def get_expiring_soon(
        self,
        days: int = 30,
        store_id: Optional[int] = None
    ) -> List[InventoryBatch]:
        """Get items expiring within specified days"""
        expiry_threshold = date.today() + timedelta(days=days)
        
        query = self.db.query(InventoryBatch).filter(
            InventoryBatch.inactive == False,
            InventoryBatch.expiry_date <= expiry_threshold,
            InventoryBatch.expiry_date > date.today()
        )
        
        if store_id:
            query = query.filter(InventoryBatch.store_id == store_id)
        
        return query.order_by(InventoryBatch.expiry_date.asc()).all()
    
    def get_expired_items(self, store_id: Optional[int] = None) -> List[InventoryBatch]:
        """Get expired items"""
        query = self.db.query(InventoryBatch).filter(
            InventoryBatch.inactive == False,
            InventoryBatch.expiry_date < date.today()
        )
        
        if store_id:
            query = query.filter(InventoryBatch.store_id == store_id)
        
        return query.all()
    
    def get_inventory_alerts(self, store_id: Optional[int] = None) -> InventoryAlertResponse:
        """Get all inventory alerts (low stock, expiring soon, expired)"""
        low_stock = self.get_low_stock_items(store_id)
        expiring_soon = self.get_expiring_soon(30, store_id)
        expired = self.get_expired_items(store_id)
        
        def to_alert_item(batch: InventoryBatch, alert_type: str) -> InventoryAlertItem:
            days_until = (batch.expiry_date - date.today()).days if batch.expiry_date else 0
            return InventoryAlertItem(
                batch_id=batch.id,
                store_id=batch.store_id,
                product_name=batch.product_name,
                batch_number=batch.batch_number,
                alert_type=alert_type,
                current_quantity=batch.quantity,
                reorder_level=batch.reorder_level,
                expiry_date=batch.expiry_date,
                days_until_expiry=days_until
            )
        
        return InventoryAlertResponse(
            low_stock_items=[to_alert_item(b, "LOW_STOCK") for b in low_stock],
            expiring_soon_items=[to_alert_item(b, "EXPIRING_SOON") for b in expiring_soon],
            expired_items=[to_alert_item(b, "EXPIRED") for b in expired],
            total_alerts=len(low_stock) + len(expiring_soon) + len(expired)
        )
    
    def reserve_stock(
        self,
        batch_id: int,
        quantity: int,
        user_id: int
    ) -> bool:
        """Reserve stock for an order"""
        batch = self.get_batch(batch_id)
        if not batch:
            return False
        
        available = batch.quantity - batch.quantity_reserved
        if quantity > available:
            return False
        
        batch.quantity_reserved += quantity
        batch.modified_by = user_id
        self.db.commit()
        
        return True
    
    def release_reserved_stock(
        self,
        batch_id: int,
        quantity: int,
        user_id: int
    ) -> bool:
        """Release reserved stock (e.g., when order is cancelled)"""
        batch = self.get_batch(batch_id)
        if not batch:
            return False
        
        batch.quantity_reserved = max(0, batch.quantity_reserved - quantity)
        batch.modified_by = user_id
        self.db.commit()
        
        return True
    
