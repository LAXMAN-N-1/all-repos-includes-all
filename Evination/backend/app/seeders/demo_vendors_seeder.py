from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import User, Role, Organization, Branch, Category, Vendor
from app.models.vendor_category_m import VendorCategory
from app.utils.password_utils import hash_password

def seed_specific_vendors():
    db = SessionLocal()
    try:
        vendor_role = db.query(Role).filter(Role.code == "VENDOR").first()
        org = db.query(Organization).first()
        branch = db.query(Branch).first()
        
        # User requested specific emails. Mapping them to our categories.
        vendor_data = [
            {
                "username": "laxman_vendor",
                "email": "laxmanlaxman1629@gmail.com",
                "company_name": "Laxman Catering & Foods",
                "category_code": "CATERING",
                "description": "Premium catering and food services."
            },
            {
                "username": "mike_venue",
                "email": "mikeeyhen123@gmail.com",
                "company_name": "Mikey's Grand Venues",
                "category_code": "VENUE",
                "description": "Elite banquet halls and event spaces."
            },
            {
                "username": "fayaz_decor",
                "email": "fayaz@gmail.com",
                "company_name": "Fayaz Events & Decor",
                "category_code": "DECOR",
                "description": "Artistic event decorations and theme styling."
            }
        ]

        for data in vendor_data:
            # Check for existing user by email as well
            existing_user = db.query(User).filter((User.username == data["username"]) | (User.email == data["email"])).first()
            if existing_user:
                print(f"⚠️ User {data['email']} already exists. Updating password, role, and profile.")
                user = existing_user
                user.password_hash = hash_password("vendor123")
                user.role_id = vendor_role.id
                db.flush()
            else:
                user = User(
                    username=data["username"],
                    email=data["email"],
                    password_hash=hash_password("vendor123"),
                    role_id=vendor_role.id,
                    organization_id=org.id,
                    branch_id=branch.id,
                    is_verified=True
                )
                db.add(user)
                db.flush()

            # Create or update Vendor Profile
            vendor = db.query(Vendor).filter(Vendor.user_id == user.id).first()
            if not vendor:
                vendor = Vendor(
                    user_id=user.id,
                    company_name=data["company_name"],
                    description=data["description"],
                    status="approved",
                    rating=4.9,
                    is_verified=True
                )
                db.add(vendor)
                db.flush()
            else:
                vendor.company_name = data["company_name"]
                vendor.description = data["description"]
                db.flush()

            # Update/Link Category
            category = db.query(Category).filter(Category.code == data["category_code"]).first()
            if category:
                # Remove old category links if any
                db.query(VendorCategory).filter(VendorCategory.vendor_id == vendor.id).delete()
                
                vendor_cat = VendorCategory(
                    vendor_id=vendor.id,
                    category_id=category.id
                )
                db.add(vendor_cat)
            
            print(f"✅ Setup complete for: {data['email']}")

        db.commit()
        print("✨ Specific vendors seeded/updated successfully!")

    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_specific_vendors()
