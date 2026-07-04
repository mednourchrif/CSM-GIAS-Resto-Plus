"""Reusable SQLAlchemy mixins.

Mixins provide cross-cutting columns (timestamps, audit trails, soft-delete)
that can be composed into any entity without duplicating column definitions.
They are designed to be mixed into declarative models::

    from app.database.mixins import TimestampMixin, AuditMixin, SoftDeleteMixin
    from app.models.base import BaseModel

    class Employee(BaseModel, TimestampMixin, AuditMixin, SoftDeleteMixin):
        __tablename__ = "employe"
        ...
"""

from datetime import datetime, timezone

from sqlalchemy import DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column


def _utcnow() -> datetime:
    """Return the current UTC timestamp (timezone-aware)."""
    return datetime.now(timezone.utc)


# ===========================================================================
# TimestampMixin
# ===========================================================================


class TimestampMixin:
    """Adds ``created_at`` and ``updated_at`` columns.

    Both columns are timezone-aware and stored in UTC.
    ``updated_at`` is automatically refreshed on every row update.
    """

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=_utcnow,
        nullable=False,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=_utcnow,
        onupdate=_utcnow,
        nullable=False,
    )


# ===========================================================================
# AuditMixin
# ===========================================================================
# The FK references ``utilisateur.id`` which is the base user table defined
# in the database specification.  The relationship will be declared by the
# concrete model so that it can choose ``lazy`` and ``uselist`` options
# appropriate to its context.
# ===========================================================================


class AuditMixin:
    """Adds audit trail columns that track who created, updated, and deleted
    a record.

    These columns store the UUID of the acting user (*not* the auto-increment
    ``id``) so the value is meaningful across distributed contexts and
    safe to expose externally.
    """

    created_by_id: Mapped[str | None] = mapped_column(
        ForeignKey("utilisateur.uuid", ondelete="SET NULL"),
        index=True,
        default=None,
    )

    updated_by_id: Mapped[str | None] = mapped_column(
        ForeignKey("utilisateur.uuid", ondelete="SET NULL"),
        index=True,
        default=None,
    )


# ===========================================================================
# SoftDeleteMixin
# ===========================================================================


class SoftDeleteMixin:
    """Adds soft-delete columns without actually removing the row.

    Queries in the repository layer will automatically filter
    ``deleted_at IS NULL`` so that soft-deleted records are invisible
    to normal business operations but remain available for audit.
    """

    deleted_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        default=None,
        nullable=True,
    )

    deleted_by_id: Mapped[str | None] = mapped_column(
        ForeignKey("utilisateur.uuid", ondelete="SET NULL"),
        default=None,
        index=True,
    )

    @property
    def is_deleted(self) -> bool:
        """Convenience check — ``True`` when the row has been soft-deleted."""
        return self.deleted_at is not None
