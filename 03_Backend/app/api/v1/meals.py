"""Meal endpoints and the protected identify-then-confirm kiosk workflow.

Category and registration routes require a managed-tablet credential (or an
administrator bearer token). Registration accepts only a short-lived,
one-use identification grant. Administrative query routes require an admin.
"""

from datetime import date

from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.models.meal import Meal
from app.models.meal_category import MealCategory
from app.models.user import User
from app.schemas.meal import (
    MealCategoryResponse,
    MealRegisterRequest,
    MealRegisterResponse,
    MealResponse,
)
from app.schemas.pagination import MealFilterParams
from app.schemas.receipt import ReceiptResponse
from app.schemas.response import PaginatedResponse, SuccessResponse
from app.security.dependencies import require_admin, require_kiosk_access
from app.services.meal_service import MealService
from app.services.receipt_service import ReceiptService
from app.utils.receipt_qr import make_receipt_token

router = APIRouter(prefix="/meals", tags=["meals"])

_service = MealService()
_receipt_service = ReceiptService()


def _enrich_meal_response(meal: Meal, db: Session) -> MealResponse:
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


def _enrich_meal_responses(
    meals: list[Meal],
    db: Session,
) -> list[MealResponse]:
    """Enrich a collection with two batch queries instead of per-row lookups."""
    if not meals:
        return []
    category_uuids = {meal.categorie_uuid for meal in meals}
    user_uuids = {meal.utilisateur_uuid for meal in meals}
    categories = {
        category.uuid: category
        for category in db.execute(
            select(MealCategory).where(MealCategory.uuid.in_(category_uuids))
        )
        .scalars()
        .all()
    }
    users = {
        user.uuid: user
        for user in db.execute(select(User).where(User.uuid.in_(user_uuids))).scalars().all()
    }
    return [
        MealResponse(
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
            categorie_nom=(
                categories[meal.categorie_uuid].nom if meal.categorie_uuid in categories else None
            ),
            nom=(users[meal.utilisateur_uuid].nom if meal.utilisateur_uuid in users else None),
            prenom=(
                users[meal.utilisateur_uuid].prenom if meal.utilisateur_uuid in users else None
            ),
        )
        for meal in meals
    ]


@router.get(
    "/categories",
    response_model=SuccessResponse[list[MealCategoryResponse]],
)
async def list_categories(
    db: Session = Depends(get_db),
    _kiosk_identity: Admin | None = Depends(require_kiosk_access),
) -> SuccessResponse[list[MealCategoryResponse]]:
    """List all meal categories for an authorized kiosk.

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
    _kiosk_identity: Admin | None = Depends(require_kiosk_access),
) -> SuccessResponse[MealRegisterResponse]:
    """Confirm a meal after successful face or QR identification."""
    meal = _service.register_by_identification(
        db,
        body.identification_token,
        body.categorie_uuid,
    )

    cat_stmt = select(MealCategory).where(MealCategory.uuid == meal.categorie_uuid)
    category = db.execute(cat_stmt).scalar_one_or_none()
    receipt = _receipt_service.get_by_meal(db, meal.uuid)

    return SuccessResponse(
        data=MealRegisterResponse(
            id=meal.id,
            uuid=meal.uuid,
            created_at=meal.created_at,
            updated_at=meal.updated_at,
            categorie_uuid=meal.categorie_uuid,
            type_identification=meal.type_identification,
            date_repas=meal.date_repas,
            heure_repas=meal.heure_repas,
            categorie_nom=category.nom if category else None,
            receipt=ReceiptResponse.model_validate(receipt).model_copy(
                update={"qr_token": make_receipt_token(receipt.uuid, receipt.numero)}
            ),
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
    _admin: Admin = Depends(require_admin),
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
        data=_enrich_meal_responses(result.items, db),
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
    _admin: Admin = Depends(require_admin),
) -> SuccessResponse[dict[str, int]]:
    """Get meal statistics for a date range."""
    stats = _service.get_stats(db, date_from=date_from, date_to=date_to)
    return SuccessResponse(
        data={
            "total_meals": stats.total_meals,
            "total_employees": stats.total_employees,
            "total_interns": stats.total_interns,
            "total_visitors": stats.total_visitors,
            "face_registrations": stats.face_registrations,
            "qr_registrations": stats.qr_registrations,
        }
    )


@router.get(
    "/today",
    summary="Repas du jour",
    description="Retourne tous les repas enregistrés aujourd'hui.",
    response_model=SuccessResponse[list[MealResponse]],
)
async def get_today_meals(
    db: Session = Depends(get_db),
    _admin: Admin = Depends(require_admin),
) -> SuccessResponse[list[MealResponse]]:
    """Get all meals registered today."""
    meals = _service.get_today(db)
    return SuccessResponse(
        data=_enrich_meal_responses(meals, db),
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
    _admin: Admin = Depends(require_admin),
) -> SuccessResponse[list[MealResponse]]:
    """Get all meals for a user (newest first)."""
    history = _service.get_history(db, user_uuid)
    return SuccessResponse(
        data=_enrich_meal_responses(history, db),
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
    _admin: Admin = Depends(require_admin),
) -> SuccessResponse[MealResponse]:
    """Get a single meal by UUID."""
    meal = _service.get(db, uuid)
    return SuccessResponse(data=_enrich_meal_response(meal, db))
