from sqlalchemy.orm import Session
from sqlalchemy import func
from fastapi import HTTPException

from app.models.service_m import Service
from app.schemas.service_schema import ServiceCreate, ServiceUpdate

class ServiceService:

    @staticmethod
    def create_service(db: Session, service: ServiceCreate, current_user):
        """Create new service"""
        existing = db.query(Service).filter(Service.code == service.code).first()
        if existing:
            raise HTTPException(status_code=400, detail="Service code already exists")
        
        new_service = Service(
            **service.dict(),
            created_by=current_user.username
        )
        db.add(new_service)
        db.commit()
        db.refresh(new_service)
        return new_service

    @staticmethod
    def get_all_services(db: Session, is_active: bool = None, skip: int = 0, limit: int = 100):
        """Get all services with optional filter"""
        query = db.query(Service).filter(Service.inactive == False)
        
        if is_active is not None:
            query = query.filter(Service.is_active == is_active)
        
        return query.offset(skip).limit(limit).all()

    @staticmethod
    def get_service_by_id(db: Session, service_id: int):
        """Get service by ID"""
        return db.query(Service).filter(
            Service.id == service_id,
            Service.inactive == False
        ).first()

    @staticmethod
    def update_service(db: Session, service_id: int, service_update: ServiceUpdate, current_user):
        """Update service"""
        service = ServiceService.get_service_by_id(db, service_id)
        if not service:
            raise HTTPException(status_code=404, detail="Service not found")
        
        for key, value in service_update.dict(exclude_unset=True).items():
            setattr(service, key, value)
        
        service.modified_by = current_user.username
        db.commit()
        db.refresh(service)
        return service

    @staticmethod
    def delete_service(db: Session, service_id: int, current_user):
        """Soft delete service"""
        service = ServiceService.get_service_by_id(db, service_id)
        if not service:
            raise HTTPException(status_code=404, detail="Service not found")
        
        service.inactive = True
        service.modified_by = current_user.username
        db.commit()
