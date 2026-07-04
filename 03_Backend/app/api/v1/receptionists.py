"""Receptionist management endpoints — CRUD + soft-delete for receptionists.

All endpoints require administrator authentication.
"""

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.schemas.admin import ReceptionistCreate, ReceptionistResponse, ReceptionistUpdate
from app.schemas.pagination import PaginationParams
from app.schemas.response import PaginatedResponse, SuccessResponse
from app.security.dependencies import require_admin
from app.services.receptionist_service import ReceptionistService

router = APIRouter(prefix="/receptionists", tags=["receptionists"])

_service = ReceptionistService()


@router.get("", response_model=PaginatedResponse[ReceptionistResponse])
async def list_receptionists(
    params: PaginationParams = Depends(),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> PaginatedResponse[ReceptionistResponse]:
    """List receptionists with pagination, sorting, and search."""
    result = _service.get_list(db, params)
    return PaginatedResponse(
        success=True,
        data=[ReceptionistResponse.model_validate(r) for r in result.items],
        total=result.total,
        page=result.page,
        page_size=result.page_size,
        total_pages=result.total_pages,
    )


@router.get("/{uuid}", response_model=SuccessResponse[ReceptionistResponse])
async def get_receptionist(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[ReceptionistResponse]:
    """Get a single receptionist by UUID."""
    receptionist = _service.get(db, uuid)
    return SuccessResponse(data=ReceptionistResponse.model_validate(receptionist))


@router.post("", response_model=SuccessResponse[ReceptionistResponse], status_code=status.HTTP_201_CREATED)
async def create_receptionist(
    body: ReceptionistCreate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[ReceptionistResponse]:
    """Create a new receptionist."""
    receptionist = _service.create(db, body, admin)
    return SuccessResponse(data=ReceptionistResponse.model_validate(receptionist))


@router.put("/{uuid}", response_model=SuccessResponse[ReceptionistResponse])
async def update_receptionist(
    uuid: str,
    body: ReceptionistUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[ReceptionistResponse]:
    """Replace a receptionist's data."""
    receptionist = _service.update(db, uuid, body, admin)
    return SuccessResponse(data=ReceptionistResponse.model_validate(receptionist))


@router.patch("/{uuid}", response_model=SuccessResponse[ReceptionistResponse])
async def patch_receptionist(
    uuid: str,
    body: ReceptionistUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[ReceptionistResponse]:
    """Partially update a receptionist."""
    receptionist = _service.update(db, uuid, body, admin)
    return SuccessResponse(data=ReceptionistResponse.model_validate(receptionist))


@router.delete("/{uuid}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_receptionist(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> Response:
    """Soft-delete a receptionist."""
    _service.delete(db, uuid, admin)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
