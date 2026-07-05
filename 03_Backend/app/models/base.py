"""Abstract base model for all business entities.

Every domain entity inherits from :class:`BaseModel`, which provides:

* ``id`` — auto-increment integer primary key (internal joins, FK targets).
* ``uuid`` — UUID v7 column (external identification, API exposure).
* ``created_at`` — UTC timestamp of row creation.
* ``updated_at`` — UTC timestamp of last update.

Concrete models override ``__tablename__`` and add domain-specific columns::

    from app.models.base import BaseModel
    from sqlalchemy.orm import Mapped, mapped_column

    class Employee(BaseModel):
        __tablename__ = "employe"
        first_name: Mapped[str] = mapped_column(String(100))
        ...
"""

import uuid as _uuid

from sqlalchemy import BigInteger, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base
from app.database.mixins import TimestampMixin


def new_uuid() -> str:
    """Generate a UUID v7 string (time-ordered, index-friendly).

    Falls back to UUID v4 if v7 is not available (Python < 3.14).
    """
    try:
        return str(_uuid.uuid7())
    except AttributeError:
        return str(_uuid.uuid4())


class BaseModel(Base, TimestampMixin):
    """Abstract base that every domain entity inherits from.

    .. note::
       ``__abstract__ = True`` prevents SQLAlchemy from creating a table
       for this class itself.  Only concrete subclasses with ``__tablename__``
       produce database tables.
    """

    __abstract__ = True

    id: Mapped[int] = mapped_column(
        BigInteger().with_variant(Integer, "sqlite"),
        primary_key=True,
        autoincrement=True,
        sort_order=-999,
    )

    uuid: Mapped[str] = mapped_column(
        String(36),
        unique=True,
        index=True,
        default=new_uuid,
        sort_order=-998,
    )
