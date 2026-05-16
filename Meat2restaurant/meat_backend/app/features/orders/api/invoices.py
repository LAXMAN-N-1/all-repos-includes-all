from typing import Any, List, Optional
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import models, schemas
from app.api import deps
from app.services.invoice import invoice_service
from app.services.whatsapp import whatsapp_service
from app.services.invoice_scheduler import auto_generate_combined_invoice, run_auto_generate_all_invoices
from app.features.orders.models.order import OrderStatus

router = APIRouter()
from fastapi.responses import Response

class PreviewItem:
    def __init__(self, product_id, quantity, unit_price, total_price, product_name):
        self.product_id = product_id
        self.quantity = quantity
        self.unit_price = unit_price
        self.total_price = total_price
        # Create a mock product object with a name attribute
        self.product = type('obj', (object,), {'name': product_name})

class PreviewInvoice:
    def __init__(self, id, created_at, due_date, status, subtotal, discount_amount, tax_total, amount_due, order_id=None, order=None):
        self.id = id
        self.created_at = created_at
        self.due_date = due_date
        self.status = status
        self.subtotal = subtotal
        self.discount_amount = discount_amount
        self.tax_total = tax_total
        self.amount_due = amount_due
        self.order_id = order_id
        self.order = order

class PreviewCustomer:
    def __init__(self, name, email, phone, address):
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address



