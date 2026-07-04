"""Visitor service — business logic for visitor management."""

from loguru import logger
from sqlalchemy.orm import Session

from app.core.exceptions import ConflictException, NotFoundException
from app.models.admin import Admin
from app.models.visitor import Visitor
from app.repositories.user import UserRepository
from app.repositories.visitor import VisitorRepository
from app.schemas.pagination import PaginatedResult, PaginationParams
from app.schemas.visitor import VisitorCreate, VisitorUpdate
from app.utils.password import hash_password


class VisitorService:
    """Business logic for visitor CRUD operations."""

    def __init__(
        self,
        visitor_repo: VisitorRepository | None = None,
        user_repo: UserRepository | None = None,
    ) -> None:
        self._visitor_repo = visitor_repo or VisitorRepository()
        self._user_repo = user_repo or UserRepository()

    def create(self, db: Session, data: VisitorCreate, admin: Admin) -> Visitor:
        if data.email:
            self._validate_unique_email(db, data.email)

        attrs = data.model_dump(exclude={"mot_de_passe"})
        if data.mot_de_passe:
            attrs["mot_de_passe"] = hash_password(data.mot_de_passe)
        attrs["type"] = "VISITEUR"
        attrs["created_by_id"] = admin.uuid
        attrs["updated_by_id"] = admin.uuid

        visitor = self._visitor_repo.create(db, **attrs)
        logger.info("Visitor created", extra={"uuid": visitor.uuid, "admin": admin.uuid})
        return visitor

    def get(self, db: Session, uuid: str) -> Visitor:
        visitor = self._visitor_repo.get_by_uuid(db, uuid)
        if visitor is None or visitor.date_suppression is not None:
            raise NotFoundException(message=f"Visiteur {uuid} introuvable.")
        return visitor

    def update(self, db: Session, uuid: str, data: VisitorUpdate, admin: Admin) -> Visitor:
        visitor = self.get(db, uuid)

        update_data = data.model_dump(exclude_unset=True, exclude={"mot_de_passe"})
        if data.mot_de_passe:
            update_data["mot_de_passe"] = hash_password(data.mot_de_passe)

        if "email" in update_data and update_data["email"] and update_data["email"] != visitor.email:
            self._validate_unique_email(db, update_data["email"])

        update_data["updated_by_id"] = admin.uuid

        updated = self._visitor_repo.update(db, visitor.id, **update_data)
        if updated is None:
            raise NotFoundException(message=f"Visiteur {uuid} introuvable.")
        logger.info("Visitor updated", extra={"uuid": uuid, "admin": admin.uuid})
        return updated

    def delete(self, db: Session, uuid: str, admin: Admin) -> None:
        from datetime import UTC, datetime

        visitor = self.get(db, uuid)
        visitor.date_suppression = datetime.now(UTC)
        db.flush()
        logger.info("Visitor soft-deleted", extra={"uuid": uuid, "admin": admin.uuid})

    def get_list(self, db: Session, params: PaginationParams) -> PaginatedResult[Visitor]:
        items, total = self._visitor_repo.search_paginated(
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
