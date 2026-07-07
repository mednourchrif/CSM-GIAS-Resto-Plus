"""User management endpoints — CRUD for admin & receptionist accounts.

All endpoints require administrator authentication.
"""

from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.schemas.pagination import PaginationParams
from app.schemas.response import PaginatedResponse, SuccessResponse
from app.schemas.user import (
    UserAdminCreate,
    UserAdminPasswordReset,
    UserAdminResponse,
    UserAdminUpdate,
)
from app.security.dependencies import require_admin
from app.services.user_admin_service import UserAdminService

router = APIRouter(prefix="/users", tags=["users"])

_service = UserAdminService()


@router.get(
    "",
    summary="Lister les utilisateurs",
    description="Retourne la liste paginée des administrateurs et réceptionnistes.",
    response_model=PaginatedResponse[UserAdminResponse],
)
async def list_users(
    params: PaginationParams = Depends(),
    type_filter: str | None = Query(None, alias="type", description="Filter by type (ADMINISTRATEUR or RECEPTION)"),
    statut_filter: str | None = Query(None, alias="statut", description="Filter by status (ACTIF or INACTIF)"),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> PaginatedResponse[UserAdminResponse]:
    result = _service.get_list(db, params, type_filter=type_filter, statut_filter=statut_filter)
    return PaginatedResponse(
        success=True,
        data=result.items,
        total=result.total,
        page=result.page,
        page_size=result.page_size,
        total_pages=result.total_pages,
    )


@router.get(
    "/{uuid}",
    summary="Obtenir un utilisateur",
    response_model=SuccessResponse[UserAdminResponse],
)
async def get_user(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[UserAdminResponse]:
    user = _service.get(db, uuid)
    return SuccessResponse(data=user)


@router.post(
    "",
    summary="Créer un utilisateur",
    description="Crée un nouvel administrateur ou réceptionniste.",
    response_model=SuccessResponse[UserAdminResponse],
    status_code=status.HTTP_201_CREATED,
)
async def create_user(
    body: UserAdminCreate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[UserAdminResponse]:
    user = _service.create(db, body, admin)
    return SuccessResponse(data=user)


@router.put(
    "/{uuid}",
    summary="Modifier un utilisateur",
    response_model=SuccessResponse[UserAdminResponse],
)
async def update_user(
    uuid: str,
    body: UserAdminUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[UserAdminResponse]:
    user = _service.update(db, uuid, body, admin)
    return SuccessResponse(data=user)


@router.put(
    "/{uuid}/password",
    summary="Réinitialiser le mot de passe",
    description="Réinitialise le mot de passe d'un utilisateur.",
    response_model=SuccessResponse,
)
async def reset_password(
    uuid: str,
    body: UserAdminPasswordReset,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse:
    _service.reset_password(db, uuid, body, admin)
    return SuccessResponse(message="Mot de passe réinitialisé avec succès.")


@router.put(
    "/{uuid}/status",
    summary="Activer/Désactiver un utilisateur",
    response_model=SuccessResponse[UserAdminResponse],
)
async def set_user_status(
    uuid: str,
    statut: str = Query(..., description="ACTIF or INACTIF"),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[UserAdminResponse]:
    from app.models.user import StatutUtilisateur

    user = _service.set_status(db, uuid, StatutUtilisateur(statut), admin)
    return SuccessResponse(data=user)


@router.delete(
    "/{uuid}",
    summary="Supprimer un utilisateur",
    description="Supprime (soft-delete) un utilisateur.",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_user(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> Response:
    _service.delete(db, uuid, admin)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
