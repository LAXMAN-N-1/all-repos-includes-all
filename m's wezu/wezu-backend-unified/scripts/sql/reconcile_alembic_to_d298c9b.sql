-- Reconcile Alembic state for exact d298c9b rollback.
-- Target revision (d298c9b head): c4f6e7f8a9d0

BEGIN;

CREATE TABLE IF NOT EXISTS alembic_version (
    version_num VARCHAR(32) NOT NULL
);

DELETE FROM alembic_version;
INSERT INTO alembic_version(version_num) VALUES ('c4f6e7f8a9d0');

COMMIT;

SELECT version_num FROM alembic_version;

