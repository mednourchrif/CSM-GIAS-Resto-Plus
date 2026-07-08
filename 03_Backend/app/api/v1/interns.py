"""Intern management endpoints — CRUD + soft-delete for interns.

All endpoints require administrator authentication.
"""

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.schemas.intern import InternCreate, InternResponse, InternUpdate
from app.schemas.pagination import PaginationParams
from app.schemas.response import PaginatedResponse, SuccessResponse
from app.security.dependencies import require_admin
from app.services.audit_service import AuditLogService
from app.services.intern_service import InternService

router = APIRouter(prefix="/interns", tags=["interns"])

_service = InternService()
_audit = AuditLogService()


@router.get(
    "",
    summary="Lister les stagiaires",
    description="Retourne la liste paginée des stagiaires avec possibilité de tri et recherche.",
    response_model=PaginatedResponse[InternResponse],
)
async def list_interns(
    params: PaginationParams = Depends(),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> PaginatedResponse[InternResponse]:
    """List interns with pagination, sorting, and search."""
    result = _service.get_list(db, params)
    return PaginatedResponse(
        success=True,
        data=[InternResponse.model_validate(i) for i in result.items],
        total=result.total,
        page=result.page,
        page_size=result.page_size,
        total_pages=result.total_pages,
    )


@router.get(
    "/{uuid}",
    summary="Obtenir un stagiaire",
    description="Retourne les détails d'un stagiaire à partir de son UUID.",
    response_model=SuccessResponse[InternResponse],
)
async def get_intern(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[InternResponse]:
    """Get a single intern by UUID."""
    intern = _service.get(db, uuid)
    return SuccessResponse(data=InternResponse.model_validate(intern))


@router.post(
    "",
    summary="Créer un stagiaire",
    description="Ajoute un nouveau stagiaire dans le système.",
    response_model=SuccessResponse[InternResponse],
    status_code=status.HTTP_201_CREATED,
)
async def create_intern(
    body: InternCreate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[InternResponse]:
    """Create a new intern."""
    intern = _service.create(db, body, admin)
    _audit.log_intern_created(
        db, admin=admin,
        intern_uuid=intern.uuid,
        intern_name=f"{intern.prenom} {intern.nom}",
    )
    return SuccessResponse(data=InternResponse.model_validate(intern))


@router.put(
    "/{uuid}",
    summary="Remplacer un stagiaire",
    description="Remplace l'intégralité des données d'un stagiaire.",
    response_model=SuccessResponse[InternResponse],
)
async def update_intern(
    uuid: str,
    body: InternUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[InternResponse]:
    """Replace an intern's data."""
    intern = _service.update(db, uuid, body, admin)
    _audit.log_intern_updated(
        db, admin=admin,
        intern_uuid=uuid,
        intern_name=f"{intern.prenom} {intern.nom}",
    )
    return SuccessResponse(data=InternResponse.model_validate(intern))


@router.patch(
    "/{uuid}",
    summary="Modifier partiellement un stagiaire",
    description="Met à jour partiellement les données d'un stagiaire (champs fournis uniquement).",
    response_model=SuccessResponse[InternResponse],
)
async def patch_intern(
    uuid: str,
    body: InternUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[InternResponse]:
    """Partially update an intern."""
    intern = _service.update(db, uuid, body, admin)
    _audit.log_intern_updated(
        db, admin=admin,
        intern_uuid=uuid,
        intern_name=f"{intern.prenom} {intern.nom}",
    )
    return SuccessResponse(data=InternResponse.model_validate(intern))


@router.delete(
    "/{uuid}",
    summary="Supprimer un stagiaire",
    description="Désactive un stagiaire (soft-delete).",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_intern(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> Response:
    """Soft-delete an intern."""
    intern = _service.get(db, uuid)
    intern_name = f"{intern.prenom} {intern.nom}"
    _service.delete(db, uuid, admin)
    _audit.log_intern_deleted(
        db, admin=admin,
        intern_uuid=uuid,
        intern_name=intern_name,
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)
