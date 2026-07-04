"""Declarative Base — foundation for all ORM models.

This module defines the single ``DeclarativeBase`` instance used by every
entity in the application, along with a consistent naming convention for
database constraints so that auto-generated Alembic migrations produce
predictable, reviewable names.
"""

from sqlalchemy import MetaData
from sqlalchemy.orm import DeclarativeBase

# ---------------------------------------------------------------------------
# Naming convention
# ---------------------------------------------------------------------------
# Every constraint created by SQLAlchemy or Alembic receives a deterministic
# name following this template.  Without it, databases auto-generate names
# like ``t1_ix_1`` or ``fk_random`` that differ across environments and
# break repeatable migrations.
# ---------------------------------------------------------------------------

CONSTRAINT_NAMING_CONVENTION: dict[str, str] = {
    "ix": "ix_%(table_name)s_%(column_0_name)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}

# ---------------------------------------------------------------------------
# Metadata & Base
# ---------------------------------------------------------------------------

metadata = MetaData(naming_convention=CONSTRAINT_NAMING_CONVENTION)


class Base(DeclarativeBase):
    """Single declarative base for all CSM-GIAS Resto+ ORM models.

    Usage::

        from app.database.base import Base
        from sqlalchemy.orm import Mapped, mapped_column

        class Employee(Base):
            __tablename__ = "employe"
            ...
    """

    metadata = metadata
