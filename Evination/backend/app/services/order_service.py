from sqlalchemy.orm import Session
from sqlalchemy import func, or_
from fastapi import HTTPException
from app.models.vendor_order_m import VendorOrder
from app.models.vendor_m import Vendor
from app.models.event_m import Event
from app.models.organization_m import Organization
from app.models.user_m import User
from app.schemas.order_schema import OrderCreate, OrderUpdate
import uuid
from datetime import datetime, timedelta

class OrderService:
    def __init__(self, db: Session):
        self.db = db

    def create_order(self, order: OrderCreate, created_by: str):
        # Generate generic Order Ref
        order_ref = f"ORD-{uuid.uuid4().hex[:8].upper()}"
        
        new_order = VendorOrder(
            **order.dict(),
            order_ref=order_ref,
            confirmed_at=func.now(),
            created_by=created_by
        )
        self.db.add(new_order)
        self.db.commit()
        self.db.refresh(new_order)
        return self.get_order(new_order.id)

    def get_orders(self, vendor_id: int = None, event_id: int = None, skip: int = 0, limit: int = 100):
        query = self.db.query(VendorOrder).\
            join(Vendor, VendorOrder.vendor_id == Vendor.id).\
            outerjoin(Event, VendorOrder.event_id == Event.id).\
            filter(VendorOrder.inactive == False)
        
        if vendor_id:
            query = query.filter(VendorOrder.vendor_id == vendor_id)
        if event_id:
            query = query.filter(VendorOrder.event_id == event_id)
            
        results = query.order_by(VendorOrder.created_at.desc()).offset(skip).limit(limit).all()
        
        return [self._format_order(order) for order in results]

    def get_order(self, order_id: int):
        order = self.db.query(VendorOrder).\
            filter(VendorOrder.id == order_id).first()
            
        if not order:
            raise HTTPException(status_code=404, detail="Order not found")
            
        return self._format_order(order)

    def update_order(self, order_id: int, order_update: OrderUpdate, modified_by: str):
        order = self.db.query(VendorOrder).filter(VendorOrder.id == order_id).first()
        if not order:
             raise HTTPException(status_code=404, detail="Order not found")
             
        for key, value in order_update.dict(exclude_unset=True).items():
            setattr(order, key, value)
            
        if order_update.status == "Completed" and not order.completed_at:
             order.completed_at = func.now()
             
        order.modified_by = modified_by
        self.db.commit()
        self.db.refresh(order)
        return self._format_order(order)

    def _format_order(self, order: VendorOrder):
        # Fetch related objects
        event = order.event if order.event_id else None
        vendor = order.vendor # Relationship should load
        
        total_paid = sum(p.amount for p in order.payments if p.status == 'completed')
        
        payment_status = "Pending"
        if total_paid >= order.amount:
            payment_status = "Fully Paid"
        elif total_paid > 0:
            payment_status = "Partially Paid"
        elif total_paid == 0 and order.status != 'Cancelled':
            payment_status = "Pending"
            
        if order.status == 'Cancelled':
             payment_status = "Refunded" if total_paid > 0 else "Cancelled"

        # Customer Info (Prioritize Event Organization)
        customer_name = "N/A"
        customer_email = "N/A"
        customer_phone = "N/A"
        
        if event and event.organization:
             customer_name = event.organization.name
             customer_email = event.organization.email or "N/A"
             customer_phone = event.organization.phone or "N/A"
        
        # Progress Calculation (Mock logic for now based on dates/status)
        progress = 0
        if order.status == 'Completed':
            progress = 100
        elif order.status == 'Cancelled':
            progress = 0
        elif order.status == 'In Progress':
            progress = 65 
        elif order.status == 'Pending':
            progress = 10 
            
        # Delivery Date logic (Mock: Event Date - 1 day or similar)
        delivery_date = event.event_date if event else order.created_at

        return {
            "id": order.id,
            "order_ref": order.order_ref,
            "vendor_id": order.vendor_id,
            "vendor_name": vendor.company_name if vendor else "Unknown Vendor",
            "vendor_contact": vendor.phone if vendor else None,
            "vendor_email": vendor.user.email if (vendor and vendor.user) else None,  # Assuming vendor has linked user
            "service_description": vendor.description if vendor else "Service items", # Fallback
            
            "event_id": order.event_id,
            "event_name": event.name if event else "General Order",
            "event_date": event.event_date if event else None,
            "event_location": event.location if event else "N/A",
            
            "customer_name": customer_name,
            "customer_email": customer_email,
            "customer_phone": customer_phone,
            
            "amount": order.amount,
            "status": order.status.title(), # Ensure Title Case
            
            "paid_amount": total_paid,
            "payment_status": payment_status,
            
            "progress": progress,
            "delivery_date": delivery_date,
            
            "confirmed_at": order.confirmed_at,
            "completed_at": order.completed_at,
            "created_at": order.created_at,
            "updated_at": order.updated_at
        }
