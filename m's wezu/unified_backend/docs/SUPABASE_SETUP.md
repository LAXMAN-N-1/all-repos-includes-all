# Supabase Setup (Backend)

This backend runs in **Supabase-only auth mode**.

## 1) Create environment file

```bash
cp .env.supabase.example .env
```

Fill these required values:

- `SECRET_KEY`
- `QR_SIGNING_KEY`
- `DATABASE_URL`
- `REDIS_URL`
- `SUPABASE_URL`
- `SUPABASE_JWKS_URL`
- `SUPABASE_JWT_ISSUER`
- `SUPABASE_SERVICE_ROLE_KEY`

`SUPABASE_SERVICE_ROLE_KEY` is required for backend admin operations that call
Supabase Admin Auth, including `POST /api/v1/admin/users`. Store it only in the
backend runtime environment or secret manager. Do not expose it to the frontend.

## 2) Run migrations

```bash
python3 scripts/run_alembic.py upgrade head
```

## 3) Start API

```bash
uvicorn app.main:app --reload
```

## 4) Auth contract

- Backend accepts only **Supabase access tokens** on protected routes.
- Canonical identity endpoint: `GET /api/v1/auth/me`
- Legacy auth/session endpoints are tombstoned (`410 Gone`).
