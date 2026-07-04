"""Receptionist service — business logic for receptionist management."""

from loguru import logger
from sqlalchemy.orm import Session

from app.core.exceptions import ConflictException, NotFoundException
from app.models.admin import Admin, Receptionist
from app.repositories.admin import ReceptionistRepository
from app.repositories.user import UserRepository
from app.schemas.admin import ReceptionistCreate, ReceptionistUpdate
from app.schemas.pagination import PaginatedResult, PaginationParams
from app.utils.password import hash_password


class ReceptionistService:
    """Business logic for receptionist CRUD operations."""

    def __init__(
        self,
        receptionist_repo: ReceptionistRepository | None = None,
        user_repo: UserRepository | None = None,
    ) -> None:
        self._receptionist_repo = receptionist_repo or ReceptionistRepository()
        self._user_repo = user_repo or UserRepository()

    def create(self, db: Session, data: ReceptionistCreate, admin: Admin) -> Receptionist:
        if data.email:
            self._validate_unique_email(db, data.email)

        attrs = data.model_dump(exclude={"mot_de_passe"})
        if data.mot_de_passe:
            attrs["mot_de_passe"] = hash_password(data.mot_de_passe)
        attrs["type"] = "RECEPTION"
        attrs["created_by_id"] = admin.uuid
        attrs["updated_by_id"] = admin.uuid

        receptionist = self._receptionist_repo.create(db, **attrs)
        logger.info("Receptionist created", extra={"uuid": receptionist.uuid, "admin": admin.uuid})
        return receptionist

    def get(self, db: Session, uuid: str) -> Receptionist:
        receptionist = self._receptionist_repo.get_by_uuid(db, uuid)
        if receptionist is None or receptionist.date_suppression is not None:
            raise NotFoundException(message=f"Réceptionniste {uuid} introuvable.")
        return receptionist

    def update(self, db: Session, uuid: str, data: ReceptionistUpdate, admin: Admin) -> Receptionist:
        receptionist = self.get(db, uuid)

        update_data = data.model_dump(exclude_unset=True, exclude={"mot_de_passe"})
        if data.mot_de_passe:
            update_data["mot_de_passe"] = hash_password(data.mot_de_passe)

        if "email" in update_data and update_data["email"] and update_data["email"] != receptionist.email:
            self._validate_unique_email(db, update_data["email"])

        update_data["updated_by_id"] = admin.uuid

        updated = self._receptionist_repo.update(db, receptionist.id, **update_data)
        if updated is None:
            raise NotFoundException(message=f"Réceptionniste {uuid} introuvable.")
        logger.info("Receptionist updated", extra={"uuid": uuid, "admin": admin.uuid})
        return updated

    def delete(self, db: Session, uuid: str, admin: Admin) -> None:
        from datetime import UTC, datetime

        receptionist = self.get(db, uuid)
        receptionist.date_suppression = datetime.now(UTC)
        db.flush()
        logger.info("Receptionist soft-deleted", extra={"uuid": uuid, "admin": admin.uuid})

    def get_list(self, db: Session, params: PaginationParams) -> PaginatedResult[Receptionist]:
        items, total = self._receptionist_repo.search_paginated(
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

    def _validate_unique_email(self, db: Session, email: str) -> None:
        existing = self._user_repo.get_by_email(db, email)
        if existing is not None:
            raise ConflictException(
                message=f"Un utilisateur avec l'email « {email} » existe déjà.",
            )
