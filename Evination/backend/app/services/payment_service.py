from sqlalchemy.orm import Session
from sqlalchemy import func
from fastapi import HTTPException
from app.models.vendor_payment_m import VendorPayment
from app.models.vendor_m import Vendor
from app.models.vendor_order_m import VendorOrder
from app.schemas.payment_schema import PaymentCreate, PaymentUpdate
import uuid

class PaymentService:
    def __init__(self, db: Session):
        self.db = db

    def create_payment(self, payment: PaymentCreate, created_by: str):
        # Generate ref
        ref = f"PAY-{uuid.uuid4().hex[:8].upper()}"
        
        new_payment = VendorPayment(
            **payment.dict(),
            payment_ref=ref,
            paid_at=func.now()
        )
        self.db.add(new_payment)
        self.db.commit()
        self.db.refresh(new_payment)
        return self.get_payment(new_payment.id)
        
    def get_payments(self, vendor_id: int = None, skip: int = 0, limit: int = 100):
        query = self.db.query(VendorPayment, Vendor, VendorOrder).\
            join(Vendor, VendorPayment.vendor_id == Vendor.id).\
            outerjoin(VendorOrder, VendorPayment.order_id == VendorOrder.id)
            
        if vendor_id:
            query = query.filter(VendorPayment.vendor_id == vendor_id)
            
        results = query.order_by(VendorPayment.paid_at.desc()).offset(skip).limit(limit).all()
        return [self._format_payment(p, v, o) for p, v, o in results]

    def get_payment(self, payment_id: int):
        result = self.db.query(VendorPayment, Vendor, VendorOrder).\
            join(Vendor, VendorPayment.vendor_id == Vendor.id).\
            outerjoin(VendorOrder, VendorPayment.order_id == VendorOrder.id).\
            filter(VendorPayment.id == payment_id).first()
            
        if not result:
            raise HTTPException(status_code=404, detail="Payment not found")
            
        return self._format_payment(*result)

    def _format_payment(self, payment, vendor, order):
        return {
            "id": payment.id,
            "payment_ref": payment.payment_ref,
            "vendor_id": payment.vendor_id,
            "vendor_name": vendor.company_name if vendor else None,
            "order_id": payment.order_id,
            "order_ref": order.order_ref if order else None, # Assuming order_ref exists
            "amount": payment.amount,
            "payment_method": payment.payment_method,
            "status": payment.status,
            "paid_at": payment.paid_at
        }
