from sqlalchemy.orm import Session
from sqlalchemy import and_
from typing import Optional, List, Tuple, TYPE_CHECKING
from typing import Optional, List, Tuple, TYPE_CHECKING
from datetime import datetime
import uuid as uuid_lib

from app.models.procurement_order import ProcurementOrder, ProcurementStatus
from app.models.store import Store
from app.models.supplier import Supplier
from app.models.audit_log import AuditActionType
from app.schemas.procurement_schema import (
    ProcurementOrderCreate, ProcurementOrderUpdate, ProcurementFilters,
    ProcurementApproval, ProcurementReceive
)

if TYPE_CHECKING:
    from app.services.audit_service import AuditService
    from app.services.inventory_service import InventoryService
from app.schemas.inventory_schema import InventoryBatchCreate


class ProcurementService:
    """Service for procurement order (Store Direct Purchase) workflow"""
    
    def __init__(self, db: Session, audit_service: "AuditService", inventory_service: "InventoryService"):
        self.db = db
        self.audit_service = audit_service
        self.inventory_service = inventory_service
    
    def _generate_po_number(self) -> str:
        """Generate unique PO number"""
        timestamp = datetime.utcnow().strftime("%Y%m%d")
        random_part = str(uuid_lib.uuid4())[:8].upper()
        return f"PO-{timestamp}-{random_part}"
    
    def create_order(
        self,
        data: ProcurementOrderCreate,
        user_id: int
    ) -> ProcurementOrder:
        """Create a new procurement order (draft status)"""
        # Calculate totals
        totals = data.calculate_totals()
        
        # Convert items to JSON format
        items_json = [
            {
                "medicine_id": str(item.medicine_id),
                "medicine_name": item.medicine_name,
                "quantity": item.quantity,
                "unit_price": item.unit_price,
                "total": item.quantity * item.unit_price
            }
            for item in data.items
        ]
        
        po = ProcurementOrder(
            po_number=self._generate_po_number(),
            store_id=data.store_id,
            supplier_id=data.supplier_id,
            status=ProcurementStatus.DRAFT,
            expected_delivery_date=data.expected_delivery_date,
            subtotal=totals["subtotal"],
            tax_amount=totals["tax_amount"],
            discount_amount=totals["discount_amount"],
            total_amount=totals["total_amount"],
            items=items_json,
            notes=data.notes,
            created_by=user_id
        )
        self.db.add(po)
        self.db.commit()
        self.db.refresh(po)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.CREATE,
            entity_type="ProcurementOrder",
            entity_id=po.id,
            new_values={"po_number": po.po_number, "status": po.status.value}
        )
        
        return po
    
    def get_order(self, order_id: int) -> Optional[ProcurementOrder]:
        """Get a single procurement order by ID"""
        return self.db.query(ProcurementOrder).filter(
            ProcurementOrder.id == order_id,
            ProcurementOrder.inactive == False
        ).first()
    
    def get_order_by_po_number(self, po_number: str) -> Optional[ProcurementOrder]:
        """Get procurement order by PO number"""
        return self.db.query(ProcurementOrder).filter(
            ProcurementOrder.po_number == po_number,
            ProcurementOrder.inactive == False
        ).first()
    
    def get_orders(
        self,
        filters: ProcurementFilters,
        page: int = 1,
        page_size: int = 20,
        store_ids: Optional[List[int]] = None  # For role-based filtering
    ) -> Tuple[List[ProcurementOrder], int]:
        """Get paginated list of procurement orders with filters"""
        query = self.db.query(ProcurementOrder).filter(ProcurementOrder.inactive == False)
        
        # Role-based store filtering
        if store_ids:
            query = query.filter(ProcurementOrder.store_id.in_(store_ids))
        
        if filters.store_id:
            query = query.filter(ProcurementOrder.store_id == filters.store_id)
        
        if filters.supplier_id:
            query = query.filter(ProcurementOrder.supplier_id == filters.supplier_id)
        
        if filters.status:
            query = query.filter(ProcurementOrder.status == ProcurementStatus(filters.status.value))
        
        if filters.date_from:
            query = query.filter(ProcurementOrder.created_at >= filters.date_from)
        
        if filters.date_to:
            query = query.filter(ProcurementOrder.created_at <= filters.date_to)
        
        if filters.po_number:
            query = query.filter(ProcurementOrder.po_number.ilike(f"%{filters.po_number}%"))
        
        total = query.count()
        offset = (page - 1) * page_size
        orders = query.order_by(ProcurementOrder.created_at.desc()).offset(offset).limit(page_size).all()
        
        return orders, total
    
    def update_order(
        self,
        order_id: int,
        data: ProcurementOrderUpdate,
        user_id: int
    ) -> Optional[ProcurementOrder]:
        """Update a procurement order (only in DRAFT status)"""
        po = self.get_order(order_id)
        if not po:
            return None
        
        if po.status != ProcurementStatus.DRAFT:
            raise ValueError("Can only update orders in DRAFT status")
        
        old_values = {"status": po.status.value}
        
        if data.expected_delivery_date is not None:
            po.expected_delivery_date = data.expected_delivery_date
        
        if data.notes is not None:
            po.notes = data.notes
        
        if data.items is not None:
            items_json = [
                {
                    "medicine_id": str(item.medicine_id),
                    "medicine_name": item.medicine_name,
                    "quantity": item.quantity,
                    "unit_price": item.unit_price,
                    "total": item.quantity * item.unit_price
                }
                for item in data.items
            ]
            po.items = items_json
            
            # Recalculate totals
            subtotal = sum(item.quantity * item.unit_price for item in data.items)
            po.subtotal = subtotal
            po.total_amount = subtotal
        
        po.modified_by = user_id
        self.db.commit()
        self.db.refresh(po)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="ProcurementOrder",
            entity_id=po.id,
            old_values=old_values,
            new_values={"items_count": len(po.items or [])}
        )
        
        return po
    
    def submit_for_approval(
        self,
        order_id: int,
        user_id: int,
        internal_notes: Optional[str] = None
    ) -> Optional[ProcurementOrder]:
        """Submit a draft PO for approval"""
        po = self.get_order(order_id)
        if not po:
            return None
        
        if po.status != ProcurementStatus.DRAFT:
            raise ValueError("Can only submit orders in DRAFT status")
        
        old_status = po.status.value
        po.status = ProcurementStatus.SUBMITTED
        po.order_date = datetime.utcnow()
        if internal_notes:
            po.internal_notes = internal_notes
        po.modified_by = user_id
        
        self.db.commit()
        self.db.refresh(po)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="ProcurementOrder",
            entity_id=po.id,
            old_values={"status": old_status},
            new_values={"status": po.status.value}
        )
        
        return po
    
    def approve_or_reject(
        self,
        order_id: int,
        user_id: int,
        data: ProcurementApproval
    ) -> Optional[ProcurementOrder]:
        """Approve or reject a submitted PO"""
        po = self.get_order(order_id)
        if not po:
            return None
        
        if po.status != ProcurementStatus.SUBMITTED:
            raise ValueError("Can only approve/reject orders in SUBMITTED status")
        
        old_status = po.status.value
        
        if data.approved:
            po.status = ProcurementStatus.APPROVED
            po.approved_by = user_id
            po.approved_at = datetime.utcnow()
        else:
            po.status = ProcurementStatus.REJECTED
            po.rejection_reason = data.rejection_reason
        
        po.modified_by = user_id
        self.db.commit()
        self.db.refresh(po)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="ProcurementOrder",
            entity_id=po.id,
            old_values={"status": old_status},
            new_values={
                "status": po.status.value,
                "approved": data.approved,
                "rejection_reason": data.rejection_reason
            }
        )
        
        return po
    
    def mark_ordered(
        self,
        order_id: int,
        user_id: int
    ) -> Optional[ProcurementOrder]:
        """Mark an approved PO as ordered (sent to supplier)"""
        po = self.get_order(order_id)
        if not po:
            return None
        
        if po.status != ProcurementStatus.APPROVED:
            raise ValueError("Can only mark APPROVED orders as ordered")
        
        old_status = po.status.value
        po.status = ProcurementStatus.ORDERED
        po.modified_by = user_id
        
        self.db.commit()
        self.db.refresh(po)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="ProcurementOrder",
            entity_id=po.id,
            old_values={"status": old_status},
            new_values={"status": po.status.value}
        )
        
        return po
    
    def receive_items(
        self,
        order_id: int,
        user_id: int,
        data: ProcurementReceive
    ) -> Optional[ProcurementOrder]:
        """Receive items against a PO and update inventory"""
        po = self.get_order(order_id)
        if not po:
            return None
        
        if po.status not in [ProcurementStatus.ORDERED, ProcurementStatus.PARTIALLY_RECEIVED]:
            raise ValueError("Can only receive items for ORDERED or PARTIALLY_RECEIVED orders")
        
        old_status = po.status.value
        
        # Store received items
        received_json = [
            {
                "medicine_id": str(item.medicine_id),
                "medicine_name": item.medicine_name,
                "ordered_quantity": item.ordered_quantity,
                "received_quantity": item.received_quantity,
                "batch_number": item.batch_number,
                "expiry_date": item.expiry_date.isoformat() if item.expiry_date else None,
                "notes": item.notes
            }
            for item in data.items_received
        ]
        po.items_received = received_json
        po.received_by = user_id
        po.received_date = datetime.utcnow()
        
        # Determine if partial or complete
        if data.partial:
            po.status = ProcurementStatus.PARTIALLY_RECEIVED
        else:
            po.status = ProcurementStatus.RECEIVED
        
        if data.notes:
            po.notes = (po.notes or "") + f"\n[Receiving Notes]: {data.notes}"
        
        po.modified_by = user_id
        self.db.commit()
        self.db.refresh(po)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="ProcurementOrder",
            entity_id=po.id,
            old_values={"status": old_status},
            new_values={
                "status": po.status.value,
                "items_received_count": len(data.items_received)
            }
        )
        
        # Create inventory batches from received items
        for received_item in data.items_received:
            # Find matching PO item to get cost price
            cost_price = 0.0
            
            # Helper to normalize IDs for comparison
            rec_id = str(received_item.medicine_id) if received_item.medicine_id is not None else None
            
            for po_item in po.items:
                po_id = str(po_item.get("medicine_id")) if po_item.get("medicine_id") and str(po_item.get("medicine_id")) != 'None' else None
                
                # Match by ID if present, otherwise Name
                if (rec_id and po_id and rec_id == po_id) or \
                   (not rec_id and not po_id and received_item.medicine_name == po_item.get("medicine_name")):
                    cost_price = float(po_item.get("unit_price", 0))
                    break
            
            # Create Batch
            batch_data = InventoryBatchCreate(
                store_id=po.store_id,
                medicine_id=received_item.medicine_id,
                product_name=received_item.medicine_name,
                batch_number=received_item.batch_number or f"PO-{po.po_number}-{uuid_lib.uuid4().hex[:6].upper()}",
                expiry_date=received_item.expiry_date.date() if received_item.expiry_date else datetime.utcnow().date(), # Fallback if missing
                manufacture_date=datetime.utcnow().date(), # Default to today
                quantity=received_item.received_quantity,
                cost_price=cost_price,
                selling_price=cost_price, # Default to cost, update later
                mrp=cost_price, # Default
                reorder_level=10, # Default
                supplier_invoice=po.po_number, # Use PO number as invoice ref
                supplier_batch=received_item.batch_number,
                rack_location="Receiving",
                created_by=user_id
            )
            self.inventory_service.create_batch(batch_data, user_id)
        
        return po
    
    def cancel_order(
        self,
        order_id: int,
        user_id: int,
        reason: Optional[str] = None
    ) -> Optional[ProcurementOrder]:
        """Cancel a procurement order"""
        po = self.get_order(order_id)
        if not po:
            return None
        
        if po.status in [ProcurementStatus.RECEIVED, ProcurementStatus.CANCELLED]:
            raise ValueError("Cannot cancel RECEIVED or already CANCELLED orders")
        
        old_status = po.status.value
        po.status = ProcurementStatus.CANCELLED
        if reason:
            po.rejection_reason = reason
        po.modified_by = user_id
        
        self.db.commit()
        self.db.refresh(po)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="ProcurementOrder",
            entity_id=po.id,
            old_values={"status": old_status},
            new_values={"status": po.status.value, "reason": reason}
        )
        
        return po
    
    def get_store_name(self, store_id: int) -> Optional[str]:
        """Helper to get store name"""
        store = self.db.query(Store).filter(Store.id == store_id).first()
        return store.name if store else None
    
    def get_supplier_name(self, supplier_id: int) -> Optional[str]:
        """Helper to get supplier name"""
        supplier = self.db.query(Supplier).filter(Supplier.id == supplier_id).first()
        return supplier.name if supplier else None
