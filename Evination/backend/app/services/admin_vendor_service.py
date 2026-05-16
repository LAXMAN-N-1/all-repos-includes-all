from sqlalchemy.orm import Session
from app.models.vendor_m import Vendor, VendorTier
from app.models.vendor_category_m import VendorCategory
from app.models.vendor_document_m import VendorDocument, VerificationStatus
from app.models.vendor_commission_m import VendorCommissionSetting
from app.models.vendor_restriction_m import VendorRestriction
from datetime import datetime

class AdminVendorService:
    def __init__(self, db: Session):
        self.db = db

    def get_pending_vendors(self):
        return self.db.query(Vendor).filter(Vendor.status == "pending").all() # Changed pending_approval to pending to match registration defaults

    def get_vendors_by_status(self, status: str, category_id: int = None):
        query = self.db.query(Vendor)
        if status and status.lower() != 'all':
            query = query.filter(Vendor.status == status)
        
        if category_id:
            query = query.join(VendorCategory).filter(VendorCategory.category_id == category_id)
            
        return query.all()

    def get_vendor_details(self, vendor_id: int):
        return self.db.query(Vendor).filter(Vendor.id == vendor_id).first()

    def verify_document(self, doc_id: int, status: str, admin_id: int, reason: str = None):
        doc = self.db.query(VendorDocument).filter(VendorDocument.id == doc_id).first()
        if not doc:
            raise Exception("Document not found")
        
        doc.verification_status = VerificationStatus(status) # verified, rejected
        doc.verified_by_id = admin_id
        doc.rejection_reason = reason
        self.db.commit()
        return doc

    def update_vendor_tier(self, vendor_id: int, tier: str):
        vendor = self.db.query(Vendor).filter(Vendor.id == vendor_id).first()
        vendor.tier = VendorTier(tier)
        self.db.commit()
        return vendor

    def configure_commission(self, vendor_id: int, commission_pct: float, category_id: int = None):
        # Check if specific setting exists
        setting = self.db.query(VendorCommissionSetting).filter(
            VendorCommissionSetting.vendor_id == vendor_id,
            VendorCommissionSetting.category_id == category_id
        ).first()
        
        if setting:
            setting.commission_percentage = commission_pct
        else:
            new_setting = VendorCommissionSetting(
                vendor_id=vendor_id,
                category_id=category_id,
                commission_percentage=commission_pct
            )
            self.db.add(new_setting)
        
        self.db.commit()

    def set_restrictions(self, vendor_id: int, restrictions: dict):
        restriction = self.db.query(VendorRestriction).filter(VendorRestriction.vendor_id == vendor_id).first()
        if not restriction:
            restriction = VendorRestriction(vendor_id=vendor_id)
            self.db.add(restriction)
            
        if 'max_quotations' in restrictions:
            restriction.max_quotations_per_day = restrictions['max_quotations']
        if 'allowed_areas' in restrictions:
            restriction.allowed_service_areas = restrictions['allowed_areas']
            
        self.db.commit()

    def approve_vendor(self, vendor_id: int, approved_by_id: int):
        vendor = self.db.query(Vendor).filter(Vendor.id == vendor_id).first()
        
        # Check if critical docs verified? (Optional logic)
        
        vendor.status = "active"
        vendor.is_verified = True
        # Log approval if we had an audit log
        self.db.commit()
        
        # Notification logic would go here
        return vendor

    def reject_vendor(self, vendor_id: int, reason: str):
        vendor = self.db.query(Vendor).filter(Vendor.id == vendor_id).first()
        vendor.status = "rejected"
        # store reason?
        self.db.commit()
        return vendor

    def create_vendor(self, data):
        from app.models.user_m import User
        from app.models.role_m import Role
        from app.models.vendor_m import Vendor
        from app.models.vendor_payout_m import VendorPayoutSetting
        from app.models.vendor_document_m import VendorDocument, DocumentType
        from app.utils.password_utils import get_password_hash
        from fastapi import HTTPException

        # 1. Check if user exists
        existing_user = self.db.query(User).filter(User.email == data.email).first()
        if existing_user:
             raise HTTPException(status_code=400, detail="User with this email already exists")
        
        # 2. Get Vendor Role
        vendor_role = self.db.query(Role).filter(Role.code == "VENDOR").first()
        if not vendor_role:
             raise HTTPException(status_code=500, detail="Vendor role configuration missing")

        # 3. Create User
        name_parts = data.contact_person.strip().split(' ', 1)
        first_name = name_parts[0]
        last_name = name_parts[1] if len(name_parts) > 1 else ""

        new_user = User(
            username=data.email,
            email=data.email,
            password_hash=get_password_hash(data.password),
            role_id=vendor_role.id,
            first_name=first_name, 
            last_name=last_name,
            phone=data.phone,
            inactive=False 
        )
        self.db.add(new_user)
        self.db.flush()

        # 4. Create Vendor Profile (Active by default for Admin creation)
        services_list = []
        if data.services_description:
            services_list = [s.strip() for s in data.services_description.split(',')]

        new_vendor = Vendor(
            user_id=new_user.id,
            company_name=data.company_name,
            company_type=data.business_type,
            contact_person=data.contact_person,
            email=data.email,
            phone=data.phone,
            address=data.address,
            city=data.city,
            state=data.state,
            zip_code=data.zip_code,
            services_offered=services_list,
            description=data.services_description,
            status="active", # Admin created = Active
            is_verified=True
        )
        self.db.add(new_vendor)
        self.db.flush()

        # 5. Banking
        if data.account_number:
             payout = VendorPayoutSetting(
                 vendor_id=new_vendor.id,
                 bank_account_number=data.account_number,
                 bank_ifsc=data.ifsc_code,
             )
             self.db.add(payout)

        # 6. Documents (Optional)
        if data.business_license_url:
             doc = VendorDocument(
                 vendor_id=new_vendor.id,
                 document_type="business_registration", # Use string if Enum fails import or DocumentType not avail here
                 file_url=data.business_license_url,
                 verification_status="verified" # Verify strictly
             )
             self.db.add(doc)
        
        self.db.commit()
        return new_vendor
