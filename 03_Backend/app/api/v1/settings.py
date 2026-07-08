"""Settings endpoint — system configuration management."""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.schemas.response import SuccessResponse
from app.schemas.setting import (
    DatabaseStatusResponse,
    SettingsBatchUpdate,
    SettingsResponse,
    VersionInfoResponse,
)
from app.security.dependencies import require_admin
from app.services.audit_service import AuditLogService
from app.services.setting_service import SettingService

router = APIRouter(prefix="/settings", tags=["settings"])

_service = SettingService()
_audit = AuditLogService()


@router.get(
    "",
    summary="Get all settings",
    description="Returns all system settings grouped by category.",
    response_model=SuccessResponse[SettingsResponse],
)
async def get_settings(
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[SettingsResponse]:
    result = _service.get_settings(db)
    return SuccessResponse(data=result)


@router.put(
    "",
    summary="Update settings",
    description="Batch update system settings.",
    response_model=SuccessResponse[SettingsResponse],
)
async def update_settings(
    body: SettingsBatchUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[SettingsResponse]:
    old = _service.get_settings(db)
    result = _service.update_settings(db, body.settings)
    for key, new_value in body.settings.items():
        old_value = old.raw.get(key)
        if str(old_value) != str(new_value):
            _audit.log_settings_updated(
                db, admin=admin,
                old_value=str(old_value) if old_value is not None else None,
                new_value=str(new_value),
                setting_key=key,
            )
    return SuccessResponse(data=result)


@router.post(
    "/reset",
    summary="Reset settings to defaults",
    description="Reset all settings to their default values.",
    response_model=SuccessResponse[SettingsResponse],
)
async def reset_settings(
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[SettingsResponse]:
    result = _service.reset_to_defaults(db)
    _audit.log(
        db, action="SETTINGS_RESET", user_name=f"{admin.prenom} {admin.nom}",
        user_role="ADMIN", user_uuid=admin.uuid,
        entity_type="SETTINGS", entity_name="all",
        description="Paramètres réinitialisés aux valeurs par défaut",
    )
    return SuccessResponse(data=result)


@router.get(
    "/version",
    summary="Get version info",
    description="Returns application and backend version information.",
    response_model=SuccessResponse[VersionInfoResponse],
)
async def get_version(
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[VersionInfoResponse]:
    result = _service.get_version_info()
    return SuccessResponse(data=result)


@router.get(
    "/database",
    summary="Get database status",
    description="Returns database connection status and metadata.",
    response_model=SuccessResponse[DatabaseStatusResponse],
)
async def get_database_status(
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[DatabaseStatusResponse]:
    result = _service.get_database_status(db)
    return SuccessResponse(data=result)
