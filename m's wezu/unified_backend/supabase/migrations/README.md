# Supabase SQL Migration Mirrors

Files in this directory are generated from Alembic revisions using:

```bash
python3 scripts/export_supabase_migration_sql.py --end <revision> --name "<name>"
```

Do not edit these files manually as primary schema source.
Alembic remains canonical.
