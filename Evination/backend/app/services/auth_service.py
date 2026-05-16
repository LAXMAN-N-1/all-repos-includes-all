from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from datetime import timedelta
from app.models.user_m import User
from app.models.menu_m import Menu
from app.models.role_right_m import RoleRight
from app.utils.password_utils import verify_password
from app.utils.jwt_utils import create_access_token
from app.utils.permission_utils import get_user_permissions
from app.config import settings
from app.schemas.auth_schema import LoginResponse

class AuthService:
    def __init__(self, db: Session):
        self.db = db

    def login(self, username, password) -> LoginResponse:
        # 1. Validate User
        # Allow login by username or email
        from sqlalchemy import or_
        user = self.db.query(User).filter(
            or_(User.username == username, User.email == username),
            User.inactive == False
        ).first()

        if not user or not verify_password(password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )

        # 2. Generate JWT Token
        access_token = create_access_token(
            data={
                "sub": str(user.id),
                "username": user.username,
                "email": user.email,
                "role_id": user.role_id,
            },
            expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        )

        # 3. Fetch UI Menus (RoleRights)
        role_rights = self.db.query(RoleRight).filter(
            RoleRight.role_id == user.role_id,
            RoleRight.can_view == True,
            RoleRight.inactive == False
        ).all()

        menu_ids = [rr.menu_id for rr in role_rights]
        
        menus = self.db.query(Menu).filter(
            Menu.id.in_(menu_ids),
            Menu.inactive == False
        ).order_by(Menu.sort_order).all()

        menus_out = [{
            "id": m.id,
            "name": m.name,
            "route": m.route,
            "code": m.code,
            "icon": m.icon,
            "parent_id": m.parent_id,
        } for m in menus]

        rights_out = [{
            "menu_id": rr.menu_id,
            "can_view": rr.can_view,
            "can_create": rr.can_create,
            "can_edit": rr.can_edit,
            "can_delete": rr.can_delete,
        } for rr in role_rights]

        # 4. Fetch Backend Permissions
        permissions = get_user_permissions(self.db, user.role_id)

        # 5. Return Response
        return LoginResponse(
            access_token=access_token,
            token_type="bearer",
            user={
                "id": user.id,
                "username": user.username,
                "email": user.email,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "role_code": user.role.code,
                "role_id": user.role_id,
                "organization_id": user.organization_id,
                "branch_id": user.branch_id
            },
            menus=menus_out,
            rights=rights_out,
            permissions=permissions
        )

    def register_vendor(self, data):
        # Avoid circular imports usually, but here fine or move to top
        from app.models.role_m import Role
        from app.models.vendor_m import Vendor
        from app.models.vendor_payout_m import VendorPayoutSetting
        from app.models.vendor_document_m import VendorDocument, DocumentType
        from app.utils.password_utils import get_password_hash
        
        # 1. Check if user exists
        existing_user = self.db.query(User).filter(User.email == data.email).first()
        if existing_user:
             raise HTTPException(status_code=400, detail="User with this email already exists")
        
        # 2. Get Vendor Role
        vendor_role = self.db.query(Role).filter(Role.code == "VENDOR").first()
        if not vendor_role:
             # Fallback or error
             raise HTTPException(status_code=500, detail="Vendor role configuration missing")

        # 3. Create User
        # Split name for first/last
        name_parts = data.contact_person.strip().split(' ', 1)
        first_name = name_parts[0]
        last_name = name_parts[1] if len(name_parts) > 1 else ""

        new_user = User(
            username=data.email, # Use email as username
            email=data.email,
            password_hash=get_password_hash(data.password),
            role_id=vendor_role.id,
            first_name=first_name, 
            last_name=last_name,
            phone=data.phone,
            # Inactive in 'base' usually means disabled, but for custom logic:
            # We can set inactive=False (Active User) but Vendor Profile is 'pending'
            inactive=False 
        )
        self.db.add(new_user)
        self.db.flush()

        # 4. Create Vendor Profile
        # Services offered is a list in UI, but maybe text in DB or JSON?
        # data.services_description is string. model.services_offered is JSON.
        # We can split by comma if simple text
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
            status="pending"
        )
        self.db.add(new_vendor)
        self.db.flush()

        # 5. Banking (PayoutSetting)
        if data.account_number:
            # Check if payout setting already exists to prevent UNIQUE constraint error
            existing_payout = self.db.query(VendorPayoutSetting).filter(VendorPayoutSetting.vendor_id == new_vendor.id).first()
            if not existing_payout:
                payout = VendorPayoutSetting(
                    vendor_id=new_vendor.id,
                    bank_account_number=data.account_number,
                    bank_ifsc=data.ifsc_code,
                    # bank_name not in model, can add later if crucial
                )
                self.db.add(payout)

        # 6. Documents
        if data.business_license_url:
             doc = VendorDocument(
                 vendor_id=new_vendor.id,
                 document_type=DocumentType.BUSINESS_REGISTRATION, 
                 file_url=data.business_license_url,
                 verification_status="pending"
             )
             self.db.add(doc)
        
        if data.insurance_cert_url:
             doc = VendorDocument(
                 vendor_id=new_vendor.id,
                 document_type=DocumentType.INSURANCE,
                 file_url=data.insurance_cert_url,
                 verification_status="pending"
             )
             self.db.add(doc)

        self.db.commit()
        return {"message": "Vendor registered successfully. Waiting for Admin Approval.", "user_id": new_user.id}
