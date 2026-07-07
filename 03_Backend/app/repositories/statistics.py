"""Statistics aggregation repository."""

from collections import Counter
from datetime import date, datetime, timedelta

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.meal import Meal
from app.models.meal_category import MealCategory
from app.models.qr_code import QrCode
from app.models.user import User
from app.schemas.statistics import (
    DashboardStatsResponse,
    MealCountByDate,
    MealDistributionItem,
    PeakHourItem,
    RecentRegistrationItem,
    RegistrationMethodItem,
    UserTypeDistributionItem,
)


class DashboardStats:
    """Aggregated statistics for the admin dashboard."""

    def __init__(self, db: Session, today: date) -> None:
        self._db = db
        self._today = today

    def compute(self) -> DashboardStatsResponse:
        today = self._today
        week_start = today - timedelta(days=today.weekday())
        month_start = today.replace(day=1)

        return DashboardStatsResponse(
            overview=self._overview(today, week_start, month_start),
            meals_per_day=self._meals_per_day(week_start, today),
            meal_distribution=self._meal_distribution(today, month_start),
            user_type_distribution=self._user_type_distribution(),
            registration_methods=self._registration_methods(today, month_start),
            peak_hours=self._peak_hours(month_start, today),
            recent_registrations=self._recent_registrations(),
        )

    # ------------------------------------------------------------------
    # Overview
    # ------------------------------------------------------------------

    def _overview(
        self, today: date, week_start: date, month_start: date
    ) -> dict:
        meals_today = self._count_meals(today, today)
        meals_week = self._count_meals(week_start, today)
        meals_month = self._count_meals(month_start, today)

        qr_today = self._count_meals_by_method(today, today, "QR")
        face_today = self._count_meals_by_method(today, today, "FACE")

        employees = self._count_users("EMPLOYE")
        interns = self._count_users("STAGIAIRE")
        visitors = self._count_users("VISITEUR")

        active_qr, expired_qr = self._qr_code_stats()

        return {
            "meals_today": meals_today,
            "meals_this_week": meals_week,
            "meals_this_month": meals_month,
            "employees": employees,
            "interns": interns,
            "visitors": visitors,
            "qr_registrations_today": qr_today,
            "face_registrations_today": face_today,
            "active_qr_codes": active_qr,
            "expired_qr_codes": expired_qr,
        }

    def _count_meals(self, date_from: date, date_to: date) -> int:
        stmt = select(func.count()).select_from(Meal).where(
            Meal.date_repas >= date_from, Meal.date_repas <= date_to
        )
        return self._db.execute(stmt).scalar() or 0

    def _count_meals_by_method(
        self, date_from: date, date_to: date, method: str
    ) -> int:
        stmt = (
            select(func.count())
            .select_from(Meal)
            .where(
                Meal.date_repas >= date_from,
                Meal.date_repas <= date_to,
                Meal.type_identification == method,
            )
        )
        return self._db.execute(stmt).scalar() or 0

    def _count_users(self, user_type: str) -> int:
        stmt = (
            select(func.count())
            .select_from(User)
            .where(User.type == user_type, User.statut == "ACTIF")
        )
        return self._db.execute(stmt).scalar() or 0

    def _qr_code_stats(self) -> tuple[int, int]:
        now = datetime.utcnow()
        total = select(func.count()).select_from(QrCode)
        active = self._db.execute(
            total.where(QrCode.statut == "ACTIF", QrCode.date_expiration > now)
        ).scalar() or 0
        expired = self._db.execute(
            total.where(
                or_(QrCode.statut == "EXPIRE", QrCode.date_expiration <= now)
            )
        ).scalar() or 0
        return active, expired

    # ------------------------------------------------------------------
    # Meals per day (line chart)
    # ------------------------------------------------------------------

    def _meals_per_day(self, date_from: date, date_to: date) -> list[MealCountByDate]:
        stmt = (
            select(Meal.date_repas, func.count().label("count"))
            .where(Meal.date_repas >= date_from, Meal.date_repas <= date_to)
            .group_by(Meal.date_repas)
            .order_by(Meal.date_repas)
        )
        return [
            MealCountByDate(date=str(row.date_repas), count=row.count)
            for row in self._db.execute(stmt).all()
        ]

    # ------------------------------------------------------------------
    # Meal distribution by category (donut chart)
    # ------------------------------------------------------------------

    def _meal_distribution(
        self, date_from: date, date_to: date
    ) -> list[MealDistributionItem]:
        stmt = (
            select(Meal.categorie_uuid, func.count().label("count"))
            .where(Meal.date_repas >= date_from, Meal.date_repas <= date_to)
            .group_by(Meal.categorie_uuid)
        )
        counts = {row.categorie_uuid: row.count for row in self._db.execute(stmt).all()}

        cat_stmt = select(MealCategory)
        categories = self._db.execute(cat_stmt).scalars().all()

        return [
            MealDistributionItem(
                name=cat.nom,
                count=counts.get(cat.uuid, 0),
            )
            for cat in categories
        ]

    # ------------------------------------------------------------------
    # User type distribution
    # ------------------------------------------------------------------

    def _user_type_distribution(self) -> list[UserTypeDistributionItem]:
        stmt = (
            select(User.type, func.count().label("count"))
            .where(User.statut == "ACTIF")
            .group_by(User.type)
        )
        return [
            UserTypeDistributionItem(type=row.type, count=row.count)
            for row in self._db.execute(stmt).all()
        ]

    # ------------------------------------------------------------------
    # Registration methods
    # ------------------------------------------------------------------

    def _registration_methods(
        self, date_from: date, date_to: date
    ) -> list[RegistrationMethodItem]:
        stmt = (
            select(Meal.type_identification, func.count().label("count"))
            .where(Meal.date_repas >= date_from, Meal.date_repas <= date_to)
            .group_by(Meal.type_identification)
        )
        return [
            RegistrationMethodItem(method=row.type_identification, count=row.count)
            for row in self._db.execute(stmt).all()
        ]

    # ------------------------------------------------------------------
    # Peak hours (bar chart)
    # ------------------------------------------------------------------

    def _peak_hours(self, date_from: date, date_to: date) -> list[PeakHourItem]:
        stmt = (
            select(
                func.extract("hour", Meal.heure_repas).label("hour"),
                func.count().label("count"),
            )
            .where(Meal.date_repas >= date_from, Meal.date_repas <= date_to)
            .group_by(func.extract("hour", Meal.heure_repas))
            .order_by("hour")
        )
        return [
            PeakHourItem(hour=int(row.hour), count=row.count)
            for row in self._db.execute(stmt).all()
        ]

    # ------------------------------------------------------------------
    # Recent registrations
    # ------------------------------------------------------------------

    def _recent_registrations(self) -> list[RecentRegistrationItem]:
        stmt = (
            select(
                Meal.uuid,
                Meal.utilisateur_uuid,
                Meal.type_identification,
                Meal.date_repas,
                Meal.heure_repas,
                User.nom,
                User.prenom,
                Meal.categorie_uuid,
            )
            .join(User, Meal.utilisateur_uuid == User.uuid)
            .order_by(Meal.heure_repas.desc())
            .limit(10)
        )
        items: list[RecentRegistrationItem] = []
        for row in self._db.execute(stmt).all():
            cat_stmt = select(MealCategory.nom).where(
                MealCategory.uuid == row.categorie_uuid
            )
            cat_name = self._db.execute(cat_stmt).scalar()
            items.append(
                RecentRegistrationItem(
                    uuid=row.uuid,
                    utilisateur_uuid=row.utilisateur_uuid,
                    nom=row.nom,
                    prenom=row.prenom,
                    type_identification=row.type_identification,
                    date_repas=str(row.date_repas),
                    heure_repas=row.heure_repas.isoformat(),
                    categorie_nom=cat_name,
                )
            )
        return items
