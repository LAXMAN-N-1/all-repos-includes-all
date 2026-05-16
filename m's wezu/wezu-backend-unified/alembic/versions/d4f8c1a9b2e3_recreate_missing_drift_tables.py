"""recreate_missing_drift_tables

Revision ID: d4f8c1a9b2e3
Revises: 96b415319b0a
Create Date: 2026-04-16 00:00:00.000000

Creates the 13 tables flagged by the startup ``schema.drift.summary`` check
in production logs (2026-04-15T23:27:15Z). All of them are referenced by
live ``SQLModel`` ``table=True`` models but were never materialised by any
existing migration — they previously only existed via ``create_all()``,
which is disabled in production.

Tables created (all with ``CREATE TABLE IF NOT EXISTS`` so the migration
is idempotent against any DB state):

    1.  auto_responses              (app.models.support.AutoResponse)
    2.  battery_reservations        (app.models.battery_reservation.BatteryReservation)
    3.  biometric_credentials       (app.models.biometric.BiometricCredential)
    4.  cart_items                  (app.models.cart.CartItem)
    5.  churn_predictions           (app.models.analytics.ChurnPrediction)
    6.  logistics_manifests         (app.models.logistics.LogisticsManifest)
    7.  pricing_recommendations     (app.models.analytics.PricingRecommendation)
    8.  security_questions          (app.models.security_question.SecurityQuestion)
    9.  shelf_batteries             (app.models.warehouse.ShelfBattery)
    10. user_security_questions     (app.models.security_question.UserSecurityQuestion)
    11. user_status_logs            (app.models.user_history.UserStatusLog)
    12. warehouse_racks             (app.models.warehouse.Rack)
    13. warehouse_shelves           (app.models.warehouse.Shelf)

Without these, any endpoint that touches the corresponding SQLModel raises
``psycopg2.errors.UndefinedTable`` and 500s on the first hit. The drift
check itself (added in e7b3c8a5f2d1) is non-fatal so the app boots, but
each affected feature is silently broken.

