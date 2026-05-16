from app.database import SessionLocal
from app.models.user_m import User
from app.models.role_m import Role
from app.utils.password_utils import hash_password
from sqlalchemy import or_

def seed_demo_customers():
    """Create demo customer accounts for testing."""
    db = SessionLocal()
    
    try:
        # Get CUSTOMER role
        customer_role = db.query(Role).filter(Role.code == "CUSTOMER").first()
        if not customer_role:
            print("❌ CUSTOMER role not found!")
            return
        
        customers = [
            {
                "username": "laxman_customer",
                "email": "laxmanlaxman1629@gmail.com",
                "password": "laxman123",
                "first_name": "Laxman",
                "last_name": "Customer"
            },
            {
                "username": "mike_customer",
                "email": "mikeeyhen123@gmail.com",
                "password": "mike123",
                "first_name": "Mike",
                "last_name": "Customer"
            },
            {
                "username": "fayaz_customer",
                "email": "fayaz@gmail.com",
                "password": "fayaz123",
                "first_name": "Fayaz",
                "last_name": "Customer"
            },
            {
                "username": "demo_customer",
                "email": "customer@evination.com",
                "password": "customer123",
                "first_name": "Demo",
                "last_name": "Customer"
            }
        ]
        
        for customer_data in customers:
            # Check if user exists
            existing_user = db.query(User).filter(
                or_(
                    User.username == customer_data["username"],
                    User.email == customer_data["email"]
                )
            ).first()
            
            if existing_user:
                # Update existing user to CUSTOMER role with correct password
                print(f"✓ Updating existing user: {customer_data['email']}")
                existing_user.role_id = customer_role.id
                existing_user.password_hash = hash_password(customer_data["password"])
                existing_user.first_name = customer_data["first_name"]
                existing_user.last_name = customer_data["last_name"]
            else:
                # Create new customer
                print(f"✓ Creating new customer: {customer_data['email']}")
                new_customer = User(
                    username=customer_data["username"],
                    email=customer_data["email"],
                    password_hash=hash_password(customer_data["password"]),
                    first_name=customer_data["first_name"],
                    last_name=customer_data["last_name"],
                    role_id=customer_role.id,
                    is_verified=True,
                    inactive=False
                )
                db.add(new_customer)
        
        db.commit()
        print("\n✅ Customer accounts created/updated successfully!")
        print("\nCustomer Credentials:")
        for customer in customers:
            print(f"  Email: {customer['email']} | Password: {customer['password']}")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    seed_demo_customers()
