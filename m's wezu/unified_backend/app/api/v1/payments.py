"""
Payments, Invoices, Refunds and Webhook API
Canonical module for payment methods, transactions, revenue dashboards,
refund workflows, invoice generation, and Razorpay webhook handling.
"""
from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException, status, Request
from fastapi.responses import StreamingResponse
from sqlmodel import Session, select
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, UTC, timedelta

from app.api import deps
from app.core.audit import audit_log
from app.core.config import settings
from app.models.user import User
from app.models.catalog import CatalogOrder
from app.models.rental import Rental
from app.models.financial import Transaction, Wallet
from app.models.payment_method import PaymentMethod
from app.models.refund import Refund
from app.services.invoice_service import InvoiceService
from app.services.analytics_service import AnalyticsService
from app.services.payment_service import PaymentService
from app.services.payment_method_service import PaymentMethodService
from app.services.razorpay_webhook_service import RazorpayWebhookService
from app.schemas.common import DataResponse
from app.schemas.payment import (
    RevenueSummary, StationRevenueResponse, 
    RevenueForecastResponse, ProfitMarginResponse
)

router = APIRouter()
admin_router = APIRouter()

# Schemas
class RefundRequest(BaseModel):
    transaction_id: Optional[int] = None
    order_id: Optional[int] = None
    reason: str
    amount: Optional[float] = None  # If None, full refund

class PaymentMethodCreate(BaseModel):
    type: str  # card, upi, netbanking
    provider_token: str
    provider: str = "razorpay"
    is_default: bool = False
    details: dict = Field(default_factory=dict)


def _get_owned_transaction(db: Session, user_id: int, transaction_id: int) -> Optional[Transaction]:
    return db.exec(
        select(Transaction)
        .join(Wallet, Wallet.id == Transaction.wallet_id)
        .where(Transaction.id == transaction_id, Wallet.user_id == user_id)
    ).first()

# Payment Method Endpoints
@router.post("/methods")
async def add_payment_method(
    method: PaymentMethodCreate,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db)
):
    """Add a new payment method"""
    method_row, created = PaymentMethodService.add_method(
        session,
        user_id=current_user.id,
        method_type=method.type,
        provider_token=method.provider_token,
        provider=method.provider,
        is_default=method.is_default,
        details=method.details,
    )
    return {
        "message": "Payment method added successfully" if created else "Payment method already exists",
        "created": created,
        "method_id": method_row.id,
        "method": PaymentMethodService.serialize(method_row),
    }

@router.delete("/methods/{method_id}")
async def delete_payment_method(
    method_id: int,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db)
):
    """Delete a payment method"""
    PaymentMethodService.delete_method(session, user_id=current_user.id, method_id=method_id)
    return {"message": "Payment method deleted successfully", "method_id": method_id}


@router.post("/methods/{method_id}/default")
def set_default_payment_method(
    method_id: int,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db),
):
    selected = session.exec(
        select(PaymentMethod)
        .where(PaymentMethod.id == method_id)
        .where(PaymentMethod.user_id == current_user.id)
        .where(PaymentMethod.status == "active")
    ).first()
    if not selected:
        raise HTTPException(status_code=404, detail="Payment method not found")

    active_methods = session.exec(
        select(PaymentMethod)
        .where(PaymentMethod.user_id == current_user.id)
        .where(PaymentMethod.status == "active")
    ).all()
    now = datetime.now(UTC)
    for row in active_methods:
        row.is_default = row.id == selected.id
        row.updated_at = now
        session.add(row)
    session.commit()
    return {"message": "Default payment method updated", "method_id": selected.id}


# Invoice Endpoints
@router.get("/orders/{order_id}/invoice", response_class=StreamingResponse)
def download_order_invoice(
    order_id: int,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db)
):
    """
    Download PDF invoice for order
    Returns PDF file
    """
    # Verify order belongs to user
    order = session.get(CatalogOrder, order_id)
    if not order or order.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    
    # Generate invoice
    pdf_buffer = InvoiceService.generate_order_invoice(order_id, session)
    
    if not pdf_buffer:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate invoice"
        )
    
    return StreamingResponse(
        pdf_buffer,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f"attachment; filename=invoice_{order.order_number}.pdf"
        }
    )

@router.get("/rentals/{rental_id}/invoice", response_class=StreamingResponse)
def download_rental_invoice(
    rental_id: int,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db)
):
    """Download PDF invoice for rental"""
    # Verify rental belongs to user
    rental = session.get(Rental, rental_id)
    if not rental or rental.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Rental not found"
        )
    
    pdf_buffer = InvoiceService.generate_rental_invoice(rental_id, session)
    
    if not pdf_buffer:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate invoice"
        )
    
    return StreamingResponse(
        pdf_buffer,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f"attachment; filename=rental_invoice_{rental_id}.pdf"
        }
    )



# Moved up to avoid route precedence issues with /{id}
@router.get("/payment-methods", response_model=DataResponse[dict])
def get_payment_methods(
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db),
):
    """Get available payment methods"""
    saved_methods = PaymentMethodService.list_serialized_methods(session, current_user.id)
    default_method_id = next((item["id"] for item in saved_methods if item.get("is_default")), None)
    return DataResponse(
        success=True,
        data={
            "methods": PaymentMethodService.available_method_catalog(),
            "saved_methods": saved_methods,
            "default_method_id": default_method_id,
        }
    )

@router.get("/{id}", response_model=DataResponse[dict])
def get_payment_detail(
    id: int,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db)
):
    """Single transaction detail"""
    txn = session.get(Transaction, id)
    if not txn or (txn.user_id != current_user.id and not current_user.is_superuser):
        raise HTTPException(status_code=404, detail="Transaction not found")
    return DataResponse(success=True, data=txn)

@admin_router.post("/transactions/{id}/refund", response_model=DataResponse[dict])
def admin_initiate_refund(
    id: int,
    request: RefundRequest,
    current_user: User = Depends(deps.get_current_active_admin),
    session: Session = Depends(deps.get_db)
):
    """Admin: initiate manual refund for a transaction"""
    txn = session.get(Transaction, id)
    if not txn:
        raise HTTPException(status_code=404, detail="Transaction not found")
        
    # Call PaymentService to refund via gateway
    rf_data = PaymentService.refund_transaction(txn.payment_gateway_ref, request.amount)
    
    # Update local DB or Transaction status if successful handled in webhook too
    txn.status = "refunded"
    session.add(txn)
    session.commit()
    
    return DataResponse(success=True, data={"refund_id": rf_data.get("id"), "status": "initiated"})

@router.get("/{id}/refund-status", response_model=DataResponse[dict])
def get_refund_status(
    id: int,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db),
):
    """Track refund processing status for a transaction the current user owns."""
    # Ownership check via wallet join — returns None for transactions belonging
    # to other users, preventing ID-enumeration of refund state.
    transaction = _get_owned_transaction(session, current_user.id, id)
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")

    refund = session.exec(select(Refund).where(Refund.transaction_id == id)).first()
    if not refund:
        raise HTTPException(status_code=404, detail="No refund found for this transaction")
    return DataResponse(success=True, data={"status": refund.status, "processed_at": refund.processed_at})

@admin_router.get("/transactions", response_model=DataResponse[list])
def admin_get_all_payments(
    status: Optional[str] = None,
    user_id: Optional[int] = None,
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(deps.get_current_active_admin),
    session: Session = Depends(deps.get_db)
):
    """Admin: all platform transactions with filters"""
    statement = select(Transaction)
    if status:
        statement = statement.where(Transaction.status == status)
    if user_id:
        statement = statement.where(Transaction.user_id == user_id)
        
    txns = session.exec(statement.offset(skip).limit(limit).order_by(Transaction.created_at.desc())).all()
    return DataResponse(success=True, data=txns)

# Revenue Dashboards
@admin_router.get("/revenue", response_model=DataResponse[RevenueSummary])
def get_revenue_dashboard(
    period: str = "daily",  # daily, weekly, monthly
    current_user: User = Depends(deps.get_current_active_admin),
    session: Session = Depends(deps.get_db)
):
    """Revenue summary with comparison"""
    # Define time range
    end = datetime.now(UTC)
    if period == "weekly":
        start = end - timedelta(days=7)
    elif period == "monthly":
        start = end - timedelta(days=30)
    else:
        start = end - timedelta(days=1)
        
    stats = AnalyticsService.get_revenue_stats(session, start, end)
    return DataResponse(success=True, data=stats)

@admin_router.get("/revenue/by-station", response_model=DataResponse[List[StationRevenueResponse]])
def get_revenue_by_station(
    current_user: User = Depends(deps.get_current_active_admin),
    session: Session = Depends(deps.get_db)
):
    """Revenue broken down per station"""
    data = AnalyticsService.get_revenue_by_station(session)
    return DataResponse(success=True, data=data)

@admin_router.get("/revenue/forecast", response_model=DataResponse[List[RevenueForecastResponse]])
def get_revenue_forecast(
    days: int = 30,
    current_user: User = Depends(deps.get_current_active_admin),
    session: Session = Depends(deps.get_db)
):
    """Projected revenue for next 30 days"""
    data = AnalyticsService.calculate_revenue_forecast(session, days)
    return DataResponse(success=True, data=data)

@admin_router.get("/profit-margins", response_model=DataResponse[List[ProfitMarginResponse]])
def get_profit_margins(
    current_user: User = Depends(deps.get_current_active_admin),
    session: Session = Depends(deps.get_db)
):
    """Margin analysis per station"""
    data = AnalyticsService.get_profit_margins(session)
    return DataResponse(success=True, data=data)

# Refund Endpoints
@router.post("/orders/{order_id}/refund", response_model=DataResponse[dict])
@audit_log("REQUEST_REFUND", "PAYMENT", resource_id_param="order_id")
def request_refund(
    order_id: int,
    request: RefundRequest,
    http_request: Request = None,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db)
):
    """
    Request refund for order
    Creates refund request for admin approval
    """
    order = session.get(CatalogOrder, order_id)
    if not order or order.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    
    if order.status not in ["CONFIRMED", "SHIPPED"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Order cannot be refunded"
        )
    
    # Create refund transaction
    from app.models.financial import Transaction
    from datetime import datetime, UTC
    
    refund_amount = request.amount or order.total_amount
    
    transaction = Transaction(
        user_id=current_user.id,
        order_id=order_id,
        transaction_type="REFUND",
        amount=refund_amount,
        status="PENDING",
        description=f"Refund request: {request.reason}",
        created_at=datetime.now(UTC)
    )
    session.add(transaction)
    session.commit()
    
    return DataResponse(
        success=True,
        data={
            "transaction_id": transaction.id,
            "refund_amount": refund_amount,
            "status": "PENDING",
            "message": "Refund request submitted. Processing time: 3-5 business days"
        }
    )

@router.get("/refunds", response_model=DataResponse[list])
def get_user_refunds(
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db)
):
    """List refund requests submitted by the user (pending/completed Transaction rows of type REFUND).
    For gateway-confirmed refund records with metadata, use GET /refunds/history."""
    from app.models.financial import Transaction
    from sqlmodel import select
    
    refunds = session.exec(
        select(Transaction)
        .where(Transaction.user_id == current_user.id)
        .where(Transaction.transaction_type == "REFUND")
        .order_by(Transaction.created_at.desc())
    ).all()
    
    return DataResponse(
        success=True,
        data=[
            {
                "id": refund.id,
                "order_id": refund.order_id,
                "amount": refund.amount,
                "status": refund.status,
                "description": refund.description,
                "created_at": refund.created_at.isoformat()
            }
            for refund in refunds
        ]
    )


@router.get("/refunds/history")
def list_refunds(
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db),
):
    """List gateway-confirmed Refund records with processing metadata (gateway_refund_id, processed_at).
    For user-submitted refund requests (pending state), use GET /refunds."""
    rows = session.exec(
        select(Refund, Transaction)
        .join(Transaction, Refund.transaction_id == Transaction.id)
        .join(Wallet, Transaction.wallet_id == Wallet.id)
        .where(Wallet.user_id == current_user.id)
        .order_by(Refund.created_at.desc())
    ).all()
    return [
        {
            "id": refund.id,
            "transaction_id": transaction.id,
            "amount": float(refund.amount),
            "status": refund.status,
            "reason": refund.reason,
            "created_at": refund.created_at,
            "processed_at": refund.processed_at,
            "gateway_refund_id": refund.gateway_refund_id,
        }
        for refund, transaction in rows
    ]


@router.get("/{transaction_id}/receipt")
def get_receipt(
    transaction_id: int,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db),
):
    """Get receipt metadata for a wallet transaction."""
    transaction = _get_owned_transaction(session, current_user.id, transaction_id)
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")

    return {
        "transaction_id": transaction.id,
        "amount": transaction.amount,
        "status": transaction.status,
        "type": transaction.type,
        "category": transaction.category,
        "created_at": transaction.created_at,
        "description": transaction.description,
        "receipt_url": f"/receipts/{transaction.id}.pdf",
    }


@router.get("/invoice/{transaction_id}")
def get_invoice(
    transaction_id: int,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db),
):
    """Get invoice metadata for a wallet transaction."""
    transaction = _get_owned_transaction(session, current_user.id, transaction_id)
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")

    amount = Decimal(str(transaction.amount)).quantize(Decimal("0.01"))
    gst = (amount * Decimal(str(settings.GST_RATE))).quantize(Decimal("0.01"))

    return {
        "invoice_id": f"INV-{transaction.id}",
        "transaction_id": transaction.id,
        "amount": float(amount),
        "gst": float(gst),
        "total": float(amount + gst),
        "status": transaction.status,
        "description": transaction.description,
        "invoice_url": f"/invoices/{transaction.id}.pdf",
    }


# Razorpay Webhook

@router.post("/webhooks/razorpay")
async def razorpay_webhook(
    request: Request,
    session: Session = Depends(deps.get_db),
):
    """
    Handle Razorpay webhooks via queue (with sync fallback).
    """
    body = await request.body()
    signature = request.headers.get("X-Razorpay-Signature")
    event_id = request.headers.get("X-Razorpay-Event-Id")

    if not RazorpayWebhookService.verify_signature(body, signature):
        raise HTTPException(status_code=400, detail="Invalid signature")

    payload = RazorpayWebhookService.parse_payload(body)
    if settings.WEBHOOK_QUEUE_ENABLED:
        queued_id = RazorpayWebhookService.enqueue_event(
            body=body,
            signature=signature,
            payload=payload,
            source="/api/v1/payments/webhooks/razorpay",
            event_id=event_id,
        )
        if queued_id:
            return {
                "status": "accepted",
                "mode": "queued",
                "queue_id": queued_id,
                "event_id": RazorpayWebhookService.compute_event_id(body, event_id),
            }
        if settings.WEBHOOK_QUEUE_REQUIRED:
            raise HTTPException(status_code=503, detail="Webhook queue is unavailable. Please retry.")

    return RazorpayWebhookService.process_event(session, payload)
