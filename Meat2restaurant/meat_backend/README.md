# Meat2Restaurant 🥩 – Backend Engine

The central backend API powering the B2B Meat Ordering Platform. 
Built for production scale, utilizing **FastAPI**, **PostgreSQL (Neon)**, **SQLAlchemy ORM**, and **Pydantic**. 

## 📦 Architecture
- **Framework**: `FastAPI` (Python 3.13)
- **Database**: `PostgreSQL` via SQLAlchemy + Alembic Migrations
- **Payment Processing**: `Stripe API`
- **Communications**: `Twilio` / `Meta API` (WhatsApp integration)
- **Containerization**: Docker-ready for AWS ECS / AppRunner deployments.

---

## 🚀 Getting Started (Local Development)

### 1. Environment Configurations
The application securely separates configuration environments via the `APP_ENV` variable.
1. Create a `.env` file in the root backend directory by copying the `.env.example`.
2. Fill out your Neon DB URL and Stripe Test keys.

### 2. Standalone Python Setup
```bash
# Setup virtual environment
python -m venv .venv
source .venv/bin/activate

# Install requirements
pip install -r requirements.txt

# Run the Uvicorn web server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

---

## 🐳 Docker Orchestration

For robust zero-setup orchestration and AWS deployments, use Docker. 

### Running Locally with Docker Compose
```bash
docker-compose up --build
```
This will mount your local directory (`app/`) onto the container, enabling auto-reload when you save Python files. 

### Production Docker Build
Ensure the `.env.production` file is securely loaded into your CI/CD or AWS ECS task variables.
```bash
docker build -t meat2restaurant-api .
docker run -p 8000:8000 -e APP_ENV=production -e SECRET_KEY='<SECURE_KEY>' meat2restaurant-api
```

---

## 🗄️ Database Migrations (Alembic)
Whenever you modify SQLAlchemy Models in `app/models/`, you must update the database schema.
1. Auto-generate the migration script:
   ```bash
   alembic revision --autogenerate -m "Added new model"
   ```
2. Apply the schema changes:
   ```bash
   alembic upgrade head
   ```

---

## 📡 API Documentation
Because this runs on FastAPI, the self-documenting interactive Swagger UI is available out of the box:
- **Swagger UI**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **ReDoc**: [http://localhost:8000/redoc](http://localhost:8000/redoc)
