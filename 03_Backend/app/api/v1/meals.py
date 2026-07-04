"""Meal registration endpoints — the central business workflow.

All endpoints are protected by admin authentication.  The ``register``
endpoint uses ``require_reception`` so that both admins and receptionists
can register meals during lunch service.
"""

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.schemas.meal import (
    MealCategoryResponse,
    MealRegisterRequest,
    MealRegisterResponse,
    MealResponse,
)
from app.schemas.pagination import PaginationParams
from app.schemas.response import PaginatedResponse, SuccessResponse
from app.security.dependencies import require_admin, require_reception
from app.services.meal_service import MealService

router = APIRouter(prefix="/meals", tags=["meals"])

_service = MealService()


def _to_meal_response(meal) -> MealResponse:
    """Build a MealResponse, resolving the category name and user name."""
    from sqlalchemy import select

    from app.models.meal_category import MealCategory
    from app.models.user import User

    db = None  # resolved in the endpoint
    return MealResponse(
        id=meal.id,
        uuid=meal.uuid,
        created_at=meal.created_at,
        updated_at=meal.updated_at,
        utilisateur_uuid=meal.utilisateur_uuid,
        qr_uuid=meal.qr_uuid,
        categorie_uuid=meal.categorie_uuid,
        type_identification=meal.type_identification,
        date_repas=meal.date_repas,
        heure_repas=meal.heure_repas,
        enregistre_par_uuid=meal.enregistre_par_uuid,
    )


def _enrich_meal_response(meal, db: Session) -> MealResponse:
    """Enrich a MealResponse with category name and user name."""
    from sqlalchemy import select

    from app.models.meal_category import MealCategory
    from app.models.user import User

    cat_stmt = select(MealCategory).where(MealCategory.uuid == meal.categorie_uuid)
    category = db.execute(cat_stmt).scalar_one_or_none()

    user_stmt = select(User).where(User.uuid == meal.utilisateur_uuid)
    user = db.execute(user_stmt).scalar_one_or_none()

    return MealResponse(
        id=meal.id,
        uuid=meal.uuid,
        created_at=meal.created_at,
        updated_at=meal.updated_at,
        utilisateur_uuid=meal.utilisateur_uuid,
        qr_uuid=meal.qr_uuid,
        categorie_uuid=meal.categorie_uuid,
        type_identification=meal.type_identification,
        date_repas=meal.date_repas,
        heure_repas=meal.heure_repas,
        enregistre_par_uuid=meal.enregistre_par_uuid,
        categorie_nom=category.nom if category else None,
        nom=user.nom if user else None,
        prenom=user.prenom if user else None,
    )


@router.post(
    "/register",
    response_model=SuccessResponse[MealRegisterResponse],
    status_code=status.HTTP_201_CREATED,
)
async def register_meal(
    body: MealRegisterRequest,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_reception),
) -> SuccessResponse[MealRegisterResponse]:
    """Register a meal via QR code validation.

    Validates:
    * Restaurant is open (12:30–14:00)
    * QR token is valid
    * User has not already eaten today
    * Category exists
    """
    meal = _service.register_by_qr(db, body.token, body.categorie_uuid, admin=admin)

    from sqlalchemy import select

    from app.models.meal_category import MealCategory

    cat_stmt = select(MealCategory).where(MealCategory.uuid == meal.categorie_uuid)
    category = db.execute(cat_stmt).scalar_one_or_none()

    return SuccessResponse(
        data=MealRegisterResponse(
            id=meal.id,
            uuid=meal.uuid,
            created_at=meal.created_at,
            updated_at=meal.updated_at,
            utilisateur_uuid=meal.utilisateur_uuid,
            categorie_uuid=meal.categorie_uuid,
            type_identification=meal.type_identification,
            date_repas=meal.date_repas,
            heure_repas=meal.heure_repas,
            qr_uuid=meal.qr_uuid,
            enregistre_par_uuid=meal.enregistre_par_uuid,
            categorie_nom=category.nom if category else None,
        ),
    )


@router.get(
    "",
    response_model=PaginatedResponse[MealResponse],
)
async def list_meals(
    params: PaginationParams = Depends(),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> PaginatedResponse[MealResponse]:
    """List meals with pagination, sorting, and search."""
    result = _service.get_list(db, params)
    return PaginatedResponse(
        success=True,
        data=[_enrich_meal_response(m, db) for m in result.items],
        total=result.total,
        page=result.page,
        page_size=result.page_size,
        total_pages=result.total_pages,
    )


@router.get(
    "/{uuid}",
    response_model=SuccessResponse[MealResponse],
)
async def get_meal(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[MealResponse]:
    """Get a single meal by UUID."""
    meal = _service.get(db, uuid)
    return SuccessResponse(data=_enrich_meal_response(meal, db))


@router.get(
    "/history/{user_uuid}",
    response_model=SuccessResponse[list[MealResponse]],
)
async def get_meal_history(
    user_uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[list[MealResponse]]:
    """Get all meals for a user (newest first)."""
    history = _service.get_history(db, user_uuid)
    return SuccessResponse(
        data=[_enrich_meal_response(m, db) for m in history],
    )


@router.get(
    "/today",
    response_model=SuccessResponse[list[MealResponse]],
)
async def get_today_meals(
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[list[MealResponse]]:
    """Get all meals registered today."""
    meals = _service.get_today(db)
    return SuccessResponse(
        data=[_enrich_meal_response(m, db) for m in meals],
    )
