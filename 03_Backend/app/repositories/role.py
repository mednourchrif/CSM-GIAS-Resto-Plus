"""Role repository."""

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.role import Role
from app.repositories.base import BaseRepository


class RoleRepository(BaseRepository[Role]):
    """CRUD operations for the ``role`` table."""

    def __init__(self) -> None:
        super().__init__(Role)

    def get_by_nom(self, db: Session, nom: str) -> Role | None:
        """Fetch a role by its unique name."""
        stmt = select(Role).where(Role.nom == nom)
        return db.execute(stmt).scalar_one_or_none()
