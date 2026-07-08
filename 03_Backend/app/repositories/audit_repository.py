from datetime import date, datetime

from sqlalchemy import select, func, or_
from sqlalchemy.orm import Session

from app.models.audit_log import AuditLog
from app.repositories.base import BaseRepository
from app.schemas.audit import AuditLogFilterParams


class AuditLogRepository(BaseRepository[AuditLog]):
    def __init__(self) -> None:
        super().__init__(AuditLog)

    def search_paginated(
        self,
        db: Session,
        *,
        page: int,
        page_size: int,
        filters: AuditLogFilterParams | None = None,
    ) -> tuple[list[AuditLog], int]:
        stmt = select(AuditLog)

        if filters:
            if filters.date_from:
                stmt = stmt.where(AuditLog.timestamp >= filters.date_from)
            if filters.date_to:
                stmt = stmt.where(AuditLog.timestamp <= filters.date_to)
            if filters.user_uuid:
                stmt = stmt.where(AuditLog.user_uuid == filters.user_uuid)
            if filters.role:
                stmt = stmt.where(AuditLog.user_role == filters.role)
            if filters.action:
                stmt = stmt.where(AuditLog.action == filters.action)
            if filters.entity_type:
                stmt = stmt.where(AuditLog.entity_type == filters.entity_type)
            if filters.status:
                stmt = stmt.where(AuditLog.status == filters.status)
            if filters.search:
                pattern = f"%{filters.search}%"
                stmt = stmt.where(
                    or_(
                        AuditLog.user_name.ilike(pattern),
                        AuditLog.entity_name.ilike(pattern),
                        AuditLog.description.ilike(pattern),
                    )
                )

        total_stmt = stmt.with_only_columns(func.count(AuditLog.id))
        stmt = stmt.order_by(AuditLog.timestamp.desc(), AuditLog.id.desc())
        stmt = stmt.offset((page - 1) * page_size).limit(page_size)

        total = db.execute(total_stmt).scalar() or 0
        items = list(db.execute(stmt).scalars().all())
        return items, total

    def get_actions(self, db: Session) -> list[str]:
        stmt = select(AuditLog.action).distinct().order_by(AuditLog.action)
        return list(db.execute(stmt).scalars().all())

    def get_entity_types(self, db: Session) -> list[str]:
        stmt = select(AuditLog.entity_type).distinct().order_by(AuditLog.entity_type)
        return list(db.execute(stmt).scalars().all())
