"""Intern service — business logic for intern management."""

from loguru import logger
from sqlalchemy.orm import Session

from app.core.exceptions import ConflictException, NotFoundException, ValidationException
from app.models.admin import Admin
from app.models.intern import Intern
from app.repositories.intern import InternRepository
from app.repositories.user import UserRepository
from app.schemas.intern import InternCreate, InternUpdate
from app.schemas.pagination import PaginatedResult, PaginationParams
from app.utils.date_utils import today_utc
from app.utils.password import hash_password
from app.utils.validators import validate_date_range


class InternService:
    """Business logic for intern CRUD operations."""

    def __init__(
        self,
        intern_repo: InternRepository | None = None,
        user_repo: UserRepository | None = None,
    ) -> None:
        self._intern_repo = intern_repo or InternRepository()
        self._user_repo = user_repo or UserRepository()

    def create(self, db: Session, data: InternCreate, admin: Admin) -> Intern:
        self._validate_dates(data.date_debut_stage, data.date_fin_stage)
        self._validate_unique_matricule(db, data.matricule)
        if data.email:
            self._validate_unique_email(db, data.email)

        attrs = data.model_dump(exclude={"mot_de_passe"})
        if data.mot_de_passe:
            attrs["mot_de_passe"] = hash_password(data.mot_de_passe)
        attrs["type"] = "STAGIAIRE"
        attrs["created_by_id"] = admin.uuid
        attrs["updated_by_id"] = admin.uuid

        intern = self._intern_repo.create(db, **attrs)
        logger.info("Intern created", extra={"uuid": intern.uuid, "admin": admin.uuid})
        return intern

    def get(self, db: Session, uuid: str) -> Intern:
        intern = self._intern_repo.get_by_uuid(db, uuid)
        if intern is None or intern.date_suppression is not None:
            raise NotFoundException(message=f"Stagiaire {uuid} introuvable.")
        return intern

    def update(self, db: Session, uuid: str, data: InternUpdate, admin: Admin) -> Intern:
        intern = self.get(db, uuid)

        update_data = data.model_dump(exclude_unset=True, exclude={"mot_de_passe"})
        if data.mot_de_passe:
            update_data["mot_de_passe"] = hash_password(data.mot_de_passe)

        new_start = update_data.get("date_debut_stage", intern.date_debut_stage)
        new_end = update_data.get("date_fin_stage", intern.date_fin_stage)
        self._validate_dates(new_start, new_end)

        if "matricule" in update_data and update_data["matricule"] != intern.matricule:
            self._validate_unique_matricule(db, update_data["matricule"])
        if "email" in update_data and update_data["email"] and update_data["email"] != intern.email:
            self._validate_unique_email(db, update_data["email"])

        update_data["updated_by_id"] = admin.uuid

        updated = self._intern_repo.update(db, intern.id, **update_data)
        if updated is None:
            raise NotFoundException(message=f"Stagiaire {uuid} introuvable.")
        logger.info("Intern updated", extra={"uuid": uuid, "admin": admin.uuid})
        return updated

    def delete(self, db: Session, uuid: str, admin: Admin) -> None:
        from datetime import UTC, datetime

        intern = self.get(db, uuid)
        intern.date_suppression = datetime.now(UTC)
        db.flush()
        logger.info("Intern soft-deleted", extra={"uuid": uuid, "admin": admin.uuid})

    def get_list(self, db: Session, params: PaginationParams) -> PaginatedResult[Intern]:
        items, total = self._intern_repo.search_paginated(
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

    def _validate_dates(self, start, end) -> None:
        if not validate_date_range(start, end):
            raise ValidationException(
                message="La date de fin de stage doit être postérieure à la date de début.",
                details={"date_debut_stage": str(start), "date_fin_stage": str(end)},
            )

    def _validate_unique_matricule(self, db: Session, matricule: str) -> None:
        existing = self._intern_repo.get_by_matricule(db, matricule)
        if existing is not None:
            raise ConflictException(
                message=f"Un stagiaire avec le matricule « {matricule} » existe déjà.",
            )

    def _validate_unique_email(self, db: Session, email: str) -> None:
        existing = self._user_repo.get_by_email(db, email)
        if existing is not None:
            raise ConflictException(
                message=f"Un utilisateur avec l'email « {email} » existe déjà.",
            )
