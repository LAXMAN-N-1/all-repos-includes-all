from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class PrescriptionStatusEnum(str, Enum):
    PENDING = "PENDING"
    PROCESSING = "PROCESSING"
    VERIFIED = "VERIFIED"
    REJECTED = "REJECTED"
    FILLED = "FILLED"
    CANCELLED = "CANCELLED"


# ============= Extracted Data Schemas =============

class ExtractedMedicine(BaseModel):
    """Schema for medicine extracted from prescription via OCR"""
    name: str
    strength: Optional[str] = None  # e.g., "625mg", "40mg"
    dosage: Optional[str] = None
    quantity: Optional[str] = None
    frequency: Optional[str] = None  # e.g., "1-0-1"
    duration: Optional[str] = None  # e.g., "5 days"
    instructions: Optional[str] = None  # e.g., "after meals", "before meals"
    medicine_id: Optional[int] = None  # Matched from catalog
    raw_name: Optional[str] = None  # Original OCR text
    match_score: Optional[float] = None  # Fuzzy match score


class ExtractedPrescriptionData(BaseModel):
    """Schema for OCR-extracted prescription data"""
    doctor_name: Optional[str] = None
    doctor_license: Optional[str] = None
    hospital_clinic: Optional[str] = None
    patient_name: Optional[str] = None
    prescription_date: Optional[str] = None
    medicines: List[ExtractedMedicine] = []
    raw_text: Optional[str] = None


# ============= Request Schemas =============

class PrescriptionUpload(BaseModel):
    """Schema for uploading a prescription"""
    store_id: Optional[int] = None
    image_url: str = Field(..., min_length=1)
    notes: Optional[str] = None


class PrescriptionVerify(BaseModel):
    """Schema for pharmacist to verify prescription"""
    status: PrescriptionStatusEnum = Field(..., description="Must be VERIFIED or REJECTED")
    doctor_name: Optional[str] = None
    doctor_license: Optional[str] = None
    hospital_clinic: Optional[str] = None
    prescription_date: Optional[datetime] = None
    valid_until: Optional[datetime] = None
    refills_allowed: int = Field(default=0, ge=0)
    pharmacist_notes: Optional[str] = None
    rejection_reason: Optional[str] = None


class PrescriptionUpdate(BaseModel):
    """Schema for updating prescription details"""
    store_id: Optional[int] = None
    status: Optional[PrescriptionStatusEnum] = None
    notes: Optional[str] = None


class ExtractedMedicineUpdate(BaseModel):
    """Schema for updating a single extracted medicine"""
    name: str
    strength: Optional[str] = None
    frequency: Optional[str] = None  # e.g., "1-0-1"
    duration: Optional[str] = None  # e.g., "5 days"
    instructions: Optional[str] = None  # e.g., "after meals"
    quantity: Optional[int] = None


class ExtractedDataUpdate(BaseModel):
    """Schema for pharmacist to update/correct OCR extracted data"""
    doctor_name: Optional[str] = None
    patient_name: Optional[str] = None
    patient_age: Optional[int] = None
    patient_gender: Optional[str] = None
    date: Optional[str] = None
    hospital_clinic: Optional[str] = None
    medicines: List[ExtractedMedicineUpdate] = []


# ============= Response Schemas =============

class PrescriptionOCRResult(BaseModel):
    """Schema for OCR processing result"""
    prescription_id: int
    extracted_data: ExtractedPrescriptionData
    confidence_score: float = Field(..., ge=0, le=1)
    processed_at: datetime
    status: str  # "SUCCESS", "PARTIAL", "FAILED"
    error_message: Optional[str] = None


class PrescriptionResponse(BaseModel):
    """Schema for prescription response"""
    id: int
    customer_id: int
    store_id: Optional[int] = None
    verified_by: Optional[int] = None
    status: PrescriptionStatusEnum
    image_url: Optional[str] = None
    image_thumbnail_url: Optional[str] = None
    extracted_data: Optional[Dict[str, Any]] = None
    ocr_confidence_score: Optional[float] = None
    ocr_processed_at: Optional[datetime] = None
    doctor_name: Optional[str] = None
    doctor_license: Optional[str] = None
    hospital_clinic: Optional[str] = None
    prescription_date: Optional[datetime] = None
    valid_until: Optional[datetime] = None
    refills_allowed: int = 0
    refills_used: int = 0
    verified_at: Optional[datetime] = None
    rejection_reason: Optional[str] = None
    notes: Optional[str] = None
    pharmacist_notes: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class PrescriptionSummaryResponse(BaseModel):
    """Schema for prescription summary (list view)"""
    id: int
    customer_id: int
    customer_name: Optional[str] = None
    store_id: Optional[int] = None
    store_name: Optional[str] = None
    status: PrescriptionStatusEnum
    has_image: bool
    doctor_name: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class PrescriptionListResponse(BaseModel):
    """Schema for paginated prescription list"""
    items: List[PrescriptionSummaryResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


class PendingPrescriptionQueue(BaseModel):
    """Schema for pending prescription queue (pharmacist view)"""
    items: List[PrescriptionSummaryResponse]
    total_pending: int
    total_processing: int


# ============= Filter Schemas =============

class PrescriptionFilters(BaseModel):
    """Schema for prescription filters"""
    store_id: Optional[int] = None
    customer_id: Optional[int] = None
    status: Optional[PrescriptionStatusEnum] = None
    verified_by: Optional[int] = None
    date_from: Optional[datetime] = None
    date_to: Optional[datetime] = None


# ============= Availability Check Schemas =============

class MedicineAvailability(BaseModel):
    """Schema for individual medicine availability"""
    name: str
    strength: Optional[str] = None
    available: bool
    quantity_available: int = 0
    unit_price: Optional[float] = None
    inventory_batch_id: Optional[int] = None
    expiry_date: Optional[datetime] = None
    reason: Optional[str] = None  # "out_of_stock", "expired", "not_found"
    alternatives: List[str] = []  # Alternative medicine suggestions


class PrescriptionAvailabilityResponse(BaseModel):
    """Schema for prescription medicine availability check"""
    prescription_id: int
    status: PrescriptionStatusEnum
    store_id: Optional[int] = None
    store_name: Optional[str] = None
    total_medicines: int
    available_count: int
    unavailable_count: int
    medicines: List[MedicineAvailability]
    can_order: bool  # True if at least 1 medicine is available
    estimated_total: float = 0.0  # Total price for available medicines

