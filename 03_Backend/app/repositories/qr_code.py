"""QR Code repository."""

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.qr_code import QrCode
from app.repositories.base import BaseRepository


class QrCodeRepository(BaseRepository[QrCode]):
    """CRUD operations for the qr_code table."""

    def __init__(self) -> None:
        super().__init__(QrCode)

    def get_by_hash(self, db: Session, qr_hash: str) -> QrCode | None:
        """Fetch a QR code by its SHA-256 hash."""
        stmt = select(QrCode).where(QrCode.qr_hash == qr_hash)
        return db.execute(stmt).scalar_one_or_none()

    def get_active_by_owner(self, db: Session, owner_uuid: str) -> QrCode | None:
        """Return the active QR code for an owner, if one exists."""
        stmt = (
            select(QrCode)
            .where(
                QrCode.proprietaire_uuid == owner_uuid,
                QrCode.statut == "ACTIF",
            )
            .order_by(QrCode.id.desc())
            .limit(1)
        )
        return db.execute(stmt).scalar_one_or_none()

    def get_history_by_owner(
        self,
        db: Session,
        owner_uuid: str,
    ) -> list[QrCode]:
        """Return all QR codes ever issued to an owner (newest first)."""
        stmt = (
            select(QrCode)
            .where(QrCode.proprietaire_uuid == owner_uuid)
            .order_by(QrCode.id.desc())
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
    ) -> tuple[list[QrCode], int]:
        """Search QR codes with pagination, sorting, and optional search."""
        base_stmt = select(QrCode)

        if search:
            pattern = f"%{search}%"
            base_stmt = base_stmt.where(
                or_(
                    QrCode.proprietaire_uuid.ilike(pattern),
                    QrCode.type_proprietaire.ilike(pattern),
                    QrCode.statut.ilike(pattern),
                )
            )

        count_stmt = select(func.count()).select_from(base_stmt.subquery())
        total = db.execute(count_stmt).scalar() or 0

        if sort and hasattr(QrCode, sort):
            sort_col = getattr(QrCode, sort)
            base_stmt = base_stmt.order_by(sort_col.asc() if order == "asc" else sort_col.desc())
        else:
            base_stmt = base_stmt.order_by(QrCode.id.desc())

        offset = (page - 1) * page_size
        base_stmt = base_stmt.offset(offset).limit(page_size)

        items = list(db.execute(base_stmt).scalars().all())
        return items, total
