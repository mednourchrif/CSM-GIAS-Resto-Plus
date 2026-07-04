"""Visitor repository."""

from datetime import date

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.visitor import Visitor
from app.repositories.base import BaseRepository


class VisitorRepository(BaseRepository[Visitor]):
    """CRUD operations for the visiteur extension table."""

    def __init__(self) -> None:
        super().__init__(Visitor)

    def get_by_date(self, db: Session, dt: date) -> list[Visitor]:
        """Fetch all visitors for a given visit date."""
        stmt = select(Visitor).where(Visitor.date_visite == dt)
        return list(db.execute(stmt).scalars().all())

    def get_today(self, db: Session) -> list[Visitor]:
        """Fetch visitors whose visit date is today."""
        return self.get_by_date(db, date.today())

    def search_paginated(
        self,
        db: Session,
        *,
        search: str | None = None,
        sort: str | None = None,
        order: str = "asc",
        page: int = 1,
        page_size: int = 20,
    ) -> tuple[list[Visitor], int]:
        """Search visitors with pagination, sorting, and optional search."""
        base_stmt = select(Visitor)

        if search:
            pattern = f"%{search}%"
            base_stmt = base_stmt.where(
                or_(
                    Visitor.nom.ilike(pattern),
                    Visitor.prenom.ilike(pattern),
                    Visitor.societe.ilike(pattern),
                )
            )

        count_stmt = select(func.count()).select_from(base_stmt.subquery())
        total = db.execute(count_stmt).scalar() or 0

        if sort and hasattr(Visitor, sort):
            sort_col = getattr(Visitor, sort)
            base_stmt = base_stmt.order_by(sort_col.asc() if order == "asc" else sort_col.desc())
        else:
            base_stmt = base_stmt.order_by(Visitor.id.desc())

        offset = (page - 1) * page_size
        base_stmt = base_stmt.offset(offset).limit(page_size)

        items = list(db.execute(base_stmt).scalars().all())
        return items, total
