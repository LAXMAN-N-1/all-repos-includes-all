"""
Invoice email delivery endpoints
"""
from typing import Any
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import os

from app import models
from app.api import deps

router = APIRouter()


@router.post("/invoices/{invoice_id}/send-email")
def send_invoice_email(
    invoice_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Send invoice PDF via email to customer (Staff Only)
    """
    invoice = db.query(models.Invoice).filter(models.Invoice.id == invoice_id).first()
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")
    
    customer = db.query(models.Customer).filter(models.Customer.id == invoice.customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    
    if not invoice.pdf_url:
        raise HTTPException(status_code=400, detail="Invoice PDF not generated yet")
    
    # Convert PDF URL to file path
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
    pdf_path = os.path.join(base_dir, "static", "invoices", f"invoice_{invoice.id}.pdf")
    
    if not os.path.exists(pdf_path):
        raise HTTPException(status_code=404, detail="PDF file not found on server")
    
    # Send email
    from app.services.email import email_service
    success = email_service.send_invoice_email(
        customer_email=customer.email,
        customer_name=customer.name,
        invoice_id=invoice.id,
        pdf_path=pdf_path
    )
    
    if success:
        # Update invoice status to 'sent' if it was 'draft'
        if invoice.status == "draft":
            invoice.status = "sent"
            db.add(invoice)
            db.commit()
        
        return {"message": f"Invoice sent successfully to {customer.email}", "email_sent": True}
    else:
        return {"message": "Email service not configured. Invoice not sent.", "email_sent": False}


@router.post("/invoices/combined/{combined_id}/send-email")
def send_combined_invoice_email(
    combined_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Send combined invoice (statement) PDF via email to customer (Staff Only)
    """
    combined = db.query(models.CombinedInvoice).filter(models.CombinedInvoice.id == combined_id).first()
    if not combined:
        raise HTTPException(status_code=404, detail="Combined invoice not found")
    
    customer = db.query(models.Customer).filter(models.Customer.id == combined.customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    
    if not combined.pdf_url:
        raise HTTPException(status_code=400, detail="Combined invoice PDF not generated yet")
    
    # Convert PDF URL to file path
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
    pdf_path = os.path.join(base_dir, "static", "invoices", f"combined_invoice_{combined.id}.pdf")
    
    if not os.path.exists(pdf_path):
        raise HTTPException(status_code=404, detail="PDF file not found on server")
    
    # Send email
    from app.services.email import email_service
    success = email_service.send_invoice_email(
        customer_email=customer.email,
        customer_name=customer.name,
        invoice_id=combined.id,
        pdf_path=pdf_path
    )
    
    if success:
        # Update status to 'sent' if it was 'draft'
        if combined.status == "draft":
            combined.status = "sent"
            db.add(combined)
            db.commit()
        
        return {"message": f"Statement sent successfully to {customer.email}", "email_sent": True}
    else:
        return {"message": "Email service not configured. Statement not sent.", "email_sent": False}
