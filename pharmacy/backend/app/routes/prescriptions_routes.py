from fastapi import APIRouter, Depends, HTTPException, status, Query, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import Optional
from typing import Optional
from datetime import datetime
from app.database import get_db
from app.models.user import User, UserRole
from app.auth.deps import get_current_user
from app.services.prescription_service import PrescriptionService
from app.dependencies import get_prescription_service
from app.schemas.prescription_schema import (
    PrescriptionUpload, PrescriptionVerify, PrescriptionUpdate,
    PrescriptionResponse, PrescriptionSummaryResponse, PrescriptionListResponse,
    PrescriptionFilters, PrescriptionStatusEnum, PendingPrescriptionQueue,
    PrescriptionOCRResult, PrescriptionAvailabilityResponse, ExtractedDataUpdate
)

router = APIRouter(prefix="/api/v1/prescriptions", tags=["Prescriptions"])



def prescription_to_response(prescription) -> PrescriptionResponse:
    """Convert Prescription model to PrescriptionResponse schema"""
    return PrescriptionResponse(
        id=prescription.id,
        customer_id=prescription.customer_id,
        store_id=prescription.store_id,
        verified_by=prescription.verified_by,
        status=PrescriptionStatusEnum(prescription.status.value),
        image_url=prescription.image_url,
        image_thumbnail_url=prescription.image_thumbnail_url,
        extracted_data=prescription.extracted_data,
        ocr_confidence_score=prescription.ocr_confidence_score,
        ocr_processed_at=prescription.ocr_processed_at,
        doctor_name=prescription.doctor_name,
        doctor_license=prescription.doctor_license,
        hospital_clinic=prescription.hospital_clinic,
        prescription_date=prescription.prescription_date,
        valid_until=prescription.valid_until,
        refills_allowed=prescription.refills_allowed or 0,
        refills_used=prescription.refills_used or 0,
        verified_at=prescription.verified_at,
        rejection_reason=prescription.rejection_reason,
        notes=prescription.notes,
        pharmacist_notes=prescription.pharmacist_notes,
        created_at=prescription.created_at,
        updated_at=prescription.updated_at
    )


@router.get("/", response_model=PrescriptionListResponse)
async def list_prescriptions(
    store_id: Optional[int] = Query(None),
    customer_id: Optional[int] = Query(None),
    status: Optional[PrescriptionStatusEnum] = Query(None),
    verified_by: Optional[int] = Query(None),
    date_from: Optional[datetime] = Query(None),
    date_to: Optional[datetime] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    service: PrescriptionService = Depends(get_prescription_service)
):
    """
    List prescriptions with filters.
    - HQ Admin: Can see all
    - Store Admin/Pharmacist: Only assigned stores
    - Customer: Only own prescriptions
    """
    filters = PrescriptionFilters(
        store_id=store_id,
        customer_id=customer_id,
        status=status,
        verified_by=verified_by,
        date_from=date_from,
        date_to=date_to
    )
    
    # Apply role-based access control
    if current_user.role.code == UserRole.CUSTOMER.value:
        filters.customer_id = current_user.id
    elif current_user.role.code != UserRole.HQ_ADMIN.value:
        assigned_store_ids = [str(s.id) for s in current_user.assigned_stores]
        if store_id and str(store_id) not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
        if not store_id and assigned_store_ids:
            filters.store_id = int(assigned_store_ids[0])
    
    prescriptions, total = service.get_prescriptions(filters, page, page_size)
    
    items = []
    for rx in prescriptions:
        customer_name = rx.customer.full_name if rx.customer else None
        store_name = rx.store.name if rx.store else None
        items.append(PrescriptionSummaryResponse(
            id=rx.id,
            customer_id=rx.customer_id,
            customer_name=customer_name,
            store_id=rx.store_id,
            store_name=store_name,
            status=PrescriptionStatusEnum(rx.status.value),
            has_image=bool(rx.image_url),
            doctor_name=rx.doctor_name,
            created_at=rx.created_at
        ))
    
    total_pages = (total + page_size - 1) // page_size
    
    return PrescriptionListResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )


@router.post("/upload", response_model=PrescriptionResponse, status_code=status.HTTP_201_CREATED)
async def upload_prescription(
    data: PrescriptionUpload,
    current_user: User = Depends(get_current_user),
    service: PrescriptionService = Depends(get_prescription_service)
):
    """
    Upload a prescription using pre-uploaded image URL.
    Queues the prescription for OCR processing and pharmacist verification.
    """
    prescription = service.upload_prescription(data, current_user.id)
    return prescription_to_response(prescription)


