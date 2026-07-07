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

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session, selectinload

from app.models.admin import Admin
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

    def search_paginated_admins(
        self,
        db: Session,
        *,
        search: str | None = None,
        sort: str | None = None,
        order: str = "asc",
        page: int = 1,
        page_size: int = 20,
        type_filter: str | None = None,
        statut_filter: str | None = None,
    ) -> tuple[list[User], int]:
        """Search admin & reception users with pagination."""
        types = [TypeUtilisateur.ADMINISTRATEUR, TypeUtilisateur.RECEPTION]
        base_stmt = (
            select(User)
            .options(selectinload(Admin.role))
            .where(User.type.in_(types))
            .where(User.date_suppression.is_(None))
        )

        if type_filter:
            base_stmt = base_stmt.where(User.type == type_filter)
        if statut_filter:
            base_stmt = base_stmt.where(User.statut == statut_filter)
        if search:
            pattern = f"%{search}%"
            base_stmt = base_stmt.where(
                or_(
                    User.nom.ilike(pattern),
                    User.prenom.ilike(pattern),
                    User.email.ilike(pattern),
                )
            )

        count_stmt = select(func.count()).select_from(base_stmt.subquery())
        total = db.execute(count_stmt).scalar() or 0

        if sort and hasattr(User, sort):
            sort_col = getattr(User, sort)
            base_stmt = base_stmt.order_by(sort_col.asc() if order == "asc" else sort_col.desc())
        else:
            base_stmt = base_stmt.order_by(User.id.desc())

        offset = (page - 1) * page_size
        base_stmt = base_stmt.offset(offset).limit(page_size)

        items = list(db.execute(base_stmt).scalars().all())
        return items, total
