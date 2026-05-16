from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from app.database import get_db
from app.schemas.service_schema import ServiceCreate, ServiceUpdate, ServiceResponse
from app.services.service_service import ServiceService
from app.dependencies import get_current_active_user, PermissionChecker
from app.models.user_m import User

router = APIRouter(prefix="/services", tags=["Services"])


@router.post(
    "/",
    response_model=ServiceResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["service.create"]))]
)
async def create_service(
    service: ServiceCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Create new service"""
    return ServiceService.create_service(db, service, current_user)


@router.get(
    "/",
    response_model=List[ServiceResponse],
    dependencies=[Depends(PermissionChecker(["service.view"]))]
)
async def get_services(
    is_active: Optional[bool] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get all services"""
    return ServiceService.get_all_services(db, is_active, skip, limit)


@router.get(
    "/{service_id}",
    response_model=ServiceResponse,
    dependencies=[Depends(PermissionChecker(["service.view"]))]
)
async def get_service(
    service_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get service by ID"""
    service = ServiceService.get_service_by_id(db, service_id)
    if not service:
        raise HTTPException(status_code=404, detail="Service not found")
    return service


@router.put(
    "/{service_id}",
    response_model=ServiceResponse,
    dependencies=[Depends(PermissionChecker(["service.update"]))]
)
async def update_service(
    service_id: int,
    service_update: ServiceUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Update service"""
    return ServiceService.update_service(db, service_id, service_update, current_user)


@router.delete(
    "/{service_id}",
    dependencies=[Depends(PermissionChecker(["service.delete"]))]
)
async def delete_service(
    service_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Soft delete service"""
    ServiceService.delete_service(db, service_id, current_user)
    return {"message": "Service deleted successfully"}