@router.get("/", response_model=List[schemas.Invoice])
def read_invoices(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    status: Optional[str] = None,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve invoices.
    """
    query = db.query(models.Invoice)
    
    # Security: Partners see only their invoices
    if getattr(current_user, "identity_type", None) == "partner":
        query = query.filter(models.Invoice.customer_id == current_user.id)
    
    if status:
        query = query.filter(models.Invoice.status == status)
        
    invoices = query.offset(skip).limit(limit).all()
    return invoices


@router.get("/payments", response_model=List[schemas.Payment])
def read_payments(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Retrieve payments.
    """
    payments = db.query(models.Payment).offset(skip).limit(limit).all()
    return payments


@router.get("/credit-notes", response_model=List[schemas.CreditNote])
def read_credit_notes(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Retrieve credit notes.
    """
    credit_notes = db.query(models.CreditNote).offset(skip).limit(limit).all()
    return credit_notes


@router.post("/credit-notes", response_model=schemas.CreditNote)
def create_credit_note(
    *,
    db: Session = Depends(deps.get_db),
    credit_note_in: schemas.CreditNoteCreate,
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Create new credit note.
    """
    credit_note = models.CreditNote(
        **credit_note_in.dict()
    )
    db.add(credit_note)
    db.commit()
    db.refresh(credit_note)
    return credit_note


@router.post("/generate-daily-combined", response_model=schemas.CombinedInvoice)
def generate_daily_combined_invoice(
    *,
    db: Session = Depends(deps.get_db),
    customer_id: int,
    date: datetime = None,
    due_date: datetime = None,  # Admin override
    discount_percentage: float = 0.0, # NEW: Discount override
    current_user: models.User = Depends(deps.get_current_active_staff), # Only staff/admin
) -> Any:
    """
    Generate a combined invoice (Statement) for a specific customer.
    Combines ALL unpaid, uncombined invoices into a single statement.
    """
    if not date:
        date = datetime.utcnow()
    
    # Check Customer
    customer = db.query(models.Customer).filter(models.Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    # Use the Scheduler Logic (Thick Service, Thin Controller)
    from app.services.invoice_scheduler import auto_generate_combined_invoice
    
    try:
        combined_invoice = auto_generate_combined_invoice(
            db, 
            customer, 
            today=date.date(), 
            override_due_date=due_date,
            discount_percentage=discount_percentage
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating invoice: {str(e)}")

    if not combined_invoice:
        raise HTTPException(status_code=404, detail="No eligible unpaid invoices found to combine.")

    return combined_invoice

@router.post("/generate-consolidated", response_model=schemas.CombinedInvoice)
def generate_consolidated_invoice(
    *,
    db: Session = Depends(deps.get_db),
    request: schemas.ConsolidatedInvoiceRequest,
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Generate a consolidated invoice (Statement) for a specific customer based on specific orders.
    This creates a CombinedInvoice and links the invoices of the selected orders to it.
    """
    
    # 1. Fetch Customer
    customer = db.query(models.Customer).filter(models.Customer.id == request.customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    # 2. Identify Target Invoices
    # Only fetch invoices that are NOT already part of a combined invoice and are NOT paid.
    # We fetch based on the Orders selected.
    
    target_invoices = []
    
    # Track reasons for rejection to provide better error messages
    rejection_reasons = []

    if request.order_ids:
        # Fetch specific orders
        orders = db.query(models.Order).filter(models.Order.id.in_(request.order_ids)).all()


        
        for order in orders:
            # Check for existing invoice
            existing_invoice = db.query(models.Invoice).filter(models.Invoice.order_id == order.id).first()
            
            if existing_invoice:
                 # Check eligibility
                 if existing_invoice.status == "paid":
                     rejection_reasons.append(f"Order #{order.id} is already paid.")
                 elif existing_invoice.combined_invoice_id is not None:
                     rejection_reasons.append(f"Order #{order.id} is already in Statement #{existing_invoice.combined_invoice_id}.")
                 else:
                     target_invoices.append(existing_invoice)
            else:
                # AUTO-CREATE INVOICE FOR UNBILLED ORDER
                # Reuse logic from create_invoice but programmatic
                subtotal = order.total_amount # Order total is the source of truth
                invoice = models.Invoice(
                    customer_id=customer.id,
                    order_id=order.id,
                    subtotal=subtotal,
                    amount_due=subtotal, # Assuming no discount/tax initially
                    due_date=request.due_date or (datetime.utcnow() + timedelta(days=7)),
                    status="draft",
                    invoice_date=datetime.utcnow(),
                    terms=order.payment_terms
                )
                db.add(invoice)
                db.flush() # Get ID
                target_invoices.append(invoice)

    elif request.month and request.year:
        # Fetch by Period - Look for ORDERS in this period
        from sqlalchemy import extract
        orders = db.query(models.Order).filter(
            models.Order.customer_id == customer.id,
            models.Order.status == "delivered", # Only delivered orders?
            extract('month', models.Order.created_at) == request.month,
            extract('year', models.Order.created_at) == request.year
        ).all()
        
        for order in orders:
            existing_invoice = db.query(models.Invoice).filter(models.Invoice.order_id == order.id).first()
             
            if existing_invoice:
                 if existing_invoice.status != "paid" and existing_invoice.combined_invoice_id is None:
                     target_invoices.append(existing_invoice)
            else:
                 # Auto-create
                subtotal = order.total_amount
                invoice = models.Invoice(
                    customer_id=customer.id,
                    order_id=order.id,
                    subtotal=subtotal,
                    amount_due=subtotal, 
                    due_date=request.due_date or (datetime.utcnow() + timedelta(days=7)),
                    status="draft",
                    invoice_date=datetime.utcnow(),
                    terms=order.payment_terms
                )
                db.add(invoice)
                db.flush()
                target_invoices.append(invoice)
    
    else:
        raise HTTPException(status_code=400, detail="Must provide either order_ids or month/year")

    if not target_invoices:
        if rejection_reasons:
            raise HTTPException(status_code=400, detail=f"Unable to consolidate: {'; '.join(rejection_reasons)}")
        raise HTTPException(status_code=404, detail="No eligible invoices found to consolidate.")

    # 3. Create Combined Invoice Record
    subtotal = sum(inv.amount_due for inv in target_invoices)
    total_amount = subtotal # Discounts on statement level? For now, sum of dues.
    
    combined = models.CombinedInvoice(
        customer_id=customer.id,
        invoice_date=datetime.utcnow(), 
        subtotal=subtotal,
        total_amount=total_amount,
        status="draft",
        due_date=request.due_date or (datetime.utcnow() + timedelta(days=7))
    )
    db.add(combined)
    db.flush()
    
    # 4. Link Single Invoices to Combined
    for inv in target_invoices:
        inv.combined_invoice_id = combined.id
        db.add(inv)
        
    # 5. Generate Statement PDF
    try:
        pdf_url = invoice_service.generate_combined_pdf(combined, customer, target_invoices)
        combined.pdf_url = pdf_url
    except Exception as e:
        print(f"PDF Gen Error: {e}")
        # Don't fail transaction, but log
        
    db.commit()
    db.refresh(combined)
    return combined

@router.post("/auto-generate-all")
def auto_generate_all_invoices(
    *,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Automatically generate combined invoices for all eligible B2B customers based on their billing cycles.
    This endpoint should be called daily (manually or via scheduler).
    
    Returns statistics about invoice generation.
    """
    from app.services.invoice_scheduler import run_auto_generate_all_invoices as generate_all
    
    results = generate_all(db)
    
    return {
        "status": "success",
        "message": f"Generated {results['invoices_generated']} combined invoices for {len(results['customers_processed'])} customers",
        "details": results
    }

    
@router.get("/combined", response_model=List[schemas.CombinedInvoice])
def read_combined_invoices(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    customer_id: Optional[int] = None,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve combined invoices.
    """
    query = db.query(models.CombinedInvoice)
    if customer_id:
        query = query.filter(models.CombinedInvoice.customer_id == customer_id)
    
    # Security: Partners see only their statements
    if getattr(current_user, "identity_type", None) == "partner":
        query = query.filter(models.CombinedInvoice.customer_id == current_user.id)
        
    return query.offset(skip).limit(limit).all()

@router.get("/combined/{combined_id}", response_model=schemas.CombinedInvoice)
def read_combined_invoice(
    combined_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get a specific combined invoice.
    """
    stmt = db.query(models.CombinedInvoice).filter(models.CombinedInvoice.id == combined_id).first()
    if not stmt:
        raise HTTPException(status_code=404, detail="Combined invoice not found")
        
    # Security check
    if getattr(current_user, "identity_type", None) == "partner":
        if stmt.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not authorized to view this statement")
            
    return stmt

@router.post("/", response_model=schemas.Invoice)
def create_invoice(
     *,
    db: Session = Depends(deps.get_db),
    invoice_in: schemas.InvoiceCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create a new invoice.
    Can be created from an existing order (order_id) OR directly with items (creates a backing order).
    """
    # 1. Handle Direct Invoice Creation (No Order ID provided, but Items provided)
    if not invoice_in.order_id and invoice_in.items:
        # Create a backing Order to track inventory and sales
        from app.features.orders.models.order import Order, OrderItem, OrderStatus
        from app.services.pricing import pricing_service
        
        # Calculate totals
        total_amount = 0.0
        order_items = []
        
        # Verify Customer
        customer = db.query(models.Customer).filter(models.Customer.id == invoice_in.customer_id).first()
        if not customer:
            raise HTTPException(status_code=404, detail="Customer not found")

        # Process Items
        for item_in in invoice_in.items:
            # 1. Handle Manual Item (product_id=0)
            if not item_in.product_id or item_in.product_id == 0:
                unit_price = item_in.unit_price
                line_total = unit_price * item_in.quantity
                
                order_items.append({
                    "product_id": None, # Null in DB for manual items
                    "variant_id": None,
                    "quantity": item_in.quantity,
                    "unit_price": unit_price,
                    "total_price": line_total,
                    "notes": item_in.name # Store name in notes or just use as is
                })
                total_amount += line_total
                continue

            # 2. Handle DB Product
            product = db.query(models.Product).filter(models.Product.id == item_in.product_id).first()
            if not product:
                raise HTTPException(status_code=404, detail=f"Product {item_in.product_id} not found")
            
            # Pricing Logic (Use provided unit_price if relevant, or calculate)
            # For direct invoices, we often trust the admin's provided unit_price
            unit_price = item_in.unit_price if item_in.unit_price > 0 else pricing_service.calculate_unit_price(
                db, product, customer, item_in.quantity, item_in.variant_id
            )
            line_total = unit_price * item_in.quantity
            
            # Reduce Stock (Optional: Direct Invoice assumes immediate confirmation)
            if product.stock_quantity is not None:
                product.stock_quantity -= item_in.quantity
                db.add(product)
            
            order_items.append({
                "product_id": product.id,
                "variant_id": item_in.variant_id,
                "quantity": item_in.quantity,
                "unit_price": unit_price,
                "total_price": line_total
            })
            total_amount += line_total
            
        # Create Order
        new_order = Order(
            customer_id=invoice_in.customer_id,
            total_amount=total_amount,
            status=OrderStatus.DELIVERED, # Direct invoices are usually for completed transactions or immediate dispatch
            notes="Auto-created from Direct Invoice",
            payment_terms=invoice_in.terms,
            created_at=invoice_in.invoice_date or datetime.utcnow()
        )
        db.add(new_order)
        db.flush() # Get ID
        
        # Add Order Items
        for i in order_items:
            db.add(OrderItem(order_id=new_order.id, **i))
            
        invoice_in.order_id = new_order.id
        # Recalculate invoice totals based on these items? 
        # The frontend sends amounts, but backend calculation is safer?
        # For now, we trust the calculated order totals as the subtotal source
        subtotal = total_amount
        
    # 2. Handle Existing Order
    elif invoice_in.order_id:
        from sqlalchemy.orm import joinedload
        items = db.query(models.OrderItem).options(
            joinedload(models.OrderItem.product)
        ).filter(models.OrderItem.order_id == invoice_in.order_id).all()
        subtotal = sum(item.total_price for item in items)
    else:
        # Fallback (Manual Amount)
        subtotal = invoice_in.amount_due

    # 3. Final Calculations
    tax_total = 0.0 # Placeholder
    discount_amount = 0.0
    if invoice_in.discount_percentage > 0:
        discount_amount = subtotal * (invoice_in.discount_percentage / 100)
    
    final_amount = subtotal - discount_amount + tax_total

    # 4. Create Invoice
    invoice = models.Invoice(
        customer_id=invoice_in.customer_id,
        order_id=invoice_in.order_id,
        subtotal=subtotal,
        tax_total=tax_total,
        discount_percentage=invoice_in.discount_percentage,
        discount_amount=discount_amount,
        amount_due=final_amount,
        due_date=invoice_in.due_date,
        status=invoice_in.status,
        pdf_url=invoice_in.pdf_url,
        # New Fields
        invoice_date=invoice_in.invoice_date or datetime.utcnow(),
        terms=invoice_in.terms,
        subject=invoice_in.subject,
        salesperson_id=invoice_in.salesperson_id,
        notes=invoice_in.notes
    )
    db.add(invoice)
    db.flush()
    
    # Trigger PDF Generation
    # (Fetch items again to ensure we have them all properly loaded)
    order_items_for_pdf = db.query(models.OrderItem).filter(models.OrderItem.order_id == invoice.order_id).all()
    customer = db.query(models.Customer).filter(models.Customer.id == invoice.customer_id).first()
    
    # ERP-Grade Financial Consistency: Update balance for B2B customers
    # If this is a direct/manual invoice NOT linked to a previously confirmed order, 
    # we must ensure it's tracked in the customer's current balance (debt).
    if customer and customer.customer_type == "b2b":
        # Note: If it's linked to an order, the order's status transition would normally handle this,
        # but for direct invoices, we increment here to represent immediate charge.
        customer.current_balance = (customer.current_balance or 0.0) + final_amount
        db.add(customer)
        print(f"DEBUG: [FINANCE] Direct Invoice for ${final_amount} created. Customer {customer.id} balance: {customer.current_balance}")

    try:
        pdf_url = invoice_service.generate_pdf(invoice, customer, order_items_for_pdf)
        invoice.pdf_url = pdf_url
    except Exception as e:
        print(f"PDF Generation Failed: {e}")
    
    db.commit()
    db.refresh(invoice)
    return invoice

@router.post("/{invoice_id}/send-whatsapp")
def send_invoice_via_whatsapp(
    invoice_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    invoice = db.query(models.Invoice).filter(models.Invoice.id == invoice_id).first()
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")
    
    customer = invoice.customer
    if not customer.phone:
        raise HTTPException(status_code=400, detail="Customer has no phone number")
    
    # Send message with PDF URL
    msg = f"📄 Invoice #{invoice.id} for ${invoice.amount_due} is ready. View here: {invoice.pdf_url}"
    success = whatsapp_service.send_message(customer.phone, msg)
    
    if success:
        invoice.status = "sent"
        db.commit()
        return {"status": "success", "message": "Invoice sent via WhatsApp"}
    else:
        raise HTTPException(status_code=500, detail="Failed to send WhatsApp message")

@router.post("/{invoice_id}/pay", response_model=schemas.Invoice)
def pay_invoice(
    invoice_id: int,
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user),
) -> Any:
    """
    Mark an invoice as paid and record the transaction.
    """
    invoice = db.query(models.Invoice).filter(models.Invoice.id == invoice_id).first()
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")
        
    # Security: Partners can only pay their own
    if getattr(current_user, "identity_type", None) == "partner":
        if invoice.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not authorized to pay this invoice")
    
    if invoice.status == "paid":
        return invoice
        
    # Financial Logic: Reduce Customer Debt Balance
    customer = invoice.customer
    if customer and customer.customer_type == "b2b":
        customer.current_balance -= invoice.amount_due
        # Avoid negative balance due to rounding
        if customer.current_balance < 0:
            customer.current_balance = 0
        db.add(customer)
            
    # Audit Trail: Record in Payments table
    try:
        user_email = getattr(current_user, "email", "unknown")
        payment = models.Payment(
            customer_id=invoice.customer_id,
            invoice_id=invoice.id,
            amount=invoice.amount_due,
            payment_method="Manual/Direct",
            status="confirmed",
            payment_date=datetime.utcnow(),
            notes=f"Payment for Inv #{invoice.id} recorded by {user_email}"
        )
        db.add(payment)
        db.flush() # Ensure ID generation and buffer population
    except Exception as e:
        print(f"CRITICAL: Failed to create payment record: {e}")
        raise HTTPException(status_code=500, detail=f"Database persistent failure: {str(e)}")

    invoice.status = "paid"
    
    # NEW: Sync Order payment status if applicable
    if invoice.order:
        invoice.order.payment_status = "paid"
        db.add(invoice.order)

    db.commit()
    db.refresh(invoice)
    return invoice

@router.post("/combined/{combined_id}/pay", response_model=schemas.CombinedInvoice)
def pay_combined_invoice(
    combined_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Mark a combined invoice as paid and record the transaction.
    """
    combined = db.query(models.CombinedInvoice).filter(models.CombinedInvoice.id == combined_id).first()
    if not combined:
        raise HTTPException(status_code=404, detail="Combined invoice not found")
        
    # Security: Partners can only pay their own
    if getattr(current_user, "identity_type", None) == "partner":
        if combined.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not authorized to pay this statement")
    
    if combined.status == "paid":
        return combined

    customer = combined.customer
    if customer and customer.customer_type == "b2b":
        customer.current_balance -= combined.total_amount
        if customer.current_balance < 0:
            customer.current_balance = 0
        db.add(customer)

    # 1. Update linked invoices and their orders
    for inv in combined.invoices:
        inv.status = "paid"
        if inv.order:
            inv.order.payment_status = "paid"
            db.add(inv.order)
        db.add(inv)

    # 2. Record Payment
    try:
        user_email = getattr(current_user, "email", "unknown")
        payment = models.Payment(
            customer_id=combined.customer_id,
            combined_invoice_id=combined.id,
            amount=combined.total_amount,
            payment_method="Manual/Direct",
            status="confirmed",
            payment_date=datetime.utcnow(),
            notes=f"Combined Payment for Statement #{combined.id} recorded by {user_email}"
        )
        db.add(payment)
        db.flush()
    except Exception as e:
        print(f"CRITICAL: Failed to create combined payment record: {e}")
        raise HTTPException(status_code=500, detail=f"Database persistent failure: {str(e)}")

    combined.status = "paid"
    db.commit()
    db.refresh(combined)
    return combined

@router.get("/{invoice_id}", response_model=schemas.Invoice)
def read_invoice(
    invoice_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    invoice = db.query(models.Invoice).filter(models.Invoice.id == invoice_id).first()
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")
        
    # Security: Partners see only their invoices
    if getattr(current_user, "identity_type", None) == "partner":
        if invoice.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not authorized to view this invoice")
            
    return invoice


@router.put("/{invoice_id}", response_model=schemas.Invoice)
def update_invoice(
    *,
    invoice_id: int,
    invoice_in: schemas.InvoiceUpdate,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update an invoice (limited fields: status, pdf_url, stripe_invoice_id).
    Cannot update paid invoices.
    """
    if current_user.role not in ["admin", "staff"]:
        raise HTTPException(
            status_code=403,
            detail="You do not have permission to update invoices."
        )
    
    invoice = db.query(models.Invoice).filter(models.Invoice.id == invoice_id).first()
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")
    
    # Prevent updates to paid invoices
    if invoice.status == "paid":
        raise HTTPException(
            status_code=400,
            detail="Cannot update a paid invoice."
        )
    
    update_data = invoice_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(invoice, field, value)
    
    db.add(invoice)
    db.commit()
    db.refresh(invoice)
    return invoice


@router.delete("/{invoice_id}", response_model=schemas.Invoice)
def delete_invoice(
    *,
    invoice_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Delete (cancel) an invoice.
    Cannot delete paid invoices - use soft delete by marking as cancelled.
    """
    invoice = db.query(models.Invoice).filter(models.Invoice.id == invoice_id).first()
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")
    
    # Prevent deletion of paid invoices
    if invoice.status == "paid":
        raise HTTPException(
            status_code=400,
            detail="Cannot delete a paid invoice. Contact support for refunds."
        )
    
    # Soft delete by marking as cancelled instead of hard delete
    invoice.status = "cancelled"
    db.add(invoice)
    db.commit()
    db.refresh(invoice)
    return invoice


@router.post("/{invoice_id}/push", response_model=schemas.Invoice)
def push_invoice(
    invoice_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Push an invoice to the customer app (triggers a notification).
    """
    invoice = db.query(models.Invoice).filter(models.Invoice.id == invoice_id).first()
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")
    
    if invoice.status == "paid":
        raise HTTPException(status_code=400, detail="Cannot push a paid invoice")

    # Update Status
    invoice.status = "sent"
    db.add(invoice)
    
    # Create Notification
    notification = models.Notification(
        customer_id=invoice.customer_id,
        title="New Invoice Payment Requested",
        message=f"Invoice #{invoice.id} for ${invoice.amount_due} has been generated. Tap to pay now.",
        type="invoice_pushed",
        payload={
            "invoice_id": invoice.id,
            "amount": invoice.amount_due,
            "order_id": invoice.order_id,
            "pdf_url": invoice.pdf_url
        }
    )
    db.add(notification)
    
    db.commit()
    db.refresh(invoice)
    return invoice



@router.post("/combined/{combined_id}/push", response_model=schemas.CombinedInvoice)
def push_combined_invoice(
    combined_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Push a combined invoice to the customer app (triggers a notification).
    """
    combined = db.query(models.CombinedInvoice).filter(models.CombinedInvoice.id == combined_id).first()
    if not combined:
        raise HTTPException(status_code=404, detail="Combined invoice not found")
    
    if combined.status == "paid":
        raise HTTPException(status_code=400, detail="Cannot push a paid statement")

    # Update Status
    combined.status = "sent"
    db.add(combined)
    
    # Create Notification
    notification = models.Notification(
        customer_id=combined.customer_id,
        title="New Billing Statement Ready",
        message=f"Statement #{combined.id} for ${combined.total_amount} is ready. View and pay now.",
        type="invoice_pushed", 
        payload={
            "combined_id": combined.id,
            "amount": combined.total_amount,
            "pdf_url": combined.pdf_url
        }
    )
    db.add(notification)
    
    db.commit()
    db.refresh(combined)
    return combined

@router.post("/{invoice_id}/regenerate-pdf", response_model=schemas.Invoice)
def regenerate_invoice_pdf(
    invoice_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Manually trigger PDF generation for an invoice.
    """
    invoice = db.query(models.Invoice).filter(models.Invoice.id == invoice_id).first()
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")
    
    order_items = db.query(models.OrderItem).filter(models.OrderItem.order_id == invoice.order_id).all()
    customer = db.query(models.Customer).filter(models.Customer.id == invoice.customer_id).first()
    
    try:
        from app.services.invoice import invoice_service
        pdf_url = invoice_service.generate_pdf(invoice, customer, order_items)
        invoice.pdf_url = pdf_url
        db.add(invoice)
        db.commit()
        db.refresh(invoice)
    except Exception as e:
        import traceback
        print(f"FAILED TO REGENERATE PDF: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"PDF Generation Failed: {str(e)}")
        
    return invoice

@router.post("/combined/{combined_id}/regenerate-pdf", response_model=schemas.CombinedInvoice)
def regenerate_combined_invoice_pdf(
    combined_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Manually trigger PDF generation for a combined invoice.
    """
    combined = db.query(models.CombinedInvoice).filter(models.CombinedInvoice.id == combined_id).first()
    if not combined:
        raise HTTPException(status_code=404, detail="Combined invoice not found")
    
    # Get all sub-invoices
    sub_invoices = db.query(models.Invoice).filter(models.Invoice.combined_id == combined_id).all()
    customer = combined.customer
    
    try:
        from app.services.invoice import invoice_service
        pdf_url = invoice_service.generate_combined_pdf(combined, customer, sub_invoices)
        combined.pdf_url = pdf_url
        db.add(combined)
        db.commit()
        db.refresh(combined)
    except Exception as e:
        import traceback
        print(f"FAILED TO REGENERATE COMBINED PDF: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"PDF Generation Failed: {str(e)}")
        
    return combined


from fastapi import Body

# ... imports ...

@router.post("/generate-preview")
def generate_invoice_preview(
    *,
    db: Session = Depends(deps.get_db),
    invoice_in: dict = Body(...), # Explicitly define as Body
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Generate a PDF preview without saving to DB.
    """
    # 1. Mock Customer
    customer_data = invoice_in.get('customer', {})
    customer = PreviewCustomer(
        name=customer_data.get('business_name', 'Unknown'),
        email=customer_data.get('email'),
        phone=customer_data.get('phone'),
        address=customer_data.get('address')
    )

    # 2. Mock Items
    items = []
    subtotal = 0.0
    
    for item in invoice_in.get('items', []):
        # Handle both 'qty' and 'quantity' to be safe
        qty = float(item.get('quantity') or item.get('qty') or 0)
        rate = float(item.get('unit_price') or item.get('rate') or 0)
        discount = float(item.get('discount', 0)) # Percentage
        
        line_sub = qty * rate
        line_total = line_sub * (1 - discount / 100)
        
        subtotal += line_total
        items.append(PreviewItem(
            product_id=None,
            quantity=qty,
            unit_price=rate,
            total_price=line_total,
            product_name=item.get('name', 'Item')
        ))

    # 3. Mock Invoice
    invoice_date = datetime.fromisoformat(invoice_in.get('invoice_date').replace('Z', ''))
    due_date = datetime.fromisoformat(invoice_in.get('due_date').replace('Z', ''))
    
    invoice = PreviewInvoice(
        id=99999, # Dummy ID
        created_at=invoice_date,
        due_date=due_date,
        status='DRAFT',
        subtotal=subtotal,
        discount_amount=0, # Applied per line in this logic
        tax_total=0,
        amount_due=subtotal,
        order_id=invoice_in.get('order_number')
    )

    # 4. Generate PDF
    pdf = invoice_service.generate_pdf(invoice, customer, items)
    
    # Return as bytes
    return Response(content=pdf.output(dest='S').encode('latin1'), media_type="application/pdf")
