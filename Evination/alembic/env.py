import sys
from pathlib import Path
from logging.config import fileConfig

from sqlalchemy import engine_from_config, pool
from alembic import context

# Load .env automatically
from dotenv import load_dotenv
load_dotenv()

# Add parent directory to sys.path
sys.path.append(str(Path(__file__).resolve().parents[1]))

# Import your Base and settings
from app.database import Base
from app.models import (organization_m,branch_m,department_m,role_m,user_m,menu_m,role_right_m,attachment_m,
    audit_log_m,settings_m,vendor_m,permission_m,role_permission_m,menu_permission_m,category_m,event_category_m,
    event_m,vendor_bid_m,vendor_category_m,vendor_order_m,vendor_payment_m,event_type_m,event_manager_profile_m,
    service_m,vendor_notification_m,chat_m,review_m
)

from app.config import settings  # your Pydantic settings class

# Alembic Config object
config = context.config

# Set up logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Target metadata for autogenerate
target_metadata = Base.metadata

# Offline migrations
def run_migrations_offline() -> None:
    url = settings.DATABASE_URL  # read from .env
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()

# Online migrations
def run_migrations_online() -> None:
    configuration = config.get_section(config.config_ini_section)
    configuration["sqlalchemy.url"] = settings.DATABASE_URL  # override placeholder
    connectable = engine_from_config(
        configuration,
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata
        )

        with context.begin_transaction():
            context.run_migrations()

# Run offline or online depending on mode
if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
