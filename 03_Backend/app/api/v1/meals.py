"""Meal registration endpoints — the central business workflow.

The ``register`` endpoint is a **public** kiosk endpoint: it does not
require any JWT authentication.  Identification is performed entirely
through the QR token supplied in the request body.

All other endpoints (list, today, history, detail) remain protected by
admin authentication.
"""

from datetime import date

from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.models.meal_category import MealCategory
from app.models.user import User
from app.schemas.meal import (
    MealCategoryResponse,
    MealRegisterRequest,
    MealRegisterResponse,
    MealResponse,
)
from app.schemas.pagination import MealFilterParams, PaginationParams
from app.schemas.response import PaginatedResponse, SuccessResponse
from app.security.dependencies import require_admin
from app.services.meal_service import MealService

router = APIRouter(prefix="/meals", tags=["meals"])

_service = MealService()


def _enrich_meal_response(meal, db: Session) -> MealResponse:
    """Enrich a MealResponse with category name and user name."""
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


@router.get(
    "/categories",
    response_model=SuccessResponse[list[MealCategoryResponse]],
)
async def list_categories(
    db: Session = Depends(get_db),
) -> SuccessResponse[list[MealCategoryResponse]]:
    """List all meal categories (public — no auth required).

    The kiosk uses this to populate the meal selection screen with
    the correct category UUIDs.
    """
    stmt = select(MealCategory).order_by(MealCategory.nom)
    categories = db.execute(stmt).scalars().all()
    return SuccessResponse(
        data=[
            MealCategoryResponse(
                id=c.id,
                uuid=c.uuid,
                created_at=c.created_at,
                updated_at=c.updated_at,
                nom=c.nom,
                description=c.description,
            )
            for c in categories
        ],
    )


@router.post(
    "/register",
    response_model=SuccessResponse[MealRegisterResponse],
    status_code=status.HTTP_201_CREATED,
)
async def register_meal(
    body: MealRegisterRequest,
    db: Session = Depends(get_db),
) -> SuccessResponse[MealRegisterResponse]:
    """Register a meal via QR token OR direct user UUID.

    This is a **public** kiosk endpoint — no JWT required.
    Authentication is performed via the QR token or the user UUID.

    When ``utilisateur_uuid`` is provided (Face Recognition flow),
    the meal is registered directly without QR validation.

    Validates:
    * Restaurant is open (12:30–00:00)
    * Category exists
    * User has not already eaten today
    """
    if body.token:
        meal = _service.register_by_qr(db, body.token, body.categorie_uuid, admin=None)
    elif body.utilisateur_uuid:
        meal = _service.register_by_user_uuid(
            db, body.utilisateur_uuid, body.categorie_uuid, type_identification="FACE",
        )
    else:
        from fastapi import HTTPException
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Fournir 'token' (QR) ou 'utilisateur_uuid' (reconnaissance faciale).",
        )

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
    summary="Lister les repas",
    description=(
        "Retourne la liste paginée des repas avec filtres. "
        "Paramètres de filtre : date_from, date_to, categorie_uuid, "
        "type_identification (QR|FACE), user_type (EMPLOYE|STAGIAIRE|VISITEUR)."
    ),
    response_model=PaginatedResponse[MealResponse],
)
async def list_meals(
    params: MealFilterParams = Depends(),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> PaginatedResponse[MealResponse]:
    """List meals with pagination, filters, and search."""
    result = _service.get_list(
        db,
        params,
        date_from=params.date_from,
        date_to=params.date_to,
        categorie_uuid=params.categorie_uuid,
        type_identification=params.type_identification,
        user_type=params.user_type,
    )
    return PaginatedResponse(
        success=True,
        data=[_enrich_meal_response(m, db) for m in result.items],
        total=result.total,
        page=result.page,
        page_size=result.page_size,
        total_pages=result.total_pages,
    )


@router.get(
    "/stats",
    summary="Statistiques des repas",
    description="Retourne les statistiques des repas pour une période.",
)
async def get_meal_stats(
    date_from: date | None = None,
    date_to: date | None = None,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse:
    """Get meal statistics for a date range."""
    stats = _service.get_stats(db, date_from=date_from, date_to=date_to)
    return SuccessResponse(data={
        "total_meals": stats.total_meals,
        "total_employees": stats.total_employees,
        "total_interns": stats.total_interns,
        "total_visitors": stats.total_visitors,
        "face_registrations": stats.face_registrations,
        "qr_registrations": stats.qr_registrations,
    })


@router.get(
    "/today",
    summary="Repas du jour",
    description="Retourne tous les repas enregistrés aujourd'hui.",
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


@router.get(
    "/history/{user_uuid}",
    summary="Historique des repas d'un utilisateur",
    description="Retourne tous les repas d'un utilisateur (du plus récent au plus ancien).",
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
    "/{uuid}",
    summary="Obtenir un repas",
    description="Retourne les détails d'un repas à partir de son UUID.",
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
