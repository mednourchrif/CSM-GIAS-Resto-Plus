"""Receipt persistence and administration filtering."""

from datetime import date

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.receipt import Receipt
from app.repositories.base import BaseRepository


class ReceiptRepository(BaseRepository[Receipt]):
    def __init__(self) -> None:
        super().__init__(Receipt)

    def get_by_meal(self, db: Session, meal_uuid: str) -> Receipt | None:
        return db.execute(
            select(Receipt).where(Receipt.repas_uuid == meal_uuid)
        ).scalar_one_or_none()

    def search_paginated(
        self,
        db: Session,
        *,
        search: str | None = None,
        date_from: date | None = None,
        date_to: date | None = None,
        category: str | None = None,
        user_type: str | None = None,
        identification_type: str | None = None,
        page: int = 1,
        page_size: int = 20,
    ) -> tuple[list[Receipt], int]:
        stmt = select(Receipt)
        if search:
            pattern = f"%{search}%"
            stmt = stmt.where(
                or_(
                    Receipt.numero.ilike(pattern),
                    Receipt.nom.ilike(pattern),
                    Receipt.prenom.ilike(pattern),
                    Receipt.matricule.ilike(pattern),
                )
            )
        if date_from:
            stmt = stmt.where(Receipt.date_repas >= date_from)
        if date_to:
            stmt = stmt.where(Receipt.date_repas <= date_to)
        if category:
            stmt = stmt.where(Receipt.categorie_nom == category)
        if user_type:
            stmt = stmt.where(Receipt.type_utilisateur == user_type)
        if identification_type:
            stmt = stmt.where(Receipt.type_identification == identification_type)

        total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar() or 0
        items = list(
            db.execute(
                stmt.order_by(Receipt.heure_repas.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
            )
            .scalars()
            .all()
        )
        return items, total
