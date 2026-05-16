from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.auth_schema import LoginRequest, LoginResponse
from app.schemas.vendor_schema import VendorRegistrationRequest
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/login", response_model=LoginResponse)
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    """
    Login endpoint - Returns JWT token with user info, menus, rights, and permissions
    """
    auth_service = AuthService(db)
    return auth_service.login(request.username, request.password)

@router.post("/vendor/register", status_code=status.HTTP_201_CREATED)
async def register_vendor(request: VendorRegistrationRequest, db: Session = Depends(get_db)):
    """
    Register a new vendor with full details (status=pending).
    """
    auth_service = AuthService(db)
    return auth_service.register_vendor(request)