The DDL deliberately keeps NOT NULL / FK constraints in sync with the
SQLModel definitions so that the drift detector reports clean on the next
boot. Only PostgreSQL is targeted — SQLite/dev DBs continue to rely on
``SQLModel.metadata.create_all`` via ``AUTO_CREATE_TABLES``.
"""
from typing import Union, Sequence

from alembic import op
import sqlalchemy as sa


revision: str = "d4f8c1a9b2e3"
down_revision: Union[str, None] = "96b415319b0a"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


_STATEMENTS: list[str] = [
    # ── auto_responses ────────────────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS auto_responses (
        id SERIAL PRIMARY KEY,
        keyword VARCHAR NOT NULL,
        response TEXT NOT NULL,
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_auto_responses_keyword ON auto_responses (keyword)",

    # ── battery_reservations ──────────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS battery_reservations (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id),
        station_id INTEGER NOT NULL REFERENCES stations(id),
        battery_id INTEGER REFERENCES batteries(id),
        start_time TIMESTAMP NOT NULL,
        end_time TIMESTAMP NOT NULL,
        status VARCHAR NOT NULL DEFAULT 'PENDING',
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_battery_reservations_start_time ON battery_reservations (start_time)",
    "CREATE INDEX IF NOT EXISTS ix_battery_reservations_status ON battery_reservations (status)",

    # ── biometric_credentials ─────────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS biometric_credentials (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id),
        device_id VARCHAR NOT NULL,
        credential_id VARCHAR NOT NULL UNIQUE,
        public_key TEXT NOT NULL,
        friendly_name VARCHAR DEFAULT 'My Device',
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        last_used_at TIMESTAMP
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_biometric_credentials_user_id ON biometric_credentials (user_id)",
    "CREATE INDEX IF NOT EXISTS ix_biometric_credentials_device_id ON biometric_credentials (device_id)",
    "CREATE INDEX IF NOT EXISTS ix_biometric_credentials_credential_id ON biometric_credentials (credential_id)",

    # ── cart_items ────────────────────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS cart_items (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id),
        product_id INTEGER NOT NULL REFERENCES products(id),
        variant_id INTEGER REFERENCES product_variants(id),
        quantity INTEGER NOT NULL DEFAULT 1,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT cart_items_quantity_positive CHECK (quantity > 0)
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_cart_items_user_id ON cart_items (user_id)",

    # ── churn_predictions ─────────────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS churn_predictions (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id),
        churn_probability DOUBLE PRECISION NOT NULL DEFAULT 0.0,
        churn_risk_level VARCHAR NOT NULL,
        days_since_last_activity INTEGER NOT NULL DEFAULT 0,
        days_since_last_rental INTEGER,
        total_rentals INTEGER NOT NULL DEFAULT 0,
        total_spend DOUBLE PRECISION NOT NULL DEFAULT 0.0,
        app_opens_last_30_days INTEGER NOT NULL DEFAULT 0,
        searches_last_30_days INTEGER NOT NULL DEFAULT 0,
        support_tickets_last_30_days INTEGER NOT NULL DEFAULT 0,
        has_unresolved_issues BOOLEAN NOT NULL DEFAULT FALSE,
        has_negative_reviews BOOLEAN NOT NULL DEFAULT FALSE,
        payment_failures_count INTEGER NOT NULL DEFAULT 0,
        top_churn_factors JSONB,
        recommended_actions JSONB,
        retention_action_taken VARCHAR,
        retention_action_date TIMESTAMP,
        did_churn BOOLEAN,
        churn_date DATE,
        model_version VARCHAR NOT NULL DEFAULT 'v1.0',
        prediction_date DATE NOT NULL DEFAULT CURRENT_DATE,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_churn_predictions_user_id ON churn_predictions (user_id)",
    "CREATE INDEX IF NOT EXISTS ix_churn_predictions_prediction_date ON churn_predictions (prediction_date)",

    # ── logistics_manifests ───────────────────────────────────────────────
    # battery_transfers already references this via FK in earlier migrations,
    # so creating it retroactively is safe (Postgres validates new rows only).
    """
    CREATE TABLE IF NOT EXISTS logistics_manifests (
        id SERIAL PRIMARY KEY,
        manifest_number VARCHAR NOT NULL UNIQUE,
        driver_id INTEGER REFERENCES users(id),
        vehicle_id VARCHAR,
        status VARCHAR NOT NULL DEFAULT 'draft',
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_logistics_manifests_manifest_number ON logistics_manifests (manifest_number)",

    # ── pricing_recommendations ───────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS pricing_recommendations (
        id SERIAL PRIMARY KEY,
        recommendation_type VARCHAR NOT NULL,
        entity_type VARCHAR NOT NULL,
        entity_id INTEGER,
        current_price DOUBLE PRECISION NOT NULL,
        recommended_price DOUBLE PRECISION NOT NULL,
        price_change_percentage DOUBLE PRECISION NOT NULL,
        demand_factor DOUBLE PRECISION NOT NULL DEFAULT 1.0,
        competition_factor DOUBLE PRECISION NOT NULL DEFAULT 1.0,
        seasonality_factor DOUBLE PRECISION NOT NULL DEFAULT 1.0,
        inventory_factor DOUBLE PRECISION NOT NULL DEFAULT 1.0,
        expected_revenue_change_percentage DOUBLE PRECISION,
        expected_volume_change_percentage DOUBLE PRECISION,
        confidence_score DOUBLE PRECISION NOT NULL DEFAULT 0.0,
        risk_level VARCHAR NOT NULL DEFAULT 'MEDIUM',
        valid_from TIMESTAMP NOT NULL,
        valid_until TIMESTAMP NOT NULL,
        status VARCHAR NOT NULL DEFAULT 'PENDING',
        implemented_at TIMESTAMP,
        implemented_by INTEGER REFERENCES users(id),
        actual_revenue_change DOUBLE PRECISION,
        actual_volume_change DOUBLE PRECISION,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_pricing_recommendations_status ON pricing_recommendations (status)",
    "CREATE INDEX IF NOT EXISTS ix_pricing_recommendations_entity ON pricing_recommendations (entity_type, entity_id)",

    # ── security_questions ────────────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS security_questions (
        id SERIAL PRIMARY KEY,
        question_text VARCHAR NOT NULL UNIQUE,
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """,

    # ── user_security_questions ───────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS user_security_questions (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id),
        question_id INTEGER NOT NULL REFERENCES security_questions(id),
        hashed_answer VARCHAR NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_user_security_questions_user_id ON user_security_questions (user_id)",

    # ── warehouse_racks ───────────────────────────────────────────────────
    # warehouses table already exists (not in drift list).
    """
    CREATE TABLE IF NOT EXISTS warehouse_racks (
        id SERIAL PRIMARY KEY,
        warehouse_id INTEGER NOT NULL REFERENCES warehouses(id),
        name VARCHAR NOT NULL
    )
    """,

    # ── warehouse_shelves ─────────────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS warehouse_shelves (
        id SERIAL PRIMARY KEY,
        rack_id INTEGER NOT NULL REFERENCES warehouse_racks(id),
        name VARCHAR NOT NULL,
        capacity INTEGER NOT NULL DEFAULT 50
    )
    """,

    # ── shelf_batteries ───────────────────────────────────────────────────
    # NB: battery_id is a STRING (matches the SQLModel — these are external
    # serial numbers, not FKs into batteries.id).
    """
    CREATE TABLE IF NOT EXISTS shelf_batteries (
        id SERIAL PRIMARY KEY,
        shelf_id INTEGER NOT NULL REFERENCES warehouse_shelves(id),
        battery_id VARCHAR NOT NULL UNIQUE
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_shelf_batteries_shelf_id ON shelf_batteries (shelf_id)",
    "CREATE INDEX IF NOT EXISTS ix_shelf_batteries_battery_id ON shelf_batteries (battery_id)",

    # ── user_status_logs ──────────────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS user_status_logs (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id),
        actor_id INTEGER NOT NULL REFERENCES users(id),
        action_type VARCHAR NOT NULL,
        old_value VARCHAR,
        new_value VARCHAR,
        reason VARCHAR,
        expires_at TIMESTAMP,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_user_status_logs_user_id ON user_status_logs (user_id)",
    "CREATE INDEX IF NOT EXISTS ix_user_status_logs_action_type ON user_status_logs (action_type)",
]


def upgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name != "postgresql":
        # SQLite/others: SQLModel.metadata.create_all covers dev DBs.
        return
    for stmt in _STATEMENTS:
        op.execute(sa.text(stmt))


def downgrade() -> None:
    # Intentional no-op: dropping these tables would re-introduce the
    # runtime 500s this migration exists to fix. If a rollback is truly
    # required it should be done manually after confirming code no longer
    # references the corresponding SQLModels.
    pass
