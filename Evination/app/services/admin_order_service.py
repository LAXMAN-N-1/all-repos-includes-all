from sqlalchemy.orm import Session, joinedload
from fastapi import HTTPException, status
from typing import List

from app.models.vendor_order_m import VendorOrder
from app.models.event_m import Event
from app.models.vendor_m import Vendor
from app.models.user_m import User
from app.models.organization_m import Organization
from app.schemas.admin_order_schema import AdminOrderListSchema, AdminOrderDetailSchema

class AdminOrderService:
    @staticmethod
    def _map_to_order_schema(order: VendorOrder, is_detail: bool = False):
        event_name = order.event.name if order.event else "Unknown Event"
        event_date = order.event.event_date.strftime("%b %d, %Y") if order.event and order.event.event_date else "N/A"
        event_location = order.event.location or order.event.venue or "Unknown Location"
        
        vendor_name = order.vendor.company_name if order.vendor else "Unknown Vendor"
        vendor_contact = order.vendor.phone or "N/A"
        # Access Vendor User for email
        vendor_user = order.vendor.user if order.vendor else None
        vendor_email = vendor_user.email if vendor_user else "N/A"

        # Customer Info
        customer_name = "N/A"
        customer_email = "N/A"
        customer_phone = "N/A"
        
        if order.event and order.event.organization:
             # Organization is the 'customer' usually, but it links to a User or has contact info
             # Checking organization_m.py or assuming organization links to user
             # Assuming Organization -> User relationship exists or Organization has contact details
             # Let's try to get user from Organization if possible, or just Org name
             org = order.event.organization
             customer_name = org.name
             customer_email = org.email or "N/A"
             customer_phone = org.phone or "N/A"

        # Service
        # We don't have a direct 'service' column in VendorOrder, maybe it's implied by Vendor Category or from Bid
        # We'll use Vendor Business Type or Category as proxy
        service = order.vendor.business_type or "Service"

        # Dates
        order_date_str = order.created_at.strftime("%b %d, %Y") if order.created_at else "N/A"
        delivery_date_str = event_date # Delivery usually matches event date

        # Financials
        total_amount = order.amount
        paid_amount = sum(p.amount for p in order.payments) if order.payments else 0.0
        
        payment_status = "Pending"
        if paid_amount >= total_amount:
            payment_status = "Fully Paid"
        elif paid_amount > 0:
            payment_status = "Partially Paid"
        
        # Progress
        # Mocking progress based on status or randomness if no data
        progress = 0
        if order.status.lower() == "completed":
            progress = 100
        elif order.status.lower() == "confirmed":
            progress = 25
        elif order.status.lower() == "in progress":
            progress = 50
        
        common_data = {
            "id": f"ORD-{order.id}", # Formatting as per design
            "eventName": event_name,
            "vendor": vendor_name,
            "service": service,
            "amount": total_amount,
            "status": order.status.title(),
            "orderDate": order_date_str,
            "deliveryDate": delivery_date_str,
            "progress": progress
        }

        if not is_detail:
            return AdminOrderListSchema(**common_data)
        
        # Detail Extras
        return AdminOrderDetailSchema(
            **common_data,
            customerName=customer_name,
            customerEmail=customer_email,
            customerPhone=customer_phone,
            eventDate=event_date,
            eventLocation=event_location,
            vendorContact=vendor_contact,
            vendorEmail=vendor_email,
            serviceDescription=f"{service} services for {event_name}", # Generated description
            paymentStatus=payment_status,
            paidAmount=paid_amount,
            notes="No specific notes." # Default
        )

    @staticmethod
    def get_all_orders(db: Session, skip: int = 0, limit: int = 100):
        # Eager load relationships to avoid N+1
        orders = db.query(VendorOrder).\
            options(
                joinedload(VendorOrder.event).joinedload(Event.organization),
                joinedload(VendorOrder.vendor).joinedload(Vendor.user),
                joinedload(VendorOrder.payments)
            ).\
            offset(skip).limit(limit).all()
            
        return [AdminOrderService._map_to_order_schema(o) for o in orders]

    @staticmethod
    def get_order_details(db: Session, order_id: str):
        # Handle "ORD-123" format
        oid = order_id.replace("ORD-", "")
        if not oid.isdigit():
             raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid Order ID")
             
        order = db.query(VendorOrder).\
            filter(VendorOrder.id == int(oid)).\
            options(
                joinedload(VendorOrder.event).joinedload(Event.organization),
                joinedload(VendorOrder.vendor).joinedload(Vendor.user),
                joinedload(VendorOrder.payments)
            ).first()
            
        if not order:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Order not found")
            
        return AdminOrderService._map_to_order_schema(order, is_detail=True)
