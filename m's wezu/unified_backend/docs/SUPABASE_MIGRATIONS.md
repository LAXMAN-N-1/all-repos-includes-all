# Supabase Migration Workflow

## Decision

- **Source of truth**: `alembic/versions/*`
- **Supabase SQL files**: generated mirrors in `supabase/migrations/*`
- Do not hand-edit both independently.

This keeps one authoritative migration graph while still supporting Supabase migration files for fresh Supabase databases and platform workflows.

## Runtime requirement

- Migration tooling is enforced on **Python 3.11+**.
- Use wrappers:
  - `python3 scripts/run_alembic.py ...`
  - `python3 scripts/tooling_doctor.py` (diagnostics)

## Fresh Supabase DB bootstrap

1. Set `.env` using the Supabase template:
   - `cp .env.supabase.example .env`
2. Fill `DATABASE_URL` with your Supabase Postgres connection string.
3. Apply canonical schema from Alembic:

```bash
python3 scripts/run_alembic.py upgrade head
```

4. Verify revision:

```sql
select version_num from alembic_version;
```

## Maintaining Supabase migration files

After adding a new Alembic migration, generate a Supabase SQL mirror file:

```bash
python3 scripts/export_supabase_migration_sql.py \
  --end <ALEMBIC_REVISION_ID> \
  --name "<short_migration_name>"
```

Example:

```bash
python3 scripts/export_supabase_migration_sql.py \
  --end fb1c2d3e4f5a \
  --name "add_user_role_assignment_actor_fields"
```

This writes a timestamped file to `supabase/migrations/`.

## Notes

- For merge revisions (multiple `down_revision`s), pass `--start` explicitly.
- If your team uses Supabase CLI migration apply, use the generated SQL files in `supabase/migrations/`.
- Never create schema changes directly in Supabase SQL without an Alembic revision first.
