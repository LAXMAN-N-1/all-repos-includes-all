"""Add CombinedInvoice model

Revision ID: c1a2b3c4d5e6
Revises: dbafb739a7c0
Create Date: 2026-01-23 14:15:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = 'c1a2b3c4d5e6'
down_revision = 'a11228992f49'
branch_labels = None
depends_on = None


def upgrade():
    # Create combined_invoices table
    op.create_table('combined_invoices',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('customer_id', sa.Integer(), nullable=False),
        sa.Column('invoice_date', sa.DateTime(), nullable=True),
        sa.Column('total_amount', sa.Float(), nullable=False),
        sa.Column('status', sa.String(length=50), nullable=True),
        sa.Column('pdf_url', sa.String(length=500), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['customer_id'], ['customers.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_combined_invoices_customer_id'), 'combined_invoices', ['customer_id'], unique=False)
    op.create_index(op.f('ix_combined_invoices_id'), 'combined_invoices', ['id'], unique=False)
    
    # Add combined_invoice_id to invoices table
    op.add_column('invoices', sa.Column('combined_invoice_id', sa.Integer(), nullable=True))
    op.create_foreign_key('fk_invoices_combined_invoice_id', 'invoices', 'combined_invoices', ['combined_invoice_id'], ['id'])


def downgrade():
    # Remove combined_invoice_id from invoices table
    op.drop_constraint('fk_invoices_combined_invoice_id', 'invoices', type_='foreignkey')
    op.drop_column('invoices', 'combined_invoice_id')
    
    # Drop combined_invoices table
    op.drop_index(op.f('ix_combined_invoices_id'), table_name='combined_invoices')
    op.drop_index(op.f('ix_combined_invoices_customer_id'), table_name='combined_invoices')
    op.drop_table('combined_invoices')
