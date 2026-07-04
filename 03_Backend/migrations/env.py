"""Alembic environment configuration.

This module is loaded every time Alembic runs.  It configures the
database connection and tells Alembic which metadata object to watch
for changes when auto-generating migrations.

All business models MUST be imported here (even if unused) so that
their ``__tablename__`` and columns are registered in
``Base.metadata``.  Otherwise ``alembic revision --autogenerate`` will
produce empty (or incomplete) migrations.
"""

import sys
from logging.config import fileConfig
from pathlib import Path

from alembic import context
from sqlalchemy import engine_from_config, pool

# Add the project root to sys.path so that Alembic can import ``app.*``
# modules regardless of the working directory from which it is invoked.
_project_root = Path(__file__).resolve().parent.parent
if str(_project_root) not in sys.path:
    sys.path.insert(0, str(_project_root))

# ------------------------------------------------------------------
# Register all models so Alembic discovers their metadata.
# ------------------------------------------------------------------
# Each future model file should be imported here.  For example:
#
#     from app.models import employe, stagiaire, visiteur  # noqa: F401
#
# Until the first business model exists, the line below imports the
# abstract ``BaseModel`` (which itself contributes no table), but it
# demonstrates the mechanism.
# ------------------------------------------------------------------
from app.database.base import Base  # noqa: F401

# Import all model modules so their metadata is registered with
# ``Base``.  Each ``__init__.py`` import chain registers every entity.
from app.models import (  # noqa: F401, F403
    Admin,
    BaseModel,
    Employee,
    Intern,
    Receptionist,
    Role,
    User,
    Visitor,
)

# Alembic Config object
config = context.config

# Override the placeholder ``sqlalchemy.url`` from ``alembic.ini`` with
# the URL computed by the application's settings.  This guarantees that
# the same configuration is used at runtime and during migrations.
from app.core.config import settings  # noqa: E402

config.set_main_option("sqlalchemy.url", settings.database_url)

# Set up Python logging from the alembic.ini [loggers] section
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# The metadata that Alembic watches for schema changes
target_metadata = Base.metadata


# -- Offline mode ----------------------------------------------------------

def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode.

    The database URL is used to generate SQL scripts without connecting
    to a live database.  Useful for review, DBA approval, or air-gapped
    environments.
    """
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


# -- Online mode -----------------------------------------------------------

def run_migrations_online() -> None:
    """Run migrations against a live database.

    Alembic creates its own engine from the configured URL and manages
    the connection lifecycle.
    """
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
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


# -- Dispatch --------------------------------------------------------------

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
