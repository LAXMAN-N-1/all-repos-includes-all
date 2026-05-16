# Multi-Pharmacy ERP System

A comprehensive Enterprise Resource Planning (ERP) system designed for multi-store pharmacy management. This backend application is built with **FastAPI** and provides robust features for inventory management, prescription handling, order processing, and role-based access control (RBAC).

## 🚀 Features

*   **Multi-Tenant Architecture**: Manage multiple pharmacy stores under a single HQ organization.
*   **Role-Based Access Control (RBAC)**: secure access for HQ Admins, Store Admins, Pharmacists, and Customers.
*   **Inventory Management**: Track batches, expiry dates, and stock levels across stores.
*   **Prescription Processing**: Digital workflow for prescription verification and fulfillment.
*   **Order Management**: Full lifecycle management from placement to pickup/delivery.
*   **Dashboard & Analytics**: Role-specific dashboards for real-time insights.
*   **Secure Authentication**: OAuth2 with JWT tokens and PBKDF2 password hashing.

## 🛠️ Tech Stack

*   **Framework**: [FastAPI](https://fastapi.tiangolo.com/) (Python)
*   **Database**: PostgreSQL
*   **ORM**: SQLAlchemy
*   **Migrations**: Alembic
*   **Validation**: Pydantic v2
*   **Authentication**: OAuth2 (JWT) + Passlib (PBKDF2-SHA256)

## 📋 Prerequisites

*   Python 3.9+
*   PostgreSQL Database

## ⚙️ Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository_url>
cd Pharma_ERP
```

### 2. Set Up Virtual Environment
**Windows:**
```bash
python -m venv venv
.\venv\Scripts\activate
```

**Linux/Mac:**
```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Configuration
Create a `.env` file in the root directory with the following variables:

```ini
# App
APP_NAME="Multi-Pharmacy ERP"
DEBUG=True
ENVIRONMENT=development

# Database (PostgreSQL)
DATABASE_URL=postgresql://user:password@localhost:5432/pharma_db
DB_ECHO=False

# Security
SECRET_KEY=your_super_secret_key_here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# CORS
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8000
```

### 5. Database Migration
Initialize the database schema:
```bash
alembic upgrade head
```

### 6. Seed Default Data
Populate the database with initial roles, permissions, menus, and the default admin user:
```bash
python -m app.seeders.initial_data
```

## ▶️ Running the Application

Start the development server:
```bash
uvicorn app.main:app --reload
```

The API will be available at: `http://localhost:8000`

## 📖 API Documentation

Interactive API documentation (Swagger UI) is automatically generated:

*   **Swagger UI**: [http://localhost:8000/docs](http://localhost:8000/docs)
*   **ReDoc**: [http://localhost:8000/redoc](http://localhost:8000/redoc)

## 🔐 Default Credentials

**HQ Admin**
*   **Email**: `admin@pharma.com`
*   **Password**: `admin123`

## 🤝 Contributing

1.  Fork the repository
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request
