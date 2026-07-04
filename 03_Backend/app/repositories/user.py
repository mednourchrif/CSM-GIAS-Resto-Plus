"""User repository (base ``utilisateur`` table).

Because ``User`` is the parent of a joined-table inheritance hierarchy,
queries against ``UserRepository`` return instances of the appropriate
sub-class (``Admin``, ``Employee``, etc.) automatically.

Polymorphic queries work transparently::

    user_repo = UserRepository()
    user = user_repo.get_by_email(db, "admin@example.com")
    # ``user`` will be an ``Admin`` instance if the DB row's type
    # column is ``ADMINISTRATEUR``.
"""

from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.models.user import StatutUtilisateur, TypeUtilisateur, User
from app.repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    """CRUD operations for the ``utilisateur`` table."""

    def __init__(self) -> None:
        super().__init__(User)

    def get_by_email(self, db: Session, email: str) -> User | None:
        """Fetch a user by email address (case-insensitive)."""
        stmt = select(User).where(User.email.ilike(email))
        return db.execute(stmt).scalar_one_or_none()

    def get_by_type(self, db: Session, type: TypeUtilisateur) -> list[User]:
        """Fetch all users of a given type."""
        stmt = select(User).where(User.type == type)
        return list(db.execute(stmt).scalars().all())

    def get_active(self, db: Session) -> list[User]:
        """Fetch all users whose status is ``ACTIF``."""
        stmt = select(User).where(User.statut == StatutUtilisateur.ACTIF)
        return list(db.execute(stmt).scalars().all())

    def search(
        self,
        db: Session,
        query: str,
    ) -> list[User]:
        """Search users by name or email (simple LIKE search)."""
        pattern = f"%{query}%"
        stmt = select(User).where(
            or_(
                User.nom.ilike(pattern),
                User.prenom.ilike(pattern),
                User.email.ilike(pattern),
            )
        )
        return list(db.execute(stmt).scalars().all())
