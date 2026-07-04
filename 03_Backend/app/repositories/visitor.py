"""Visitor repository."""

from datetime import date

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.visitor import Visitor
from app.repositories.base import BaseRepository


class VisitorRepository(BaseRepository[Visitor]):
    """CRUD operations for the ``visiteur`` extension table."""

    def __init__(self) -> None:
        super().__init__(Visitor)

    def get_by_date(self, db: Session, dt: date) -> list[Visitor]:
        """Fetch all visitors for a given visit date."""
        stmt = select(Visitor).where(Visitor.date_visite == dt)
        return list(db.execute(stmt).scalars().all())

    def get_today(self, db: Session) -> list[Visitor]:
        """Fetch visitors whose visit date is today."""
        return self.get_by_date(db, date.today())
