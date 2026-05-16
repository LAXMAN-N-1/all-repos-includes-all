from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from typing import Optional, List, Tuple, TYPE_CHECKING
from app.models.supplier import Supplier
from app.models.audit_log import AuditActionType
from app.schemas.supplier_schema import SupplierCreate, SupplierUpdate, SupplierFilters, SupplierScopeEnum

if TYPE_CHECKING:
    from app.services.audit_service import AuditService


class SupplierService:
    """Service for supplier/vendor management"""
    
    def __init__(self, db: Session, audit_service: "AuditService"):
        self.db = db
        self.audit_service = audit_service
    
    def create_supplier(self, data: SupplierCreate, user_id: int) -> Supplier:
        """Create a new supplier"""
        supplier = Supplier(
            name=data.name,
            code=data.code,
            contact_person=data.contact_person,
            email=data.email,
            phone=data.phone,
            fax=data.fax,
            website=data.website,
            address=data.address,
            city=data.city,
            state=data.state,
            postal_code=data.postal_code,
            country=data.country or "India",
            license_number=data.license_number,
            drug_license_number=data.drug_license_number,
            gst_number=data.gst_number,
            tax_id=data.tax_id,
            payment_terms=data.payment_terms,
            credit_limit=data.credit_limit or 0.0,
            notes=data.notes,
            scope=data.scope,
            store_id=data.store_id,
            inactive=False,
            is_approved=False,
            created_by=user_id
        )
        self.db.add(supplier)
        self.db.commit()
        self.db.refresh(supplier)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.CREATE,
            entity_type="Supplier",
            entity_id=supplier.id,
            new_values={"name": supplier.name, "code": supplier.code}
        )
        
        return supplier
    
    def get_supplier(self, supplier_id: int) -> Optional[Supplier]:
        """Get a single supplier by ID"""
        return self.db.query(Supplier).filter(
            Supplier.id == supplier_id,
            Supplier.inactive == False
        ).first()
    
    def get_supplier_by_code(self, code: str) -> Optional[Supplier]:
        """Get supplier by code"""
        return self.db.query(Supplier).filter(
            Supplier.code == code,
            Supplier.inactive == False
        ).first()
    
    def get_suppliers(
        self,
        filters: SupplierFilters,
        page: int = 1,
        page_size: int = 20,
        user_store_ids: Optional[List[int]] = None
    ) -> Tuple[List[Supplier], int]:
        """Get paginated list of suppliers with filters"""
        query = self.db.query(Supplier).filter(Supplier.inactive == False)

        # Scope visibility logic
        if user_store_ids is not None:
             # Store Admin: See ORG + Own Store
             query = query.filter(
                 or_(
                     Supplier.scope == SupplierScopeEnum.ORG,
                     and_(
                         Supplier.scope == SupplierScopeEnum.STORE,
                         Supplier.store_id.in_(user_store_ids)
                     )
                 )
             )
        
        if filters.search:
            search_term = f"%{filters.search}%"
            query = query.filter(
                or_(
                    Supplier.name.ilike(search_term),
                    Supplier.code.ilike(search_term),
                    Supplier.contact_person.ilike(search_term)
                )
            )
        
        if filters.city:
            query = query.filter(Supplier.city.ilike(f"%{filters.city}%"))
        
        if filters.state:
            query = query.filter(Supplier.state.ilike(f"%{filters.state}%"))
        
        if filters.inactive is not None:
            query = query.filter(Supplier.inactive == filters.inactive)
        
        if filters.is_approved is not None:
            query = query.filter(Supplier.is_approved == filters.is_approved)
        
        total = query.count()
        offset = (page - 1) * page_size
        suppliers = query.order_by(Supplier.name.asc()).offset(offset).limit(page_size).all()
        
        return suppliers, total
    
    def search_suppliers(
        self,
        search_term: str,
        limit: int = 20,
        user_store_ids: Optional[List[int]] = None
    ) -> List[Supplier]:
        """Quick search for suppliers (autocomplete)"""
        term = f"%{search_term}%"
        query = self.db.query(Supplier).filter(
            Supplier.inactive == False,
            Supplier.inactive == False,
            or_(
                Supplier.name.ilike(term),
                Supplier.code.ilike(term)
            )
        )

        if user_store_ids is not None:
             query = query.filter(
                 or_(
                     Supplier.scope == SupplierScopeEnum.ORG,
                     and_(
                         Supplier.scope == SupplierScopeEnum.STORE,
                         Supplier.store_id.in_(user_store_ids)
                     )
                 )
             )

        return query.order_by(Supplier.name.asc()).limit(limit).all()
    
    def update_supplier(
        self,
        supplier_id: int,
        data: SupplierUpdate,
        user_id: int
    ) -> Optional[Supplier]:
        """Update a supplier"""
        supplier = self.get_supplier(supplier_id)
        if not supplier:
            return None
        
        old_values = {"name": supplier.name, "inactive": supplier.inactive}
        
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            if value is not None:
                setattr(supplier, field, value)
        
        supplier.modified_by = user_id
        self.db.commit()
        self.db.refresh(supplier)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="Supplier",
            entity_id=supplier.id,
            old_values=old_values,
            new_values=update_data
        )
        
        return supplier
    
    def delete_supplier(self, supplier_id: int, user_id: int) -> bool:
        """Soft delete a supplier"""
        supplier = self.get_supplier(supplier_id)
        if not supplier:
            return False
        
        supplier.soft_delete(user_id)
        self.db.commit()
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.DELETE,
            entity_type="Supplier",
            entity_id=supplier.id
        )
        
        return True
    
    def approve_supplier(
        self,
        supplier_id: int,
        user_id: int,
        approved: bool = True
    ) -> Optional[Supplier]:
        """Approve or disapprove a supplier"""
        supplier = self.get_supplier(supplier_id)
        if not supplier:
            return None
        
        old_approved = supplier.is_approved
        supplier.is_approved = approved
        supplier.modified_by = user_id
        self.db.commit()
        self.db.refresh(supplier)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="Supplier",
            entity_id=supplier.id,
            old_values={"is_approved": old_approved},
            new_values={"is_approved": approved}
        )
        
        return supplier
    
    def get_approved_suppliers(
        self,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Supplier], int]:
        """Get all approved and active suppliers"""
        filters = SupplierFilters(inactive=False, is_approved=True)
        return self.get_suppliers(filters, page, page_size)