@router.post("/upload-file", response_model=PrescriptionResponse, status_code=status.HTTP_201_CREATED)
async def upload_prescription_file(
    file: UploadFile = File(..., description="Prescription image (JPEG, PNG, or PDF)"),
    store_id: Optional[int] = Form(None, description="Target store ID"),
    notes: Optional[str] = Form(None, description="Customer notes"),
    current_user: User = Depends(get_current_user),
    service: PrescriptionService = Depends(get_prescription_service)
):
    """
    Upload a prescription image file directly.
    Accepts JPEG, PNG, GIF, or PDF files up to 10MB.
    File is uploaded to cloud storage (Cloudinary) and OCR is triggered automatically.
    """
    from app.utils.storage import upload_file
    import logging
    logger = logging.getLogger(__name__)
    
    # Upload file to Cloudinary
    upload_result = await upload_file(file, folder="prescriptions")
    
    # Create prescription with uploaded URLs
    prescription_data = PrescriptionUpload(
        store_id=store_id,
        image_url=upload_result["url"],
        notes=notes
    )
    
    prescription = service.upload_prescription(prescription_data, current_user.id)
    
    # Update thumbnail URL if available
    if upload_result.get("thumbnail_url"):
        prescription.image_thumbnail_url = upload_result["thumbnail_url"]
    
    # 🔄 Auto-trigger OCR processing
    try:
        logger.info(f"Auto-triggering OCR for prescription {prescription.id}")
        ocr_result = service.process_ocr(prescription.id)
        logger.info(f"OCR completed: {ocr_result.status}, found {len(ocr_result.extracted_data.medicines)} medicines")
    except Exception as e:
        # Log error but don't fail the upload
        logger.error(f"Auto-OCR failed for prescription {prescription.id}: {e}")
        # Prescription is still created, pharmacist can manually trigger OCR
    
    # Refresh prescription to get updated data
    prescription = service.get_prescription(prescription.id)
    
    return prescription_to_response(prescription)


@router.get("/pending", response_model=PendingPrescriptionQueue)
async def get_pending_prescriptions(
    store_id: Optional[int] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    service: PrescriptionService = Depends(get_prescription_service)
):
    """
    Get pending prescriptions queue for pharmacists.
    Returns prescriptions awaiting verification.
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value, UserRole.PHARMACIST.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Apply store access control
    if current_user.role.code != UserRole.HQ_ADMIN.value:
        assigned_store_ids = [str(s.id) for s in current_user.assigned_stores]
        if store_id and str(store_id) not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
        if not store_id and assigned_store_ids:
            store_id = int(assigned_store_ids[0])
    
    prescriptions, total_pending, total_processing = service.get_pending_prescriptions(
        store_id, page, page_size
    )
    
    items = []
    for rx in prescriptions:
        customer_name = rx.customer.full_name if rx.customer else None
        store_name = rx.store.name if rx.store else None
        items.append(PrescriptionSummaryResponse(
            id=rx.id,
            customer_id=rx.customer_id,
            customer_name=customer_name,
            store_id=rx.store_id,
            store_name=store_name,
            status=PrescriptionStatusEnum(rx.status.value),
            has_image=bool(rx.image_url),
            doctor_name=rx.doctor_name,
            created_at=rx.created_at
        ))
    
    return PendingPrescriptionQueue(
        items=items,
        total_pending=total_pending,
        total_processing=total_processing
    )


@router.post("/{prescription_id}/process-ocr", response_model=PrescriptionOCRResult)
async def process_prescription_ocr(
    prescription_id: int,
    current_user: User = Depends(get_current_user),
    service: PrescriptionService = Depends(get_prescription_service)
):
    """
    Trigger OCR processing for a prescription.
    This is a stub endpoint - actual OCR integration would call external service.
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value, UserRole.PHARMACIST.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    try:
        result = service.process_ocr(prescription_id)
        return result
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.get("/{prescription_id}", response_model=PrescriptionResponse)
async def get_prescription(
    prescription_id: int,
    current_user: User = Depends(get_current_user),
    service: PrescriptionService = Depends(get_prescription_service)
):
    """Get a single prescription by ID."""
    prescription = service.get_prescription(prescription_id)
    if not prescription:
        raise HTTPException(status_code=404, detail="Prescription not found")
    
    # Verify access
    if current_user.role.code == UserRole.CUSTOMER.value:
        if prescription.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Access denied")
    elif current_user.role.code != UserRole.HQ_ADMIN.value:
        assigned_store_ids = [str(s.id) for s in current_user.assigned_stores]
        if prescription.store_id and str(prescription.store_id) not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
    
    return prescription_to_response(prescription)


