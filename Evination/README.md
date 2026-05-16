**Evenation**- Event Booking Platform (Marriages, Birthdays, etc.)

A production-ready, reusable FastAPI project architecture for building enterprise applications.

## ✨ Features

- ✅ JWT Authentication & Authorization
- ✅ Role-Based Access Control (RBAC)
- ✅ Multi-Branch Single Organization Support
- ✅ Soft Delete & Audit Tracking
- ✅ S3 File Upload Integration
- ✅ Database Migrations with Alembic
- ✅ RESTful API Design
- ✅ Pydantic Data Validation
- ✅ Auto-generated API Documentation

## 🛠️ Tech Stack

- **Framework**: FastAPI
- **ORM**: SQLAlchemy
- **Database**: MySQL Community Edition
- **Migrations**: Alembic
- **Authentication**: JWT (PyJWT)
- **Password Hashing**: Passlib (bcrypt)
- **File Storage**: AWS S3 (Boto3)
- **Server**: Uvicorn

## 📦 Installation
```bash
# Clone repository
git clone <your-repo-url>
cd fastapi-mvp

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Setup environment
cp .env.example .env
# Edit .env with your configurations

# Create database
mysql -u root -p
CREATE DATABASE mvp_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;

# Run migrations
alembic upgrade head

# Seed initial data
python -m app.seeders.seed_data

# Start server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 🔐 Default Credentials