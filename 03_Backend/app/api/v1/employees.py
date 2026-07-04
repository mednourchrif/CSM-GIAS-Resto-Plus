"""Employee management endpoints — CRUD + soft-delete for employees.

All endpoints require administrator authentication.
"""

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.schemas.employee import EmployeeCreate, EmployeeResponse, EmployeeUpdate
from app.schemas.pagination import PaginationParams
from app.schemas.response import PaginatedResponse, SuccessResponse
from app.security.dependencies import require_admin
from app.services.employee_service import EmployeeService

router = APIRouter(prefix="/employees", tags=["employees"])

_service = EmployeeService()


@router.get("", response_model=PaginatedResponse[EmployeeResponse])
async def list_employees(
    params: PaginationParams = Depends(),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> PaginatedResponse[EmployeeResponse]:
    """List employees with pagination, sorting, and search."""
    result = _service.get_list(db, params)
    return PaginatedResponse(
        success=True,
        data=[EmployeeResponse.model_validate(e) for e in result.items],
        total=result.total,
        page=result.page,
        page_size=result.page_size,
        total_pages=result.total_pages,
    )


@router.get("/{uuid}", response_model=SuccessResponse[EmployeeResponse])
async def get_employee(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[EmployeeResponse]:
    """Get a single employee by UUID."""
    employee = _service.get(db, uuid)
    return SuccessResponse(data=EmployeeResponse.model_validate(employee))


@router.post("", response_model=SuccessResponse[EmployeeResponse], status_code=status.HTTP_201_CREATED)
async def create_employee(
    body: EmployeeCreate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[EmployeeResponse]:
    """Create a new employee."""
    employee = _service.create(db, body, admin)
    return SuccessResponse(data=EmployeeResponse.model_validate(employee))


@router.put("/{uuid}", response_model=SuccessResponse[EmployeeResponse])
async def update_employee(
    uuid: str,
    body: EmployeeUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[EmployeeResponse]:
    """Replace an employee's data."""
    employee = _service.update(db, uuid, body, admin)
    return SuccessResponse(data=EmployeeResponse.model_validate(employee))


@router.patch("/{uuid}", response_model=SuccessResponse[EmployeeResponse])
async def patch_employee(
    uuid: str,
    body: EmployeeUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[EmployeeResponse]:
    """Partially update an employee."""
    employee = _service.update(db, uuid, body, admin)
    return SuccessResponse(data=EmployeeResponse.model_validate(employee))


@router.delete("/{uuid}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_employee(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> Response:
    """Soft-delete an employee."""
    _service.delete(db, uuid, admin)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
