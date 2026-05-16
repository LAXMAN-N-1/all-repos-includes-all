"""
Centralized Dependency Injection for FastAPI

This module provides factory functions for all services using FastAPI's Depends system.
This is the industry-standard pattern for dependency injection in FastAPI applications.

Usage in routes:
    from app.dependencies import get_store_service
    
    @router.post("/")
    async def create_store(
        service: StoreService = Depends(get_store_service)
    ):
        ...
"""
from fastapi import Depends
from sqlalchemy.orm import Session
from app.database import get_db

# Import services
from app.services.audit_service import AuditService
from app.services.store_service import StoreService
from app.services.user_service import UserService
from app.services.role_service import RoleService
from app.services.inventory_service import InventoryService
from app.services.medicine_service import MedicineService
from app.services.order_service import OrderService
from app.services.prescription_service import PrescriptionService
from app.services.supplier_service import SupplierService
from app.services.procurement_service import ProcurementService


# =============================================================================
# Core Services
# =============================================================================

def get_audit_service(db: Session = Depends(get_db)) -> AuditService:
    """Factory for AuditService - centralized audit logging."""
    return AuditService(db)


# =============================================================================
# Business Services (with AuditService dependency)
# =============================================================================

def get_store_service(
    db: Session = Depends(get_db),
    audit_service: AuditService = Depends(get_audit_service)
) -> StoreService:
    """Factory for StoreService - store management operations."""
    return StoreService(db, audit_service)


def get_user_service(
    db: Session = Depends(get_db),
    audit_service: AuditService = Depends(get_audit_service)
) -> UserService:
    """Factory for UserService - user management operations."""
    return UserService(db, audit_service)


def get_role_service(
    db: Session = Depends(get_db),
    audit_service: AuditService = Depends(get_audit_service)
) -> RoleService:
    """Factory for RoleService - role and permission management."""
    return RoleService(db, audit_service)


def get_inventory_service(
    db: Session = Depends(get_db),
    audit_service: AuditService = Depends(get_audit_service)
) -> InventoryService:
    """Factory for InventoryService - inventory batch management."""
    return InventoryService(db, audit_service)


def get_medicine_service(
    db: Session = Depends(get_db),
    audit_service: AuditService = Depends(get_audit_service)
) -> MedicineService:
    """Factory for MedicineService - drug catalog management."""
    return MedicineService(db, audit_service)


def get_order_service(
    db: Session = Depends(get_db),
    audit_service: AuditService = Depends(get_audit_service)
) -> OrderService:
    """Factory for OrderService - order management and pickup workflow."""
    return OrderService(db, audit_service)


def get_prescription_service(
    db: Session = Depends(get_db),
    audit_service: AuditService = Depends(get_audit_service)
) -> PrescriptionService:
    """Factory for PrescriptionService - prescription processing."""
    return PrescriptionService(db, audit_service)


def get_supplier_service(
    db: Session = Depends(get_db),
    audit_service: AuditService = Depends(get_audit_service)
) -> SupplierService:
    """Factory for SupplierService - supplier/vendor management."""
    return SupplierService(db, audit_service)


def get_procurement_service(
    db: Session = Depends(get_db),
    audit_service: AuditService = Depends(get_audit_service)
) -> ProcurementService:
    """Factory for ProcurementService - procurement order workflow."""
    return ProcurementService(db, audit_service)
