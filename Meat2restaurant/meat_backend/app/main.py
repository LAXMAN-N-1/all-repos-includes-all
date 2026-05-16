"""
FastAPI Main Application
B2B Meat Ordering Platform
"""
from fastapi import FastAPI, Response, Request, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
import mangum

from app.api import api_router
from app.api import deps
from app.core.config import settings
from app.db import base # Register all models
from app.db.session import SessionLocal, engine
from app.features.cms.models.cms import WebPage, BlogPost, Recipe, LegalDocument
import asyncio
from datetime import datetime

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# --- Native CORS Middleware (Robust configuration for Dev/Prod) ---
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex="https?://.*",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# --- Security Headers (Local-friendly) ---
@app.middleware("http")
async def add_security_headers(request, call_next):
    # Log incoming request for debugging
    origin = request.headers.get("Origin")
    print(f"DEBUG: Processing {request.method} {request.url} from Origin: {origin}")
    
    response = await call_next(request)
    
    # Standard security headers (HSTS removed to avoid local HTTPS issues)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    
    # CSP: Allow anything in development
    if "Content-Security-Policy" not in response.headers:
        response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; connect-src *; img-src * data:; frame-ancestors 'none';"
        
    return response

# Standard middleware removed to avoid conflicts with custom cors_handler


# Include API router
@api_router.get("/health", tags=["health"])
async def api_health():
    return {"status": "healthy", "service": "api_v1"}

app.include_router(api_router, prefix=settings.API_V1_STR)

from fastapi import Request, Query as QueryParam
from fastapi.responses import PlainTextResponse
import logging

logger = logging.getLogger(__name__)

# ─── Static Files ──────────────────────────────────────────────────────
from fastapi.staticfiles import StaticFiles
import os

# Mount static directory for local image serving
static_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "static")
if not os.path.exists(static_dir):
    os.makedirs(static_dir)
app.mount("/static", StaticFiles(directory=static_dir), name="static")

@app.get("/")
async def root():
    return {
        "message": "B2B Meat Platform API",
        "version": settings.VERSION,
        "docs": f"{settings.API_V1_STR}/docs"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

# Lambda handler
handler = mangum.Mangum(app)

async def scheduled_publisher_task():
    while True:
        try:
            db = SessionLocal()
            now = datetime.utcnow()
            
            # WebPages
            db.query(WebPage).filter(WebPage.status == "scheduled", WebPage.scheduled_publish_at <= now, WebPage.is_deleted == False).update({
                "status": "published", "is_published": True, "published_at": now
            }, synchronize_session=False)
            
            # BlogPosts
            db.query(BlogPost).filter(BlogPost.status == "scheduled", BlogPost.scheduled_publish_at <= now, BlogPost.is_deleted == False).update({
                "status": "published", "is_published": True, "published_at": now
            }, synchronize_session=False)

            # Recipes
            db.query(Recipe).filter(Recipe.status == "scheduled", Recipe.scheduled_publish_at <= now, Recipe.is_deleted == False).update({
                "status": "published", "is_published": True, "published_at": now
            }, synchronize_session=False)

            # Legal Docs
            docs_to_publish = db.query(LegalDocument).filter(LegalDocument.status == "scheduled", LegalDocument.scheduled_effective_date <= now).all()
            for doc in docs_to_publish:
                doc.status = "published"
                doc.is_current = True
                doc.published_at = now
                db.query(LegalDocument).filter(LegalDocument.document_type == doc.document_type, LegalDocument.id != doc.id).update({"is_current": False})
                db.add(doc)

            db.commit()
            db.close()
            
        except Exception as e:
            print(f"Error in scheduled CMS publisher task: {e}")
            if 'db' in locals():
                db.close()
        
        await asyncio.sleep(60) # Poll every 60 seconds

@app.on_event("startup")
async def startup_event():
    # Only run startup tasks if not in a test environment
    if "pytest" in os.environ.get("PYTEST_CURRENT_TEST", "") or os.environ.get("TESTING"):
        print("Skipping background tasks in test environment.")
        return

    # Automatically create missing tables
    try:
        from app.db.base import Base
        Base.metadata.create_all(bind=engine)
        print("Database tables initialized successfully.")
    except Exception as e:
        print(f"Error initializing database tables: {e}")
        
    asyncio.create_task(scheduled_publisher_task())
