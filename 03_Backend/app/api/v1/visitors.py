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
from app.services.visitor_service import VisitorService

router = APIRouter(prefix="/visitors", tags=["visitors"])

_service = VisitorService()


@router.get("", response_model=PaginatedResponse[VisitorResponse])
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


@router.get("/{uuid}", response_model=SuccessResponse[VisitorResponse])
async def get_visitor(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[VisitorResponse]:
    """Get a single visitor by UUID."""
    visitor = _service.get(db, uuid)
    return SuccessResponse(data=VisitorResponse.model_validate(visitor))


@router.post("", response_model=SuccessResponse[VisitorResponse], status_code=status.HTTP_201_CREATED)
async def create_visitor(
    body: VisitorCreate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[VisitorResponse]:
    """Create a new visitor."""
    visitor = _service.create(db, body, admin)
    return SuccessResponse(data=VisitorResponse.model_validate(visitor))


@router.put("/{uuid}", response_model=SuccessResponse[VisitorResponse])
async def update_visitor(
    uuid: str,
    body: VisitorUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[VisitorResponse]:
    """Replace a visitor's data."""
    visitor = _service.update(db, uuid, body, admin)
    return SuccessResponse(data=VisitorResponse.model_validate(visitor))


@router.patch("/{uuid}", response_model=SuccessResponse[VisitorResponse])
async def patch_visitor(
    uuid: str,
    body: VisitorUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[VisitorResponse]:
    """Partially update a visitor."""
    visitor = _service.update(db, uuid, body, admin)
    return SuccessResponse(data=VisitorResponse.model_validate(visitor))


@router.delete("/{uuid}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_visitor(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> Response:
    """Soft-delete a visitor."""
    _service.delete(db, uuid, admin)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
