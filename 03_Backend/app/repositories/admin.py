"""Admin & Receptionist repository."""

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.admin import Admin, Receptionist
from app.repositories.base import BaseRepository


class AdminRepository(BaseRepository[Admin]):
    """CRUD operations for the administrateur extension table."""

    def __init__(self) -> None:
        super().__init__(Admin)


class ReceptionistRepository(BaseRepository[Receptionist]):
    """CRUD operations for the reception extension table."""

    def __init__(self) -> None:
        super().__init__(Receptionist)

    def search_paginated(
        self,
        db: Session,
        *,
        search: str | None = None,
        sort: str | None = None,
        order: str = "asc",
        page: int = 1,
        page_size: int = 20,
    ) -> tuple[list[Receptionist], int]:
        """Search receptionists with pagination, sorting, and optional search."""
        base_stmt = select(Receptionist)

        if search:
            pattern = f"%{search}%"
            base_stmt = base_stmt.where(
                or_(
                    Receptionist.nom.ilike(pattern),
                    Receptionist.prenom.ilike(pattern),
                    Receptionist.email.ilike(pattern),
                )
            )

        count_stmt = select(func.count()).select_from(base_stmt.subquery())
        total = db.execute(count_stmt).scalar() or 0

        if sort and hasattr(Receptionist, sort):
            sort_col = getattr(Receptionist, sort)
            base_stmt = base_stmt.order_by(sort_col.asc() if order == "asc" else sort_col.desc())
        else:
            base_stmt = base_stmt.order_by(Receptionist.id.desc())

        offset = (page - 1) * page_size
        base_stmt = base_stmt.offset(offset).limit(page_size)

        items = list(db.execute(base_stmt).scalars().all())
        return items, total
