from fastapi import APIRouter, Depends, HTTPException, Request, Header
from sqlalchemy.orm import Session
from typing import Any
import stripe
import logging

from app import models, schemas
from app.api import deps
from app.core.config import settings
from app.core import stripe_utils
from app.schemas.stripe_schemas import (
    StripePaymentIntentCreate, 
    StripePaymentIntentResponse,
    StripeCheckoutSessionCreate,
    StripeCheckoutSessionResponse
)

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/checkout-session", response_model=StripeCheckoutSessionResponse)
def create_checkout_session(
    *,
    db: Session = Depends(deps.get_db),
    session_in: StripeCheckoutSessionCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create a Stripe Checkout Session for an order.
    """
    order = db.query(models.Order).filter(models.Order.id == session_in.order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    amount = int(order.total_amount * 100)
    if amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be greater than zero")

    metadata = {
        "order_id": order.id,
        "user_id": current_user.id,
        "email": current_user.email,
        "customer_phone": order.customer.phone if (order.customer and order.customer.phone) else ""
    }

    try:
        session = stripe_utils.create_checkout_session(
            amount=amount,
            currency="usd",
            name=f"Order #{order.id}",
            success_url=session_in.success_url,
            cancel_url=session_in.cancel_url,
            metadata=metadata
        )
        return {"url": session.url}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/create-payment-intent", response_model=StripePaymentIntentResponse)
def create_payment_intent(
    *,
    db: Session = Depends(deps.get_db),
    payment_in: StripePaymentIntentCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create a Stripe Payment Intent for an order or invoice.
    """
    amount = 0
    metadata = {
        "user_id": current_user.id,
        "email": current_user.email
    }

    if payment_in.order_id:
        order = db.query(models.Order).filter(models.Order.id == payment_in.order_id).first()
        if not order:
            raise HTTPException(status_code=404, detail="Order not found")
        amount = int(order.total_amount * 100)
        metadata["order_id"] = order.id
    elif payment_in.invoice_id:
        invoice = db.query(models.Invoice).filter(models.Invoice.id == payment_in.invoice_id).first()
        if not invoice:
            raise HTTPException(status_code=404, detail="Invoice not found")
        amount = int(invoice.amount_due * 100)
        metadata["invoice_id"] = invoice.id
    elif payment_in.combined_invoice_id:
        combined_invoice = db.query(models.CombinedInvoice).filter(models.CombinedInvoice.id == payment_in.combined_invoice_id).first()
        if not combined_invoice:
            raise HTTPException(status_code=404, detail="Combined Invoice not found")
        amount = int(combined_invoice.total_amount * 100)
        metadata["combined_invoice_id"] = combined_invoice.id
    elif payment_in.amount_override:
        amount = int(payment_in.amount_override * 100)
    else:
        raise HTTPException(status_code=400, detail="Missing order_id, invoice_id, or amount_override")

    if amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be greater than zero")

    try:
        intent = stripe_utils.create_payment_intent(
            amount=amount,
            currency=payment_in.currency,
            metadata=metadata
        )
        return {
            "client_secret": intent.client_secret,
            "payment_intent_id": intent.id,
            "amount": amount / 100.0,
            "currency": payment_in.currency
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/webhook")
async def stripe_webhook(
    request: Request,
    stripe_signature: str = Header(None)
):
    """
    Stripe webhook handler to process payment success/failure.
    """
    payload = await request.body()
    
    try:
        event = stripe.Webhook.construct_event(
            payload, stripe_signature, settings.STRIPE_WEBHOOK_SECRET
        )
    except ValueError as e:
        # Invalid payload
        raise HTTPException(status_code=400, detail="Invalid payload")
    except stripe.error.SignatureVerificationError as e:
        # Invalid signature
        raise HTTPException(status_code=400, detail="Invalid signature")

    # Handle the event
    if event['type'] == 'payment_intent.succeeded':
        payment_intent = event['data']['object']
        await handle_payment_success(payment_intent)
    elif event['type'] == 'payment_intent.payment_failed':
        payment_intent = event['data']['object']
        # Handle failure (log, notify user, etc.)
        print(f"Payment failed for Intent: {payment_intent['id']}")
    elif event['type'] == 'checkout.session.completed':
        session_obj = event['data']['object']
        await handle_checkout_session_completed(session_obj)

    return {"status": "success"}

@router.get("/payment-success")
async def payment_success(order_id: int):
    """HTML redirect for successful payment (web customer portal)."""
    from fastapi.responses import HTMLResponse
    shop_url = (settings.PUBLIC_BASE_URL or "").rstrip("/") or "#"
    return HTMLResponse(content=f"""
        <html>
            <head><title>Payment Successful</title></head>
            <body style="font-family: sans-serif; text-align: center; padding: 60px; background: #f7f9fc;">
                <div style="max-width:480px; margin:auto; background:#fff; border-radius:16px; padding:40px; box-shadow:0 4px 24px rgba(0,0,0,0.08);">
                    <div style="font-size:56px;">✅</div>
                    <h1 style="color: #4CAF50; margin-top:16px;">Payment Successful!</h1>
                    <p style="color:#555;">Your payment for Order <b>#{order_id}</b> was received.</p>
                    <p style="color:#888; font-size:13px;">You can close this tab or return to the shop.</p>
                    <a href="{shop_url}" style="display:inline-block; margin-top:24px; padding:14px 32px; background:#635BFF; color:#fff; border-radius:10px; text-decoration:none; font-weight:bold;">Return to Shop</a>
                </div>
            </body>
        </html>
    """)

@router.get("/payment-cancelled")
async def payment_cancelled(order_id: int):
    """HTML redirect for cancelled payment (web customer portal)."""
    from fastapi.responses import HTMLResponse
    shop_url = (settings.PUBLIC_BASE_URL or "").rstrip("/") or "#"
    return HTMLResponse(content=f"""
        <html>
            <head><title>Payment Cancelled</title></head>
            <body style="font-family: sans-serif; text-align: center; padding: 60px; background: #f7f9fc;">
                <div style="max-width:480px; margin:auto; background:#fff; border-radius:16px; padding:40px; box-shadow:0 4px 24px rgba(0,0,0,0.08);">
                    <div style="font-size:56px;">❌</div>
                    <h1 style="color: #f44336; margin-top:16px;">Payment Cancelled</h1>
                    <p style="color:#555;">Payment for Order <b>#{order_id}</b> was not completed.</p>
                    <p style="color:#888; font-size:13px;">Your cart is still saved. You can go back and try again.</p>
                    <a href="{shop_url}" style="display:inline-block; margin-top:24px; padding:14px 32px; background:#635BFF; color:#fff; border-radius:10px; text-decoration:none; font-weight:bold;">Back to Shop</a>
                </div>
            </body>
        </html>
    """)

async def handle_checkout_session_completed(session_obj):
    """
    Handle successful Stripe Checkout session.
    """
    from app.db.session import SessionLocal
    from app.api.endpoints.whatsapp import finalize_and_notify_order
    
    db = SessionLocal()
    try:
        metadata = session_obj.get('metadata', {})
        order_id = metadata.get('order_id')
        customer_phone = metadata.get('customer_phone')
        
        if not order_id:
            logger.error("No order_id in checkout session metadata")
            return

        order = db.query(models.Order).filter(models.Order.id == int(order_id)).first()
        if order:
            order.payment_status = "paid"
            db.add(order)
            
            # Create payment record
            payment = models.Payment(
                customer_id=order.customer_id,
                amount=session_obj['amount_total'] / 100.0,
                payment_method="STRIPE_CHECKOUT",
                reference_id=session_obj['id'],
                status="confirmed",
                notes=f"Stripe Checkout Succeeded. Session: {session_obj['id']}"
            )
            db.add(payment)
            db.commit()
            
            # Notify user via WhatsApp
            if customer_phone:
                # We pass an empty session dict because finalize_and_notify_order 
                # now pulls what it needs from the DB order object.
                finalize_and_notify_order(customer_phone, {}, db, order.id, "Credit Card (Stripe)")
                
    except Exception as e:
        db.rollback()
        import logging
        logging.getLogger(__name__).error(f"Error handling checkout success: {e}")
    finally:
        db.close()

async def handle_payment_success(payment_intent):
    """
    Link Stripe success to our internal Payment, Order, and Invoice models.
    """
    from app.db.session import SessionLocal
    db = SessionLocal()
    try:
        metadata = payment_intent.get('metadata', {})
        order_id = metadata.get('order_id')
        invoice_id = metadata.get('invoice_id')
        combined_invoice_id = metadata.get('combined_invoice_id')
        user_id = metadata.get('user_id')
        amount = payment_intent['amount'] / 100.0

        # 1. Create a Payment record
        payment = models.Payment(
            customer_id=None, # Need to find customer_id if not in metadata
            invoice_id=int(invoice_id) if invoice_id else None,
            combined_invoice_id=int(combined_invoice_id) if combined_invoice_id else None,
            amount=amount,
            payment_method="STRIPE",
            reference_id=payment_intent['id'],
            status="confirmed",
            notes=f"Stripe Payment Succeeded. Intent: {payment_intent['id']}"
        )

        # Try to find customer_id from order or user
        if order_id:
            order = db.query(models.Order).filter(models.Order.id == int(order_id)).first()
            if order:
                payment.customer_id = order.customer_id
                order.payment_status = "paid"
                db.add(order)
        elif user_id:
            user = db.query(models.User).filter(models.User.id == int(user_id)).first()
            # If user is a partner, we might find their customer record
            # This depends on how partners are linked to customers
            pass

        db.add(payment)
        
        # 2. Update Invoice status
        if invoice_id:
            invoice = db.query(models.Invoice).filter(models.Invoice.id == int(invoice_id)).first()
            if invoice:
                invoice.status = "paid"
                if not payment.customer_id:
                    payment.customer_id = invoice.customer_id
                db.add(invoice)
        
        if combined_invoice_id:
            combined = db.query(models.CombinedInvoice).filter(models.CombinedInvoice.id == int(combined_invoice_id)).first()
            if combined:
                combined.status = "paid"
                if not payment.customer_id:
                    payment.customer_id = combined.customer_id
                # Update all sub-invoices
                for inv in combined.invoices:
                    inv.status = "paid"
                    db.add(inv)
                db.add(combined)

        db.commit()
    except Exception as e:
        db.rollback()
        print(f"Error handling payment success: {e}")
    finally:
        db.close()
