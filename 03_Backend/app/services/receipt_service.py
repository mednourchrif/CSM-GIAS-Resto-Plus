"""Receipt query and print-audit behavior."""

from datetime import UTC, datetime

from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundException
from app.models.receipt import Receipt
from app.repositories.receipt import ReceiptRepository
from app.schemas.pagination import PaginatedResult
from app.schemas.receipt import ReceiptFilterParams


class ReceiptService:
    def __init__(self, repository: ReceiptRepository | None = None) -> None:
        self._repository = repository or ReceiptRepository()

    def get(self, db: Session, uuid: str) -> Receipt:
        receipt = self._repository.get_by_uuid(db, uuid)
        if receipt is None:
            raise NotFoundException(message=f"Recu {uuid} introuvable.")
        return receipt

    def get_by_meal(self, db: Session, meal_uuid: str) -> Receipt:
        receipt = self._repository.get_by_meal(db, meal_uuid)
        if receipt is None:
            raise NotFoundException(message=f"Recu du repas {meal_uuid} introuvable.")
        return receipt

    def list(self, db: Session, params: ReceiptFilterParams) -> PaginatedResult[Receipt]:
        items, total = self._repository.search_paginated(
            db,
            search=params.search,
            date_from=params.date_from,
            date_to=params.date_to,
            category=params.category,
            user_type=params.user_type,
            identification_type=params.identification_type,
            page=params.page,
            page_size=params.page_size,
        )
        return PaginatedResult(
            items=items,
            total=total,
            page=params.page,
            page_size=params.page_size,
            total_pages=max(1, (total + params.page_size - 1) // params.page_size),
        )

    def record_print(self, db: Session, uuid: str) -> Receipt:
        receipt = self.get(db, uuid)
        receipt.nombre_impressions += 1
        receipt.derniere_impression = datetime.now(UTC)
        db.flush()
        return receipt
