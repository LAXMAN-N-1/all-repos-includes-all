
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import engine, Base

# Import all models to register them with SQLAlchemy
from app.models import (
    Organization, User, Store, Role, Permission, Menu,
    Medicine, Supplier, InventoryBatch, Prescription, Order,
    OrderItem, AuditLog, ProcurementOrder, Customer,
    Module, OrganizationModule, Alert
)

# Import routers
from app.routes import (
    auth_routes, users_routes, stores_routes, roles_routes,
    dashboard_routes, inventory_routes, orders_routes,
    prescriptions_routes, medicines_routes, analytics_routes,
    suppliers_routes, procurement_routes, payment_routes, reports_routes,
    alert_routes, admin as admin_routes, ai_routes
)

# Initialize FastAPI app with OAuth2 Swagger configuration
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.VERSION,
    debug=settings.DEBUG,
    swagger_ui_init_oauth={
        "usePkceWithAuthorizationCodeGrant": True,
        "clientId": "swagger-ui",
        "appName": "Multi-Pharmacy ERP"
    }
)

# CORS middleware
# CORS middleware
# Custom CORS Middleware to force allow all
from fastapi import Request
from fastapi.responses import JSONResponse

@app.middleware("http")
async def cors_middleware(request: Request, call_next):
    origin = request.headers.get("origin")
    if request.method == "OPTIONS":
        response = JSONResponse(content={"message": "OK"})
    else:
        response = await call_next(request)
    
    # Browser compliance: Allow-Origin cannot be '*' if Allow-Credentials is 'true'
    if origin:
        response.headers["Access-Control-Allow-Origin"] = origin
    else:
        response.headers["Access-Control-Allow-Origin"] = "*"
        
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS, PATCH"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With, Accept"
    response.headers["Access-Control-Allow-Credentials"] = "true"
    response.headers["Access-Control-Expose-Headers"] = "Content-Length, X-JSON"
    return response

# Include routers
app.include_router(auth_routes.router)
app.include_router(users_routes.router)
app.include_router(stores_routes.router)
app.include_router(roles_routes.router)
app.include_router(dashboard_routes.router)
app.include_router(inventory_routes.router)
app.include_router(orders_routes.router)
app.include_router(prescriptions_routes.router)
app.include_router(medicines_routes.router)
app.include_router(analytics_routes.router)
app.include_router(suppliers_routes.router)
app.include_router(procurement_routes.router)
app.include_router(payment_routes.router)
app.include_router(reports_routes.router)
app.include_router(alert_routes.router)
app.include_router(admin_routes.router)
app.include_router(ai_routes.router, prefix="/api/v1/ai", tags=["AI"])


@app.get("/")
async def root():
    return {
        "app": settings.APP_NAME,
        "version": settings.VERSION,
        "status": "running"
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}