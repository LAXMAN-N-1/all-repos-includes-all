from sqlalchemy.orm import Session
from sqlalchemy import and_, func
from typing import Optional, List, Tuple, TYPE_CHECKING
from typing import Optional, List, Tuple, TYPE_CHECKING
from datetime import datetime, timedelta
import uuid as uuid_module
from app.models.order import Order, OrderStatus, PaymentStatus
from app.models.order_item import OrderItem
from app.models.inventory import InventoryBatch
from app.models.medicine import Medicine
from app.models.user import User
from app.models.audit_log import AuditActionType
from app.schemas.order_schema import (
    OrderCreate, OrderStatusUpdate, OrderPaymentUpdate, OrderCancellation,
    OrderFilters, OrderItemCreate
)

if TYPE_CHECKING:
    from app.services.audit_service import AuditService


class OrderService:
    """Service for order management and pickup workflow"""
    
    def __init__(self, db: Session, audit_service: "AuditService"):
        self.db = db
        self.audit_service = audit_service
    
    def _generate_order_number(self) -> str:
        """Generate unique order number"""
        timestamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
        random_suffix = str(uuid_module.uuid4())[:6].upper()
        return f"ORD-{timestamp}-{random_suffix}"
    
    def create_order(
        self,
        data: OrderCreate,
        customer_id: int,
        user_id: int
    ) -> Order:
        """Create a new order with items (customer self-service)"""
        # Calculate totals
        subtotal = 0.0
        order_items = []
        
        for item_data in data.items:
            # Get medicine details
            medicine = self.db.query(Medicine).filter(
                Medicine.id == item_data.medicine_id,
                Medicine.inactive == False
            ).first()
            
            if not medicine:
                raise ValueError(f"Medicine not found: {item_data.medicine_id}")
            
            # Find available batch (FEFO - First Expiry First Out)
            batch = None
            if item_data.inventory_batch_id:
                batch = self.db.query(InventoryBatch).filter(
                    InventoryBatch.id == item_data.inventory_batch_id,
                    InventoryBatch.inactive == False
                ).first()
            else:
                batch = self.db.query(InventoryBatch).filter(
                    InventoryBatch.store_id == data.store_id,
                    InventoryBatch.medicine_id == item_data.medicine_id,
                    InventoryBatch.quantity - InventoryBatch.quantity_reserved >= item_data.quantity,
                    InventoryBatch.inactive == False
                ).order_by(InventoryBatch.expiry_date.asc()).first()
            
            if not batch or (batch.quantity - batch.quantity_reserved) < item_data.quantity:
                raise ValueError(f"Insufficient stock for: {medicine.name}")
            
            # Calculate item total
            unit_price = batch.selling_price
            item_total = unit_price * item_data.quantity
            subtotal += item_total
            
            order_items.append({
                "medicine": medicine,
                "batch": batch,
                "quantity": item_data.quantity,
                "unit_price": unit_price,
                "total_price": item_total
            })
        
        # Calculate tax (GST default 18%)
        tax_rate = 0.18
        tax_amount = subtotal * tax_rate
        total_amount = subtotal + tax_amount
        
        # Create order
        order = Order(
            order_number=self._generate_order_number(),
            customer_id=customer_id,
            store_id=data.store_id,
            prescription_id=data.prescription_id,
            status=OrderStatus.PENDING,
            payment_status=PaymentStatus.PENDING,
            subtotal=subtotal,
            tax_amount=tax_amount,
            total_amount=total_amount,
            customer_phone=data.customer_phone,
            customer_email=data.customer_email,
            notes=data.notes,
            estimated_pickup_time=datetime.utcnow() + timedelta(hours=2),
            created_by=user_id
        )
        self.db.add(order)
        self.db.flush()  # Get the order ID
        
        # Create order items and reserve stock
        for item in order_items:
            order_item = OrderItem(
                order_id=order.id,
                medicine_id=item["medicine"].id,
                inventory_batch_id=item["batch"].id,
                product_name=item["medicine"].name,
                product_strength=item["medicine"].strength,
                batch_number=item["batch"].batch_number,
                quantity=item["quantity"],
                unit_price=item["unit_price"],
                tax_percent=tax_rate * 100,
                total_price=item["total_price"],
                created_by=user_id
            )
            self.db.add(order_item)
            
            # Reserve stock
            item["batch"].quantity_reserved += item["quantity"]
        
        self.db.commit()
        self.db.refresh(order)
        
        # Log the action
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.CREATE,
            entity_type="Order",
            entity_id=order.id,
            new_values={"order_number": order.order_number, "total": order.total_amount},
            store_id=order.store_id
        )
        
        return order
    
    def get_order(self, order_id: int) -> Optional[Order]:
        """Get a single order by ID with items"""
        return self.db.query(Order).filter(
            Order.id == order_id,
            Order.inactive == False
        ).first()
    
    def get_order_by_number(self, order_number: str) -> Optional[Order]:
        """Get order by order number"""
        return self.db.query(Order).filter(
            Order.order_number == order_number,
            Order.inactive == False
        ).first()
    
    def get_orders(
        self,
        filters: OrderFilters,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Order], int]:
        """Get paginated list of orders with filters"""
        query = self.db.query(Order).filter(Order.inactive == False)
        
        if filters.store_id:
            query = query.filter(Order.store_id == filters.store_id)
        
        if filters.customer_id:
            query = query.filter(Order.customer_id == filters.customer_id)
        
        if filters.status:
            query = query.filter(Order.status == filters.status.value)
        
        if filters.payment_status:
            query = query.filter(Order.payment_status == filters.payment_status.value)
        
        if filters.date_from:
            query = query.filter(Order.created_at >= filters.date_from)
        
        if filters.date_to:
            query = query.filter(Order.created_at <= filters.date_to)
        
        if filters.order_number:
            query = query.filter(Order.order_number.ilike(f"%{filters.order_number}%"))
        
        total = query.count()
        offset = (page - 1) * page_size
        orders = query.order_by(Order.created_at.desc()).offset(offset).limit(page_size).all()
        
        return orders, total
    
    def get_customer_orders(
        self,
        customer_id: int,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Order], int]:
        """Get customer's orders"""
        filters = OrderFilters(customer_id=customer_id)
        return self.get_orders(filters, page, page_size)
    
    def get_store_orders(
        self,
        store_id: int,
        status: Optional[OrderStatus] = None,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Order], int]:
        """Get store orders with optional status filter"""
        filters = OrderFilters(store_id=store_id)
        if status:
            from app.schemas.order_schema import OrderStatusEnum
            filters.status = OrderStatusEnum(status.value)
        return self.get_orders(filters, page, page_size)
    
    def update_order_status(
        self,
        order_id: int,
        data: OrderStatusUpdate,
        user_id: int
    ) -> Optional[Order]:
        """Update order status (pickup workflow transitions)"""
        order = self.get_order(order_id)
        if not order:
            return None
        
        old_status = order.status
        new_status = OrderStatus(data.status.value)
        
        # Validate transitions
        valid_transitions = {
            OrderStatus.PENDING: [OrderStatus.CONFIRMED, OrderStatus.CANCELLED],
            OrderStatus.CONFIRMED: [OrderStatus.PACKED, OrderStatus.CANCELLED],
            OrderStatus.PACKED: [OrderStatus.READY_FOR_PICKUP, OrderStatus.CANCELLED],
            OrderStatus.READY_FOR_PICKUP: [OrderStatus.COMPLETED, OrderStatus.CANCELLED],
            OrderStatus.COMPLETED: [],
            OrderStatus.CANCELLED: []
        }
        
        if new_status not in valid_transitions.get(old_status, []):
            raise ValueError(f"Invalid status transition from {old_status.value} to {new_status.value}")
        
        order.status = new_status
        order.modified_by = user_id
        
        if data.internal_notes:
            order.internal_notes = data.internal_notes
        
        # Handle specific status changes
        if new_status == OrderStatus.READY_FOR_PICKUP:
            order.ready_at = datetime.utcnow()
        elif new_status == OrderStatus.COMPLETED:
            order.picked_up_at = datetime.utcnow()
            # Deduct reserved stock
            for item in order.items:
                if item.inventory_batch:
                    item.inventory_batch.quantity -= item.quantity
                    item.inventory_batch.quantity_reserved -= item.quantity
                    item.quantity_fulfilled = item.quantity
        elif new_status == OrderStatus.PACKED:
            order.packed_by = user_id
        
        self.db.commit()
        self.db.refresh(order)
        
        # Log the action
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.STATUS_CHANGE,
            entity_type="Order",
            entity_id=order.id,
            old_values={"status": old_status.value},
            new_values={"status": new_status.value},
            store_id=order.store_id
        )
        
        return order
    
    def update_payment(
        self,
        order_id: int,
        data: OrderPaymentUpdate,
        user_id: int
    ) -> Optional[Order]:
        """Update payment status"""
        order = self.get_order(order_id)
        if not order:
            return None
        
        old_status = order.payment_status
        order.payment_status = PaymentStatus(data.payment_status.value)
        
        if data.payment_method:
            from app.models.order import PaymentMethod
            order.payment_method = PaymentMethod(data.payment_method.value)
        
        order.modified_by = user_id
        self.db.commit()
        self.db.refresh(order)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="Order",
            entity_id=order.id,
            old_values={"payment_status": old_status.value},
            new_values={"payment_status": order.payment_status.value},
            store_id=order.store_id
        )
        
        return order
    
    def cancel_order(
        self,
        order_id: int,
        data: OrderCancellation,
        user_id: int
    ) -> Optional[Order]:
        """Cancel an order and release reserved stock"""
        order = self.get_order(order_id)
        if not order:
            return None
        
        if order.status in [OrderStatus.COMPLETED, OrderStatus.CANCELLED]:
            raise ValueError(f"Cannot cancel order with status: {order.status.value}")
        
        old_status = order.status
        order.status = OrderStatus.CANCELLED
        order.cancellation_reason = data.cancellation_reason
        order.modified_by = user_id
        
        # Release reserved stock
        for item in order.items:
            if item.inventory_batch:
                item.inventory_batch.quantity_reserved -= item.quantity
        
        self.db.commit()
        self.db.refresh(order)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.STATUS_CHANGE,
            entity_type="Order",
            entity_id=order.id,
            old_values={"status": old_status.value},
            new_values={"status": OrderStatus.CANCELLED.value, "reason": data.cancellation_reason},
            store_id=order.store_id
        )
        
        return order

    
