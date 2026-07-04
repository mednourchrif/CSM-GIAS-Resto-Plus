"""Database — persistence layer infrastructure.

Modules
-------
base
    Declarative ``Base`` class with naming convention.
mixins
    Reusable column mixins (timestamps, audit, soft-delete).
session
    Engine, ``SessionLocal`` factory, ``get_db`` dependency, health check.
"""

from app.database.base import Base
from app.database.session import SessionLocal, check_database_health, engine, get_db

__all__ = [
    "Base",
    "SessionLocal",
    "check_database_health",
    "engine",
    "get_db",
]
