# Meat2Restaurant Backend

FastAPI backend for Meat2Restaurant wholesale platform.

## Tech Stack
- FastAPI + Python 3.13
- PostgreSQL + SQLAlchemy + Alembic
- Docker + Docker Compose

## Run Locally
```bash
cp meat_backend/.env.example meat_backend/.env.development
docker-compose up --build
```

## Run Migrations
```bash
cd meat_backend
alembic upgrade head
```

## Run Tests
```bash
cd meat_backend
pytest tests/
```

## Environment Files
- `.env.development` — local dev
- `.env.staging` — staging server
- `.env.production` — never commit, use AWS Secrets Manager
