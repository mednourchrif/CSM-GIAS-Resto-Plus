"""Meal service — business logic for meal registration.

Design
------
The service is **identification-method agnostic** by design.  Currently,
meals are registered via QR-code validation (``register_by_qr``).  In
the future, the Face Recognition module will identify the employee and
call ``register_by_user_uuid`` directly — no changes to this service
are needed.

Single source of truth
----------------------
Every meal registration — regardless of how the person is identified —
passes through this service.  This ensures that business rules (opening
hours, duplicate prevention, category validation) are enforced exactly
once and never duplicated in future modules.
"""

from datetime import UTC, date, datetime, time

from loguru import logger
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.exceptions import BusinessException, ConflictException, NotFoundException
from app.models.admin import Admin
from app.models.meal import Meal
from app.models.meal_category import MealCategory
from app.repositories.meal import MealRepository
from app.repositories.user import UserRepository
from app.repositories.meal import MealStats
from app.schemas.pagination import PaginatedResult, PaginationParams
from app.services.audit_service import AuditLogService
from app.services.qr_code_service import QrCodeService
from app.utils.date_utils import today_utc

_audit_service = AuditLogService()

# ---------------------------------------------------------------------------
# Business constants
# ---------------------------------------------------------------------------

RESTAURANT_OPEN: time = time(12, 30)
RESTAURANT_CLOSE: time = time(22, 0)
CASABLANCA_UTC_OFFSET: int = 1  # Africa/Casablanca standard time is UTC+1


def is_restaurant_open(now: datetime | None = None) -> bool:
    """Check whether the restaurant is currently open.

    Opening hours: 12:30–00:00 Africa/Casablanca local time (UTC+1).
    """
    ref = now or datetime.now(UTC)
    if ref.tzinfo is not None:
        ref = ref.astimezone(UTC)
    local_hour = (ref.hour + CASABLANCA_UTC_OFFSET) % 24
    local_min = ref.minute
    minutes_since_midnight = local_hour * 60 + local_min
    open_minutes = RESTAURANT_OPEN.hour * 60 + RESTAURANT_OPEN.minute
    close_minutes = RESTAURANT_CLOSE.hour * 60 + RESTAURANT_CLOSE.minute
    return open_minutes <= minutes_since_midnight < close_minutes


# ---------------------------------------------------------------------------
# MealCategory seed data
# ---------------------------------------------------------------------------

CATEGORIES: list[dict[str, str]] = [
    {"nom": "Plat", "description": "Plat principal du jour"},
    {"nom": "Pizza", "description": "Pizza du jour"},
    {"nom": "Sandwich", "description": "Sandwich du jour"},
]


