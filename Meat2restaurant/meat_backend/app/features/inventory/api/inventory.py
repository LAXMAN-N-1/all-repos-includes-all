from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from app.api import deps
from app.features.inventory import schemas, models
from app.features.catalog import models as catalog_models

router = APIRouter()

# Suppliers
@router.get("/suppliers", response_model=List[schemas.SupplierResponse])
def read_suppliers(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    """List all suppliers."""
    return db.query(models.Supplier).offset(skip).limit(limit).all()

@router.post("/suppliers", response_model=schemas.SupplierResponse)
def create_supplier(
    *,
    db: Session = Depends(deps.get_db),
    supplier_in: schemas.SupplierCreate,
) -> Any:
    """Create a new supplier."""
    supplier = models.Supplier(**supplier_in.dict())
    db.add(supplier)
    db.commit()
    db.refresh(supplier)
    return supplier

# Purchase Orders
@router.get("/purchase-orders", response_model=List[schemas.PurchaseOrderResponse])
def read_purchase_orders(
    db: Session = Depends(deps.get_db),
    status: Optional[str] = None,
) -> Any:
    """List purchase orders."""
    query = db.query(models.PurchaseOrder).options(
        joinedload(models.PurchaseOrder.supplier),
        joinedload(models.PurchaseOrder.items).joinedload(models.PurchaseOrderItem.product)
    )
    if status:
        query = query.filter(models.PurchaseOrder.status == status)
    
    pos = query.all()
    for po in pos:
        po.supplier_name = po.supplier.name if po.supplier else "Unknown"
        for item in po.items:
            item.product_name = item.product.name if item.product else "Unknown"
    return pos

@router.post("/purchase-orders/{po_id}/receive", response_model=schemas.PurchaseOrderResponse)
def receive_purchase_order(
    *,
    db: Session = Depends(deps.get_db),
    po_id: int,
    receive_in: schemas.PurchaseOrderReceive,
) -> Any:
    """Receive items from a Purchase Order and update stock."""
    po = db.query(models.PurchaseOrder).filter(models.PurchaseOrder.id == po_id).first()
    if not po:
        raise HTTPException(status_code=404, detail="Purchase Order not found")
    
    for receive_item in receive_in.received_items:
        item_id = receive_item.get("item_id")
        qty = receive_item.get("quantity", 0)
        
        po_item = db.query(models.PurchaseOrderItem).filter(models.PurchaseOrderItem.id == item_id).first()
        if po_item:
            po_item.received_quantity += qty
            
            # Update Product stock
            product = db.query(catalog_models.Product).filter(catalog_models.Product.id == po_item.product_id).first()
            if product:
                product.stock_quantity += qty
            
            # Update Variant stock if applicable
            if po_item.variant_id:
                variant = db.query(catalog_models.ProductVariant).filter(catalog_models.ProductVariant.id == po_item.variant_id).first()
                if variant:
                    variant.stock_quantity += qty

    # Check if PO is fully received
    fully_received = True
    for item in po.items:
        if item.received_quantity < item.quantity:
            fully_received = False
            break
    
    if fully_received:
        po.status = "Received"
    else:
        po.status = "Partially Received"

    db.commit()
    db.refresh(po)
    return po
