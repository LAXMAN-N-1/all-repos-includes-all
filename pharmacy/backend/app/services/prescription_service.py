from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from typing import Optional, List, Tuple, Dict, Any, TYPE_CHECKING
from typing import Optional, List, Tuple, Dict, Any, TYPE_CHECKING
from datetime import datetime
import logging
from app.models.prescription import Prescription, PrescriptionStatus
from app.models.user import User
from app.models.audit_log import AuditActionType
from app.schemas.prescription_schema import (
    PrescriptionUpload, PrescriptionVerify, PrescriptionUpdate,
    PrescriptionFilters, ExtractedPrescriptionData, PrescriptionOCRResult
)

if TYPE_CHECKING:
    from app.services.audit_service import AuditService

logger = logging.getLogger(__name__)


class PrescriptionService:
    """Service for digital prescription processing with OCR/NLP hooks"""
    
    def __init__(self, db: Session, audit_service: "AuditService"):
        self.db = db
        self.audit_service = audit_service
    
    def upload_prescription(
        self,
        data: PrescriptionUpload,
        customer_id: int
    ) -> Prescription:
        """Upload a prescription image and queue for processing"""
        prescription = Prescription(
            customer_id=customer_id,
            store_id=data.store_id,
            image_url=data.image_url,
            notes=data.notes,
            status=PrescriptionStatus.PENDING,
            created_by=customer_id
        )
        self.db.add(prescription)
        self.db.commit()
        self.db.refresh(prescription)
        
        # Log the action
        self.audit_service.log_action(
            user_id=customer_id,
            action=AuditActionType.CREATE,
            entity_type="Prescription",
            entity_id=prescription.id,
            new_values={"status": prescription.status.value},
            store_id=prescription.store_id
        )
        
        return prescription
    
    def process_ocr(self, prescription_id: int) -> PrescriptionOCRResult:
        """
        Process prescription image with OCR/NLP.
        Uses EasyOCR for text extraction and Groq LLM for medicine parsing.
        """
        prescription = self.get_prescription(prescription_id)
        if not prescription:
            raise ValueError(f"Prescription not found: {prescription_id}")
        
        # Update status to PROCESSING
        prescription.status = PrescriptionStatus.PROCESSING
        self.db.commit()
        
        try:
            # 1. Fetch Image
            image_bytes = self._get_image_bytes(prescription.image_url)
            
            # 2. OCR with EasyOCR
            from app.services.medical.ocr_service import OCRService
            ocr_service = OCRService()
            
            try:
                raw_text = ocr_service.read_with_easyocr(image_bytes)
                logger.info(f"EasyOCR extracted {len(raw_text)} chars")
            except Exception as e:
                logger.warning(f"EasyOCR failed, falling back to TrOCR: {e}")
                raw_text = ocr_service.read_handwritten(image_bytes)
            
            if len(raw_text.strip()) < 5:
                logger.warning("OCR extracted very little text. Image might be unclear.")
            
            # 3. Parse with LLM (Groq)
            extracted = {}
            try:
                from app.services.medical.llm_parser import LLMedicalParser
                llm_parser = LLMedicalParser()
                llm_data = llm_parser.extract_from_text(raw_text)
                if llm_data and llm_data.get('medicines'):
                    logger.info("Using LLM parsed data.")
                    extracted = llm_data
            except Exception as e:
                logger.error(f"LLM Parsing failed: {e}")
            
            # Fallback to NLP if LLM failed
            if not extracted:
                try:
                    from app.services.medical.nlp_parser import MedicalNLPParser
                    logger.info("Falling back to NLP parser.")
                    nlp_parser = MedicalNLPParser()
                    extracted = nlp_parser.extract_entities(raw_text)
                except Exception as e:
                    logger.error(f"NLP Parser failed: {e}")
                    extracted = {"medicines": [], "raw_text": raw_text}
            
            # 4. Medicine Matching
            from app.services.medical.medicine_matcher import MedicineMatcher
            matcher = MedicineMatcher(self.db)
            final_medicines = []
            
            for med in extracted.get('medicines', []):
                med_name = med.get('name', '')
                match_result = matcher.match(med_name)
                
                final_medicines.append({
                    "name": match_result['name'],
                    "raw_name": med_name,
                    "medicine_id": match_result['id'],
                    "strength": med.get('strength'),
                    "frequency": med.get('frequency'),
                    "duration": med.get('duration'),
                    "match_score": match_result['score']
                })
            
            # Update prescription with extracted data
            prescription.extracted_data = {
                "doctor_name": extracted.get('doctor_name'),
                "patient_name": extracted.get('patient_name'),
                "patient_age": extracted.get('patient_age'),
                "patient_gender": extracted.get('patient_gender'),
                "medicines": final_medicines,
                "raw_text": raw_text
            }
            prescription.ocr_confidence_score = 0.8
            prescription.ocr_processed_at = datetime.utcnow()
            prescription.status = PrescriptionStatus.PENDING  # Back to pending for verification
            
            if extracted.get('doctor_name'):
                prescription.doctor_name = extracted.get('doctor_name')
            
            self.db.commit()
            self.db.refresh(prescription)
            
            return PrescriptionOCRResult(
                prescription_id=prescription.id,
                extracted_data=ExtractedPrescriptionData(**prescription.extracted_data),
                confidence_score=0.8,
                processed_at=prescription.ocr_processed_at,
                status="SUCCESS"
            )
            
        except Exception as e:
            prescription.status = PrescriptionStatus.PENDING
            self.db.commit()
            logger.error(f"OCR Processing failed: {str(e)}")
            return PrescriptionOCRResult(
                prescription_id=prescription.id,
                extracted_data=ExtractedPrescriptionData(raw_text=f"Error: {str(e)}"),
                confidence_score=0.0,
                processed_at=datetime.utcnow(),
                status="FAILED",
                error_message=str(e)
            )
    
    def _get_image_bytes(self, image_url: str) -> bytes:
        """Helper to fetch image bytes from URL or local path"""
        import os
        import requests
        
        if not image_url:
            raise ValueError("No image URL provided")
            
        if image_url.startswith(('http://', 'https://')):
            response = requests.get(image_url)
            response.raise_for_status()
            return response.content
        elif os.path.exists(image_url):
            with open(image_url, "rb") as f:
                return f.read()
        else:
            abs_path = os.path.join(os.getcwd(), image_url)
            if os.path.exists(abs_path):
                with open(abs_path, "rb") as f:
                    return f.read()
            raise ValueError(f"Image not found at: {image_url}")
    
    def verify_prescription(
        self,
        prescription_id: int,
        data: PrescriptionVerify,
        pharmacist_id: int
    ) -> Optional[Prescription]:
        """Verify or reject a prescription (pharmacist action)"""
        prescription = self.get_prescription(prescription_id)
        if not prescription:
            return None
        
        if prescription.status not in [PrescriptionStatus.PENDING, PrescriptionStatus.PROCESSING]:
            raise ValueError(f"Cannot verify prescription with status: {prescription.status.value}")
        
        old_status = prescription.status
        
        # Update verification fields
        prescription.status = PrescriptionStatus(data.status.value)
        prescription.verified_by = pharmacist_id
        prescription.verified_at = datetime.utcnow()
        
        if data.doctor_name:
            prescription.doctor_name = data.doctor_name
        if data.doctor_license:
            prescription.doctor_license = data.doctor_license
        if data.hospital_clinic:
            prescription.hospital_clinic = data.hospital_clinic
        if data.prescription_date:
            prescription.prescription_date = data.prescription_date
        if data.valid_until:
            prescription.valid_until = data.valid_until
        
        prescription.refills_allowed = data.refills_allowed
        
        if data.pharmacist_notes:
            prescription.pharmacist_notes = data.pharmacist_notes
        
        if data.status == PrescriptionStatus.REJECTED and data.rejection_reason:
            prescription.rejection_reason = data.rejection_reason
        
        prescription.modified_by = pharmacist_id
        self.db.commit()
        self.db.refresh(prescription)
        
        # Log the verification
        self.audit_service.log_action(
            user_id=pharmacist_id,
            action=AuditActionType.VERIFY,
            entity_type="Prescription",
            entity_id=prescription.id,
            old_values={"status": old_status.value},
            new_values={"status": prescription.status.value},
            store_id=prescription.store_id
        )
        
        return prescription
    
    def get_prescription(self, prescription_id: int) -> Optional[Prescription]:
        """Get a single prescription by ID"""
        return self.db.query(Prescription).filter(
            Prescription.id == prescription_id,
            Prescription.inactive == False
        ).first()
    
    def get_prescriptions(
        self,
        filters: PrescriptionFilters,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Prescription], int]:
        """Get paginated list of prescriptions with filters"""
        query = self.db.query(Prescription).filter(Prescription.inactive == False)
        
        if filters.store_id:
            query = query.filter(Prescription.store_id == filters.store_id)
        
        if filters.customer_id:
            query = query.filter(Prescription.customer_id == filters.customer_id)
        
        if filters.status:
            query = query.filter(Prescription.status == filters.status.value)
        
        if filters.verified_by:
            query = query.filter(Prescription.verified_by == filters.verified_by)
        
        if filters.date_from:
            query = query.filter(Prescription.created_at >= filters.date_from)
        
        if filters.date_to:
            query = query.filter(Prescription.created_at <= filters.date_to)
        
        total = query.count()
        offset = (page - 1) * page_size
        prescriptions = query.order_by(Prescription.created_at.desc()).offset(offset).limit(page_size).all()
        
        return prescriptions, total
    
    def get_pending_prescriptions(
        self,
        store_id: Optional[int] = None,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Prescription], int, int]:
        """Get pending prescriptions queue for pharmacists"""
        query = self.db.query(Prescription).filter(
            Prescription.inactive == False,
            Prescription.status.in_([PrescriptionStatus.PENDING, PrescriptionStatus.PROCESSING])
        )
        
        if store_id:
            query = query.filter(Prescription.store_id == store_id)
        
        # Get counts by status
        pending_count = self.db.query(Prescription).filter(
            Prescription.inactive == False,
            Prescription.status == PrescriptionStatus.PENDING
        )
        processing_count = self.db.query(Prescription).filter(
            Prescription.inactive == False,
            Prescription.status == PrescriptionStatus.PROCESSING
        )
        
        if store_id:
            pending_count = pending_count.filter(Prescription.store_id == store_id)
            processing_count = processing_count.filter(Prescription.store_id == store_id)
        
        total_pending = pending_count.count()
        total_processing = processing_count.count()
        
        total = query.count()
        offset = (page - 1) * page_size
        prescriptions = query.order_by(Prescription.created_at.asc()).offset(offset).limit(page_size).all()
        
        return prescriptions, total_pending, total_processing
    
    def get_customer_prescriptions(
        self,
        customer_id: int,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Prescription], int]:
        """Get customer's prescription history"""
        filters = PrescriptionFilters(customer_id=customer_id)
        return self.get_prescriptions(filters, page, page_size)
    
    def update_prescription(
        self,
        prescription_id: int,
        data: PrescriptionUpdate,
        user_id: int
    ) -> Optional[Prescription]:
        """Update prescription details"""
        prescription = self.get_prescription(prescription_id)
        if not prescription:
            return None
        
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            if value is not None:
                setattr(prescription, field, value)
        
        prescription.modified_by = user_id
        self.db.commit()
        self.db.refresh(prescription)
        
        return prescription
    
    def update_extracted_data(
        self,
        prescription_id: int,
        data: dict,
        user_id: int
    ) -> Optional[Prescription]:
        """
        Update/correct the OCR extracted data.
        Used by pharmacist to fix OCR errors before verification.
        """
        prescription = self.get_prescription(prescription_id)
        if not prescription:
            return None
        
        # Get existing extracted data or create new
        existing_data = prescription.extracted_data or {}
        
        # Update fields
        if data.get("doctor_name") is not None:
            existing_data["doctor_name"] = data["doctor_name"]
            prescription.doctor_name = data["doctor_name"]
        if data.get("patient_name") is not None:
            existing_data["patient_name"] = data["patient_name"]
        if data.get("patient_age") is not None:
            existing_data["patient_age"] = data["patient_age"]
        if data.get("patient_gender") is not None:
            existing_data["patient_gender"] = data["patient_gender"]
        if data.get("date") is not None:
            existing_data["date"] = data["date"]
        if data.get("hospital_clinic") is not None:
            existing_data["hospital_clinic"] = data["hospital_clinic"]
            prescription.hospital_clinic = data["hospital_clinic"]
        
        # Update medicines list (replace entirely if provided)
        if data.get("medicines"):
            # Convert to the format we store
            updated_medicines = []
            for med in data["medicines"]:
                updated_medicines.append({
                    "name": med.get("name"),
                    "strength": med.get("strength"),
                    "frequency": med.get("frequency"),
                    "duration": med.get("duration"),
                    "instructions": med.get("instructions"),
                    "quantity": med.get("quantity"),
                    "raw_name": med.get("name"),  # Original is now the corrected name
                    "medicine_id": None,  # Will be re-matched on availability check
                    "match_score": 100  # Manually corrected = 100% confidence
                })
            existing_data["medicines"] = updated_medicines
        
        prescription.extracted_data = existing_data
        prescription.modified_by = user_id
        
        # Log the update
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.UPDATE,
            entity_type="Prescription",
            entity_id=prescription.id,
            new_values={"extracted_data": "updated by pharmacist"},
            store_id=prescription.store_id
        )
        
        self.db.commit()
        self.db.refresh(prescription)
        
        return prescription
    
    def mark_filled(
        self,
        prescription_id: int,
        user_id: int
    ) -> Optional[Prescription]:
        """Mark prescription as filled after order completion"""
        prescription = self.get_prescription(prescription_id)
        if not prescription:
            return None
        
        if prescription.status != PrescriptionStatus.VERIFIED:
            raise ValueError("Only verified prescriptions can be filled")
        
        prescription.status = PrescriptionStatus.FILLED
        prescription.refills_used += 1
        prescription.modified_by = user_id
        self.db.commit()
        self.db.refresh(prescription)
        
        self.audit_service.log_action(
            user_id=user_id,
            action=AuditActionType.STATUS_CHANGE,
            entity_type="Prescription",
            entity_id=prescription.id,
            new_values={"status": PrescriptionStatus.FILLED.value, "refills_used": prescription.refills_used},
            store_id=prescription.store_id
        )
        
        return prescription

    def check_availability(self, prescription_id: int, store_id: Optional[int] = None) -> dict:
        """
        Check medicine availability in store inventory for a verified prescription.
        Matches extracted medicines against InventoryBatch.
        
        Args:
            prescription_id: The prescription to check
            store_id: Override store (uses prescription.store_id if not provided)
        
        Returns:
            Availability data for all extracted medicines
        """
        from app.models.inventory import InventoryBatch
        from app.models.medicine import Medicine
        from app.models.store import Store
        from datetime import datetime
        from rapidfuzz import fuzz
        
        prescription = self.get_prescription(prescription_id)
        if not prescription:
            raise ValueError(f"Prescription not found: {prescription_id}")
        
        # Use prescription store or override
        target_store_id = store_id or prescription.store_id
        
        # Get store name
        store_name = None
        if target_store_id:
            store = self.db.query(Store).filter(Store.id == target_store_id).first()
            store_name = store.name if store else None
        
        # Get extracted medicines from prescription
        extracted_data = prescription.extracted_data or {}
        extracted_medicines = extracted_data.get("medicines", [])
        
        if not extracted_medicines:
            return {
                "prescription_id": prescription_id,
                "status": prescription.status.value,
                "store_id": target_store_id,
                "store_name": store_name,
                "total_medicines": 0,
                "available_count": 0,
                "unavailable_count": 0,
                "medicines": [],
                "can_order": False,
                "estimated_total": 0.0
            }
        
        # Check availability for each medicine
        availability_results = []
        total_available = 0
        estimated_total = 0.0
        
        for med in extracted_medicines:
            med_name = med.get("name", "")
            med_strength = med.get("strength", "")
            med_id = med.get("medicine_id")
            
            result = {
                "name": med_name,
                "strength": med_strength,
                "available": False,
                "quantity_available": 0,
                "unit_price": None,
                "inventory_batch_id": None,
                "expiry_date": None,
                "reason": None,
                "alternatives": []
            }
            
            # Search inventory - first try by medicine_id if available
            batch = None
            if med_id:
                batch = self.db.query(InventoryBatch).filter(
                    InventoryBatch.medicine_id == med_id,
                    InventoryBatch.store_id == target_store_id,
                    InventoryBatch.quantity > InventoryBatch.quantity_reserved,
                    InventoryBatch.expiry_date > datetime.utcnow(),
                    InventoryBatch.inactive == False
                ).order_by(InventoryBatch.expiry_date.asc()).first()
            
            # If not found by ID, try fuzzy matching by name
            if not batch:
                # Get all medicines for fuzzy matching
                all_medicines = self.db.query(Medicine).filter(
                    Medicine.inactive == False
                ).all()
                
                best_match = None
                best_score = 0
                
                for medicine in all_medicines:
                    score = fuzz.ratio(med_name.lower(), medicine.name.lower())
                    if score > best_score and score >= 70:
                        best_score = score
                        best_match = medicine
                
                if best_match:
                    batch = self.db.query(InventoryBatch).filter(
                        InventoryBatch.medicine_id == best_match.id,
                        InventoryBatch.store_id == target_store_id,
                        InventoryBatch.quantity > InventoryBatch.quantity_reserved,
                        InventoryBatch.expiry_date > datetime.utcnow(),
                        InventoryBatch.inactive == False
                    ).order_by(InventoryBatch.expiry_date.asc()).first()
            
            if batch:
                available_qty = batch.quantity - batch.quantity_reserved
                result["available"] = True
                result["quantity_available"] = available_qty
                result["unit_price"] = float(batch.selling_price) if batch.selling_price else None
                result["inventory_batch_id"] = batch.id
                result["expiry_date"] = batch.expiry_date
                total_available += 1
                if result["unit_price"]:
                    estimated_total += result["unit_price"]
            else:
                # Check why not available
                expired_batch = self.db.query(InventoryBatch).filter(
                    InventoryBatch.store_id == target_store_id,
                    InventoryBatch.expiry_date <= datetime.utcnow(),
                    InventoryBatch.inactive == False
                ).first()
                
                if expired_batch:
                    result["reason"] = "expired"
                else:
                    result["reason"] = "out_of_stock"
            
            availability_results.append(result)
        
        total_medicines = len(extracted_medicines)
        unavailable_count = total_medicines - total_available
        
        return {
            "prescription_id": prescription_id,
            "status": prescription.status.value,
            "store_id": target_store_id,
            "store_name": store_name,
            "total_medicines": total_medicines,
            "available_count": total_available,
            "unavailable_count": unavailable_count,
            "medicines": availability_results,
            "can_order": total_available > 0,
            "estimated_total": round(estimated_total, 2)
        }
