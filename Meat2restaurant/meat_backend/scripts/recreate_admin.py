import os
import sys

# Add parent directory to path to import app
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.user import User
from app.core import security

def create_admin():
    db = SessionLocal()
    try:
        # Check if user already exists
        email = "laxmanlaxman1629@gmail.com"
        user = db.query(User).filter(User.email == email).first()
        if user:
            print(f"User {email} already exists.")
            return

        print(f"Creating super admin user: {email}")
        admin = User(
            full_name="Laxman Murari",
            email=email,
            hashed_password=security.get_password_hash("laxman123"),
            is_active=True,
            is_superuser=True,
            role="super_admin",
            permissions=["*"]
        )
        db.add(admin)
        db.commit()
        print("Super admin user created successfully!")
    except Exception as e:
        print(f"Error creating admin: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_admin()
