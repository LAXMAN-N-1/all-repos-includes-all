# app/services/vendor_payment_service.py

from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func
from typing import Optional
from fastapi import HTTPException

from app.models.vendor_payment_m import VendorPayment
from app.models.vendor_order_m import VendorOrder
from app.models.vendor_m import Vendor
from app.models.event_m import Event
from app.models.user_m import User
from app.schemas.vendor_payment_schema import (
    PaymentOverviewSchema,
    PaymentListItemSchema,
    PaymentListResponse,
    PaymentInvoiceSchema
)


class VendorPaymentService:
    
    @staticmethod
    def get_payment_overview(db: Session, vendor_id: int) -> PaymentOverviewSchema:
        """
        Get payment overview stats for a vendor.
        Returns total earnings, pending, paid amounts and transaction counts.
        """
        # Total earnings (all completed payments)
        total_earnings = (
            db.query(func.sum(VendorPayment.amount))
            .filter(
                VendorPayment.vendor_id == vendor_id,
                VendorPayment.status == "completed"
            )
            .scalar()
        ) or 0.0
        
        # Pending amount
        pending_amount = (
            db.query(func.sum(VendorPayment.amount))
            .filter(
                VendorPayment.vendor_id == vendor_id,
                VendorPayment.status == "pending"
            )
            .scalar()
        ) or 0.0
        
        # Paid amount (same as total earnings for completed)
        paid_amount = total_earnings
        
        # Transaction counts
        total_transactions = (
            db.query(func.count(VendorPayment.id))
            .filter(VendorPayment.vendor_id == vendor_id)
            .scalar()
        ) or 0
        
        pending_transactions = (
            db.query(func.count(VendorPayment.id))
            .filter(
                VendorPayment.vendor_id == vendor_id,
                VendorPayment.status == "pending"
            )
            .scalar()
        ) or 0
        
        completed_transactions = (
            db.query(func.count(VendorPayment.id))
            .filter(
                VendorPayment.vendor_id == vendor_id,
                VendorPayment.status == "completed"
            )
            .scalar()
        ) or 0
        
        return PaymentOverviewSchema(
            total_earnings=total_earnings,
            pending_amount=pending_amount,
            paid_amount=paid_amount,
            total_transactions=total_transactions,
            pending_transactions=pending_transactions,
            completed_transactions=completed_transactions
        )
    
    @staticmethod
    def get_payment_list(
        db: Session, 
        vendor_id: int, 
        skip: int = 0, 
        limit: int = 20,
        status: Optional[str] = None
    ) -> PaymentListResponse:
        """
        Get paginated list of payments for a vendor.
        """
        query = (
            db.query(VendorPayment)
            .options(
                joinedload(VendorPayment.order).joinedload(VendorOrder.event)
            )
            .filter(VendorPayment.vendor_id == vendor_id)
        )
        
        if status:
            query = query.filter(VendorPayment.status == status)
        
        # Get total count
        total = query.count()
        
        # Get paginated results
        payments = (
            query
            .order_by(VendorPayment.created_at.desc())
            .offset(skip)
            .limit(limit)
            .all()
        )
        
        items = []
        for payment in payments:
            order = payment.order
            event = order.event if order else None
            
            # Get consumer name from event organization
            consumer_name = None
            if event and event.organization_id:
                consumer = db.query(User).filter(User.organization_id == event.organization_id).first()
                if consumer:
                    consumer_name = f"{consumer.first_name or ''} {consumer.last_name or ''}".strip()
            
            items.append(PaymentListItemSchema(
                id=payment.id,
                order_id=payment.order_id,
                order_ref=order.order_ref if order else None,
                amount=payment.amount,
                payment_method=payment.payment_method,
                payment_ref=payment.payment_ref,
                status=payment.status,
                paid_at=payment.paid_at,
                created_at=payment.created_at,
                event_name=event.name if event else None,
                consumer_name=consumer_name
            ))
        
        return PaymentListResponse(
            items=items,
            total=total,
            skip=skip,
            limit=limit
        )
    
    @staticmethod
    def get_payment_invoice(
        db: Session, 
        payment_id: int, 
        vendor_id: int
    ) -> PaymentInvoiceSchema:
        """
        Get detailed invoice for a specific payment.
        """
        payment = (
            db.query(VendorPayment)
            .options(
                joinedload(VendorPayment.order).joinedload(VendorOrder.event),
                joinedload(VendorPayment.vendor)
            )
            .filter(
                VendorPayment.id == payment_id,
                VendorPayment.vendor_id == vendor_id
            )
            .first()
        )
        
        if not payment:
            raise HTTPException(status_code=404, detail="Payment not found")
        
        vendor = payment.vendor
        order = payment.order
        event = order.event if order else None
        
        # Get consumer details
        consumer_name = None
        consumer_email = None
        if event and event.organization_id:
            consumer = db.query(User).filter(User.organization_id == event.organization_id).first()
            if consumer:
                consumer_name = f"{consumer.first_name or ''} {consumer.last_name or ''}".strip()
                consumer_email = consumer.email
        
        # Generate invoice number
        invoice_number = f"INV-{vendor_id}-{payment.id}"
        
        return PaymentInvoiceSchema(
            invoice_number=invoice_number,
            payment_id=payment.id,
            payment_ref=payment.payment_ref,
            vendor_id=vendor.id,
            vendor_company_name=vendor.company_name,
            vendor_address=vendor.address,
            vendor_phone=vendor.phone,
            vendor_tax_id=vendor.tax_id,
            order_id=payment.order_id,
            order_ref=order.order_ref if order else None,
            event_id=event.id if event else None,
            event_name=event.name if event else None,
            event_date=event.event_date if event else None,
            consumer_name=consumer_name,
            consumer_email=consumer_email,
            amount=payment.amount,
            payment_method=payment.payment_method,
            status=payment.status,
            paid_at=payment.paid_at,
            created_at=payment.created_at,
            currency="INR",
            notes=None
        )
