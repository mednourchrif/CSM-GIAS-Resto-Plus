"""FaceEmbedding — stored face embedding for the face recognition module.

Each row stores a 512-dimensional float32 face embedding vector as a
raw BLOB (2048 bytes), along with metadata about the model that produced
it.  Only **one** embedding per user should be ``active=True`` at any
given time — the service layer enforces this invariant.
"""

from sqlalchemy import Boolean, Float, ForeignKey, LargeBinary, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class FaceEmbedding(BaseModel):
    __tablename__ = "face_embedding"

    utilisateur_uuid: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("utilisateur.uuid"),
        index=True,
    )

    embedding: Mapped[bytes] = mapped_column(
        LargeBinary(2048),
    )

    model_name: Mapped[str] = mapped_column(
        String(50),
    )

    model_version: Mapped[str] = mapped_column(
        String(20),
    )

    quality_score: Mapped[float | None] = mapped_column(
        Float,
        default=None,
    )

    active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        index=True,
    )
