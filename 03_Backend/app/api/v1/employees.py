"""Employee management endpoints — CRUD + soft-delete for employees.

All endpoints require administrator authentication.
"""

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.models.meal_category import MealCategory
from app.schemas.employee import (
    EmployeeCreate,
    EmployeeDetailResponse,
    EmployeeResponse,
    EmployeeUpdate,
    MealSummaryResponse,
)
from app.schemas.pagination import PaginationParams
from app.schemas.response import PaginatedResponse, SuccessResponse
from app.security.dependencies import require_admin
from app.services.employee_service import EmployeeService
from app.services.audit_service import AuditLogService

router = APIRouter(prefix="/employees", tags=["employees"])

_service = EmployeeService()
_audit = AuditLogService()


def _meal_summary(meal: object, db: Session) -> MealSummaryResponse | None:
    """Build a MealSummaryResponse from a Meal ORM object."""
    if meal is None:
        return None
    cat_stmt = select(MealCategory).where(MealCategory.uuid == meal.categorie_uuid)
    category = db.execute(cat_stmt).scalar_one_or_none()
    return MealSummaryResponse(
        id=meal.id,
        uuid=meal.uuid,
        created_at=meal.created_at,
        updated_at=meal.updated_at,
        categorie_nom=category.nom if category else "",
        type_identification=meal.type_identification,
        date_repas=meal.date_repas,
        heure_repas=meal.heure_repas,
    )


@router.get(
    "",
    summary="Lister les employés",
    description="Retourne la liste paginée des employés avec possibilité de tri et recherche.",
    response_model=PaginatedResponse[EmployeeResponse],
)
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


@router.get(
    "/{uuid}",
    summary="Obtenir un employé",
    description="Retourne les détails d'un employé à partir de son UUID, "
    "incluant le repas du jour, l'historique et le statut des identifications.",
    response_model=SuccessResponse[EmployeeDetailResponse],
)
async def get_employee(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[EmployeeDetailResponse]:
    """Get a single employee by UUID with enriched detail."""
    detail = _service.get_detail(db, uuid)

    return SuccessResponse(
        data=EmployeeDetailResponse(
            id=detail.employee.id,
            uuid=detail.employee.uuid,
            created_at=detail.employee.created_at,
            updated_at=detail.employee.updated_at,
            nom=detail.employee.nom,
            prenom=detail.employee.prenom,
            email=detail.employee.email,
            matricule=detail.employee.matricule,
            photo_path=detail.employee.photo_path,
            date_enrolement=detail.employee.date_enrolement,
            statut_enrolement=detail.employee.statut_enrolement,
            statut=detail.employee.statut,
            langue=detail.employee.langue,
            date_suppression=detail.employee.date_suppression,
            today_meal=_meal_summary(detail.today_meal, db),
            last_meals=[_meal_summary(m, db) for m in detail.last_meals],
            face_enrolled=detail.face_enrolled,
            qr_generated=detail.qr_generated,
        )
    )


@router.post("", response_model=SuccessResponse[EmployeeResponse], status_code=status.HTTP_201_CREATED)
async def create_employee(
    body: EmployeeCreate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[EmployeeResponse]:
    """Create a new employee."""
    employee = _service.create(db, body, admin)
    _audit.log_employee_created(
        db, admin=admin,
        employee_uuid=employee.uuid,
        employee_name=f"{employee.prenom} {employee.nom}",
    )
    return SuccessResponse(data=EmployeeResponse.model_validate(employee))


@router.put(
    "/{uuid}",
    summary="Remplacer un employé",
    description="Remplace l'intégralité des données d'un employé.",
    response_model=SuccessResponse[EmployeeResponse],
)
async def update_employee(
    uuid: str,
    body: EmployeeUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[EmployeeResponse]:
    """Replace an employee's data."""
    employee = _service.update(db, uuid, body, admin)
    _audit.log_employee_updated(
        db, admin=admin,
        employee_uuid=uuid,
        employee_name=f"{employee.prenom} {employee.nom}",
    )
    return SuccessResponse(data=EmployeeResponse.model_validate(employee))


@router.patch(
    "/{uuid}",
    summary="Modifier partiellement un employé",
    description="Met à jour partiellement les données d'un employé (champs fournis uniquement).",
    response_model=SuccessResponse[EmployeeResponse],
)
async def patch_employee(
    uuid: str,
    body: EmployeeUpdate,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[EmployeeResponse]:
    """Partially update an employee."""
    employee = _service.update(db, uuid, body, admin)
    _audit.log_employee_updated(
        db, admin=admin,
        employee_uuid=uuid,
        employee_name=f"{employee.prenom} {employee.nom}",
    )
    return SuccessResponse(data=EmployeeResponse.model_validate(employee))


@router.delete(
    "/{uuid}",
    summary="Supprimer un employé",
    description="Désactive un employé (soft-delete).",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_employee(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> Response:
    """Soft-delete an employee."""
    employee = _service.get(db, uuid)
    employee_name = f"{employee.prenom} {employee.nom}"
    _service.delete(db, uuid, admin)
    _audit.log_employee_deleted(
        db, admin=admin,
        employee_uuid=uuid,
        employee_name=employee_name,
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)
