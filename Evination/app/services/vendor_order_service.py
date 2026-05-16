from sqlalchemy.orm import Session
from sqlalchemy import func
from fastapi import HTTPException
from typing import List, Optional
from datetime import datetime

from app.models.vendor_order_m import VendorOrder
from app.models.event_m import Event
from app.models.organization_m import Organization
from app.models.vendor_m import Vendor
from app.models.user_m import User

from app.schemas.vendor_order_schema import (
    VendorOrderListSchema,
    VendorOrderDetailSchema,
    VendorOrderStatusUpdateSchema,
    VendorOrderStatsSchema
)

class VendorOrderService:

    @staticmethod
    def get_orders(
        db: Session,
        vendor_id: int,
        status: Optional[str] = None,
        skip: int = 0,
        limit: int = 100
    ) -> List[VendorOrderListSchema]:
        
        query = db.query(VendorOrder).filter(
            VendorOrder.vendor_id == vendor_id
        )
        
        if status:
            query = query.filter(VendorOrder.status == status)
            
        orders = query.order_by(VendorOrder.created_at.desc()).offset(skip).limit(limit).all()
        
        result = []
        for order in orders:
            event_name = "N/A"
            event_date = "N/A"
            customer_name = "N/A"
            
            if order.event:
                event_name = order.event.name
                event_date = order.event.event_date.strftime("%Y-%m-%d") if order.event.event_date else "N/A"
                if order.event.organization:
                    customer_name = order.event.organization.name
            
            result.append(VendorOrderListSchema(
                id=order.id,
                order_ref=order.order_ref,
                event_name=event_name,
                event_date=event_date,
                customer_name=customer_name,
                amount=order.amount,
                status=order.status,
                created_at=order.created_at
            ))
            
        return result

    @staticmethod
    def get_order_detail(
        db: Session,
        order_id: int,
        vendor_id: int
    ) -> VendorOrderDetailSchema:
        order = db.query(VendorOrder).filter(
            VendorOrder.id == order_id,
            VendorOrder.vendor_id == vendor_id
        ).first()
        
        if not order:
            raise HTTPException(404, "Order not found")
            
        event_name = "N/A"
        event_date = "N/A"
        event_location = None
        customer_name = "N/A"
        customer_email = None
        customer_phone = None
        
        if order.event:
            event_name = order.event.name
            event_date = order.event.event_date.strftime("%Y-%m-%d") if order.event.event_date else "N/A"
            event_location = f"{order.event.city}, {order.event.state}" if order.event.city else order.event.location
            
            if order.event.organization:
                customer_name = order.event.organization.name
                # Try to get contact info from org users? Or just org email/phone if exists
                # Assuming Organization model has email/phone or we take a user linked to it.
                # For now using placeholders or checking org fields.
                customer_email = order.event.organization.email
                customer_phone = order.event.organization.phone

        return VendorOrderDetailSchema(
            id=order.id,
            order_ref=order.order_ref,
            amount=order.amount,
            status=order.status,
            created_at=order.created_at,
            confirmed_at=order.confirmed_at,
            completed_at=order.completed_at,
            event_id=order.event_id,
            event_name=event_name,
            event_date=event_date,
            event_location=event_location,
            customer_name=customer_name,
            customer_email=customer_email,
            customer_phone=customer_phone
        )

    @staticmethod
    def update_order_status(
        db: Session,
        order_id: int,
        vendor_id: int,
        data: VendorOrderStatusUpdateSchema
    ):
        order = db.query(VendorOrder).filter(
            VendorOrder.id == order_id,
            VendorOrder.vendor_id == vendor_id
        ).first()
        
        if not order:
            raise HTTPException(404, "Order not found")
            
        # Logic for status transition?
        # e.g. confirmed -> completed
        
        order.status = data.status
        if data.status == "confirmed" and not order.confirmed_at:
            order.confirmed_at = datetime.utcnow()
        if data.status == "completed" and not order.completed_at:
            order.completed_at = datetime.utcnow()
            
        db.commit()
        db.refresh(order)
        return {"message": "Order status updated", "status": order.status}

    @staticmethod
    def get_order_stats(
        db: Session,
        vendor_id: int
    ) -> VendorOrderStatsSchema:
        
        total_orders = db.query(func.count(VendorOrder.id)).filter(VendorOrder.vendor_id == vendor_id).scalar()
        pending_orders = db.query(func.count(VendorOrder.id)).filter(VendorOrder.vendor_id == vendor_id, VendorOrder.status == "pending").scalar()
        active_orders = db.query(func.count(VendorOrder.id)).filter(VendorOrder.vendor_id == vendor_id, VendorOrder.status.in_(["confirmed", "in_progress"])).scalar()
        completed_orders = db.query(func.count(VendorOrder.id)).filter(VendorOrder.vendor_id == vendor_id, VendorOrder.status == "completed").scalar()
        
        total_revenue = db.query(func.sum(VendorOrder.amount)).filter(VendorOrder.vendor_id == vendor_id, VendorOrder.status == "completed").scalar() or 0.0
        
        return VendorOrderStatsSchema(
            total_orders=total_orders or 0,
            pending_orders=pending_orders or 0,
            active_orders=active_orders or 0,
            completed_orders=completed_orders or 0,
            total_revenue=total_revenue
        )
