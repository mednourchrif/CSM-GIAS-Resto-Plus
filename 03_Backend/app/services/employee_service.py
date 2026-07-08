"""Employee service — business logic for employee management."""

from datetime import date

from dataclasses import dataclass

from loguru import logger
from sqlalchemy.orm import Session

from app.core.exceptions import ConflictException, NotFoundException
from app.models.admin import Admin
from app.models.employee import Employee
from app.models.meal import Meal
from app.repositories.employee import EmployeeRepository
from app.repositories.face_repository import FaceEmbeddingRepository
from app.repositories.meal import MealRepository
from app.repositories.qr_code import QrCodeRepository
from app.repositories.user import UserRepository
from app.schemas.employee import EmployeeCreate, EmployeeUpdate
from app.schemas.pagination import PaginatedResult, PaginationParams
from app.utils.password import hash_password


@dataclass
class EmployeeDetail:
    """Rich employee detail returned by :meth:`get_detail`."""
    employee: Employee
    today_meal: Meal | None
    last_meals: list[Meal]
    face_enrolled: bool
    qr_generated: bool


class EmployeeService:
    """Business logic for employee CRUD operations."""

    def __init__(
        self,
        employee_repo: EmployeeRepository | None = None,
        user_repo: UserRepository | None = None,
        meal_repo: MealRepository | None = None,
        face_repo: FaceEmbeddingRepository | None = None,
        qr_repo: QrCodeRepository | None = None,
    ) -> None:
        self._employee_repo = employee_repo or EmployeeRepository()
        self._user_repo = user_repo or UserRepository()
        self._meal_repo = meal_repo or MealRepository()
        self._face_repo = face_repo or FaceEmbeddingRepository()
        self._qr_repo = qr_repo or QrCodeRepository()

    def create(self, db: Session, data: EmployeeCreate, admin: Admin) -> Employee:
        self._validate_unique_matricule(db, data.matricule)
        if data.email:
            self._validate_unique_email(db, data.email)

        attrs = data.model_dump(exclude={"mot_de_passe"})
        if data.mot_de_passe:
            attrs["mot_de_passe"] = hash_password(data.mot_de_passe)
        attrs["type"] = "EMPLOYE"
        attrs["created_by_id"] = admin.uuid
        attrs["updated_by_id"] = admin.uuid

        employee = self._employee_repo.create(db, **attrs)
        logger.info("Employee created", extra={"uuid": employee.uuid, "admin": admin.uuid})
        return employee

    def get(self, db: Session, uuid: str) -> Employee:
        employee = self._employee_repo.get_by_uuid(db, uuid)
        if employee is None or employee.date_suppression is not None:
            raise NotFoundException(message=f"Employé {uuid} introuvable.")
        return employee

    def get_detail(self, db: Session, uuid: str) -> EmployeeDetail:
        """Return the employee with today's meal, last meals, and ID status."""
        employee = self.get(db, uuid)

        today = date.today()
        last_meals = self._meal_repo.get_history_by_user(db, uuid, limit=6)
        today_meal: Meal | None = None
        history: list[Meal] = []
        for meal in last_meals:
            if meal.date_repas == today and today_meal is None:
                today_meal = meal
            else:
                history.append(meal)
                if len(history) == 5:
                    break

        face = self._face_repo.get_active_by_user(db, uuid)
        qr = self._qr_repo.get_active_by_owner(db, uuid)

        return EmployeeDetail(
            employee=employee,
            today_meal=today_meal,
            last_meals=history,
            face_enrolled=face is not None,
            qr_generated=qr is not None,
        )

    def update(self, db: Session, uuid: str, data: EmployeeUpdate, admin: Admin) -> Employee:
        employee = self.get(db, uuid)

        update_data = data.model_dump(exclude_unset=True, exclude={"mot_de_passe"})
        if data.mot_de_passe:
            update_data["mot_de_passe"] = hash_password(data.mot_de_passe)

        if "matricule" in update_data and update_data["matricule"] != employee.matricule:
            self._validate_unique_matricule(db, update_data["matricule"])
        if "email" in update_data and update_data["email"] and update_data["email"] != employee.email:
            self._validate_unique_email(db, update_data["email"])

        update_data["updated_by_id"] = admin.uuid

        updated = self._employee_repo.update(db, employee.id, **update_data)
        if updated is None:
            raise NotFoundException(message=f"Employé {uuid} introuvable.")
        logger.info("Employee updated", extra={"uuid": uuid, "admin": admin.uuid})
        return updated

    def delete(self, db: Session, uuid: str, admin: Admin) -> None:
        from datetime import UTC, datetime

        employee = self.get(db, uuid)
        employee.date_suppression = datetime.now(UTC)
        db.flush()
        logger.info("Employee soft-deleted", extra={"uuid": uuid, "admin": admin.uuid})

    def get_list(self, db: Session, params: PaginationParams) -> PaginatedResult[Employee]:
        items, total = self._employee_repo.search_paginated(
            db,
            search=params.search,
            sort=params.sort,
            order=params.order,
            page=params.page,
            page_size=params.page_size,
        )
        total_pages = max(1, (total + params.page_size - 1) // params.page_size)
        return PaginatedResult(
            items=items,
            total=total,
            page=params.page,
            page_size=params.page_size,
            total_pages=total_pages,
        )

    def _validate_unique_matricule(self, db: Session, matricule: str) -> None:
        existing = self._employee_repo.get_by_matricule(db, matricule)
        if existing is not None:
            raise ConflictException(
                message=f"Un employé avec le matricule « {matricule} » existe déjà.",
            )

    def _validate_unique_email(self, db: Session, email: str) -> None:
        existing = self._user_repo.get_by_email(db, email)
        if existing is not None:
            raise ConflictException(
                message=f"Un utilisateur avec l'email « {email} » existe déjà.",
            )
