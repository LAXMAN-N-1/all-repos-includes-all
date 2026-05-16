from datetime import datetime, timedelta
from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session

from app import models, schemas
from app.features.orders.models.order import OrderStatus
from app.api import deps
from app.services.pricing import pricing_service
from app.services.invoice import invoice_service
from app.services.whatsapp import whatsapp_service

router = APIRouter()


@router.get("", response_model=List[schemas.Order])
def read_orders(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    month: int = None,
    year: int = None,
    customer_id: int = None, # Added customer_id filter
    driver_id: int = None, # NEW: Filter for Driver App
    unpaid_only: bool = False, # NEW: Filter for invoice generation
    source: str = None, # NEW: Filter by order_source (web, whatsapp, offline)
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve orders.
    """
    try:
        from sqlalchemy.orm import joinedload, selectinload
        from sqlalchemy import or_, and_ as sa_and_
        # Alias 'and_' to avoid conflict if any, though inside function is fine.
        # Cleanest way:
        from sqlalchemy import or_, and_
        query = db.query(models.Order).options(
            joinedload(models.Order.shipment),
            selectinload(models.Order.items)
        ).order_by(models.Order.created_at.desc())
        
        # Source Filtering
        if source:
            query = query.filter(models.Order.order_source == source)
            
        # Date Filtering
        if month and year:
            from sqlalchemy import extract
            query = query.filter(extract('month', models.Order.created_at) == month)
            query = query.filter(extract('year', models.Order.created_at) == year)

        # Customer Filtering
        if customer_id:
            query = query.filter(models.Order.customer_id == customer_id)

        # Driver Filtering (Exact Match on Shipment)
        if driver_id:
            query = query.join(models.Shipment).filter(models.Shipment.driver_id == driver_id)

        # Security: Partners see only their orders
        if getattr(current_user, "identity_type", None) == "partner":
            query = query.filter(models.Order.customer_id == current_user.id)
            
        # Security: Drivers see only their assigned orders OR unassigned confirmed orders (Broadcast)
        if getattr(current_user, "role", None) == "driver":
             # Drivers can see:
             # 1. Orders assigned to them (driver_id == current_user.id)
             # 2. Orders that are CONFIRMED but have NO driver assigned (Broadcast)
             from sqlalchemy import or_
             
             query = query.outerjoin(models.Shipment)
             query = query.filter(
                 or_(
                     models.Shipment.driver_id == current_user.id,
                     and_(
                         models.Order.status.in_([OrderStatus.CONFIRMED, OrderStatus.OUT_FOR_DELIVERY, OrderStatus.ACCEPTED]),
                         or_(models.Shipment.driver_id == None, models.Shipment.id == None)
                     )
                 )
             )

        # Unpaid Filter for Invoice Generation
        if unpaid_only:
            # Join with Invoice to check status
            # We want orders where NO invoice is 'paid'
            from sqlalchemy import and_, or_, not_
            query = query.outerjoin(models.Invoice, models.Order.id == models.Invoice.order_id)\
                   .filter(or_(
                       models.Invoice.id == None, 
                       models.Invoice.status != "paid"
                   ))
            # Also exclude final statuses
            query = query.filter(not_(models.Order.status.in_(["paid", "completed", "cancelled"])))
            
        orders = query.offset(skip).limit(limit).all()
        return orders
    except Exception as e:
        import traceback
        import os
        # Fix: Use cross-platform path or just print to console
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail="Internal Server Error")


@router.get("/{order_id}", response_model=schemas.Order)
def read_order(
    *,
    db: Session = Depends(deps.get_db),
    order_id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get order by ID.
    """
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    # Security: Partners see only their orders
    if getattr(current_user, "identity_type", None) == "partner":
        if order.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not authorized to view this order")
            
    # Driver can only see their own orders or broadcast orders
    if current_user.role == "driver":
        shipment = order.shipment
        if shipment and shipment.driver_id != current_user.id:
            # If assigned to someone else, can't see unless it was broadcast? 
            # Actually if it's already accepted, only that driver can see.
            raise HTTPException(status_code=403, detail="Not authorized to view this order")
        
    return order


@router.post("", response_model=schemas.Order)
def create_order(
    *,
    db: Session = Depends(deps.get_db),
    order_in: schemas.OrderCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create a new order.
    """
    # 1. Fetch Customer
    customer = db.query(models.Customer).filter(models.Customer.id == order_in.customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    if customer.customer_type == "b2b" and not customer.is_verified:
        raise HTTPException(status_code=403, detail="Account pending verification. Cannot place orders.")
        
    if order_in.location_id:
        location = db.query(models.Location).filter(
            models.Location.id == order_in.location_id,
            models.Location.customer_id == customer.id
        ).first()
        if not location:
            raise HTTPException(status_code=400, detail="Invalid delivery location for this customer.")

    # 2. Compute Totals and Verify Stock
    total_amount = 0.0
    items_data = []

    for item_in in order_in.items:
        product = db.query(models.Product).filter(models.Product.id == item_in.product_id).first()
        if not product:
            raise HTTPException(status_code=404, detail=f"Product {item_in.product_id} not found")
        
        if product.stock_quantity < item_in.quantity:
            raise HTTPException(status_code=400, detail=f"Insufficient stock for {product.name}")

        # Calculate Price
        unit_price = pricing_service.calculate_unit_price(db, product, customer, item_in.quantity, item_in.variant_id)
        line_total = unit_price * item_in.quantity
        
        items_data.append({
            "product_id": product.id,
            "product": product,
            "quantity": item_in.quantity,
            "unit_price": unit_price,
            "total_price": line_total,
            "variant_id": item_in.variant_id
        })
        total_amount += line_total

    # 3. Apply Fees
    total_amount += order_in.delivery_fee + order_in.platform_fee

    # 3.5 Credit Check
    if customer.customer_type == "b2b":
        projected_balance = (customer.current_balance or 0.0) + total_amount
        if projected_balance > (customer.credit_limit or 0.0):
            raise HTTPException(status_code=403, detail="Order exceeds available credit limit.")

    # 4. Create Order
    import random
    otp = str(random.randint(1000, 9999))
    
    order = models.Order(
        customer_id=order_in.customer_id,
        location_id=order_in.location_id,
        total_amount=total_amount,
        status=OrderStatus.PENDING,
        notes=order_in.notes or f"Contact: {order_in.contact_name} ({order_in.contact_phone})",
        po_number=order_in.po_number,
        payment_terms=order_in.payment_terms,
        delivery_fee=order_in.delivery_fee,
        platform_fee=order_in.platform_fee,
        delivery_otp=otp,
        order_source=order_in.order_source,
        delivery_type=order_in.delivery_method or "standard",
        delivery_address=order_in.delivery_address,
        payment_status="pending",
    )
    db.add(order)
    db.flush()

    # 5. Create Order Items
    order_items = []
    for data in items_data:
        # Subtract stock
        product = data["product"]
        product.stock_quantity -= data["quantity"]
        db.add(product)
        
        item = models.OrderItem(
            order_id=order.id,
            product_id=data["product_id"],
            variant_id=data["variant_id"],
            quantity=data["quantity"],
            unit_price=data["unit_price"],
            total_price=data["total_price"]
        )
        db.add(item)
        order_items.append(item)

    # 6. AUTO-INVOICE GENERATION
    try:
        invoice = models.Invoice(
            customer_id=order.customer_id,
            order_id=order.id,
            subtotal=total_amount, # Match amount_due to satisfy invoice service validation
            tax_total=0.0,
            discount_percentage=0.0,
            discount_amount=0.0,
            amount_due=total_amount, # Including fees
            due_date=datetime.utcnow() + timedelta(days=7),
            status="pending"
        )
        db.add(invoice)
        db.flush()
        
        # Generate PDF
        pdf_url = invoice_service.generate_pdf(invoice, customer, order_items)
        invoice.pdf_url = pdf_url
    except Exception as e:
        import traceback
        print(f"FAILED TO GENERATE AUTO-INVOICE: {str(e)}")
        # We don't fail the order creation if invoice fails, but we log it.

    db.commit()
    db.refresh(order)
    return order

@router.put("/{order_id}", response_model=schemas.Order)
def update_order(
    *,
    db: Session = Depends(deps.get_db),
    order_id: int,
    order_in: schemas.OrderUpdate,
    background_tasks: BackgroundTasks, # Add BackgroundTasks
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update order status or details.
    """
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    update_data = order_in.dict(exclude_unset=True)
    old_status = order.status
    new_status = update_data.get("status")
    
    # 1. Update Order
    if new_status == OrderStatus.DELIVERED:
        provided_otp = update_data.get("delivery_otp")
        if not provided_otp or provided_otp != order.delivery_otp:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or missing delivery OTP"
            )

    for field, value in update_data.items():
        setattr(order, field, value)
    
    db.add(order)
    
    # 2. Record Status Change
    if new_status and new_status != old_status:
        changer_id = current_user.id if getattr(current_user, "identity_type", None) == "staff" else None
        
        status_update = models.OrderStatusUpdate(
            order_id=order.id,
            old_status=old_status,
            new_status=new_status,
            changed_by_id=changer_id,
            notes=f"Updated via API by {getattr(current_user, 'email', 'Unknown')}"
        )
        db.add(status_update)

        # ERP-Grade Financial Settlement logic (Moved OUTSIDE driver block)
        customer = order.customer
        if customer and customer.customer_type == "b2b":
            customer = db.merge(customer)
            
            # Transition to CONFIRMED: Increases usage (debits credit limit)
            if new_status == OrderStatus.CONFIRMED and old_status != OrderStatus.CONFIRMED:
                # Credit Limit Check
                usage = (customer.current_balance or 0.0) + order.total_amount
                limit = (customer.credit_limit or 0.0)
                if usage > limit:
                     raise HTTPException(
                         status_code=400, 
                         detail=f"Credit Limit Exceeded. Available: ${limit - (customer.current_balance or 0.0):,.2f}, Required: ${order.total_amount:,.2f}"
                     )
                
                customer.current_balance = (customer.current_balance or 0.0) + order.total_amount
                db.add(customer)
                print(f"DEBUG: [FINANCE] Order {order.id} CONFIRMED. Customer {customer.id} balance increased to {customer.current_balance}")

            # Transition to CANCELLED: Decreases usage (liberates credit)
            elif new_status == OrderStatus.CANCELLED and old_status == OrderStatus.CONFIRMED:
                customer.current_balance = max(0, (customer.current_balance or 0.0) - order.total_amount)
                db.add(customer)
                print(f"DEBUG: [FINANCE] Order {order.id} CANCELLED. Customer {customer.id} balance decreased to {customer.current_balance}")

    # 2.4 Auto-Assign Driver if Driver accepts a broadcast order
    final_status = getattr(order, "status", new_status)
    if final_status in [OrderStatus.OUT_FOR_DELIVERY, OrderStatus.ACCEPTED] and getattr(current_user, "role", None) in ["driver", "admin", "super_admin"]:
        shipment = order.shipment
        if not shipment or shipment.driver_id == None:
            if not shipment:
                shipment = models.Shipment(order_id=order.id, status="pending")
                db.add(shipment)
            shipment.driver_id = current_user.id
            db.add(shipment)
            print(f"DEBUG: Auto-assigned Driver {current_user.id} to Order {order.id}")
        
        # 3. Trigger WhatsApp Notification (Async)
        customer = order.customer
        if customer and customer.phone:
            if new_status == OrderStatus.CONFIRMED:
                background_tasks.add_task(whatsapp_service.send_order_confirmation, customer.phone, order.id, order.total_amount)
            elif new_status == OrderStatus.OUT_FOR_DELIVERY:
                background_tasks.add_task(whatsapp_service.send_delivery_alert, customer.phone, order.id)
            elif new_status == OrderStatus.DELIVERED:
                background_tasks.add_task(whatsapp_service.send_message, customer.phone, f"✅ Order #{order.id} has been delivered. Enjoy!")

    db.commit()
    db.refresh(order)
    return order


@router.delete("/{order_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_order(
    *,
    db: Session = Depends(deps.get_db),
    order_id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
):
    """
    Delete an order and restore stock levels.
    - Only PENDING orders can be deleted by Partners.
    - Staff/Admins can delete orders in any state (but stock restoration still applies).
    - If an order has a paid invoice, deletion is forbidden.
    """
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    # 1. Authorization & State Check
    if getattr(current_user, "identity_type", None) == "partner":
        if order.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not authorized to delete this order")
        if order.status != OrderStatus.PENDING:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot delete order in '{order.status}' state. Please contact support or request cancellation."
            )
    else:
        # Staff/Admin
        if getattr(current_user, "role", None) not in ["admin", "staff"]:
            raise HTTPException(status_code=403, detail="Not authorized to delete orders")

    # 2. Check for Paid Invoices
    for invoice in order.invoices:
        if invoice.status == "paid":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot delete an order with a paid invoice."
            )

    # 3. Restore Stock Levels
    # If the order was confirmed, we should also arguably reverse the customer balance
    # but the primary requirement is stock restoration.
    for item in order.items:
        product = item.product
        if product:
            product.stock_quantity += item.quantity
            db.add(product)

    # 4. Reverse Customer Balance (only if it was CONFIRMED and B2B)
    customer = order.customer
    if customer and customer.customer_type == "b2b":
        if order.status == OrderStatus.CONFIRMED:
            # Reverse wallet usage
            if order.wallet_amount_used > 0:
                customer.wallet_balance += order.wallet_amount_used
                db.add(models.WalletTransaction(
                    customer_id=customer.id,
                    amount=order.wallet_amount_used,
                    transaction_type="refund",
                    reference_id=f"Order #{order.id} (deletion)",
                    notes=f"Refund for deleted order #{order.id}"
                ))
            
            # Reverse debt portion
            debt_portion = order.total_amount - order.wallet_amount_used
            customer.current_balance -= debt_portion
            if customer.current_balance < 0:
                customer.current_balance = 0
            db.add(customer)

    # 5. Perform Deletion
    # cascade="all, delete-orphan" on models.Order handles OrderItem and OrderStatusUpdate
    db.delete(order)
    db.commit()


@router.post("/{order_id}/assign", response_model=schemas.Order)
def assign_driver(
    *,
    db: Session = Depends(deps.get_db),
    order_id: int,
    driver_id: int, # Query param
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Assign a driver to an order.
    """
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    # Check if shipment exists, else create
    shipment = order.shipment
    if not shipment:
        # Import here to avoid circular dependency if any, though models are loaded
        shipment = models.Shipment(order_id=order.id, status=models.sales_extras.ShipmentStatus.PENDING)
        db.add(shipment)
    
    shipment.driver_id = driver_id
    # Auto-update status to CONFIRMED if not already, to signal "Assigned"
    if order.status == OrderStatus.PENDING:
        order.status = OrderStatus.CONFIRMED
        
    db.commit()
    db.refresh(order)
    return order

