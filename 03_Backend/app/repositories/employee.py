"""Employee repository."""

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.employee import Employee, StatutEnrolement
from app.repositories.base import BaseRepository


class EmployeeRepository(BaseRepository[Employee]):
    """CRUD operations for the ``employe`` extension table."""

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
