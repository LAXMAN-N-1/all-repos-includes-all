from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from typing import Optional
from app.database import get_db
from app.models.user import User, UserRole
from app.auth.deps import get_current_user
from app.services.medicine_service import MedicineService
from app.dependencies import get_medicine_service
from app.schemas.medicine_schema import (
    MedicineCreate, MedicineUpdate, MedicineFilters,
    MedicineResponse, MedicineSummaryResponse, MedicineListResponse,
    DrugCategoryEnum, DrugScheduleEnum
)

router = APIRouter(prefix="/api/v1/medicines", tags=["Medicines"])



@router.get("/", response_model=MedicineListResponse)
async def list_medicines(
    search: Optional[str] = Query(None),
    category: Optional[DrugCategoryEnum] = Query(None),
    schedule: Optional[DrugScheduleEnum] = Query(None),
    requires_prescription: Optional[bool] = Query(None),
    is_controlled_substance: Optional[bool] = Query(None),
    manufacturer: Optional[str] = Query(None),
    inactive: Optional[bool] = Query(False),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    service: MedicineService = Depends(get_medicine_service)
):
    """List medicines with search and filters."""
    filters = MedicineFilters(
        search=search, category=category, schedule=schedule,
        requires_prescription=requires_prescription,
        is_controlled_substance=is_controlled_substance,
        manufacturer=manufacturer, inactive=inactive
    )
    medicines, total = service.get_medicines(filters, page, page_size)
    
    items = [MedicineSummaryResponse(
        id=m.id, name=m.name, generic_name=m.generic_name, brand=m.brand,
        manufacturer=m.manufacturer, category=DrugCategoryEnum(m.category.value),
        schedule=DrugScheduleEnum(m.schedule.value), requires_prescription=m.requires_prescription,
        strength=m.strength, base_price=m.base_price, inactive=m.inactive
    ) for m in medicines]
    
    return MedicineListResponse(items=items, total=total, page=page,
        page_size=page_size, total_pages=(total + page_size - 1) // page_size)


@router.get("/search")
async def search_medicines(
    q: str = Query(..., min_length=2),
    limit: int = Query(20, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    service: MedicineService = Depends(get_medicine_service)
):
    """Quick medicine search for autocomplete."""
    medicines = service.search_medicines(q, limit)
    return {"results": [{"id": str(m.id), "name": m.name, "generic_name": m.generic_name,
        "brand": m.brand, "strength": m.strength, "requires_prescription": m.requires_prescription
    } for m in medicines]}


@router.post("/", response_model=MedicineResponse, status_code=status.HTTP_201_CREATED)
async def create_medicine(
    data: MedicineCreate,
    current_user: User = Depends(get_current_user),
    service: MedicineService = Depends(get_medicine_service)
):
    """Create a new medicine in the catalog. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can manage catalog")
    medicine = service.create_medicine(data, current_user.id)
    return _medicine_to_response(medicine)


@router.get("/{medicine_id}", response_model=MedicineResponse)
async def get_medicine(
    medicine_id: int,
    current_user: User = Depends(get_current_user),
    service: MedicineService = Depends(get_medicine_service)
):
    """Get a single medicine by ID."""
    medicine = service.get_medicine(medicine_id)
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")
    return _medicine_to_response(medicine)


@router.put("/{medicine_id}", response_model=MedicineResponse)
async def update_medicine(
    medicine_id: int, data: MedicineUpdate,
    current_user: User = Depends(get_current_user),
    service: MedicineService = Depends(get_medicine_service)
):
    """Update a medicine. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can manage catalog")
    medicine = service.update_medicine(medicine_id, data, current_user.id)
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")
    return _medicine_to_response(medicine)


@router.delete("/{medicine_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_medicine(
    medicine_id: int,
    current_user: User = Depends(get_current_user),
    service: MedicineService = Depends(get_medicine_service)
):
    """Soft delete a medicine. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can manage catalog")
    if not service.delete_medicine(medicine_id, current_user.id):
        raise HTTPException(status_code=404, detail="Medicine not found")


def _medicine_to_response(m) -> MedicineResponse:
    return MedicineResponse(
        id=m.id, name=m.name, generic_name=m.generic_name, brand=m.brand,
        manufacturer=m.manufacturer, ndc_code=m.ndc_code, upc_code=m.upc_code,
        category=DrugCategoryEnum(m.category.value), schedule=DrugScheduleEnum(m.schedule.value),
        requires_prescription=m.requires_prescription, is_controlled_substance=m.is_controlled_substance,
        is_refrigerated=m.is_refrigerated, dosage_form=m.dosage_form, strength=m.strength,
        unit_of_measure=m.unit_of_measure, base_price=m.base_price, description=m.description,
        usage_instructions=m.usage_instructions, side_effects=m.side_effects,
        contraindications=m.contraindications, inactive=m.inactive,
        created_at=m.created_at, updated_at=m.updated_at
    )
