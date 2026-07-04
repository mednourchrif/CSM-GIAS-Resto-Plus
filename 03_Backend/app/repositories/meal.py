"""Meal repository."""

from datetime import date

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.meal import Meal
from app.repositories.base import BaseRepository


class MealRepository(BaseRepository[Meal]):
    """CRUD operations for the repas table."""

    def __init__(self) -> None:
        super().__init__(Meal)

    def get_by_uuid(self, db: Session, uuid: str) -> Meal | None:
        """Fetch a meal by its UUID."""
        stmt = select(Meal).where(Meal.uuid == uuid)
        return db.execute(stmt).scalar_one_or_none()

    def get_today_count_by_user(self, db: Session, user_uuid: str, meal_date: date) -> int:
        """Return the number of meals a user has registered on a given date."""
        stmt = (
            select(func.count())
            .select_from(Meal)
            .where(
                Meal.utilisateur_uuid == user_uuid,
                Meal.date_repas == meal_date,
            )
        )
        return db.execute(stmt).scalar() or 0

    def get_today(self, db: Session, meal_date: date) -> list[Meal]:
        """Return all meals registered on a given date (newest first)."""
        stmt = (
            select(Meal)
            .where(Meal.date_repas == meal_date)
            .order_by(Meal.heure_repas.desc())
        )
        return list(db.execute(stmt).scalars().all())

    def get_history_by_user(self, db: Session, user_uuid: str) -> list[Meal]:
        """Return all meals for a user (newest first)."""
        stmt = (
            select(Meal)
            .where(Meal.utilisateur_uuid == user_uuid)
            .order_by(Meal.date_repas.desc(), Meal.heure_repas.desc())
        )
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
    ) -> tuple[list[Meal], int]:
        """Search meals with pagination, sorting, and optional search."""
        base_stmt = select(Meal)

        if search:
            pattern = f"%{search}%"
            base_stmt = base_stmt.where(Meal.utilisateur_uuid.ilike(pattern))

        count_stmt = select(func.count()).select_from(base_stmt.subquery())
        total = db.execute(count_stmt).scalar() or 0

        if sort and hasattr(Meal, sort):
            sort_col = getattr(Meal, sort)
            base_stmt = base_stmt.order_by(sort_col.asc() if order == "asc" else sort_col.desc())
        else:
            base_stmt = base_stmt.order_by(Meal.id.desc())

        offset = (page - 1) * page_size
        base_stmt = base_stmt.offset(offset).limit(page_size)

        items = list(db.execute(base_stmt).scalars().all())
        return items, total
