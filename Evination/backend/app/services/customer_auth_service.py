from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.user_m import User
from app.models.role_m import Role
from app.utils.password_utils import verify_password, get_password_hash
from app.utils.jwt_utils import create_access_token

class CustomerAuthService:
    def __init__(self, db: Session):
        self.db = db

    def signup(self, first_name: str, last_name: str, email: str, password: str, phone: str = None, location: str = None):
        # Check if user exists
        existing_user = self.db.query(User).filter(User.email == email).first()
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
        
        # Get Customer Role
        customer_role = self.db.query(Role).filter(Role.code == "CUSTOMER").first()
        if not customer_role:
             # Fallback or create if not seeded (should be seeded)
             # Raising error for now ensuring seed data exists
             raise HTTPException(
                 status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                 detail="Customer role not configured in system"
             )

        # Create User
        hashed_password = get_password_hash(password)
        new_user = User(
            first_name=first_name,
            last_name=last_name,
            username=email, # Using email as username for customers
            email=email,
            password_hash=hashed_password,
            phone=phone,
            location=location,
            role_id=customer_role.id,
            is_verified=False, # Verify email later
            inactive=False
        )
        
        self.db.add(new_user)
        self.db.commit()
        self.db.refresh(new_user)
        
        return self.login(email, password)

    def login(self, identifier: str, password: str):
        # Search for user by email OR phone
        user = self.db.query(User).filter(
            (User.email == identifier) | (User.phone == identifier)
        ).first()
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )
            
        if not verify_password(password, user.password_hash):
             raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )
            
        if user.inactive:
             raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Account is inactive"
            )

        # Create JWT
        access_token = create_access_token(
            data={"sub": str(user.id), "role": user.role.code}
        )
        
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user_id": user.id,
            "username": user.username,
            "role": user.role.code
        }
