from sqlalchemy.orm import Session
from app.models.vendor_m import Vendor, VendorType, VendorTier
from app.models.vendor_commission_m import VendorCommissionSetting, GstTreatment
from app.models.vendor_payout_m import VendorPayoutSetting
from app.models.vendor_restriction_m import VendorRestriction
from app.models.vendor_document_m import VendorDocument, DocumentType, VerificationStatus
from app.models.vendor_category_m import VendorCategory
from app.models.user_m import User
from app.models.role_m import Role
from datetime import datetime

class VendorOnboardingService:
    def __init__(self, db: Session):
        self.db = db

    def initiate_registration(self, user_id: int, vendor_type: str, data: dict):
        """
        Step 1: Create Basic Vendor Profile linked to User
        """
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise Exception("User not found")
        
        # Check if vendor profile already exists
        existing_vendor = self.db.query(Vendor).filter(Vendor.user_id == user_id).first()
        if existing_vendor:
            return existing_vendor
        
        # Create Vendor
        new_vendor = Vendor(
            user_id=user_id,
            vendor_type=VendorType(vendor_type),
            company_name=data.get('company_name') if vendor_type == 'company' else data.get('business_name'),
            contact_person=data.get('contact_person'),
            phone=data.get('phone') or user.phone_number,
            email=data.get('email') or user.email,
            status="draft"
        )
        self.db.add(new_vendor)
        self.db.commit()
        self.db.refresh(new_vendor)
        
        # Initialize Settings with defaults
        self._init_settings(new_vendor.id, vendor_type)
        
        return new_vendor

    def _init_settings(self, vendor_id: int, vendor_type: str):
        # Restriction defaults
        restriction = VendorRestriction(vendor_id=vendor_id)
        if vendor_type == 'individual':
            restriction.max_quotations_per_day = 10
        
        # Payout defaults
        payout = VendorPayoutSetting(vendor_id=vendor_id)
        
        # Commission defaults (Company vs Individual)
        # Note: Category specific commissions can be added later
        commission = VendorCommissionSetting(
            vendor_id=vendor_id,
            commission_percentage=15.0 if vendor_type == 'company' else 10.0,
            gst_treatment=GstTreatment.PLATFORM_COLLECTS
        )
        
        self.db.add_all([restriction, payout, commission])
        self.db.commit()

    def save_business_details(self, vendor_id: int, data: dict):
        """
        Step 2: Business/Professional Details + Categories
        """
        vendor = self.db.query(Vendor).filter(Vendor.id == vendor_id).first()
        if not vendor:
            raise Exception("Vendor not found")
            
        # Update fields
        vendor.company_name = data.get('company_name', vendor.company_name) # Or update legal name
        vendor.trade_name = data.get('trade_name')
        vendor.year_established = data.get('year_established')
        vendor.company_type = data.get('company_type')
        vendor.team_size = data.get('team_size')
        vendor.office_type = data.get('office_type')
        vendor.description = data.get('description')
        vendor.website = data.get('website')
        
        vendor.address = data.get('address')
        vendor.city = data.get('city')
        vendor.state = data.get('state')
        vendor.zip_code = data.get('zip_code')
        vendor.location_coordinates = data.get('location_coordinates')
        
        vendor.coverage_areas = data.get('coverage_areas', [])
        
        # Handle Categories
        if 'categories' in data:
            # Clear existing? Or update. For now clear and re-add for simplicity of prototype
            self.db.query(VendorCategory).filter(VendorCategory.vendor_id == vendor_id).delete()
            for cat in data['categories']:
                vc = VendorCategory(
                    vendor_id=vendor_id,
                    category_id=cat['category_id'],
                    sub_categories=cat.get('sub_categories', []),
                    price_range_min=cat.get('price_min', 0),
                    price_range_max=cat.get('price_max'),
                    experience_years=cat.get('experience_years', 0)
                )
                self.db.add(vc)
        
        self.db.commit()
        return vendor

    def save_documents(self, vendor_id: int, documents: list):
        """
        Step 3: KYC Documents
        documents = [{'type': 'gst', 'url': '...', 'number': '...'}]
        """
        for doc in documents:
            # Check if exists to update or create
            existing = self.db.query(VendorDocument).filter(
                VendorDocument.vendor_id == vendor_id,
                VendorDocument.document_type == doc['type']
            ).first()
            
            if existing:
                existing.file_url = doc['url']
                existing.document_number = doc.get('number')
                existing.verification_status = VerificationStatus.PENDING
            else:
                new_doc = VendorDocument(
                    vendor_id=vendor_id,
                    document_type=DocumentType(doc['type']),
                    file_url=doc['url'],
                    document_number=doc.get('number'),
                    verification_status=VerificationStatus.PENDING
                )
                self.db.add(new_doc)
        
        # Update Key fields on Vendor itself for quick access
        vendor = self.db.query(Vendor).filter(Vendor.id == vendor_id).first()
        for doc in documents:
            if doc['type'] == 'gst':
                vendor.gst_number = doc.get('number')
            elif doc['type'] == 'pan':
                vendor.pan_number = doc.get('number')
                
        self.db.commit()

    def save_financials(self, vendor_id: int, data: dict):
        """
        Step 4: Banking & Tax
        """
        payout = self.db.query(VendorPayoutSetting).filter(VendorPayoutSetting.vendor_id == vendor_id).first()
        if not payout:
            payout = VendorPayoutSetting(vendor_id=vendor_id)
            self.db.add(payout)
            
        payout.bank_account_number = data.get('account_number')
        payout.bank_ifsc = data.get('ifsc')
        payout.bank_verified = False # Until penny drop or admin check
        payout.upi_id = data.get('upi_id')
        
        vendor = self.db.query(Vendor).filter(Vendor.id == vendor_id).first()
        vendor.gst_number = data.get('gst_number', vendor.gst_number)
        vendor.pan_number = data.get('pan_number', vendor.pan_number)
        
        self.db.commit()

    def submit_for_approval(self, vendor_id: int):
        """
        Final Step: Mark as pending approval
        """
        vendor = self.db.query(Vendor).filter(Vendor.id == vendor_id).first()
        if vendor:
            vendor.status = "pending_approval"
            self.db.commit()
        return vendor
