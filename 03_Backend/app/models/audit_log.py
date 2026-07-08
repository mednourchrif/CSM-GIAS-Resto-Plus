from datetime import datetime, timezone

from sqlalchemy import DateTime, String, Text, text
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class AuditLog(BaseModel):
    __tablename__ = "audit_logs"

    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        index=True,
    )
    user_uuid: Mapped[str | None] = mapped_column(String(36), index=True, default=None)
    user_name: Mapped[str] = mapped_column(String(200))
    user_role: Mapped[str] = mapped_column(String(50))
    action: Mapped[str] = mapped_column(String(100), index=True)
    entity_type: Mapped[str | None] = mapped_column(String(100), default=None)
    entity_uuid: Mapped[str | None] = mapped_column(String(36), default=None)
    entity_name: Mapped[str | None] = mapped_column(String(300), default=None)
    description: Mapped[str | None] = mapped_column(Text, default=None)
    http_method: Mapped[str | None] = mapped_column(String(10), default=None)
    endpoint: Mapped[str | None] = mapped_column(String(500), default=None)
    ip_address: Mapped[str | None] = mapped_column(String(45), default=None)
    user_agent: Mapped[str | None] = mapped_column(String(500), default=None)
    status: Mapped[str] = mapped_column(String(20), default="SUCCESS")
    metadata_json: Mapped[str | None] = mapped_column(Text, default=None)

    def __repr__(self) -> str:
        return f"<AuditLog {self.uuid} [{self.action}] by {self.user_name}>"
