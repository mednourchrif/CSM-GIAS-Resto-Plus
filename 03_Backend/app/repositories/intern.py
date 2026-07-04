"""Intern repository."""

from datetime import date

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.intern import Intern
from app.repositories.base import BaseRepository


class InternRepository(BaseRepository[Intern]):
    """CRUD operations for the ``stagiaire`` extension table."""

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
