import json
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.models.admin import Admin
from app.repositories.audit_repository import AuditLogRepository
from app.schemas.audit import AuditLogFilterParams, AuditLogResponse


class AuditLogService:
    def __init__(
        self,
        repo: AuditLogRepository | None = None,
    ) -> None:
        self._repo = repo or AuditLogRepository()

    # ── Core log method ───────────────────────────────────────────────────

    def log(
        self,
        db: Session,
        *,
        action: str,
        user_name: str,
        user_role: str,
        user_uuid: str | None = None,
        entity_type: str | None = None,
        entity_uuid: str | None = None,
        entity_name: str | None = None,
        description: str | None = None,
        http_method: str | None = None,
        endpoint: str | None = None,
        ip_address: str | None = None,
        user_agent: str | None = None,
        status: str = "SUCCESS",
        metadata_json: str | None = None,
    ) -> None:
        self._repo.create(
            db,
            user_uuid=user_uuid,
            user_name=user_name,
            user_role=user_role,
            action=action,
            entity_type=entity_type,
            entity_uuid=entity_uuid,
            entity_name=entity_name,
            description=description,
            http_method=http_method,
            endpoint=endpoint,
            ip_address=ip_address,
            user_agent=user_agent,
            status=status,
            metadata_json=metadata_json,
        )
        db.flush()

    # ── Query methods ─────────────────────────────────────────────────────

    def search(
        self,
        db: Session,
        filters: AuditLogFilterParams,
    ) -> tuple[list[AuditLogResponse], int]:
        items, total = self._repo.search_paginated(
            db,
            page=filters.page,
            page_size=filters.page_size,
            filters=filters,
        )
        return [AuditLogResponse.model_validate(item) for item in items], total

    def get_by_uuid(self, db: Session, uuid: str) -> AuditLogResponse:
        record = self._repo.get_by_uuid(db, uuid)
        if record is None:
            from app.core.exceptions import NotFoundException
            raise NotFoundException(message=f"Audit log {uuid} not found.")
        return AuditLogResponse.model_validate(record)

    def get_filters(self, db: Session) -> dict:
        return {
            "actions": self._repo.get_actions(db),
            "entity_types": self._repo.get_entity_types(db),
        }

    def get_export_data(
        self,
        db: Session,
        filters: AuditLogFilterParams,
    ) -> list[AuditLogResponse]:
        filters.page_size = 10_000
        items, _ = self.search(db, filters)
        return items

    # ── Domain-specific shorthand helpers ─────────────────────────────────

    def log_login(
        self,
        db: Session,
        *,
        user_name: str,
        user_role: str,
        user_uuid: str | None = None,
        success: bool = True,
        ip_address: str | None = None,
        user_agent: str | None = None,
    ) -> None:
        self.log(
            db,
            action="LOGIN_SUCCESS" if success else "LOGIN_FAILURE",
            user_name=user_name,
            user_role=user_role,
            user_uuid=user_uuid,
            status="SUCCESS" if success else "FAILURE",
            ip_address=ip_address,
            user_agent=user_agent,
        )

    def log_logout(
        self,
        db: Session,
        *,
        user_name: str,
        user_role: str,
        user_uuid: str | None = None,
    ) -> None:
        self.log(
            db,
            action="LOGOUT",
            user_name=user_name,
            user_role=user_role,
            user_uuid=user_uuid,
        )

    def _log_crud(
        self,
        db: Session,
        *,
        action_prefix: str,
        entity_type: str,
        entity_uuid: str,
        entity_name: str | None = None,
        admin: Admin,
        description: str | None = None,
        metadata_json: str | None = None,
    ) -> None:
        self.log(
            db,
            action=f"{entity_type}_{action_prefix}",
            user_name=f"{admin.prenom} {admin.nom}",
            user_role="ADMIN",
            user_uuid=admin.uuid,
            entity_type=entity_type,
            entity_uuid=entity_uuid,
            entity_name=entity_name,
            description=description,
            metadata_json=metadata_json,
        )

    def log_employee_created(
        self, db: Session, *, admin: Admin, employee_uuid: str, employee_name: str
    ) -> None:
        self._log_crud(
            db,
            action_prefix="CREATED",
            entity_type="EMPLOYEE",
            entity_uuid=employee_uuid,
            entity_name=employee_name,
            admin=admin,
        )

    def log_employee_updated(
        self, db: Session, *, admin: Admin, employee_uuid: str, employee_name: str
    ) -> None:
        self._log_crud(
            db,
            action_prefix="UPDATED",
            entity_type="EMPLOYEE",
            entity_uuid=employee_uuid,
            entity_name=employee_name,
            admin=admin,
        )

    def log_employee_deleted(
        self, db: Session, *, admin: Admin, employee_uuid: str, employee_name: str
    ) -> None:
        self._log_crud(
            db,
            action_prefix="DELETED",
            entity_type="EMPLOYEE",
            entity_uuid=employee_uuid,
            entity_name=employee_name,
            admin=admin,
        )

    def log_employee_activated(
        self, db: Session, *, admin: Admin, employee_uuid: str, employee_name: str
    ) -> None:
        self._log_crud(
            db,
            action_prefix="ACTIVATED",
            entity_type="EMPLOYEE",
            entity_uuid=employee_uuid,
            entity_name=employee_name,
            admin=admin,
        )

    def log_employee_deactivated(
        self, db: Session, *, admin: Admin, employee_uuid: str, employee_name: str
    ) -> None:
        self._log_crud(
            db,
            action_prefix="DEACTIVATED",
            entity_type="EMPLOYEE",
            entity_uuid=employee_uuid,
            entity_name=employee_name,
            admin=admin,
        )

    def log_visitor_created(
        self, db: Session, *, admin: Admin, visitor_uuid: str, visitor_name: str
    ) -> None:
        self._log_crud(
            db, action_prefix="CREATED", entity_type="VISITOR",
            entity_uuid=visitor_uuid, entity_name=visitor_name, admin=admin,
        )

    def log_visitor_updated(
        self, db: Session, *, admin: Admin, visitor_uuid: str, visitor_name: str
    ) -> None:
        self._log_crud(
            db, action_prefix="UPDATED", entity_type="VISITOR",
            entity_uuid=visitor_uuid, entity_name=visitor_name, admin=admin,
        )

    def log_visitor_deleted(
        self, db: Session, *, admin: Admin, visitor_uuid: str, visitor_name: str
    ) -> None:
        self._log_crud(
            db, action_prefix="DELETED", entity_type="VISITOR",
            entity_uuid=visitor_uuid, entity_name=visitor_name, admin=admin,
        )

    def log_intern_created(
        self, db: Session, *, admin: Admin, intern_uuid: str, intern_name: str
    ) -> None:
        self._log_crud(
            db, action_prefix="CREATED", entity_type="INTERN",
            entity_uuid=intern_uuid, entity_name=intern_name, admin=admin,
        )

    def log_intern_updated(
        self, db: Session, *, admin: Admin, intern_uuid: str, intern_name: str
    ) -> None:
        self._log_crud(
            db, action_prefix="UPDATED", entity_type="INTERN",
            entity_uuid=intern_uuid, entity_name=intern_name, admin=admin,
        )

    def log_intern_deleted(
        self, db: Session, *, admin: Admin, intern_uuid: str, intern_name: str
    ) -> None:
        self._log_crud(
            db, action_prefix="DELETED", entity_type="INTERN",
            entity_uuid=intern_uuid, entity_name=intern_name, admin=admin,
        )

    def log_user_created(
        self, db: Session, *, admin: Admin, user_uuid: str, user_name: str
    ) -> None:
        self._log_crud(
            db, action_prefix="CREATED", entity_type="USER",
            entity_uuid=user_uuid, entity_name=user_name, admin=admin,
        )

    def log_user_updated(
        self, db: Session, *, admin: Admin, user_uuid: str, user_name: str
    ) -> None:
        self._log_crud(
            db, action_prefix="UPDATED", entity_type="USER",
            entity_uuid=user_uuid, entity_name=user_name, admin=admin,
        )

    def log_user_deleted(
        self, db: Session, *, admin: Admin, user_uuid: str, user_name: str
    ) -> None:
        self._log_crud(
            db, action_prefix="DELETED", entity_type="USER",
            entity_uuid=user_uuid, entity_name=user_name, admin=admin,
        )

    def log_password_changed(
        self, db: Session, *, admin: Admin, user_uuid: str, user_name: str
    ) -> None:
        self._log_crud(
            db, action_prefix="PASSWORD_CHANGED", entity_type="USER",
            entity_uuid=user_uuid, entity_name=user_name, admin=admin,
        )

    def log_role_changed(
        self, db: Session, *, admin: Admin, user_uuid: str, user_name: str,
        old_role: str, new_role: str,
    ) -> None:
        self.log(
            db,
            action="USER_ROLE_CHANGED",
            user_name=f"{admin.prenom} {admin.nom}",
            user_role="ADMIN",
            user_uuid=admin.uuid,
            entity_type="USER",
            entity_uuid=user_uuid,
            entity_name=user_name,
            description=f"Rôle changé de {old_role} à {new_role}",
        )

    def log_qr_generated(
        self, db: Session, *, admin: Admin, qr_uuid: str,
        owner_type: str, owner_name: str,
    ) -> None:
        self.log(
            db,
            action="QR_GENERATED",
            user_name=f"{admin.prenom} {admin.nom}",
            user_role="ADMIN",
            user_uuid=admin.uuid,
            entity_type="QR_CODE",
            entity_uuid=qr_uuid,
            entity_name=f"QR {owner_type} - {owner_name}",
        )

    def log_qr_downloaded(
        self, db: Session, *, admin: Admin, qr_uuid: str,
        owner_name: str,
    ) -> None:
        self.log(
            db, action="QR_DOWNLOADED", user_name=f"{admin.prenom} {admin.nom}",
            user_role="ADMIN", user_uuid=admin.uuid,
            entity_type="QR_CODE", entity_uuid=qr_uuid,
            entity_name=owner_name,
        )

    def log_qr_printed(
        self, db: Session, *, admin: Admin, qr_uuid: str, owner_name: str,
    ) -> None:
        self.log(
            db, action="QR_PRINTED", user_name=f"{admin.prenom} {admin.nom}",
            user_role="ADMIN", user_uuid=admin.uuid,
            entity_type="QR_CODE", entity_uuid=qr_uuid,
            entity_name=owner_name,
        )

    def log_qr_deleted(
        self, db: Session, *, admin: Admin, qr_uuid: str, owner_name: str,
    ) -> None:
        self._log_crud(
            db, action_prefix="DELETED", entity_type="QR_CODE",
            entity_uuid=qr_uuid, entity_name=owner_name, admin=admin,
        )

    def log_face_enrolled(
        self, db: Session, *, admin: Admin, employee_uuid: str, employee_name: str,
    ) -> None:
        self.log(
            db, action="FACE_ENROLLED", user_name=f"{admin.prenom} {admin.nom}",
            user_role="ADMIN", user_uuid=admin.uuid,
            entity_type="FACE_EMBEDDING", entity_uuid=employee_uuid,
            entity_name=employee_name,
        )

    def log_face_reenrolled(
        self, db: Session, *, admin: Admin, employee_uuid: str, employee_name: str,
    ) -> None:
        self.log(
            db, action="FACE_REENROLLED", user_name=f"{admin.prenom} {admin.nom}",
            user_role="ADMIN", user_uuid=admin.uuid,
            entity_type="FACE_EMBEDDING", entity_uuid=employee_uuid,
            entity_name=employee_name,
        )

    def log_face_removed(
        self, db: Session, *, admin: Admin, employee_uuid: str, employee_name: str,
    ) -> None:
        self.log(
            db, action="FACE_REMOVED", user_name=f"{admin.prenom} {admin.nom}",
            user_role="ADMIN", user_uuid=admin.uuid,
            entity_type="FACE_EMBEDDING", entity_uuid=employee_uuid,
            entity_name=employee_name,
        )

    def log_meal_registered(
        self, db: Session, *,
        employee_uuid: str, employee_name: str,
        meal_type: str,
        recognition_method: str,
    ) -> None:
        from app.models.admin import Admin
        self.log(
            db,
            action="MEAL_REGISTERED",
            user_name="System",
            user_role="SYSTEM",
            entity_type="MEAL",
            entity_uuid=employee_uuid,
            entity_name=employee_name,
            description=f"Repas {meal_type} via {recognition_method}",
            metadata_json=json.dumps({
                "meal_type": meal_type,
                "recognition_method": recognition_method,
            }),
        )

    def log_settings_updated(
        self, db: Session, *, admin: Admin,
        old_value: str | None, new_value: str | None,
        setting_key: str,
    ) -> None:
        self.log(
            db,
            action="SETTINGS_UPDATED",
            user_name=f"{admin.prenom} {admin.nom}",
            user_role="ADMIN",
            user_uuid=admin.uuid,
            entity_type="SETTINGS",
            entity_name=setting_key,
            description=f"Paramètre mis à jour: {old_value} → {new_value}",
            metadata_json=json.dumps({
                "key": setting_key,
                "old_value": old_value,
                "new_value": new_value,
            }),
        )
