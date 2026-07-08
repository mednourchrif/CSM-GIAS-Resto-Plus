"""Audit log endpoints — query, filter, and export audit trails.

All endpoints require administrator authentication.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.schemas.audit import (
    AuditLogExportResponse,
    AuditLogFilterParams,
    AuditLogFiltersResponse,
    AuditLogResponse,
)
from app.schemas.response import PaginatedResponse, SuccessResponse
from app.security.dependencies import require_admin
from app.services.audit_service import AuditLogService

router = APIRouter(prefix="/audit", tags=["audit"])

_service = AuditLogService()


@router.get(
    "",
    summary="Lister les logs d'audit",
    description="Retourne la liste paginée des logs d'audit avec filtres.",
    response_model=PaginatedResponse[AuditLogResponse],
)
async def list_audit_logs(
    params: AuditLogFilterParams = Depends(),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> PaginatedResponse[AuditLogResponse]:
    items, total = _service.search(db, params)
    page_size = params.page_size
    total_pages = max(1, (total + page_size - 1) // page_size)
    return PaginatedResponse(
        success=True,
        data=items,
        total=total,
        page=params.page,
        page_size=page_size,
        total_pages=total_pages,
    )


@router.get(
    "/filters",
    summary="Options de filtrage",
    description="Retourne les valeurs distinctes disponibles pour les filtres.",
    response_model=SuccessResponse[AuditLogFiltersResponse],
)
async def get_audit_filters(
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[AuditLogFiltersResponse]:
    data = _service.get_filters(db)
    return SuccessResponse(data=AuditLogFiltersResponse(**data))


@router.get(
    "/export",
    summary="Exporter les logs d'audit",
    description="Exporte les logs d'audit selon les filtres appliqués.",
    response_model=SuccessResponse[list[AuditLogExportResponse]],
)
async def export_audit_logs(
    params: AuditLogFilterParams = Depends(),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[list[AuditLogExportResponse]]:
    items = _service.get_export_data(db, params)
    export_data = [AuditLogExportResponse.model_validate(i) for i in items]
    return SuccessResponse(data=export_data)


@router.get(
    "/{uuid}",
    summary="Détail d'un log d'audit",
    description="Retourne les détails complets d'un log d'audit.",
    response_model=SuccessResponse[AuditLogResponse],
)
async def get_audit_log(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[AuditLogResponse]:
    record = _service.get_by_uuid(db, uuid)
    return SuccessResponse(data=record)
