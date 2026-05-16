from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from typing import Optional
from app.database import get_db
from app.models.user import User, UserRole
from app.auth.deps import get_current_user
from app.services.supplier_service import SupplierService
from app.services.audit_service import AuditService
from app.schemas.supplier_schema import (
    SupplierCreate, SupplierUpdate, SupplierFilters,
    SupplierCreate, SupplierUpdate, SupplierFilters,
    SupplierResponse, SupplierSummaryResponse, SupplierListResponse,
    SupplierScopeEnum
)

router = APIRouter(prefix="/api/v1/suppliers", tags=["Suppliers"])


def get_audit_service(db: Session = Depends(get_db)) -> AuditService:
    return AuditService(db)


def get_supplier_service(
    db: Session = Depends(get_db),
    audit_service: AuditService = Depends(get_audit_service)
) -> SupplierService:
    return SupplierService(db, audit_service)


@router.get("/", response_model=SupplierListResponse)
async def list_suppliers(
    search: Optional[str] = Query(None),
    city: Optional[str] = Query(None),
    state: Optional[str] = Query(None),
    inactive: Optional[bool] = Query(False),
    is_approved: Optional[bool] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    service: SupplierService = Depends(get_supplier_service)
):
    """
    List suppliers with filters.
    Requires HQ Admin or Store Admin role.
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Determine visibility based on role
    user_store_ids = None
    if current_user.role.code != UserRole.HQ_ADMIN:
        user_store_ids = [s.id for s in current_user.assigned_stores]
    
    filters = SupplierFilters(
        search=search, city=city, state=state,
        inactive=inactive, is_approved=is_approved
    )
    suppliers, total = service.get_suppliers(filters, page, page_size, user_store_ids)
    
    items = [SupplierSummaryResponse(
        id=s.id, name=s.name, code=s.code,
        scope=s.scope, store_id=s.store_id,
        contact_person=s.contact_person, phone=s.phone,
        city=s.city, state=s.state,
        inactive=s.inactive, is_approved=s.is_approved,
        rating=s.rating
    ) for s in suppliers]
    
    return SupplierListResponse(
        items=items, total=total, page=page,
        page_size=page_size, total_pages=(total + page_size - 1) // page_size
    )


@router.get("/search")
async def search_suppliers(
    q: str = Query(..., min_length=2),
    limit: int = Query(20, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    service: SupplierService = Depends(get_supplier_service)
):
    """Quick supplier search for autocomplete."""
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Determine visibility
    user_store_ids = None
    if current_user.role.code != UserRole.HQ_ADMIN:
        user_store_ids = [s.id for s in current_user.assigned_stores]

    suppliers = service.search_suppliers(q, limit, user_store_ids)
    return {"results": [{
        "id": str(s.id), "name": s.name, "code": s.code,
        "scope": s.scope,
        "contact_person": s.contact_person, "phone": s.phone
    } for s in suppliers]}


@router.post("/", response_model=SupplierResponse, status_code=status.HTTP_201_CREATED)
async def create_supplier(
    data: SupplierCreate,
    current_user: User = Depends(get_current_user),
    service: SupplierService = Depends(get_supplier_service)
):
    """Create a new supplier. HQ Admin or Store Admin."""
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Enforce scope for Store Admin
    if current_user.role.code == UserRole.STORE_ADMIN:
        if not current_user.assigned_stores:
             raise HTTPException(status_code=400, detail="Store Admin has no assigned store")
        # Force STORE scope and assigned store
        data.scope = SupplierScopeEnum.STORE
        data.store_id = current_user.assigned_stores[0].id
    
    # HQ Admin can create ORG (default) or STORE specific if provided

    # Check if code already exists
    existing = service.get_supplier_by_code(data.code)
    if existing:
        raise HTTPException(status_code=400, detail="Supplier code already exists")
    
    supplier = service.create_supplier(data, current_user.id)
    return _supplier_to_response(supplier)


@router.get("/{supplier_id}", response_model=SupplierResponse)
async def get_supplier(
    supplier_id: int,
    current_user: User = Depends(get_current_user),
    service: SupplierService = Depends(get_supplier_service)
):
    """Get a single supplier by ID."""
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    supplier = service.get_supplier(supplier_id)
    if not supplier:
        raise HTTPException(status_code=404, detail="Supplier not found")
    return _supplier_to_response(supplier)


@router.put("/{supplier_id}", response_model=SupplierResponse)
async def update_supplier(
    supplier_id: int,
    data: SupplierUpdate,
    current_user: User = Depends(get_current_user),
    service: SupplierService = Depends(get_supplier_service)
):
    """Update a supplier. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can update suppliers")
    
    supplier = service.update_supplier(supplier_id, data, current_user.id)
    if not supplier:
        raise HTTPException(status_code=404, detail="Supplier not found")
    return _supplier_to_response(supplier)


@router.delete("/{supplier_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_supplier(
    supplier_id: int,
    current_user: User = Depends(get_current_user),
    service: SupplierService = Depends(get_supplier_service)
):
    """Soft delete a supplier. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can delete suppliers")
    
    if not service.delete_supplier(supplier_id, current_user.id):
        raise HTTPException(status_code=404, detail="Supplier not found")


@router.post("/{supplier_id}/approve", response_model=SupplierResponse)
async def approve_supplier(
    supplier_id: int,
    approved: bool = Query(True),
    current_user: User = Depends(get_current_user),
    service: SupplierService = Depends(get_supplier_service)
):
    """Approve or disapprove a supplier. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can approve suppliers")
    
    supplier = service.approve_supplier(supplier_id, current_user.id, approved)
    if not supplier:
        raise HTTPException(status_code=404, detail="Supplier not found")
    return _supplier_to_response(supplier)


def _supplier_to_response(s) -> SupplierResponse:
    return SupplierResponse(
        id=s.id, name=s.name, code=s.code,
        scope=s.scope, store_id=s.store_id,
        contact_person=s.contact_person, email=s.email, phone=s.phone,
        fax=s.fax, website=s.website,
        address=s.address, city=s.city, state=s.state,
        postal_code=s.postal_code, country=s.country,
        license_number=s.license_number, drug_license_number=s.drug_license_number,
        gst_number=s.gst_number, tax_id=s.tax_id,
        payment_terms=s.payment_terms, credit_limit=s.credit_limit,
        rating=s.rating, notes=s.notes,
        inactive=s.inactive, is_approved=s.is_approved,
        created_at=s.created_at, updated_at=s.updated_at
    )
