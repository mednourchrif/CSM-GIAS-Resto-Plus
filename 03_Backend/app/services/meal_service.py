"""Meal service — business logic for meal registration.

Design
------
The service is **identification-method agnostic** by design. The kiosk-facing
path consumes a one-use grant issued by either QR or face identification.
Legacy direct QR/user entry points remain internal compatibility helpers and
are never exposed by the registration API.

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
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.exceptions import BusinessException, ConflictException, NotFoundException
from app.models.admin import Admin
from app.models.employee import Employee
from app.models.intern import Intern
from app.models.meal import Meal
from app.models.meal_category import MealCategory
from app.models.user import StatutUtilisateur, User
from app.models.visitor import Visitor
from app.repositories.meal import MealRepository, MealStats
from app.repositories.setting import SettingRepository
from app.repositories.user import UserRepository
from app.schemas.pagination import PaginatedResult, PaginationParams
from app.services.audit_service import AuditLogService
from app.services.identification_service import IdentificationService
from app.services.qr_code_service import QrCodeService
from app.utils.date_utils import to_business_timezone, today_local

_audit_service = AuditLogService()

# ---------------------------------------------------------------------------
# Business constants
# ---------------------------------------------------------------------------

RESTAURANT_OPEN: time = time(12, 30)
RESTAURANT_CLOSE: time = time(14, 0)


def is_restaurant_open(
    now: datetime | None = None,
    opening: time = RESTAURANT_OPEN,
    closing: time = RESTAURANT_CLOSE,
) -> bool:
    """Check whether the restaurant is currently open.

    Hours are interpreted in the configured restaurant timezone.
    """
    local_time = to_business_timezone(now).time().replace(tzinfo=None)
    return opening <= local_time < closing


# ---------------------------------------------------------------------------
# MealCategory seed data
# ---------------------------------------------------------------------------

CATEGORIES: list[dict[str, str]] = [
    {"nom": "Plat", "description": "Plat principal du jour"},
    {"nom": "Pizza", "description": "Pizza du jour"},
    {"nom": "Sandwich", "description": "Sandwich du jour"},
]


class MealService:
    """Business logic shared by grant, QR, and internal face workflows."""

    def __init__(
        self,
        meal_repo: MealRepository | None = None,
        qr_service: QrCodeService | None = None,
        user_repo: UserRepository | None = None,
        identification_service: IdentificationService | None = None,
        setting_repo: SettingRepository | None = None,
    ) -> None:
        self._meal_repo = meal_repo or MealRepository()
        self._qr_service = qr_service or QrCodeService()
        self._user_repo = user_repo or UserRepository()
        self._identification_service = identification_service or IdentificationService()
        self._setting_repo = setting_repo or SettingRepository()

    # ==================================================================
    # Registration methods
    # ==================================================================

    def ensure_no_meal_today(
        self,
        db: Session,
        user_uuid: str,
        _now: datetime | None = None,
    ) -> None:
        """Reject an identified person who already received today's meal.

        Identification endpoints call this before issuing a kiosk grant so
        the user gets immediate feedback instead of choosing a category
        first. Registration still repeats the check and the database unique
        constraint remains the final protection against concurrent requests.
        """
        meal_date = today_local(_now)
        if self._meal_repo.get_today_count_by_user(db, user_uuid, meal_date) > 0:
            raise ConflictException(
                message="Votre repas a déjà été enregistré aujourd'hui.",
                details={"date": str(meal_date), "reason": "MEAL_ALREADY_REGISTERED"},
            )

    def register_by_identification(
        self,
        db: Session,
        identification_token: str,
        categorie_uuid: str,
        _now: datetime | None = None,
    ) -> Meal:
        """Consume a one-use identification grant and register the meal."""
        with db.begin_nested():
            grant = self._identification_service.consume(
                db,
                identification_token,
            )
            return self._register(
                db=db,
                user_uuid=grant.utilisateur_uuid,
                categorie_uuid=categorie_uuid,
                qr_uuid=grant.qr_uuid,
                type_identification=grant.identification_type,
                _now=_now,
            )

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
        """Internal compatibility helper for an already-identified user.

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
        """Core registration logic shared by all identification methods.

        Validates in order:
        1. Restaurant is open.
        2. Category exists.
        3. User has not already eaten today.

        :param _now: Internal override for testing time-dependent logic.
        """
        now = _now or datetime.now(UTC)
        opening, closing = self._restaurant_hours(db)

        if not is_restaurant_open(now, opening, closing):
            raise BusinessException(
                message=(
                    "Le restaurant est fermé. "
                    f"Service de {opening.strftime('%H:%M')} "
                    f"a {closing.strftime('%H:%M')}."
                ),
                details={
                    "heure_locale": to_business_timezone(now).strftime("%H:%M"),
                    "ouverture": opening.strftime("%H:%M"),
                    "fermeture": closing.strftime("%H:%M"),
                },
            )

        category = self._get_category(db, categorie_uuid)
        today = today_local(now)
        user = self._get_eligible_user(
            db,
            user_uuid=user_uuid,
            identification_type=type_identification,
            meal_date=today,
        )

        self.ensure_no_meal_today(db, user_uuid, _now=now)

        try:
            with db.begin_nested():
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
        except IntegrityError as exc:
            raise ConflictException(
                message=("Un repas a déjà été enregistré pour cette personne aujourd'hui."),
                details={"date": str(today)},
            ) from exc

        logger.info("Meal registered")

        user_name = f"{user.prenom} {user.nom}"

        _audit_service.log_meal_registered(
            db,
            employee_uuid=user_uuid,
            employee_name=user_name,
            meal_type=category.nom if category else "",
            recognition_method=type_identification,
        )

        return meal

    def _restaurant_hours(self, db: Session) -> tuple[time, time]:
        """Read the configured service window, falling back to safe defaults."""
        opening_setting = self._setting_repo.get_by_key(db, "opening_hour")
        closing_setting = self._setting_repo.get_by_key(db, "closing_hour")
        try:
            opening = time.fromisoformat(
                opening_setting.value if opening_setting else RESTAURANT_OPEN.isoformat()
            )
            closing = time.fromisoformat(
                closing_setting.value if closing_setting else RESTAURANT_CLOSE.isoformat()
            )
        except ValueError:
            return RESTAURANT_OPEN, RESTAURANT_CLOSE
        if opening >= closing:
            return RESTAURANT_OPEN, RESTAURANT_CLOSE
        return opening, closing

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
        return self._meal_repo.get_today(db, today_local())

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

    def _get_eligible_user(
        self,
        db: Session,
        *,
        user_uuid: str,
        identification_type: str,
        meal_date: date,
    ) -> User:
        """Load a user and enforce status, date, and identification rules."""
        user = self._user_repo.get_by_uuid(db, user_uuid)
        if user is None or user.date_suppression is not None:
            raise NotFoundException(message="Utilisateur introuvable.")
        if user.statut != StatutUtilisateur.ACTIF:
            raise BusinessException(message="Ce compte n'est pas actif.")

        method = identification_type.upper()
        if method == "FACE":
            if not isinstance(user, Employee):
                raise BusinessException(
                    message="La reconnaissance faciale est réservée aux employés.",
                )
            return user

        if method != "QR":
            raise BusinessException(message="Méthode d'identification invalide.")

        if isinstance(user, Intern):
            if not user.date_debut_stage <= meal_date <= user.date_fin_stage:
                raise BusinessException(
                    message="Le stage n'est pas actif à cette date.",
                )
            return user

        if isinstance(user, Visitor):
            if user.date_visite != meal_date:
                raise BusinessException(
                    message="Le QR visiteur n'est valable que le jour de la visite.",
                )
            return user

        raise BusinessException(
            message="Ce type d'utilisateur ne peut pas s'identifier par QR code.",
        )

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
