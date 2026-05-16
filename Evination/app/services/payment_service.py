from sqlalchemy.orm import Session
from app.models.vendor_order_m import VendorOrder
from app.models.vendor_payment_m import VendorPayment
from app.models.event_m import Event, EventStatus
from app.schemas.payment_schema import PaymentInitiate
from datetime import datetime
from fastapi import HTTPException
import uuid
import razorpay
from app.config import settings

# Initialize Razorpay Client
client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))

class PaymentService:
    @staticmethod
    def initiate_payment(db: Session, payment_data: PaymentInitiate, user_id: int):
        # 1. Fetch the order
        order = db.query(VendorOrder).filter(VendorOrder.id == payment_data.order_id).first()
        if not order:
            raise HTTPException(404, "Order not found")
        
        # 2. Validate amount (Basic check)
        # Note: payment_data.amount should be passed in INR, Razorpay expects Paikse
        if float(order.amount) != float(payment_data.amount):
           raise HTTPException(400, "Payment amount mismatch")

        # 3. Create Razorpay Order
        amount_in_paise = int(payment_data.amount * 100)
        currency = payment_data.currency
        
        try:
            razorpay_order = client.order.create({
                "amount": amount_in_paise,
                "currency": currency,
                "receipt": f"order_rcptid_{payment_data.order_id}",
                "notes": {
                    "order_id": payment_data.order_id,
                    "user_id": user_id
                }
            })
        except Exception as e:
             raise HTTPException(500, detail=f"Razorpay Error: {str(e)}")

        transaction_id = razorpay_order.get("id")

        # 4. Create VendorPayment record (Pending)
        payment = VendorPayment(
            vendor_id=order.vendor_id,
            order_id=order.id,
            amount=payment_data.amount,
            payment_method=payment_data.payment_method,
            payment_ref=transaction_id, # Store Razorpay Order ID here
            status="pending"
        )
        db.add(payment)
        db.commit()
        db.refresh(payment)
        
        return {
            "transaction_id": transaction_id,
            "status": "created",
            "amount": payment.amount,
            "currency": currency,
            "message": "Payment initiated successfully. Proceed to gateway."
        }

    @staticmethod
    def verify_payment(db: Session, razorpay_payment_id: str, razorpay_order_id: str, razorpay_signature: str):
        # 1. Verify Signature
        try:
            client.utility.verify_payment_signature({
                'razorpay_order_id': razorpay_order_id,
                'razorpay_payment_id': razorpay_payment_id,
                'razorpay_signature': razorpay_signature
            })
        except razorpay.errors.SignatureVerificationError:
            raise HTTPException(400, "Invalid payment signature")

        # 2. Fetch Payment Record
        # We stored razorpay_order_id in payment_ref
        payment = db.query(VendorPayment).filter(VendorPayment.payment_ref == razorpay_order_id).first()
        if not payment:
            raise HTTPException(404, "Payment transaction not found")
            
        order = db.query(VendorOrder).filter(VendorOrder.id == payment.order_id).first()
        if not order:
            raise HTTPException(404, "Order associated with payment not found")

        # 3. Mark Payment as Completed
        payment.status = "completed"
        payment.paid_at = datetime.utcnow()
        # Optionally create a new field to store the actual payment_id if needed, or append to notes
        
        # 4. Mark Order as Confirmed
        order.status = "confirmed"
        order.confirmed_at = datetime.utcnow()
        
        # 5. Mark Event as Confirmed
        event = db.query(Event).filter(Event.id == order.event_id).first()
        if event:
             event.status = EventStatus.CONFIRMED
            
        db.commit()

        return {
            "transaction_id": razorpay_payment_id,
            "status": "success",
            "amount": payment.amount, 
            "message": "Payment verified successfully. Event is confirmed."
        }
