from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import User, Role, Organization, Branch, Category, Vendor
from app.models.vendor_category_m import VendorCategory
from app.utils.password_utils import hash_password

def register_sai_vendor():
    db = SessionLocal()
    try:
        print("🚀 Starting registration for Sai Vendor...")
        
        vendor_role = db.query(Role).filter(Role.code == "VENDOR").first()
        org = db.query(Organization).first()
        branch = db.query(Branch).first()
        
        email = "sai@gmail.com"
        username = "sai_vendor"
        password = "laxman123"
        company_name = "Sai Global Events"
        
        # 1. Create/Update User
        existing_user = db.query(User).filter((User.username == username) | (User.email == email)).first()
        
        if existing_user:
            print(f"⚠️ User {email} already exists. Updating password and ensuring Vendor role.")
            user = existing_user
            user.password_hash = hash_password(password)
            user.role_id = vendor_role.id
            db.flush()
        else:
            print(f"👤 Creating new user {email}...")
            user = User(
                username=username,
                email=email,
                password_hash=hash_password(password),
                role_id=vendor_role.id,
                organization_id=org.id,
                branch_id=branch.id,
                first_name="Sai",
                last_name="Vendor",
                is_verified=True,
                created_by="script"
            )
            db.add(user)
            db.flush() # flush to get user.id

        # 2. Create/Update Vendor Profile
        vendor = db.query(Vendor).filter(Vendor.user_id == user.id).first()
        if not vendor:
            print("📝 Creating Vendor Profile...")
            vendor = Vendor(
                user_id=user.id,
                company_name=company_name,
                description="Comprehensive event services provider covering all categories.",
                status="approved",
                rating=5.0,
                is_verified=True,
                created_by="script"
            )
            db.add(vendor)
            db.flush()
        else:
            print("📝 Updating Vendor Profile...")
            vendor.status = "approved"
            vendor.company_name = company_name
            db.flush()

        # 3. Link to ALL Categories
        print("🔗 Linking to ALL Categories (All Services)...")
        all_categories = db.query(Category).all()
        
        # Clear existing categories for this vendor to be safe/clean
        db.query(VendorCategory).filter(VendorCategory.vendor_id == vendor.id).delete()
        
        for cat in all_categories:
            print(f"   - Adding category: {cat.name} ({cat.code})")
            vendor_cat = VendorCategory(
                vendor_id=vendor.id,
                category_id=cat.id
            )
            db.add(vendor_cat)
        
        db.commit()
        print("✨ Registration complete! Sai is now a vendor for ALL services.")
        print(f"   Credits: {email} / {password}")

    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    register_sai_vendor()
