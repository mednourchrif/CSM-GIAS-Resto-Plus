"""Generic service base class.

Services sit between the API layer (routes) and the data layer
(repositories).  They encapsulate **business logic** that spans multiple
repositories or requires domain validation beyond simple CRUD.

:class:`BaseService` provides the transaction wrapper and default
CRUD delegation so that domain services only need to override methods
when custom logic is required.

Usage::

    from app.services.base import BaseService
    from app.repositories.role import RoleRepository

    class RoleService(BaseService[RoleRepository]):
        ...
"""

from sqlalchemy.orm import Session


class BaseService[R]:
    """Generic service with standard CRUD delegation.

    :param repository: The repository instance to delegate to.
    """

    def __init__(
        self,
        repository: R,
    ) -> None:
        self._repository = repository

    # ------------------------------------------------------------------
    # Properties
    # ------------------------------------------------------------------

    @property
    def repo(self) -> R:
        """The underlying repository instance."""
        return self._repository

    # ------------------------------------------------------------------
    # Default CRUD — override in subclasses to inject business logic
    # ------------------------------------------------------------------

    def get(self, db: Session, id: int) -> object | None:
        """Fetch by integer primary key."""
        return self._repository.get(db, id)

    def get_by_uuid(self, db: Session, uuid: str) -> object | None:
        """Fetch by UUID string."""
        return self._repository.get_by_uuid(db, uuid)

    def get_all(self, db: Session) -> list[object]:
        """Fetch all records."""
        return self._repository.get_all(db)

    def count(self, db: Session) -> int:
        """Return total record count."""
        return self._repository.count(db)

    def create(self, db: Session, **attrs: object) -> object:
        """Create a new record.

        Override to add domain validation before persisting.
        """
        return self._repository.create(db, **attrs)

    def update(self, db: Session, id: int, **attrs: object) -> object | None:
        """Update a record by primary key.

        Override to add domain validation before persisting.
        """
        return self._repository.update(db, id, **attrs)

    def delete(self, db: Session, id: int) -> bool:
        """Hard-delete a record.

        Override to check business invariants before deletion.
        """
        return self._repository.delete(db, id)
