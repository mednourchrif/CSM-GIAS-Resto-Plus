"""Employee repository."""

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.employee import Employee, StatutEnrolement
from app.repositories.base import BaseRepository


class EmployeeRepository(BaseRepository[Employee]):
    """CRUD operations for the employe extension table."""

    def __init__(self) -> None:
        super().__init__(Employee)

    def get_by_matricule(self, db: Session, matricule: str) -> Employee | None:
        """Fetch an employee by HR matricule."""
        stmt = select(Employee).where(Employee.matricule == matricule)
        return db.execute(stmt).scalar_one_or_none()

    def get_enrolled(self, db: Session) -> list[Employee]:
        """Fetch employees whose biometric enrollment is complete."""
        stmt = select(Employee).where(Employee.statut_enrolement == StatutEnrolement.ENROLE)
        return list(db.execute(stmt).scalars().all())

    def get_pending_enrollment(self, db: Session) -> list[Employee]:
        """Fetch employees who still need biometric enrollment."""
        stmt = select(Employee).where(Employee.statut_enrolement == StatutEnrolement.NON_ENROLE)
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
    ) -> tuple[list[Employee], int]:
        """Search employees with pagination, sorting, and optional search."""
        base_stmt = select(Employee)

        if search:
            pattern = f"%{search}%"
            base_stmt = base_stmt.where(
                or_(
                    Employee.matricule.ilike(pattern),
                    Employee.nom.ilike(pattern),
                    Employee.prenom.ilike(pattern),
                    Employee.email.ilike(pattern),
                )
            )

        count_stmt = select(func.count()).select_from(base_stmt.subquery())
        total = db.execute(count_stmt).scalar() or 0

        if sort and hasattr(Employee, sort):
            sort_col = getattr(Employee, sort)
            base_stmt = base_stmt.order_by(sort_col.asc() if order == "asc" else sort_col.desc())
        else:
            base_stmt = base_stmt.order_by(Employee.id.desc())

        offset = (page - 1) * page_size
        base_stmt = base_stmt.offset(offset).limit(page_size)

        items = list(db.execute(base_stmt).scalars().all())
        return items, total
