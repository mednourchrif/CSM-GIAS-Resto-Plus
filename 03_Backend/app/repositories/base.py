"""Generic CRUD repository base class.

All domain repositories inherit from :class:`BaseRepository`, which
provides a full set of database-agnostic CRUD operations built on
SQLAlchemy 2.x ``select()`` / ``update()`` / ``delete()`` patterns.

The repository pattern isolates the ORM layer from the service layer so
that:

* Services never import SQLAlchemy types directly.
* Unit tests can mock repositories without touching the database.
* Swapping storage back-ends only requires re-implementing this one class.

Usage::

    from app.repositories.base import BaseRepository
    from app.models.role import Role

    class RoleRepository(BaseRepository[Role]):
        ...
"""

from datetime import UTC, datetime

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.base import BaseModel


class BaseRepository[M: BaseModel]:
    """Generic repository with standard CRUD operations.

    :param model_class: The SQLAlchemy ORM model class this repository
        operates on (e.g. ``Role``, ``User``).
    """

    def __init__(self, model_class: type[M]) -> None:
        self._model = model_class

    # ------------------------------------------------------------------
    # Query helpers
    # ------------------------------------------------------------------

    @property
    def model(self) -> type[M]:
        """The ORM model class bound to this repository."""
        return self._model

    # ------------------------------------------------------------------
    # Read operations
    # ------------------------------------------------------------------

    def get(self, db: Session, id: int) -> M | None:
        """Fetch a single record by its integer primary key."""
        return db.get(self._model, id)

    def get_by_uuid(self, db: Session, uuid: str) -> M | None:
        """Fetch a single record by its UUID."""
        stmt = select(self._model).where(self._model.uuid == uuid)
        return db.execute(stmt).scalar_one_or_none()

    def get_all(self, db: Session) -> list[M]:
        """Fetch all records (no filtering, no pagination)."""
        stmt = select(self._model)
        return list(db.execute(stmt).scalars().all())

    def exists(self, db: Session, id: int) -> bool:
        """Check whether a record with the given primary key exists."""
        stmt = select(select(self._model).where(self._model.id == id).exists())
        return db.execute(stmt).scalar() or False

    def count(self, db: Session) -> int:
        """Return the total number of records."""
        stmt = select(func.count()).select_from(self._model)
        return db.execute(stmt).scalar() or 0

    # ------------------------------------------------------------------
    # Write operations
    # ------------------------------------------------------------------

    def create(self, db: Session, **attrs: object) -> M:
        """Create a new record from keyword attributes and flush.

        Returns the newly created ORM instance.
        """
        instance = self._model(**attrs)
        db.add(instance)
        db.flush()
        db.refresh(instance)
        return instance

    def update(self, db: Session, id: int, **attrs: object) -> M | None:
        """Update a record by primary key and return the updated instance.

        Only non-``None`` values in ``attrs`` are applied.  Returns
        ``None`` if the record does not exist.
        """
        instance = db.get(self._model, id)
        if instance is None:
            return None

        for key, value in attrs.items():
            if value is not None:
                setattr(instance, key, value)

        db.flush()
        db.refresh(instance)
        return instance

    def delete(self, db: Session, id: int) -> bool:
        """Hard-delete a record by primary key.

        Returns ``True`` if a row was deleted, ``False`` if the record
        did not exist.
        """
        instance = db.get(self._model, id)
        if instance is None:
            return False
        db.delete(instance)
        db.flush()
        return True

    # ------------------------------------------------------------------
    # Soft-delete (only for models with ``SoftDeleteMixin``)
    # ------------------------------------------------------------------

    def soft_delete(
        self,
        db: Session,
        id: int,
        deleted_by_id: str | None = None,
    ) -> M | None:
        """Set the ``deleted_at`` timestamp on a record (soft-delete).

        Only works if the model class includes :class:`SoftDeleteMixin`.
        Returns ``None`` if the record does not exist.
        """
        instance = db.get(self._model, id)
        if instance is None:
            return None

        now = datetime.now(UTC)
        if hasattr(instance, "deleted_at"):
            instance.deleted_at = now
        if deleted_by_id and hasattr(instance, "deleted_by_id"):
            instance.deleted_by_id = deleted_by_id

        db.flush()
        db.refresh(instance)
        return instance

    def restore(self, db: Session, id: int) -> M | None:
        """Restore a soft-deleted record by clearing ``deleted_at``.

        Returns ``None`` if the record does not exist.
        """
        instance = db.get(self._model, id)
        if instance is None:
            return None

        if hasattr(instance, "deleted_at"):
            instance.deleted_at = None
        if hasattr(instance, "deleted_by_id"):
            instance.deleted_by_id = None

        db.flush()
        db.refresh(instance)
        return instance
