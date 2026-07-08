"""Visitor management endpoints — CRUD + soft-delete for visitors.

All endpoints require administrator authentication.
"""

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.schemas.pagination import PaginationParams
from app.schemas.response import PaginatedResponse, SuccessResponse
from app.schemas.visitor import VisitorCreate, VisitorResponse, VisitorUpdate
from app.security.dependencies import require_admin
from app.services.audit_service import AuditLogService
from app.services.visitor_service import VisitorService

router = APIRouter(prefix="/visitors", tags=["visitors"])

_service = VisitorService()
_audit = AuditLogService()


@router.get(
    "",
    summary="Lister les visiteurs",
    description="Retourne la liste paginée des visiteurs avec possibilité de tri et recherche.",
    response_model=PaginatedResponse[VisitorResponse],
)
async def list_visitors(
    params: PaginationParams = Depends(),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> PaginatedResponse[VisitorResponse]:
    """List visitors with pagination, sorting, and search."""
    result = _service.get_list(db, params)
    return PaginatedResponse(
        success=True,
        data=[VisitorResponse.model_validate(v) for v in result.items],
        total=result.total,
        page=result.page,
        page_size=result.page_size,
        total_pages=result.total_pages,
    )


@router.get(
    "/{uuid}",
    summary="Obtenir un visiteur",
    description="Retourne les détails d'un visiteur à partir de son UUID.",
    response_model=SuccessResponse[VisitorResponse],
)
async def get_visitor(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[VisitorResponse]:
    """Get a single visitor by UUID."""
    visitor = _service.get(db, uuid)
    return SuccessResponse(data=VisitorResponse.model_validate(visitor))


@router.post(
    "",
    summary="Créer un visiteur",
    description="Ajoute un nouveau visiteur dans le système.",
    response_model=SuccessResponse[VisitorResponse],
    status_code=status.HTTP_201_CREATED,
)
async def create_visitor(
    body: VisitorCreate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[VisitorResponse]:
    """Create a new visitor."""
    visitor = _service.create(db, body, admin)
    _audit.log_visitor_created(
        db, admin=admin,
        visitor_uuid=visitor.uuid,
        visitor_name=f"{visitor.prenom} {visitor.nom}",
    )
    return SuccessResponse(data=VisitorResponse.model_validate(visitor))


@router.put(
    "/{uuid}",
    summary="Remplacer un visiteur",
    description="Remplace l'intégralité des données d'un visiteur.",
    response_model=SuccessResponse[VisitorResponse],
)
async def update_visitor(
    uuid: str,
    body: VisitorUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[VisitorResponse]:
    """Replace a visitor's data."""
    visitor = _service.update(db, uuid, body, admin)
    _audit.log_visitor_updated(
        db, admin=admin,
        visitor_uuid=uuid,
        visitor_name=f"{visitor.prenom} {visitor.nom}",
    )
    return SuccessResponse(data=VisitorResponse.model_validate(visitor))


@router.patch(
    "/{uuid}",
    summary="Modifier partiellement un visiteur",
    description="Met à jour partiellement les données d'un visiteur (champs fournis uniquement).",
    response_model=SuccessResponse[VisitorResponse],
)
async def patch_visitor(
    uuid: str,
    body: VisitorUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[VisitorResponse]:
    """Partially update a visitor."""
    visitor = _service.update(db, uuid, body, admin)
    _audit.log_visitor_updated(
        db, admin=admin,
        visitor_uuid=uuid,
        visitor_name=f"{visitor.prenom} {visitor.nom}",
    )
    return SuccessResponse(data=VisitorResponse.model_validate(visitor))


@router.delete(
    "/{uuid}",
    summary="Supprimer un visiteur",
    description="Désactive un visiteur (soft-delete).",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_visitor(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> Response:
    """Soft-delete a visitor."""
    visitor = _service.get(db, uuid)
    visitor_name = f"{visitor.prenom} {visitor.nom}"
    _service.delete(db, uuid, admin)
    _audit.log_visitor_deleted(
        db, admin=admin,
        visitor_uuid=uuid,
        visitor_name=visitor_name,
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)
