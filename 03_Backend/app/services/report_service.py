"""Report service — aggregated restaurant activity reports."""

from datetime import date, datetime, timezone
from typing import Any

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.meal import Meal
from app.models.meal_category import MealCategory
from app.models.user import User
from app.schemas.reports import (
    ReportDistributionItem,
    ReportFilterParams,
    ReportOverview,
    ReportPeakHourItem,
    ReportResponse,
    ReportTimeSeriesItem,
)


class ReportService:
    """Aggregated restaurant activity report generator.

    Queries the ``Meal`` (repas) table with optional filters and groups
    results at the requested granularity.
    """

    def __init__(self, db: Session, params: ReportFilterParams) -> None:
        self._db = db
        self._params = params

    def generate(self) -> ReportResponse:
        params = self._params

        overview = self._compute_overview()
        meals_per_day = self._meals_by_granularity()
        meals_by_hour = self._peak_hours()
        meals_by_category = self._meal_distribution()
        registration_methods = self._registration_methods()
        people_by_type = self._people_by_type()

        period_label = self._period_label()
        date_from = str(params.date_from) if params.date_from else ""
        date_to = str(params.date_to) if params.date_to else ""
        generated_at = datetime.now(timezone.utc).isoformat()

        return ReportResponse(
            overview=overview,
            meals_per_day=meals_per_day,
            meals_by_hour=meals_by_hour,
            meals_by_category=meals_by_category,
            registration_methods=registration_methods,
            people_by_type=people_by_type,
            period_label=period_label,
            date_from=date_from,
            date_to=date_to,
            generated_at=generated_at,
        )

    # ------------------------------------------------------------------
    # Filter helpers
    # ------------------------------------------------------------------

    def _apply_filters(self, stmt: Any) -> Any:
        params = self._params
        if params.date_from:
            stmt = stmt.where(Meal.date_repas >= params.date_from)
        if params.date_to:
            stmt = stmt.where(Meal.date_repas <= params.date_to)
        if params.type_identification:
            stmt = stmt.where(Meal.type_identification == params.type_identification)
        if params.categorie_uuid:
            stmt = stmt.where(Meal.categorie_uuid == params.categorie_uuid)
        if params.user_type:
            stmt = stmt.where(User.type == params.user_type)
        return stmt

    def _base_count_query(self) -> Any:
        stmt = select(func.count()).select_from(Meal)
        if self._params.user_type:
            stmt = stmt.join(User, Meal.utilisateur_uuid == User.uuid)
        stmt = self._apply_filters(stmt)
        return stmt

    # ------------------------------------------------------------------
    # Overview
    # ------------------------------------------------------------------

    def _compute_overview(self) -> ReportOverview:
        total_meals = self._db.execute(self._base_count_query()).scalar() or 0

        if self._params.user_type:
            total_employees = total_meals if self._params.user_type == "EMPLOYE" else 0
            total_interns = total_meals if self._params.user_type == "STAGIAIRE" else 0
            total_visitors = total_meals if self._params.user_type == "VISITEUR" else 0
        else:
            total_employees = self._count_by_user_type("EMPLOYE")
            total_interns = self._count_by_user_type("STAGIAIRE")
            total_visitors = self._count_by_user_type("VISITEUR")

        qr_registrations = self._count_by_method("QR")
        face_registrations = self._count_by_method("FACE")

        peak_hour_str, _ = self._find_peak_hour()
        most_selected_meal = self._find_most_selected_meal()

        return ReportOverview(
            total_meals=total_meals,
            total_employees=total_employees,
            total_interns=total_interns,
            total_visitors=total_visitors,
            qr_registrations=qr_registrations,
            face_registrations=face_registrations,
            failed_recognitions=0,
            failed_qr_scans=0,
            average_processing_time=None,
            peak_hour=peak_hour_str,
            most_selected_meal=most_selected_meal,
        )

    def _count_by_user_type(self, user_type: str) -> int:
        stmt = (
            select(func.count())
            .select_from(Meal)
            .join(User, Meal.utilisateur_uuid == User.uuid)
            .where(User.type == user_type)
        )
        stmt = self._apply_filters(stmt)
        return self._db.execute(stmt).scalar() or 0

    def _count_by_method(self, method: str) -> int:
        stmt = self._base_count_query().where(Meal.type_identification == method)
        return self._db.execute(stmt).scalar() or 0

    def _find_peak_hour(self) -> tuple[str | None, int]:
        stmt = (
            select(
                func.extract("hour", Meal.heure_repas).label("hour"),
                func.count().label("count"),
            )
            .select_from(Meal)
        )
        if self._params.user_type:
            stmt = stmt.join(User, Meal.utilisateur_uuid == User.uuid)
        stmt = self._apply_filters(stmt)
        stmt = stmt.group_by(func.extract("hour", Meal.heure_repas)).order_by(func.count().desc())
        row = self._db.execute(stmt).first()
        if row:
            return f"{int(row.hour):02d}:00", row.count
        return None, 0

    def _find_most_selected_meal(self) -> str | None:
        stmt = (
            select(Meal.categorie_uuid, func.count().label("count"))
            .select_from(Meal)
        )
        if self._params.user_type:
            stmt = stmt.join(User, Meal.utilisateur_uuid == User.uuid)
        stmt = self._apply_filters(stmt)
        stmt = stmt.group_by(Meal.categorie_uuid).order_by(func.count().desc())
        row = self._db.execute(stmt).first()
        if row:
            cat_stmt = select(MealCategory.nom).where(MealCategory.uuid == row.categorie_uuid)
            cat_name = self._db.execute(cat_stmt).scalar()
            return cat_name or row.categorie_uuid
        return None

    # ------------------------------------------------------------------
    # Time series by granularity
    # ------------------------------------------------------------------

    def _meals_by_granularity(self) -> list[ReportTimeSeriesItem]:
        if self._params.granularity == "weekly":
            return self._meals_weekly()
        elif self._params.granularity == "monthly":
            return self._meals_monthly()
        return self._meals_daily()

    def _meals_daily(self) -> list[ReportTimeSeriesItem]:
        stmt = (
            select(Meal.date_repas, func.count().label("count"))
            .select_from(Meal)
        )
        if self._params.user_type:
            stmt = stmt.join(User, Meal.utilisateur_uuid == User.uuid)
        stmt = self._apply_filters(stmt)
        stmt = stmt.group_by(Meal.date_repas).order_by(Meal.date_repas)
        return [
            ReportTimeSeriesItem(period=str(row.date_repas), count=row.count)
            for row in self._db.execute(stmt).all()
        ]

    def _meals_weekly(self) -> list[ReportTimeSeriesItem]:
        stmt = (
            select(
                func.year(Meal.date_repas).label("year"),
                func.week(Meal.date_repas).label("week"),
                func.count().label("count"),
            )
            .select_from(Meal)
        )
        if self._params.user_type:
            stmt = stmt.join(User, Meal.utilisateur_uuid == User.uuid)
        stmt = self._apply_filters(stmt)
        stmt = stmt.group_by(
            func.year(Meal.date_repas), func.week(Meal.date_repas)
        ).order_by(func.year(Meal.date_repas), func.week(Meal.date_repas))
        return [
            ReportTimeSeriesItem(
                period=f"{row.year}-W{int(row.week):02d}", count=row.count
            )
            for row in self._db.execute(stmt).all()
        ]

    def _meals_monthly(self) -> list[ReportTimeSeriesItem]:
        stmt = (
            select(
                func.year(Meal.date_repas).label("year"),
                func.month(Meal.date_repas).label("month"),
                func.count().label("count"),
            )
            .select_from(Meal)
        )
        if self._params.user_type:
            stmt = stmt.join(User, Meal.utilisateur_uuid == User.uuid)
        stmt = self._apply_filters(stmt)
        stmt = stmt.group_by(
            func.year(Meal.date_repas), func.month(Meal.date_repas)
        ).order_by(func.year(Meal.date_repas), func.month(Meal.date_repas))
        return [
            ReportTimeSeriesItem(
                period=f"{row.year}-{int(row.month):02d}", count=row.count
            )
            for row in self._db.execute(stmt).all()
        ]

    # ------------------------------------------------------------------
    # Peak hours
    # ------------------------------------------------------------------

    def _peak_hours(self) -> list[ReportPeakHourItem]:
        stmt = (
            select(
                func.extract("hour", Meal.heure_repas).label("hour"),
                func.count().label("count"),
            )
            .select_from(Meal)
        )
        if self._params.user_type:
            stmt = stmt.join(User, Meal.utilisateur_uuid == User.uuid)
        stmt = self._apply_filters(stmt)
        stmt = stmt.group_by(func.extract("hour", Meal.heure_repas)).order_by("hour")
        return [
            ReportPeakHourItem(hour=int(row.hour), count=row.count)
            for row in self._db.execute(stmt).all()
        ]

    # ------------------------------------------------------------------
    # Meal distribution by category
    # ------------------------------------------------------------------

    def _meal_distribution(self) -> list[ReportDistributionItem]:
        stmt = (
            select(Meal.categorie_uuid, func.count().label("count"))
            .select_from(Meal)
        )
        if self._params.user_type:
            stmt = stmt.join(User, Meal.utilisateur_uuid == User.uuid)
        stmt = self._apply_filters(stmt)
        stmt = stmt.group_by(Meal.categorie_uuid)

        counts = {row.categorie_uuid: row.count for row in self._db.execute(stmt).all()}

        cat_stmt = select(MealCategory)
        categories = self._db.execute(cat_stmt).scalars().all()

        return [
            ReportDistributionItem(label=cat.nom, count=counts.get(cat.uuid, 0))
            for cat in categories
        ]

    # ------------------------------------------------------------------
    # Registration methods
    # ------------------------------------------------------------------

    def _registration_methods(self) -> list[ReportDistributionItem]:
        stmt = (
            select(Meal.type_identification, func.count().label("count"))
            .select_from(Meal)
        )
        if self._params.user_type:
            stmt = stmt.join(User, Meal.utilisateur_uuid == User.uuid)
        stmt = self._apply_filters(stmt)
        stmt = stmt.group_by(Meal.type_identification)
        return [
            ReportDistributionItem(label=row.type_identification, count=row.count)
            for row in self._db.execute(stmt).all()
        ]

    # ------------------------------------------------------------------
    # People by type
    # ------------------------------------------------------------------

    def _people_by_type(self) -> list[ReportDistributionItem]:
        stmt = (
            select(User.type, func.count().label("count"))
            .select_from(Meal)
            .join(User, Meal.utilisateur_uuid == User.uuid)
        )
        stmt = self._apply_filters(stmt)
        stmt = stmt.group_by(User.type)
        return [
            ReportDistributionItem(label=row.type, count=row.count)
            for row in self._db.execute(stmt).all()
        ]

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _period_label(self) -> str:
        params = self._params
        if params.date_from and params.date_to:
            return f"{params.date_from} to {params.date_to}"
        elif params.date_from:
            return f"From {params.date_from}"
        elif params.date_to:
            return f"Until {params.date_to}"
        return "All time"
