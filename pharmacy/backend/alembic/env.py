from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context
import sys
import os
from pathlib import Path

# Add parent directory to Python path so we can import app modules
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

# Import Base and settings
from app.database import Base
from app.config import settings

# Import all models so Alembic can detect them
from app.models import organization, user, store, role, permission, menu,order,prescription,inventory
# Import other models as you create them
# from app.models.medicine import Medicine
# from app.models.inventory import InventoryBatch
# from app.models.supplier import Supplier
# from app.models.prescription import Prescription
# from app.models.order import Order, OrderItem
# from app.models.audit_log import AuditLog
# from app.models.configuration import Configuration

# This is the Alembic Config object
config = context.config

# Override sqlalchemy.url with the one from our settings
# This allows us to use DATABASE_URL from .env file
config.set_main_option('sqlalchemy.url', settings.DATABASE_URL)

# Interpret the config file for Python logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Add your model's MetaData object here for 'autogenerate' support
target_metadata = Base.metadata


def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
        compare_server_default=True,
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    # Get configuration section
    configuration = config.get_section(config.config_ini_section)
    
    # Override the sqlalchemy.url from our settings
    configuration['sqlalchemy.url'] = settings.DATABASE_URL
    
    # Create engine
    connectable = engine_from_config(
        configuration,
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
            compare_server_default=True,
        )

        with context.begin_transaction():
            context.run_migrations()


# Determine which mode to run
if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
