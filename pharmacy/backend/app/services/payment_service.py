"""Razorpay Payment Service for handling online payments"""
import razorpay
import hmac
import hashlib
import logging
from typing import Optional, Dict, Any, TYPE_CHECKING
from sqlalchemy.orm import Session

from app.config import settings
from app.models.order import Order, PaymentStatus, PaymentMethod

if TYPE_CHECKING:
    from app.services.audit_service import AuditService

logger = logging.getLogger(__name__)


class RazorpayService:
    """Service for Razorpay payment gateway operations"""
    
    def __init__(self, db: Session, audit_service: Optional["AuditService"] = None):
        self.db = db
        self.audit_service = audit_service
        self.client = razorpay.Client(
            auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET)
        )
    
    def create_razorpay_order(self, order_id: int) -> Dict[str, Any]:
        """
        Create a Razorpay order for the given internal order.
        
        Args:
            order_id: Internal order ID
            
        Returns:
            Dict with razorpay_order_id, amount, currency, and key
            
        Raises:
            ValueError: If order not found or already paid
        """
        order = self.db.query(Order).filter(Order.id == order_id).first()
        if not order:
            raise ValueError(f"Order {order_id} not found")
        
        if order.payment_status == PaymentStatus.PAID:
            raise ValueError(f"Order {order_id} is already paid")
        
        # If Razorpay order already exists and not paid, return existing
        if order.razorpay_order_id:
            try:
                rz_order = self.client.order.fetch(order.razorpay_order_id)
                if rz_order.get('status') != 'paid':
                    return {
                        "razorpay_order_id": order.razorpay_order_id,
                        "razorpay_key": settings.RAZORPAY_KEY_ID,
                        "amount": int(order.total_amount * 100),  # Convert to paise
                        "currency": "INR",
                        "order_id": order.id,
                        "order_number": order.order_number,
                        "customer_name": order.customer.full_name if order.customer else None,
                        "customer_email": order.customer_email,
                        "customer_phone": order.customer_phone,
                        "description": f"Payment for Order #{order.order_number}"
                    }
            except Exception as e:
                logger.warning(f"Failed to fetch existing Razorpay order: {e}")
        
        # Create new Razorpay order
        amount_paise = int(order.total_amount * 100)  # Convert to paise
        
        razorpay_order_data = {
            "amount": amount_paise,
            "currency": "INR",
            "receipt": order.order_number,
            "notes": {
                "order_id": str(order.id),
                "store_id": str(order.store_id)
            }
        }
        
        try:
            rz_order = self.client.order.create(data=razorpay_order_data)
        except Exception as e:
            logger.error(f"Razorpay order creation failed: {e}")
            raise ValueError(f"Payment gateway error: {str(e)}")
        
        # Save Razorpay order ID to our order
        order.razorpay_order_id = rz_order['id']
        self.db.commit()
        
        # Log the action
        if self.audit_service:
            self.audit_service.log_action(
                action="CREATE_PAYMENT_ORDER",
                entity_type="Order",
                entity_id=order.id,
                new_data={"razorpay_order_id": rz_order['id']},
                user_id=order.customer_id
            )
        
        return {
            "razorpay_order_id": rz_order['id'],
            "razorpay_key": settings.RAZORPAY_KEY_ID,
            "amount": amount_paise,
            "currency": "INR",
            "order_id": order.id,
            "order_number": order.order_number,
            "customer_name": order.customer.full_name if order.customer else None,
            "customer_email": order.customer_email,
            "customer_phone": order.customer_phone,
            "description": f"Payment for Order #{order.order_number}"
        }
    
    def verify_payment(
        self,
        order_id: int,
        razorpay_order_id: str,
        razorpay_payment_id: str,
        razorpay_signature: str,
        user_id: Optional[int] = None
    ) -> Dict[str, Any]:
        """
        Verify Razorpay payment signature and update order status.
        
        Args:
            order_id: Internal order ID
            razorpay_order_id: Razorpay order ID
            razorpay_payment_id: Razorpay payment ID
            razorpay_signature: Razorpay signature
            user_id: User performing the action
            
        Returns:
            Dict with verification result
            
        Raises:
            ValueError: If verification fails
        """
        order = self.db.query(Order).filter(Order.id == order_id).first()
        if not order:
            raise ValueError(f"Order {order_id} not found")
        
        # Verify signature
        key_secret = settings.RAZORPAY_KEY_SECRET
        msg = f"{razorpay_order_id}|{razorpay_payment_id}"
        generated_signature = hmac.new(
            key_secret.encode('utf-8'),
            msg.encode('utf-8'),
            hashlib.sha256
        ).hexdigest()
        
        if generated_signature != razorpay_signature:
            # Log failed verification attempt
            if self.audit_service:
                self.audit_service.log_action(
                    action="PAYMENT_VERIFICATION_FAILED",
                    entity_type="Order",
                    entity_id=order.id,
                    new_data={
                        "razorpay_payment_id": razorpay_payment_id,
                        "reason": "Signature mismatch"
                    },
                    user_id=user_id
                )
            raise ValueError("Payment verification failed: Invalid signature")
        
        # Update order with payment details
        order.razorpay_payment_id = razorpay_payment_id
        order.razorpay_signature = razorpay_signature
        order.payment_status = PaymentStatus.PAID
        order.payment_method = PaymentMethod.RAZORPAY
        
        self.db.commit()
        
        # Log successful payment
        if self.audit_service:
            self.audit_service.log_action(
                action="PAYMENT_VERIFIED",
                entity_type="Order",
                entity_id=order.id,
                new_data={
                    "razorpay_payment_id": razorpay_payment_id,
                    "payment_status": "PAID"
                },
                user_id=user_id
            )
        
        return {
            "success": True,
            "message": "Payment verified successfully",
            "order_id": order.id,
            "order_number": order.order_number,
            "payment_status": order.payment_status.value,
            "razorpay_payment_id": razorpay_payment_id
        }
    
    def get_payment_status(self, order_id: int) -> Dict[str, Any]:
        """
        Get payment status for an order.
        
        Args:
            order_id: Internal order ID
            
        Returns:
            Dict with payment status details
        """
        order = self.db.query(Order).filter(Order.id == order_id).first()
        if not order:
            raise ValueError(f"Order {order_id} not found")
        
        return {
            "order_id": order.id,
            "order_number": order.order_number,
            "payment_status": order.payment_status.value,
            "payment_method": order.payment_method.value if order.payment_method else None,
            "razorpay_order_id": order.razorpay_order_id,
            "razorpay_payment_id": order.razorpay_payment_id,
            "total_amount": order.total_amount,
            "is_paid": order.payment_status == PaymentStatus.PAID
        }
    
    def process_webhook(self, payload: Dict[str, Any], signature: str) -> Dict[str, Any]:
        """
        Process Razorpay webhook for payment events.
        
        Args:
            payload: Webhook payload
            signature: Razorpay webhook signature
            
        Returns:
            Dict with processing result
        """
        # Verify webhook signature
        webhook_secret = settings.RAZORPAY_WEBHOOK_SECRET
        if webhook_secret:
            try:
                self.client.utility.verify_webhook_signature(
                    str(payload),
                    signature,
                    webhook_secret
                )
            except Exception as e:
                logger.error(f"Webhook signature verification failed: {e}")
                raise ValueError("Invalid webhook signature")
        
        event = payload.get('event')
        
        if event == 'payment.captured':
            payment = payload.get('payload', {}).get('payment', {}).get('entity', {})
            razorpay_order_id = payment.get('order_id')
            razorpay_payment_id = payment.get('id')
            
            # Find order by Razorpay order ID
            order = self.db.query(Order).filter(
                Order.razorpay_order_id == razorpay_order_id
            ).first()
            
            if order and order.payment_status != PaymentStatus.PAID:
                order.razorpay_payment_id = razorpay_payment_id
                order.payment_status = PaymentStatus.PAID
                order.payment_method = PaymentMethod.RAZORPAY
                self.db.commit()
                
                logger.info(f"Order {order.id} marked as PAID via webhook")
        
        elif event == 'payment.failed':
            payment = payload.get('payload', {}).get('payment', {}).get('entity', {})
            razorpay_order_id = payment.get('order_id')
            
            order = self.db.query(Order).filter(
                Order.razorpay_order_id == razorpay_order_id
            ).first()
            
            if order:
                order.payment_status = PaymentStatus.FAILED
                self.db.commit()
                
                logger.info(f"Order {order.id} marked as FAILED via webhook")
        
        elif event == 'refund.created':
            refund = payload.get('payload', {}).get('refund', {}).get('entity', {})
            payment_id = refund.get('payment_id')
            
            order = self.db.query(Order).filter(
                Order.razorpay_payment_id == payment_id
            ).first()
            
            if order:
                order.payment_status = PaymentStatus.REFUNDED
                self.db.commit()
                
                logger.info(f"Order {order.id} marked as REFUNDED via webhook")
        
        return {"status": "ok", "message": "Webhook processed successfully"}
    
    def initiate_refund(
        self,
        order_id: int,
        amount: Optional[float] = None,
        reason: Optional[str] = None,
        user_id: Optional[int] = None
    ) -> Dict[str, Any]:
        """
        Initiate a refund for a paid order.
        
        Args:
            order_id: Internal order ID
            amount: Refund amount (optional, defaults to full refund)
            reason: Reason for refund
            user_id: User initiating the refund
            
        Returns:
            Dict with refund details
            
        Raises:
            ValueError: If refund cannot be initiated
        """
        order = self.db.query(Order).filter(Order.id == order_id).first()
        if not order:
            raise ValueError(f"Order {order_id} not found")
        
        if order.payment_status != PaymentStatus.PAID:
            raise ValueError("Cannot refund: Order is not in PAID status")
        
        if not order.razorpay_payment_id:
            raise ValueError("Cannot refund: No Razorpay payment ID found")
        
        # Determine refund amount
        refund_amount = amount if amount else order.total_amount
        refund_amount_paise = int(refund_amount * 100)
        
        refund_data = {
            "amount": refund_amount_paise,
            "speed": "normal"
        }
        
        if reason:
            refund_data["notes"] = {"reason": reason}
        
        try:
            refund = self.client.payment.refund(
                order.razorpay_payment_id,
                refund_data
            )
        except Exception as e:
            logger.error(f"Refund initiation failed: {e}")
            raise ValueError(f"Refund failed: {str(e)}")
        
        # Update order status
        order.payment_status = PaymentStatus.REFUNDED
        self.db.commit()
        
        # Log the refund
        if self.audit_service:
            self.audit_service.log_action(
                action="REFUND_INITIATED",
                entity_type="Order",
                entity_id=order.id,
                new_data={
                    "refund_id": refund.get('id'),
                    "refund_amount": refund_amount,
                    "reason": reason
                },
                user_id=user_id
            )
        
        return {
            "success": True,
            "message": "Refund initiated successfully",
            "refund_id": refund.get('id'),
            "order_id": order.id,
            "refund_amount": refund_amount,
            "refund_status": refund.get('status', 'initiated')
        }
