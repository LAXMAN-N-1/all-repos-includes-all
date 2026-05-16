from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.config import settings

# DB
from app.database import engine, Base
from app.seeders.seed_data import seed_database
from app.seeders.service_seeder import seed_services
from app.seeders.category_event_type_seeder import seed_categories_and_event_types
# Core Admin Routes
from app.routes import (auth_route,user_route,organization_route,branch_route,role_route,menu_route,category_route,
    event_type_route, event_route,  event_manager_route,service_route,consumer_event_route,
    vendor_bidding_route,admin_bid_review_route,consumer_selection_route,
    review_route, chat_route, payment_route # ADDED NEW ROUTES
)
# Vendor Routes
from app.routes.vendor_auth_route import router as vendor_auth_router
from app.routes.vendor_profile_route import router as vendor_profile_router
from app.routes.vendor_dashboard_route import router as vendor_dashboard_router
from app.routes.vendor_notification_route import router as vendor_notification_router

from app.routes.vendor_route import router as vendor_general_router

# Admin Bidding Routes (NEW)
from app.routes.admin_bidding_route import router as admin_bidding_router

# Admin Vendor Management Routes (NEW)
from app.routes.admin_vendor_route import router as admin_vendor_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup logic
    print("🚀 Application startup: Running seeders...")
    seed_database()
    seed_services()
    seed_categories_and_event_types()

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
    allow_origins=["*"],        # Modify later for security
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
app.include_router(menu_route.router, prefix="/api")

app.include_router(category_route.router, prefix="/api")  # NEW
app.include_router(event_type_route.router, prefix="/api")  # NEW
app.include_router(service_route.router, prefix="/api")
app.include_router(event_route.router, prefix="/api")  # NEW
app.include_router(event_manager_route.router, prefix="/api")  # NEW

# ---- Vendor APIs ----
app.include_router(vendor_auth_router, prefix="/api")
app.include_router(vendor_profile_router, prefix="/api")
app.include_router(vendor_general_router, prefix="/api") # Added vendor_route (general)
app.include_router(vendor_dashboard_router, prefix="/api")
app.include_router(vendor_bidding_route.router, prefix="/api")
app.include_router(vendor_notification_router, prefix="/api")

# ---- Vendor Orders (NEW) ----
from app.routes.vendor_order_route import router as vendor_order_router
app.include_router(vendor_order_router, prefix="/api")

# ---- Vendor Payments (NEW) ----
from app.routes.vendor_payment_route import router as vendor_payment_router
app.include_router(vendor_payment_router, prefix="/api")

# ---- Vendor Activity (NEW) ----
from app.routes.vendor_activity_route import router as vendor_activity_router
app.include_router(vendor_activity_router, prefix="/api")


# ---- Consumer APIs ----
from app.routes.consumer_auth_route import router as consumer_auth_router
app.include_router(consumer_auth_router, prefix="/api")  # Consumer Auth
app.include_router(consumer_event_route.router, prefix="/api")
app.include_router(consumer_selection_route.router, prefix="/api")

# ---- New Features (Review, Chat, Payment) ----
app.include_router(review_route.router, prefix="/api")
app.include_router(chat_route.router, prefix="/api")
app.include_router(payment_route.router, prefix="/api")

# ---- Admin Bidding APIs ----
app.include_router(admin_bidding_router, prefix="/api")
app.include_router(admin_bid_review_route.router, prefix="/api")


# ---- Admin Vendor Management APIs ----
app.include_router(admin_vendor_router, prefix="/api")

# ---- Admin Quote Details ----
from app.routes.admin_quote_route import router as admin_quote_router
app.include_router(admin_quote_router, prefix="/api")

# ---- Admin Order Management ----
from app.routes.admin_order_route import router as admin_order_router
app.include_router(admin_order_router, prefix="/api")

# ---- Admin Dashboard ----
from app.routes.admin_dashboard_route import router as admin_dashboard_router
app.include_router(admin_dashboard_router, prefix="/api")

# ---- Department Management ----
from app.routes.department_route import router as department_router
app.include_router(department_router, prefix="/api")

# ---- NEW ANALYTICS & DASHBOARD APIs ----
from app.routes import admin_dashboard_api, vendor_dashboard_api, consumer_dashboard_api

app.include_router(admin_dashboard_api.router)
app.include_router(vendor_dashboard_api.router)
app.include_router(consumer_dashboard_api.router)

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









