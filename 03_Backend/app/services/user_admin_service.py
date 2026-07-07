"""User admin service — business logic for managing admin & reception accounts."""

from datetime import UTC, datetime

from loguru import logger
from sqlalchemy.orm import Session

from app.core.exceptions import ConflictException, NotFoundException
from app.models.admin import Admin, Receptionist
from app.models.user import StatutUtilisateur, TypeUtilisateur, User
from app.repositories.user import UserRepository
from app.schemas.pagination import PaginatedResult, PaginationParams
from app.schemas.user import (
    UserAdminCreate,
    UserAdminPasswordReset,
    UserAdminResponse,
    UserAdminUpdate,
)
from app.utils.password import hash_password


class UserAdminService:
    """Business logic for admin & receptionist user CRUD."""

    def __init__(
        self,
        user_repo: UserRepository | None = None,
    ) -> None:
        self._user_repo = user_repo or UserRepository()

    def _to_response(self, user: User) -> UserAdminResponse:
        role_name = None
        derniere_connexion = None
        if isinstance(user, Admin):
            try:
                role_name = user.role.nom if user.role else None
            except Exception:
                pass
            try:
                derniere_connexion = user.derniere_connexion
            except Exception:
                pass
        return UserAdminResponse(
            id=user.id,
            uuid=user.uuid,
            nom=user.nom,
            prenom=user.prenom,
            email=user.email,
            type=user.type.value,
            statut=user.statut.value,
            role_name=role_name,
            derniere_connexion=derniere_connexion,
            created_at=user.created_at,
            updated_at=user.updated_at,
            created_by_id=user.created_by_id,
            updated_by_id=user.updated_by_id,
        )

    def get_list(
        self,
        db: Session,
        params: PaginationParams,
        type_filter: str | None = None,
        statut_filter: str | None = None,
    ) -> PaginatedResult[UserAdminResponse]:
        items, total = self._user_repo.search_paginated_admins(
            db,
            search=params.search,
            sort=params.sort,
            order=params.order,
            page=params.page,
            page_size=params.page_size,
            type_filter=type_filter,
            statut_filter=statut_filter,
        )
        total_pages = max(1, (total + params.page_size - 1) // params.page_size)
        return PaginatedResult(
            items=[self._to_response(u) for u in items],
            total=total,
            page=params.page,
            page_size=params.page_size,
            total_pages=total_pages,
        )

    def get(self, db: Session, uuid: str) -> UserAdminResponse:
        user = self._user_repo.get_by_uuid(db, uuid)
        if user is None or user.date_suppression is not None:
            raise NotFoundException(message=f"Utilisateur {uuid} introuvable.")
        if user.type not in (TypeUtilisateur.ADMINISTRATEUR, TypeUtilisateur.RECEPTION):
            raise NotFoundException(message=f"Utilisateur {uuid} introuvable.")
        return self._to_response(user)

    def create(self, db: Session, data: UserAdminCreate, admin: Admin) -> UserAdminResponse:
        self._validate_unique_email(db, data.email)

        attrs = data.model_dump(exclude={"mot_de_passe", "role_id", "type"})
        attrs["mot_de_passe"] = hash_password(data.mot_de_passe)
        attrs["created_by_id"] = admin.uuid
        attrs["updated_by_id"] = admin.uuid

        if data.type == TypeUtilisateur.ADMINISTRATEUR:
            user = Admin(**attrs)
        else:
            user = Receptionist(**attrs)
        db.add(user)
        db.flush()

        if isinstance(user, Admin) and data.role_id is not None:
            user.role_id = data.role_id
            db.flush()

        db.refresh(user)

        logger.info("User created", extra={"uuid": user.uuid, "type": data.type, "admin": admin.uuid})
        return self._to_response(user)

    def update(self, db: Session, uuid: str, data: UserAdminUpdate, admin: Admin) -> UserAdminResponse:
        user = self._get_user(db, uuid)

        update_data = data.model_dump(exclude_unset=True, exclude={"role_id"})
        if "email" in update_data and update_data["email"]:
            existing = self._user_repo.get_by_email(db, update_data["email"])
            if existing is not None and existing.id != user.id:
                raise ConflictException(message=f"L'email « {update_data['email']} » est déjà utilisé.")

        update_data["updated_by_id"] = admin.uuid

        updated = self._user_repo.update(db, user.id, **update_data)
        if updated is None:
            raise NotFoundException(message=f"Utilisateur {uuid} introuvable.")

        if isinstance(updated, Admin) and data.role_id is not None:
            updated.role_id = data.role_id
            db.flush()

        logger.info("User updated", extra={"uuid": uuid, "admin": admin.uuid})
        return self._to_response(updated)

    def reset_password(self, db: Session, uuid: str, data: UserAdminPasswordReset, admin: Admin) -> None:
        user = self._get_user(db, uuid)
        hashed = hash_password(data.mot_de_passe)
        self._user_repo.update(db, user.id, mot_de_passe=hashed)
        logger.info("Password reset", extra={"uuid": uuid, "admin": admin.uuid})

    def set_status(self, db: Session, uuid: str, statut: StatutUtilisateur, admin: Admin) -> UserAdminResponse:
        user = self._get_user(db, uuid)
        updated = self._user_repo.update(db, user.id, statut=statut, updated_by_id=admin.uuid)
        if updated is None:
            raise NotFoundException(message=f"Utilisateur {uuid} introuvable.")
        logger.info("User status changed", extra={"uuid": uuid, "statut": statut.value, "admin": admin.uuid})
        return self._to_response(updated)

    def delete(self, db: Session, uuid: str, admin: Admin) -> None:
        user = self._get_user(db, uuid)
        user.date_suppression = datetime.now(UTC)
        db.flush()
        logger.info("User soft-deleted", extra={"uuid": uuid, "admin": admin.uuid})

    def _get_user(self, db: Session, uuid: str) -> User:
        user = self._user_repo.get_by_uuid(db, uuid)
        if user is None or user.date_suppression is not None:
            raise NotFoundException(message=f"Utilisateur {uuid} introuvable.")
        if user.type not in (TypeUtilisateur.ADMINISTRATEUR, TypeUtilisateur.RECEPTION):
            raise NotFoundException(message=f"Utilisateur {uuid} introuvable.")
        return user

    def _validate_unique_email(self, db: Session, email: str) -> None:
        existing = self._user_repo.get_by_email(db, email)
        if existing is not None:
            raise ConflictException(message=f"Un utilisateur avec l'email « {email} » existe déjà.")
