"""Short-lived proof that the kiosk successfully identified a user."""

from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class IdentificationGrant(BaseModel):
    __tablename__ = "identification_grant"

    token_hash: Mapped[str] = mapped_column(
        String(64),
        unique=True,
        index=True,
    )
    utilisateur_uuid: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("utilisateur.uuid", ondelete="CASCADE"),
        index=True,
    )
    identification_type: Mapped[str] = mapped_column(String(20))
    qr_uuid: Mapped[str | None] = mapped_column(
        String(36),
        ForeignKey("qr_code.uuid", ondelete="SET NULL"),
        default=None,
    )
    expires_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        index=True,
    )
    consumed_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        default=None,
        index=True,
    )
