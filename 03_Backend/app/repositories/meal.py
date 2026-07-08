"""Meal repository."""

from datetime import date

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.meal import Meal
from app.models.user import User
from app.repositories.base import BaseRepository


class MealStats:
    """Statistics for a given date range."""

    def __init__(
        self,
        total_meals: int = 0,
        total_employees: int = 0,
        total_interns: int = 0,
        total_visitors: int = 0,
        face_registrations: int = 0,
        qr_registrations: int = 0,
    ) -> None:
        self.total_meals = total_meals
        self.total_employees = total_employees
        self.total_interns = total_interns
        self.total_visitors = total_visitors
        self.face_registrations = face_registrations
        self.qr_registrations = qr_registrations


class MealRepository(BaseRepository[Meal]):
    """CRUD operations for the repas table."""

    def __init__(self) -> None:
        super().__init__(Meal)

    def get_by_uuid(self, db: Session, uuid: str) -> Meal | None:
        stmt = select(Meal).where(Meal.uuid == uuid)
        return db.execute(stmt).scalar_one_or_none()

    def get_today_count_by_user(
        self, db: Session, user_uuid: str, meal_date: date
    ) -> int:
        stmt = (
            select(func.count())
            .select_from(Meal)
            .where(Meal.utilisateur_uuid == user_uuid, Meal.date_repas == meal_date)
        )
        return db.execute(stmt).scalar() or 0

    def get_today(self, db: Session, meal_date: date) -> list[Meal]:
        stmt = (
            select(Meal)
            .where(Meal.date_repas == meal_date)
            .order_by(Meal.heure_repas.desc())
        )
        return list(db.execute(stmt).scalars().all())

    def get_history_by_user(
        self, db: Session, user_uuid: str, limit: int | None = None
    ) -> list[Meal]:
        stmt = (
            select(Meal)
            .where(Meal.utilisateur_uuid == user_uuid)
            .order_by(Meal.date_repas.desc(), Meal.heure_repas.desc())
        )
        if limit is not None:
            stmt = stmt.limit(limit)
        return list(db.execute(stmt).scalars().all())

    def search_paginated(
        self,
        db: Session,
        *,
        search: str | None = None,
        sort: str | None = None,
        order: str = "asc",
        page: int = 1,
        page_size: int = 20,
        date_from: date | None = None,
        date_to: date | None = None,
        categorie_uuid: str | None = None,
        type_identification: str | None = None,
        user_type: str | None = None,
    ) -> tuple[list[Meal], int]:
        base_stmt = select(Meal)

        if date_from:
            base_stmt = base_stmt.where(Meal.date_repas >= date_from)
        if date_to:
            base_stmt = base_stmt.where(Meal.date_repas <= date_to)
        if categorie_uuid:
            base_stmt = base_stmt.where(Meal.categorie_uuid == categorie_uuid)
        if type_identification:
            base_stmt = base_stmt.where(Meal.type_identification == type_identification)

        if search or user_type:
            base_stmt = base_stmt.join(User, Meal.utilisateur_uuid == User.uuid)
            if search:
                pattern = f"%{search}%"
                base_stmt = base_stmt.where(
                    User.nom.ilike(pattern)
                    | User.prenom.ilike(pattern)
                    | User.email.ilike(pattern)
                    | Meal.utilisateur_uuid.ilike(pattern)
                )
            if user_type:
                base_stmt = base_stmt.where(User.type == user_type)

        count_stmt = select(func.count()).select_from(base_stmt.subquery())
        total = db.execute(count_stmt).scalar() or 0

        if sort and hasattr(Meal, sort):
            sort_col = getattr(Meal, sort)
            base_stmt = base_stmt.order_by(
                sort_col.asc() if order == "asc" else sort_col.desc()
            )
        else:
            base_stmt = base_stmt.order_by(Meal.id.desc())

        offset = (page - 1) * page_size
        base_stmt = base_stmt.offset(offset).limit(page_size)

        items = list(db.execute(base_stmt).scalars().all())
        return items, total

    def get_stats(
        self,
        db: Session,
        *,
        date_from: date | None = None,
        date_to: date | None = None,
    ) -> MealStats:
        stmt = select(Meal)
        if date_from:
            stmt = stmt.where(Meal.date_repas >= date_from)
        if date_to:
            stmt = stmt.where(Meal.date_repas <= date_to)

        all_meals = list(db.execute(stmt).scalars().all())

        total_meals = len(all_meals)
        face_count = sum(1 for m in all_meals if m.type_identification == "FACE")
        qr_count = sum(1 for m in all_meals if m.type_identification == "QR")

        user_uuids = {m.utilisateur_uuid for m in all_meals}
        if not user_uuids:
            return MealStats()

        user_stmt = select(User).where(User.uuid.in_(user_uuids))
        users = list(db.execute(user_stmt).scalars().all())

        employees = sum(1 for u in users if str(u.type) == "EMPLOYE")
        interns = sum(1 for u in users if str(u.type) == "STAGIAIRE")
        visitors = sum(1 for u in users if str(u.type) == "VISITEUR")

        return MealStats(
            total_meals=total_meals,
            total_employees=employees,
            total_interns=interns,
            total_visitors=visitors,
            face_registrations=face_count,
            qr_registrations=qr_count,
        )
