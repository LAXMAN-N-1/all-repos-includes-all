from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import Optional, List, Tuple, TYPE_CHECKING
from typing import Optional, List, Tuple, TYPE_CHECKING
from datetime import datetime
from app.models.medicine import Medicine, DrugSchedule, DrugCategory
from app.models.audit_log import AuditActionType
from app.schemas.medicine_schema import MedicineCreate, MedicineUpdate, MedicineFilters

if TYPE_CHECKING:
    from app.services.audit_service import AuditService


class MedicineService:
    """Service for drug catalog management"""
    
    def __init__(self, db: Session, audit_service: "AuditService"):
        self.db = db
        self.audit_service = audit_service
    
    def create_medicine(self, data: MedicineCreate, user_id: int) -> Medicine:
        """Create a new medicine in the catalog"""
        medicine = Medicine(
            name=data.name,
            generic_name=data.generic_name,
            brand=data.brand,
            manufacturer=data.manufacturer,
            ndc_code=data.ndc_code,
            upc_code=data.upc_code,
            category=DrugCategory(data.category.value),
            schedule=DrugSchedule(data.schedule.value),
            requires_prescription=data.requires_prescription,
            is_controlled_substance=data.is_controlled_substance,
            is_refrigerated=data.is_refrigerated,
            dosage_form=data.dosage_form,
            strength=data.strength,
            unit_of_measure=data.unit_of_measure,
            base_price=data.base_price,
            description=data.description,
            usage_instructions=data.usage_instructions,
            side_effects=data.side_effects,
            contraindications=data.contraindications,
            inactive=False,
            created_by=user_id
        )
        self.db.add(medicine)
        self.db.commit()
        self.db.refresh(medicine)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.CREATE,
            entity_type="Medicine",
            entity_id=medicine.id,
            new_values={"name": medicine.name, "ndc_code": medicine.ndc_code}
        )
        
        return medicine
    
    def get_medicine(self, medicine_id: int) -> Optional[Medicine]:
        """Get a single medicine by ID"""
        return self.db.query(Medicine).filter(
            Medicine.id == medicine_id,
            Medicine.inactive == False
        ).first()
    
    def get_medicine_by_ndc(self, ndc_code: str) -> Optional[Medicine]:
        """Get medicine by NDC code"""
        return self.db.query(Medicine).filter(
            Medicine.ndc_code == ndc_code,
            Medicine.inactive == False
        ).first()
    
    def get_medicines(
        self,
        filters: MedicineFilters,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Medicine], int]:
        """Get paginated list of medicines with filters"""
        query = self.db.query(Medicine).filter(Medicine.inactive == False)
        
        if filters.search:
            search_term = f"%{filters.search}%"
            query = query.filter(
                or_(
                    Medicine.name.ilike(search_term),
                    Medicine.generic_name.ilike(search_term),
                    Medicine.brand.ilike(search_term)
                )
            )
        
        if filters.category:
            query = query.filter(Medicine.category == filters.category.value)
        
        if filters.schedule:
            query = query.filter(Medicine.schedule == filters.schedule.value)
        
        if filters.requires_prescription is not None:
            query = query.filter(Medicine.requires_prescription == filters.requires_prescription)
        
        if filters.is_controlled_substance is not None:
            query = query.filter(Medicine.is_controlled_substance == filters.is_controlled_substance)
        
        if filters.manufacturer:
            query = query.filter(Medicine.manufacturer.ilike(f"%{filters.manufacturer}%"))
        
        if filters.inactive is not None:
            query = query.filter(Medicine.inactive == filters.inactive)
        
        total = query.count()
        offset = (page - 1) * page_size
        medicines = query.order_by(Medicine.name.asc()).offset(offset).limit(page_size).all()
        
        return medicines, total
    
    def search_medicines(
        self,
        search_term: str,
        limit: int = 20
    ) -> List[Medicine]:
        """Quick search for medicines (autocomplete)"""
        term = f"%{search_term}%"
        return self.db.query(Medicine).filter(
            Medicine.inactive == False,
            Medicine.inactive == False,
            or_(
                Medicine.name.ilike(term),
                Medicine.generic_name.ilike(term),
                Medicine.brand.ilike(term)
            )
        ).order_by(Medicine.name.asc()).limit(limit).all()
    
    def update_medicine(
        self,
        medicine_id: int,
        data: MedicineUpdate,
        user_id: int
    ) -> Optional[Medicine]:
        """Update a medicine"""
        medicine = self.get_medicine(medicine_id)
        if not medicine:
            return None
        
        old_values = {"name": medicine.name, "inactive": medicine.inactive}
        
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            if value is not None:
                # Handle enum conversions
                if field == "category":
                    value = DrugCategory(value.value)
                elif field == "schedule":
                    value = DrugSchedule(value.value)
                setattr(medicine, field, value)
        
        medicine.modified_by = user_id
        self.db.commit()
        self.db.refresh(medicine)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="Medicine",
            entity_id=medicine.id,
            old_values=old_values,
            new_values=update_data
        )
        
        return medicine
    
    def delete_medicine(self, medicine_id: int, user_id: int) -> bool:
        """Soft delete a medicine"""
        medicine = self.get_medicine(medicine_id)
        if not medicine:
            return False
        
        medicine.soft_delete(user_id)
        self.db.commit()
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.DELETE,
            entity_type="Medicine",
            entity_id=medicine.id
        )
        
        return True
    
    def get_controlled_substances(
        self,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Medicine], int]:
        """Get all controlled substances"""
        filters = MedicineFilters(is_controlled_substance=True)
        return self.get_medicines(filters, page, page_size)
    
    def get_prescription_medicines(
        self,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Medicine], int]:
        """Get medicines that require prescription"""
        filters = MedicineFilters(requires_prescription=True)
        return self.get_medicines(filters, page, page_size)
    
    def get_by_category(
        self,
        category: DrugCategory,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Medicine], int]:
        """Get medicines by category"""
        from app.schemas.medicine_schema import DrugCategoryEnum
        filters = MedicineFilters(category=DrugCategoryEnum(category.value))
        return self.get_medicines(filters, page, page_size)
    
