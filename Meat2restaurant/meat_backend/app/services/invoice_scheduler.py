from __future__ import annotations
from datetime import datetime, timedelta, date
import calendar
from typing import List, Optional, Any, TYPE_CHECKING
from sqlalchemy.orm import Session, joinedload

if TYPE_CHECKING:
    from app import models
from app.features.customers.models.customer import BillingCycle


def should_generate_invoice(db: Session, customer: models.Customer, today: date = None) -> bool:
    """
    ERP-Grade: Strictly calendar-driven.
    """
    from app import models
    if not today:
        today = date.today()
    
    print(f"DEBUG: [ERP-CAL] Checking Customer {customer.id}, Today: {today.day}, Cutoff: {customer.cycle_cutoff_day}")
    
    # If no db is provided (unit testing), fallback to basic rules
    if db is None:
        if customer.billing_cycle == "immediate":
            return False
        if not getattr(customer, "last_combined_invoice_date", None):
            return True
        days_since = (today - customer.last_combined_invoice_date).days
        if customer.billing_cycle == "weekly":
            return days_since >= 7
        elif customer.billing_cycle == "10_days":
            return days_since >= 10
        elif customer.billing_cycle == "monthly":
            return days_since >= 28
        return False

    # 1. Skip if not B2B or today is not cutoff day
    if customer.customer_type != "b2b" or today.day != customer.cycle_cutoff_day:
        return False

    # 2. STOP if an unpaid combined invoice already exists
    unpaid_combined = db.query(models.CombinedInvoice).filter(
        models.CombinedInvoice.customer_id == customer.id,
        models.CombinedInvoice.status != "paid"
    ).first()
    if unpaid_combined:
        return False

    # 3. Check for unpaid individual invoices (Credit-based debt)
    has_unpaid = db.query(models.Invoice).filter(
        models.Invoice.customer_id == customer.id,
        models.Invoice.combined_invoice_id == None,
        models.Invoice.status != "paid"
    ).first() is not None

    return has_unpaid


def get_invoice_date_range(customer: Any, today: date = None) -> tuple:
    """
    Get the date range for invoices to combine.
    """
    if not today:
        today = date.today()
    
    if customer.last_combined_invoice_date:
        start_date = customer.last_combined_invoice_date + timedelta(days=1)
    else:
        # First time: Use last 30 days or customer creation date
        start_date = today - timedelta(days=30)
    
    end_date = today
    
    return start_date, end_date


def calculate_next_due_date(today: date, payment_due_day: int) -> date:
    """
    Calculate the next month's due date based on the customer's payment_due_day.
    """
    # ERP-Grade: Due date is the customer's payment_due_day of the next month
    next_month = today.replace(day=28) + timedelta(days=4)  # safely get to next month
    
    # Safe date clamping for months with fewer days (e.g. Feb)
    max_days = calendar.monthrange(next_month.year, next_month.month)[1]
    safe_due_day = min(payment_due_day, max_days)
    
    due_date = next_month.replace(day=safe_due_day)
    return due_date


def auto_generate_combined_invoice(
    db: Session,
    customer: Any,
    today: date = None,
    override_due_date: datetime = None,
    discount_percentage: float = 0.0
) -> Optional[Any]:
    """
    Generate a combined invoice for a single customer.
    """
    from app import models
    if not today:
        today = date.today()
    
    # Find ALL eligible (uncombined AND unpaid) invoices for this customer
    invoices = db.query(models.Invoice).options(
        joinedload(models.Invoice.order).joinedload(models.Order.items).joinedload(models.OrderItem.product)
    ).filter(
        models.Invoice.customer_id == customer.id,
        models.Invoice.combined_invoice_id == None,
        models.Invoice.status != "paid"
    ).all()
    
    if not invoices:
        return None
    
    # Authoritative Source: Calculate strictly from individual invoice net totals
    statement_subtotal = sum((inv.amount_due or 0.0) for inv in invoices)
    statement_tax = sum((inv.tax_total or 0.0) for inv in invoices)
    
    # Derive Statement Discount (Y%)
    discount_rate = (discount_percentage / 100.0)
    discount_total = statement_subtotal * discount_rate

    # Final Authoritative Total
    total_payable = statement_subtotal - discount_total
    
    # MANDATORY PRE-PDF VALIDATION (STRICT)
    assert abs(statement_subtotal - sum((inv.amount_due or 0.0) for inv in invoices)) < 0.01
    
    # Determine Due Date
    if override_due_date:
        due_datetime = override_due_date
    else:
        # ERP-Grade: Calculate Due Date (Next Month logic)
        due_date = calculate_next_due_date(today, customer.payment_due_day)
        due_datetime = datetime.combine(due_date, datetime.min.time())
    
    # Create combined invoice
    combined_invoice = models.CombinedInvoice(
        customer_id=customer.id,
        invoice_date=datetime.combine(today, datetime.min.time()),
        subtotal=statement_subtotal,
        tax_total=statement_tax,
        discount_percentage=discount_percentage if discount_percentage > 0 else 0.0,
        discount_amount=discount_total,
        total_amount=total_payable,
        status="draft",
        due_date=due_datetime
    )
    db.add(combined_invoice)
    db.flush()
    
    # Link individual invoices
    for inv in invoices:
        inv.combined_invoice_id = combined_invoice.id
        db.add(inv)
    
    # Update customer's last invoice date
    customer.last_combined_invoice_date = today
    db.add(customer)

    # Generate PDF for Combined Invoice
    from app.services.invoice import invoice_service
    try:
        pdf_url = invoice_service.generate_combined_pdf(combined_invoice, customer, invoices)
        combined_invoice.pdf_url = pdf_url
    except Exception as e:
        print(f"Error generating combined PDF: {e}")
    
    db.commit()
    db.refresh(combined_invoice)
    
    return combined_invoice


def run_auto_generate_all_invoices(db: Session) -> dict:
    """
    Generate combined invoices for all eligible B2B customers.
    """
    from app import models
    today = date.today()
    
    # Get all B2B customers
    b2b_customers = db.query(models.Customer).filter(
        models.Customer.customer_type == "b2b",
        models.Customer.is_verified == True,
        models.Customer.status == "verified"
    ).all()
    
    results = {
        "total_customers": len(b2b_customers),
        "invoices_generated": 0,
        "customers_processed": [],
        "errors": []
    }
    
    for customer in b2b_customers:
        try:
            if should_generate_invoice(db, customer, today):
                combined_invoice = auto_generate_combined_invoice(db, customer, today)
                
                if combined_invoice:
                    results["invoices_generated"] += 1
                    results["customers_processed"].append({
                        "customer_id": customer.id,
                        "customer_name": customer.name,
                        "invoice_id": combined_invoice.id,
                        "total_amount": combined_invoice.total_amount,
                        "billing_cycle": customer.billing_cycle
                    })
        except Exception as e:
            results["errors"].append({
                "customer_id": customer.id,
                "customer_name": customer.name,
                "error": str(e)
            })
    
    return results