@router.put("/{prescription_id}/verify", response_model=PrescriptionResponse)
async def verify_prescription(
    prescription_id: int,
    data: PrescriptionVerify,
    current_user: User = Depends(get_current_user),
    service: PrescriptionService = Depends(get_prescription_service)
):
    """
    Verify or reject a prescription (pharmacist action).
    Only pharmacists, store admins, and HQ admins can verify.
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value, UserRole.PHARMACIST.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Validate status
    if data.status not in [PrescriptionStatusEnum.VERIFIED, PrescriptionStatusEnum.REJECTED]:
        raise HTTPException(
            status_code=400, 
            detail="Status must be VERIFIED or REJECTED"
        )
    
    try:
        prescription = service.verify_prescription(prescription_id, data, current_user.id)
        if not prescription:
            raise HTTPException(status_code=404, detail="Prescription not found")
        return prescription_to_response(prescription)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{prescription_id}", response_model=PrescriptionResponse)
async def update_prescription(
    prescription_id: int,
    data: PrescriptionUpdate,
    current_user: User = Depends(get_current_user),
    service: PrescriptionService = Depends(get_prescription_service)
):
    """Update prescription details."""
    prescription = service.update_prescription(prescription_id, data, current_user.id)
    if not prescription:
        raise HTTPException(status_code=404, detail="Prescription not found")
    return prescription_to_response(prescription)


@router.post("/{prescription_id}/mark-filled", response_model=PrescriptionResponse)
async def mark_prescription_filled(
    prescription_id: int,
    current_user: User = Depends(get_current_user),
    service: PrescriptionService = Depends(get_prescription_service)
):
    """Mark a prescription as filled after order completion."""
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value, UserRole.PHARMACIST.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    try:
        prescription = service.mark_filled(prescription_id, current_user.id)
        if not prescription:
            raise HTTPException(status_code=404, detail="Prescription not found")
        return prescription_to_response(prescription)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/{prescription_id}/availability", response_model=PrescriptionAvailabilityResponse)
async def check_prescription_availability(
    prescription_id: int,
    store_id: Optional[int] = Query(None, description="Override store for availability check"),
    current_user: User = Depends(get_current_user),
    service: PrescriptionService = Depends(get_prescription_service)
):
    """
    Check medicine availability for a prescription.
    Matches extracted medicines against store inventory.
    
    - Returns which medicines are available
    - Returns quantity, price, and batch information
    - Can be called by customer after pharmacist verification
    """
    # Verify access
    prescription = service.get_prescription(prescription_id)
    if not prescription:
        raise HTTPException(status_code=404, detail="Prescription not found")
    
    if current_user.role.code == UserRole.CUSTOMER.value:
        if prescription.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Access denied")
    
    try:
        availability = service.check_availability(prescription_id, store_id)
        return PrescriptionAvailabilityResponse(**availability)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{prescription_id}/extracted-data", response_model=PrescriptionResponse)
async def update_extracted_data(
    prescription_id: int,
    data: ExtractedDataUpdate,
    current_user: User = Depends(get_current_user),
    service: PrescriptionService = Depends(get_prescription_service)
):
    """
    Update/correct OCR extracted data (pharmacist action).
    Used to fix errors in patient info, doctor info, or medicines.
    
    - Only pharmacists, store admins, and HQ admins can update
    - Updates extracted_data JSON field on prescription
    - Medicines list can be completely replaced with corrected data
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value, UserRole.PHARMACIST.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    prescription = service.get_prescription(prescription_id)
    if not prescription:
        raise HTTPException(status_code=404, detail="Prescription not found")
    
    try:
        updated_prescription = service.update_extracted_data(
            prescription_id, 
            data.model_dump(exclude_unset=True), 
            current_user.id
        )
        if not updated_prescription:
            raise HTTPException(status_code=404, detail="Prescription not found")
        return prescription_to_response(updated_prescription)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

