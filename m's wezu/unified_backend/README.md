# WEZU — Backend Services

High-performance FastAPI backend powering the WEZU battery swapping ecosystem, including the Dealer Portal and Customer App.

## 🚀 Key Modules
- **Dealer Portal API**: Comprehensive endpoints for onboarding, inventory, and analytics.
- **Onboarding Engine**: 8-stage verification workflow with automated checks.
- **Auth & RBAC**: Real-time authentication and role-based access control.
- **Database**: SQLModel with Neon DB (PostgreSQL).

## 🛠 Tech Stack
- **Language**: Python 3.10+
- **Framework**: FastAPI
- **ORM**: SQLModel / SQLAlchemy
- **Database**: PostgreSQL (Neon)
- **Validation**: Pydantic v2

## 🏁 Development Setup

0. **Python runtime requirement**:
   - Use Python `3.11+` only (repo is pinned to `.python-version` = `3.11`).

1. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Run migrations**:
   ```bash
   python3 scripts/run_alembic.py upgrade head
   ```

3. **Run the server**:
   ```bash
   uvicorn app.main:app --reload --port 8000
   ```

4. **API Documentation**:
   Access interactive docs at `http://localhost:8000/docs`.

5. **Run tests (runtime-safe wrapper)**:
   ```bash
   python3 scripts/run_pytest.py -q
   ```

6. **Inspect local tooling/runtime health**:
   ```bash
   python3 scripts/tooling_doctor.py
   ```

## 🌐 Coolify + Traefik Deployment

For ingress through Coolify/Traefik (no app host port publishing), follow:

- [DEPLOY_COOLIFY_TRAEFIK.md](docs/DEPLOY_COOLIFY_TRAEFIK.md)
- [DOCKER_MULTI_PHASE_DEPLOYMENT.md](docs/DOCKER_MULTI_PHASE_DEPLOYMENT.md)

## 🧭 Supabase Migrations

- Supabase auth setup: [SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md)
- Supabase DB migration workflow: [SUPABASE_MIGRATIONS.md](docs/SUPABASE_MIGRATIONS.md)

## 📊 Logging (Production)

The backend now uses a unified structured logging pipeline from `app/core/logging.py`.

- JSON structured logs in production.
- Request/correlation IDs on every request log line.
- Automatic redaction for sensitive fields (`token`, `password`, `secret`, cookies, etc.).
- Safe serialization for validation errors (no bytes serialization crashes).
- Noise controls for health/readiness logs via `LOG_EXCLUDE_PATHS`.

Key envs:
- `LOG_LEVEL`
- `LOG_REQUESTS`
- `LOG_ACCESS_LOGS`
- `LOG_HEALTHCHECKS`
- `LOG_SLOW_REQUEST_THRESHOLD_MS`
- `LOG_REDACT_SENSITIVE_FIELDS`
- `LOG_MAX_FIELD_LENGTH`
- `LOG_MAX_COLLECTION_ITEMS`
- `LOG_EXCLUDE_PATHS`

## 📂 Repository Structure
- `app/api/v1`: Route handlers grouped by domain.
- `app/models`: SQLModel definitions.
- `app/db`: Session management and DB migrations.

---
© 2026 WEZU Tech.
