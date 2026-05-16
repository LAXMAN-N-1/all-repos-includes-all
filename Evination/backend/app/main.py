from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.config import settings

# DB
from app.database import engine, Base
from app.seeders.seed_data import seed_database
from app.seeders.category_event_type_seeder import seed_categories_and_event_types

# Core Admin Routes
from app.routes import (
    auth_route,
    user_route,
    organization_route,
    branch_route,
    role_route,
    role_right_route, # NEW
    menu_route,
    category_route,
    event_type_route,
    event_route,
    event_manager_route
)

from app.routes import vendor_route as admin_vendor_route # Admin managing vendors
from app.routes import order_route # NEW
from app.routes import report_route # NEW

# Vendor Routes (Vendor Side)
from app.routes.vendor_auth_route import router as vendor_auth_router
from app.routes.vendor_dashboard_route import router as vendor_dashboard_router

# Admin Bidding Routes
from app.routes.admin_bidding_route import router as admin_bidding_router
from app.routes import vendor_category_route
from app.routes import payment_route
from app.routes import vendor_bidding_route # NEW

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup logic
    print("🚀 Application startup: Running seeders...")
    # Create all tables (Alembic is preferred, this is a safety net)
    Base.metadata.create_all(bind=engine)
    
    # Conditional seeding for production safety
    if getattr(settings, "SEED_DB", False):
        print("🌱 Seeding database...")
        seed_database()
        seed_categories_and_event_types()
    else:
        print("⏭️ Skipping database seeding (SEED_DB=False)")

    yield

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Evination FastAPI Application",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    lifespan=lifespan
)
    
# -------------------------
# CORS
# -------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------------
# ROUTES REGISTRATION
# -------------------------

# ---- Core Admin APIs ----
app.include_router(auth_route.router, prefix="/api")
app.include_router(user_route.router, prefix="/api")
app.include_router(organization_route.router, prefix="/api")
app.include_router(branch_route.router, prefix="/api")
app.include_router(role_route.router, prefix="/api")
app.include_router(role_right_route.router, prefix="/api")
app.include_router(menu_route.router, prefix="/api")

app.include_router(category_route.router, prefix="/api")
app.include_router(event_type_route.router, prefix="/api")
app.include_router(event_route.router, prefix="/api")
app.include_router(event_manager_route.router, prefix="/api")

# ---- Admin Business Modules ----
app.include_router(admin_vendor_route.router, prefix="/api") # Admin Vendor Mgmt + Vendor Profile
app.include_router(admin_bidding_router, prefix="/api")
app.include_router(order_route.router, prefix="/api")
app.include_router(report_route.router, prefix="/api")
app.include_router(vendor_category_route.router, prefix="/api") # NEW
app.include_router(payment_route.router, prefix="/api") # NEW

# ---- Vendor Side APIs ----
app.include_router(vendor_auth_router, prefix="/api")
app.include_router(vendor_dashboard_router, prefix="/api")
app.include_router(vendor_bidding_route.router, prefix="/api") # NEW
# Note: vendor_profile_route is likely redundant if vendor_route handles /vendor/me. 

# ---- Customer Side APIs ----
from app.routes import customer_auth_route
from app.routes import booking_route
from app.routes import customer_bidding_route

app.include_router(customer_auth_route.router, prefix="/api")
app.include_router(booking_route.router, prefix="/api")
app.include_router(customer_bidding_route.router, prefix="/api")

# ---- Finance & Policy Routes (NEW) ----
from app.routes import refund_route
from app.routes import settlement_route
from app.routes import notification_route # NEW
app.include_router(refund_route.router, prefix="/api")
app.include_router(settlement_route.router, prefix="/api")
app.include_router(notification_route.router, prefix="/api") # NEW

from app.routes import master_route
from app.routes import bidding_route # FIX: Import added
app.include_router(master_route.router, prefix="/api")
app.include_router(bidding_route.router, prefix="/api")

# ---- Vendor Onboarding (NEW) ----
from app.routes import vendor_onboarding_route
from app.routes import admin_vendor_mgmt_route

app.include_router(vendor_onboarding_route.router, prefix="/api")
app.include_router(vendor_onboarding_route.router, prefix="/api")
app.include_router(admin_vendor_mgmt_route.router, prefix="/api")

# ---- Customer Admin (NEW) ----
from app.routes import admin_customer_route
app.include_router(admin_customer_route.router, prefix="/api")



# -------------------------
# HEALTH / ROOT
# -------------------------
@app.get("/")
async def root():
    return {
        "message": "Welcome to Evenation API",
        "version": settings.APP_VERSION,
        "docs": "/api/docs"
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy", "version": settings.APP_VERSION}
