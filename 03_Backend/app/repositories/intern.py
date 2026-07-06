"""Intern repository."""

from datetime import date

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.intern import Intern
from app.repositories.base import BaseRepository


class InternRepository(BaseRepository[Intern]):
    """CRUD operations for the stagiaire extension table."""

    def __init__(self) -> None:
        super().__init__(Intern)

    def get_by_matricule(self, db: Session, matricule: str) -> Intern | None:
        """Fetch an intern by HR matricule."""
        stmt = select(Intern).where(Intern.matricule == matricule)
        return db.execute(stmt).scalar_one_or_none()

    def get_active_on_date(self, db: Session, dt: date) -> list[Intern]:
        """Fetch interns whose internship covers the given date."""
        stmt = select(Intern).where(
            Intern.date_debut_stage <= dt,
            Intern.date_fin_stage >= dt,
        )
        return list(db.execute(stmt).scalars().all())

    def get_expired(self, db: Session) -> list[Intern]:
        """Fetch interns whose internship has ended."""
        today = date.today()
        stmt = select(Intern).where(Intern.date_fin_stage < today)
        return list(db.execute(stmt).scalars().all())

    def search_paginated(
        self,
        db: Session,
        *,
        search: str | None = None,
        sort: str | None = None,
        order: str = "asc",
        page: int = 1,
        page_size: int = 20,
    ) -> tuple[list[Intern], int]:
        """Search interns with pagination, sorting, and optional search.

        Excludes soft-deleted interns (date_suppression IS NULL).
        """
        base_stmt = select(Intern).where(Intern.date_suppression.is_(None))

        if search:
            pattern = f"%{search}%"
            base_stmt = base_stmt.where(
                or_(
                    Intern.matricule.ilike(pattern),
                    Intern.nom.ilike(pattern),
                    Intern.prenom.ilike(pattern),
                )
            )

        count_stmt = select(func.count()).select_from(base_stmt.subquery())
        total = db.execute(count_stmt).scalar() or 0

        if sort and hasattr(Intern, sort):
            sort_col = getattr(Intern, sort)
            base_stmt = base_stmt.order_by(sort_col.asc() if order == "asc" else sort_col.desc())
        else:
            base_stmt = base_stmt.order_by(Intern.id.desc())

        offset = (page - 1) * page_size
        base_stmt = base_stmt.offset(offset).limit(page_size)

        items = list(db.execute(base_stmt).scalars().all())
        return items, total
