from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


class DrugScheduleEnum(str, Enum):
    OTC = "OTC"
    PRESCRIPTION = "PRESCRIPTION"
    SCHEDULE_II = "SCHEDULE_II"
    SCHEDULE_III = "SCHEDULE_III"
    SCHEDULE_IV = "SCHEDULE_IV"
    SCHEDULE_V = "SCHEDULE_V"


class DrugCategoryEnum(str, Enum):
    ANALGESIC = "ANALGESIC"
    ANTIBIOTIC = "ANTIBIOTIC"
    ANTIVIRAL = "ANTIVIRAL"
    ANTIFUNGAL = "ANTIFUNGAL"
    CARDIOVASCULAR = "CARDIOVASCULAR"
    RESPIRATORY = "RESPIRATORY"
    GASTROINTESTINAL = "GASTROINTESTINAL"
    DERMATOLOGICAL = "DERMATOLOGICAL"
    NEUROLOGICAL = "NEUROLOGICAL"
    HORMONAL = "HORMONAL"
    IMMUNOLOGICAL = "IMMUNOLOGICAL"
    VITAMIN_SUPPLEMENT = "VITAMIN_SUPPLEMENT"
    OTHER = "OTHER"


# ============= Request Schemas =============

class MedicineCreate(BaseModel):
    """Schema for creating a new medicine"""
    name: str = Field(..., min_length=1, max_length=255)
    generic_name: str = Field(..., min_length=1, max_length=255)
    brand: Optional[str] = Field(None, max_length=255)
    manufacturer: str = Field(..., min_length=1, max_length=255)
    ndc_code: Optional[str] = Field(None, max_length=50)
    upc_code: Optional[str] = Field(None, max_length=50)
    category: DrugCategoryEnum = DrugCategoryEnum.OTHER
    schedule: DrugScheduleEnum = DrugScheduleEnum.OTC
    requires_prescription: bool = False
    is_controlled_substance: bool = False
    is_refrigerated: bool = False
    dosage_form: Optional[str] = Field(None, max_length=100)
    strength: Optional[str] = Field(None, max_length=100)
    unit_of_measure: Optional[str] = Field(None, max_length=50)
    base_price: float = Field(default=0.0, ge=0)
    description: Optional[str] = None
    usage_instructions: Optional[str] = None
    side_effects: Optional[str] = None
    contraindications: Optional[str] = None


class MedicineUpdate(BaseModel):
    """Schema for updating a medicine"""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    generic_name: Optional[str] = Field(None, min_length=1, max_length=255)
    brand: Optional[str] = Field(None, max_length=255)
    manufacturer: Optional[str] = Field(None, min_length=1, max_length=255)
    category: Optional[DrugCategoryEnum] = None
    schedule: Optional[DrugScheduleEnum] = None
    requires_prescription: Optional[bool] = None
    is_controlled_substance: Optional[bool] = None
    is_refrigerated: Optional[bool] = None
    dosage_form: Optional[str] = Field(None, max_length=100)
    strength: Optional[str] = Field(None, max_length=100)
    unit_of_measure: Optional[str] = Field(None, max_length=50)
    base_price: Optional[float] = Field(None, ge=0)
    description: Optional[str] = None
    usage_instructions: Optional[str] = None
    side_effects: Optional[str] = None
    contraindications: Optional[str] = None
    inactive: Optional[bool] = None


# ============= Response Schemas =============

class MedicineResponse(BaseModel):
    """Schema for medicine response"""
    id: int
    name: str
    generic_name: str
    brand: Optional[str] = None
    manufacturer: str
    ndc_code: Optional[str] = None
    upc_code: Optional[str] = None
    category: DrugCategoryEnum
    schedule: DrugScheduleEnum
    requires_prescription: bool
    is_controlled_substance: bool
    is_refrigerated: bool
    dosage_form: Optional[str] = None
    strength: Optional[str] = None
    unit_of_measure: Optional[str] = None
    base_price: float
    description: Optional[str] = None
    usage_instructions: Optional[str] = None
    side_effects: Optional[str] = None
    contraindications: Optional[str] = None
    inactive: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class MedicineSummaryResponse(BaseModel):
    """Schema for medicine summary (list view, search results)"""
    id: int
    name: str
    generic_name: str
    brand: Optional[str] = None
    manufacturer: str
    category: DrugCategoryEnum
    schedule: DrugScheduleEnum
    requires_prescription: bool
    strength: Optional[str] = None
    base_price: float
    inactive: bool

    class Config:
        from_attributes = True


class MedicineListResponse(BaseModel):
    """Schema for paginated medicine list"""
    items: List[MedicineSummaryResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


# ============= Filter Schemas =============

class MedicineFilters(BaseModel):
    """Schema for medicine search filters"""
    search: Optional[str] = None  # Searches name, generic_name, brand
    category: Optional[DrugCategoryEnum] = None
    schedule: Optional[DrugScheduleEnum] = None
    requires_prescription: Optional[bool] = None
    is_controlled_substance: Optional[bool] = None
    manufacturer: Optional[str] = None
    inactive: Optional[bool] = None
