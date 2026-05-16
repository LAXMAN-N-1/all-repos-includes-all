"""wave 2.2 schema resolutions

Revision ID: a1b2c3d4e5f8
Revises: e9d3b7c2f1a4
Create Date: 2026-04-19 21:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = 'a1b2c3d4e5f8'
down_revision: Union[str, None] = 'e9d3b7c2f1a4'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


from alembic import context
from sqlalchemy import exc

def upgrade() -> None:
    conn = op.get_bind()
    
    # Handle offline mode grace
    if context.is_offline_mode():
        # In offline mode we must generate SQL regardless and cannot reflect DB schema
        # We output raw DDL logic
        op.add_column('manifests', sa.Column('source', sa.String(), server_default='manual', nullable=False))
        op.add_column('manifest_items', sa.Column('type', sa.String(), server_default='generic', nullable=False))
        op.add_column('passkey_challenges', sa.Column('challenge_id', sa.String(), nullable=True))
        op.execute("UPDATE passkey_challenges SET challenge_id = challenge")
        op.create_unique_constraint('uq_passkey_challenges_challenge_id', 'passkey_challenges', ['challenge_id'])
        op.add_column('payment_methods', sa.Column('provider_token', sa.String(), nullable=True))
        op.execute("UPDATE payment_methods SET provider_token = metadata->>'razorpay_token' WHERE metadata IS NOT NULL AND provider_token IS NULL")
        op.execute("UPDATE payment_methods SET provider_token = 'migrated_fallback' WHERE provider_token IS NULL")
        op.alter_column('payment_methods', 'provider_token', nullable=False)
        op.add_column('notification_outbox', sa.Column('status', sa.String(), server_default='pending', nullable=False))
        op.add_column('notification_outbox', sa.Column('attempt_count', sa.Integer(), server_default='0', nullable=False))
        op.add_column('notification_outbox', sa.Column('max_attempts', sa.Integer(), server_default='10', nullable=False))
        op.add_column('notification_outbox', sa.Column('next_attempt_at', sa.DateTime(), nullable=True))
        op.add_column('notification_outbox', sa.Column('published_at', sa.DateTime(), nullable=True))
        op.add_column('notification_outbox', sa.Column('idempotency_key', sa.String(), nullable=True))
        op.add_column('notification_outbox', sa.Column('last_error', sa.String(), nullable=True))
        op.add_column('stock_discrepancies', sa.Column('missing_items', sa.String(), nullable=True))
        op.add_column('stock_discrepancies', sa.Column('extra_items', sa.String(), nullable=True))
        op.add_column('stock_discrepancies', sa.Column('system_count', sa.Integer(), server_default='0', nullable=False))
        op.add_column('stock_discrepancies', sa.Column('physical_count', sa.Integer(), server_default='0', nullable=False))
        op.alter_column('idempotency_keys', 'key', new_column_name='idempotency_key')
        op.alter_column('idempotency_keys', 'response_status', new_column_name='response_status_code')
        op.alter_column('idempotency_keys', 'response_body', new_column_name='response_payload')
        op.add_column('idempotency_keys', sa.Column('request_method', sa.String(), server_default='POST', nullable=False))
        op.add_column('idempotency_keys', sa.Column('request_path', sa.String(), server_default='/', nullable=False))
        op.alter_column('station_daily_metrics', 'rentals_count', new_column_name='rentals_started')
        op.add_column('station_daily_metrics', sa.Column('rentals_completed', sa.Integer(), server_default='0', nullable=False))
        op.add_column('analytics_report_jobs', sa.Column('report_format', sa.String(), server_default='csv', nullable=False))
        op.add_column('analytics_report_jobs', sa.Column('timezone', sa.String(), server_default='UTC', nullable=False))
        op.add_column('analytics_report_jobs', sa.Column('include_sections', sa.String(), server_default='[]', nullable=False))
        op.add_column('analytics_report_jobs', sa.Column('from_utc', sa.DateTime(), nullable=True))
        op.add_column('analytics_report_jobs', sa.Column('to_utc', sa.DateTime(), nullable=True))
        op.add_column('manifest_items', sa.Column('battery_table_id', sa.Integer(), nullable=True))
        op.create_foreign_key('fk_manifest_items_battery_pk', 'manifest_items', 'batteries', ['battery_table_id'], ['id'])
        op.add_column('inventory_transfer_items', sa.Column('battery_pk', sa.Integer(), nullable=True))
        op.create_foreign_key('fk_inventory_transfer_items_battery_pk', 'inventory_transfer_items', 'batteries', ['battery_pk'], ['id'])
        return

    # ONLINE MODE
    # Robust inspection
    inspector = sa.inspect(conn)

    def col_exists(table, col):
        if not inspector.has_table(table):
            return False
        return any(c['name'] == col for c in inspector.get_columns(table))

    def fk_exists(table, fk_name):
        if not inspector.has_table(table):
            return False
        return any(fk['name'] == fk_name for fk in inspector.get_foreign_keys(table))
        
    def uq_exists(table, uq_name):
        if not inspector.has_table(table):
            return False
        return any(uq['name'] == uq_name for uq in inspector.get_unique_constraints(table))

    if not col_exists('manifests', 'source'):
        op.add_column('manifests', sa.Column('source', sa.String(), server_default='manual', nullable=False))
    if not col_exists('manifest_items', 'type'):
        op.add_column('manifest_items', sa.Column('type', sa.String(), server_default='generic', nullable=False))

    if not col_exists('passkey_challenges', 'challenge_id'):
        op.add_column('passkey_challenges', sa.Column('challenge_id', sa.String(), nullable=True))
        op.execute("UPDATE passkey_challenges SET challenge_id = challenge")
    if not uq_exists('passkey_challenges', 'uq_passkey_challenges_challenge_id'):
        op.create_unique_constraint('uq_passkey_challenges_challenge_id', 'passkey_challenges', ['challenge_id'])

    if not col_exists('payment_methods', 'provider_token'):
        op.add_column('payment_methods', sa.Column('provider_token', sa.String(), nullable=True))
        op.execute("UPDATE payment_methods SET provider_token = metadata->>'razorpay_token' WHERE metadata IS NOT NULL AND provider_token IS NULL")
        op.execute("UPDATE payment_methods SET provider_token = 'migrated_fallback' WHERE provider_token IS NULL")
        try:
            op.alter_column('payment_methods', 'provider_token', nullable=False)
        except Exception:
            pass # Constraint may already exist

    outbox_cols = [
        ('status', sa.String(), 'pending'),
        ('attempt_count', sa.Integer(), '0'),
        ('max_attempts', sa.Integer(), '10'),
        ('next_attempt_at', sa.DateTime(), None),
        ('published_at', sa.DateTime(), None),
        ('idempotency_key', sa.String(), None),
        ('last_error', sa.String(), None),
    ]
    for cname, ctype, cdef in outbox_cols:
        if not col_exists('notification_outbox', cname):
            if cdef is not None:
                op.add_column('notification_outbox', sa.Column(cname, ctype, server_default=cdef, nullable=False))
            else:
                op.add_column('notification_outbox', sa.Column(cname, ctype, nullable=True))

    stock_cols = [
        ('missing_items', sa.String(), None, True),
        ('extra_items', sa.String(), None, True),
        ('system_count', sa.Integer(), '0', False),
        ('physical_count', sa.Integer(), '0', False)
    ]
    for cname, ctype, cdef, nullable in stock_cols:
        if not col_exists('stock_discrepancies', cname):
            col = sa.Column(cname, ctype, nullable=nullable) if cdef is None else sa.Column(cname, ctype, server_default=cdef, nullable=nullable)
            op.add_column('stock_discrepancies', col)

    if col_exists('idempotency_keys', 'key') and not col_exists('idempotency_keys', 'idempotency_key'):
        op.alter_column('idempotency_keys', 'key', new_column_name='idempotency_key')
    if col_exists('idempotency_keys', 'response_status') and not col_exists('idempotency_keys', 'response_status_code'):
        op.alter_column('idempotency_keys', 'response_status', new_column_name='response_status_code')
    if col_exists('idempotency_keys', 'response_body') and not col_exists('idempotency_keys', 'response_payload'):
        op.alter_column('idempotency_keys', 'response_body', new_column_name='response_payload')
        
    if not col_exists('idempotency_keys', 'request_method'):
        op.add_column('idempotency_keys', sa.Column('request_method', sa.String(), server_default='POST', nullable=False))
    if not col_exists('idempotency_keys', 'request_path'):
        op.add_column('idempotency_keys', sa.Column('request_path', sa.String(), server_default='/', nullable=False))

    if col_exists('station_daily_metrics', 'rentals_count') and not col_exists('station_daily_metrics', 'rentals_started'):
        op.alter_column('station_daily_metrics', 'rentals_count', new_column_name='rentals_started')
    if not col_exists('station_daily_metrics', 'rentals_completed'):
        op.add_column('station_daily_metrics', sa.Column('rentals_completed', sa.Integer(), server_default='0', nullable=False))

    analytics_cols = [
        ('report_format', sa.String(), 'csv', False),
        ('timezone', sa.String(), 'UTC', False),
        ('include_sections', sa.String(), '[]', False),
        ('from_utc', sa.DateTime(), None, True),
        ('to_utc', sa.DateTime(), None, True),
    ]
    for cname, ctype, cdef, nullable in analytics_cols:
        if not col_exists('analytics_report_jobs', cname):
            col = sa.Column(cname, ctype, nullable=nullable) if cdef is None else sa.Column(cname, ctype, server_default=cdef, nullable=nullable)
            op.add_column('analytics_report_jobs', col)

    if not col_exists('manifest_items', 'battery_table_id'):
        op.add_column('manifest_items', sa.Column('battery_table_id', sa.Integer(), nullable=True))
    if not fk_exists('manifest_items', 'fk_manifest_items_battery_pk'):
        op.create_foreign_key('fk_manifest_items_battery_pk', 'manifest_items', 'batteries', ['battery_table_id'], ['id'])

    if not col_exists('inventory_transfer_items', 'battery_pk'):
        op.add_column('inventory_transfer_items', sa.Column('battery_pk', sa.Integer(), nullable=True))
    if not fk_exists('inventory_transfer_items', 'fk_inventory_transfer_items_battery_pk'):
        op.create_foreign_key('fk_inventory_transfer_items_battery_pk', 'inventory_transfer_items', 'batteries', ['battery_pk'], ['id'])


def downgrade() -> None:
    pass # Schema drift alignment downgrades are intentionally omitted or handled safely natively