class MealService:
    """Business logic for meal registration.

    Currently supports QR-code-based registration.
    Future Face Recognition will call ``register_by_user_uuid()``.
    """

    def __init__(
        self,
        meal_repo: MealRepository | None = None,
        qr_service: QrCodeService | None = None,
        user_repo: UserRepository | None = None,
    ) -> None:
        self._meal_repo = meal_repo or MealRepository()
        self._qr_service = qr_service or QrCodeService()
        self._user_repo = user_repo or UserRepository()

    # ==================================================================
    # Registration methods
    # ==================================================================

    def register_by_qr(
        self,
        db: Session,
        token: str,
        categorie_uuid: str,
        admin: Admin | None = None,
        _now: datetime | None = None,
    ) -> Meal:
        """Register a meal using QR-code identification.

        :param token: Raw QR token to validate.
        :param categorie_uuid: UUID of the meal category.
        :param admin: The admin/receptionist who registered the meal (optional).
        :returns: The created ``Meal`` instance.
        :raises BusinessException: If the restaurant is closed, QR is invalid,
            the user already ate today, or the category is unknown.
        """
        validation = self._qr_service.validate(db, token)

        if validation.statut.name != "VALID":
            raise BusinessException(
                message=f"QR code invalide : {validation.message or validation.statut.value}",
                details={"statut": validation.statut.value},
            )

        if validation.proprietaire_uuid is None:
            raise BusinessException(message="Impossible d'identifier le propriétaire du QR code.")

        return self._register(
            db=db,
            user_uuid=validation.proprietaire_uuid,
            categorie_uuid=categorie_uuid,
            qr_uuid=validation.qr_uuid,
            type_identification="QR",
            admin=admin,
            _now=_now,
        )

    def register_by_user_uuid(
        self,
        db: Session,
        user_uuid: str,
        categorie_uuid: str,
        type_identification: str = "FACE",
        admin: Admin | None = None,
        _now: datetime | None = None,
    ) -> Meal:
        """Register a meal for a user identified directly by UUID.

        This method is designed for the **Face Recognition** module:
        once the module identifies the employee, it calls this method
        with the employee's UUID — no QR token needed.

        :param user_uuid: UUID of the user (employee, intern, visitor).
        :param categorie_uuid: UUID of the meal category.
        :param type_identification: How the user was identified
            (default ``"FACE"``).
        :param admin: The admin/receptionist who registered the meal.
        """
        return self._register(
            db=db,
            user_uuid=user_uuid,
            categorie_uuid=categorie_uuid,
            qr_uuid=None,
            type_identification=type_identification,
            admin=admin,
            _now=_now,
        )

    def _register(
        self,
        db: Session,
        user_uuid: str,
        categorie_uuid: str,
        qr_uuid: str | None = None,
        type_identification: str = "QR",
        admin: Admin | None = None,
        _now: datetime | None = None,
    ) -> Meal:
        """Core registration logic — shared by QR and future Face identification.

        Validates in order:
        1. Restaurant is open.
        2. Category exists.
        3. User has not already eaten today.

        :param _now: Internal override for testing time-dependent logic.
        """
        now = _now or datetime.now(UTC)

        if not is_restaurant_open(now):
            raise BusinessException(
                message="Le restaurant est fermé. Service de 12h30 à 00h00.",
                details={"heure": now.strftime("%H:%M")},
            )

        category = self._get_category(db, categorie_uuid)
        today = now.date()

        existing = self._meal_repo.get_today_count_by_user(db, user_uuid, today)
        if existing > 0:
            raise ConflictException(
                message="Un repas a déjà été enregistré pour cette personne aujourd'hui.",
                details={"date": str(today)},
            )

        meal = self._meal_repo.create(
            db,
            utilisateur_uuid=user_uuid,
            qr_uuid=qr_uuid,
            categorie_uuid=categorie_uuid,
            type_identification=type_identification,
            date_repas=today,
            heure_repas=now,
            enregistre_par_uuid=admin.uuid if admin else None,
        )

        logger.info(
            "Meal registered",
            extra={
                "meal_uuid": meal.uuid,
                "user_uuid": user_uuid,
                "category": category.nom,
                "type": type_identification,
            },
        )

        user = self._user_repo.get_by_uuid(db, user_uuid)
        user_name = f"{user.prenom} {user.nom}" if user else user_uuid

        _audit_service.log_meal_registered(
            db,
            employee_uuid=user_uuid,
            employee_name=user_name,
            meal_type=category.nom if category else "",
            recognition_method=type_identification,
        )

        return meal

    # ==================================================================
    # Query methods
    # ==================================================================

    def get(self, db: Session, uuid: str) -> Meal:
        """Get a single meal by UUID."""
        meal = self._meal_repo.get_by_uuid(db, uuid)
        if meal is None:
            raise NotFoundException(message=f"Repas {uuid} introuvable.")
        return meal

    def get_today(self, db: Session) -> list[Meal]:
        """Get all meals registered today."""
        return self._meal_repo.get_today(db, today_utc())

    def get_history(self, db: Session, user_uuid: str) -> list[Meal]:
        """Get all meals for a user (newest first)."""
        user = self._user_repo.get_by_uuid(db, user_uuid)
        if user is None:
            raise NotFoundException(message=f"Utilisateur {user_uuid} introuvable.")
        return self._meal_repo.get_history_by_user(db, user_uuid)

    def get_list(
        self,
        db: Session,
        params: PaginationParams,
        *,
        date_from: date | None = None,
        date_to: date | None = None,
        categorie_uuid: str | None = None,
        type_identification: str | None = None,
        user_type: str | None = None,
    ) -> PaginatedResult[Meal]:
        """List meals with pagination, sorting, search, and filters."""
        items, total = self._meal_repo.search_paginated(
            db,
            search=params.search,
            sort=params.sort,
            order=params.order,
            page=params.page,
            page_size=params.page_size,
            date_from=date_from,
            date_to=date_to,
            categorie_uuid=categorie_uuid,
            type_identification=type_identification,
            user_type=user_type,
        )
        total_pages = max(1, (total + params.page_size - 1) // params.page_size)
        return PaginatedResult(
            items=items,
            total=total,
            page=params.page,
            page_size=params.page_size,
            total_pages=total_pages,
        )

    def get_stats(
        self,
        db: Session,
        *,
        date_from: date | None = None,
        date_to: date | None = None,
    ) -> MealStats:
        """Get meal statistics for a date range."""
        return self._meal_repo.get_stats(db, date_from=date_from, date_to=date_to)

    # ==================================================================
    # Category helpers
    # ==================================================================

    def _get_category(self, db: Session, categorie_uuid: str) -> MealCategory:
        """Load a meal category by UUID or raise."""
        stmt = select(MealCategory).where(MealCategory.uuid == categorie_uuid)
        category = db.execute(stmt).scalar_one_or_none()
        if category is None:
            raise NotFoundException(
                message=f"Catégorie de repas {categorie_uuid} introuvable.",
            )
        return category

    def get_categories(self, db: Session) -> list[MealCategory]:
        """Return all meal categories."""
        stmt = select(MealCategory).order_by(MealCategory.nom)
        return list(db.execute(stmt).scalars().all())

    @staticmethod
    def seed_categories(db: Session) -> None:
        """Seed the three static meal categories if they do not exist.

        Safe to call multiple times — skips existing categories.
        """
        for cat in CATEGORIES:
            stmt = select(MealCategory).where(MealCategory.nom == cat["nom"])
            existing = db.execute(stmt).scalar_one_or_none()
            if existing is None:
                db.add(MealCategory(nom=cat["nom"], description=cat["description"]))
        db.flush()
