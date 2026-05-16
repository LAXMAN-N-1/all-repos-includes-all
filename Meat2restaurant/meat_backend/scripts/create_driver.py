import sys
from pathlib import Path

# Add backend directory to sys.path
sys.path.append(str(Path(__file__).resolve().parents[1]))

from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.user import User
from app.core.security import get_password_hash

def create_driver_user():
    db = SessionLocal()
    try:
        email = "9154345918"  # Using phone number as email/username
        password = "9640"
        full_name = "Laxman Driver"
        role = "driver"

        existing_user = db.query(User).filter(User.email == email).first()
        if existing_user:
            print(f"User {email} already exists. Updating...")
            existing_user.hashed_password = get_password_hash(password)
            existing_user.full_name = full_name
            existing_user.role = role
            existing_user.is_active = True
        else:
            print(f"Creating user {email}...")
            user = User(
                email=email,
                hashed_password=get_password_hash(password),
                full_name=full_name,
                role=role,
                is_active=True,
                is_superuser=False
            )
            db.add(user)
        
        db.commit()
        print(f"✅ Driver user '{full_name}' ({email}) created/updated successfully!")
        
    except Exception as e:
        print(f"❌ Error creating driver: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_driver_user()
