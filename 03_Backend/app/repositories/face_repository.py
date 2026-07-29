"""Face embedding repository — data access for ``FaceEmbedding`` entities.

Extends the generic :class:`BaseRepository` with face-specific queries
such as fetching the active embedding for a user or deactivating all
embeddings belonging to a user (used during re-enrollment).
"""

from typing import Any, cast

from sqlalchemy import delete, select
from sqlalchemy.engine import CursorResult
from sqlalchemy.orm import Session

from app.models.face_embedding import FaceEmbedding
from app.models.user import StatutUtilisateur, TypeUtilisateur, User
from app.repositories.base import BaseRepository


class FaceEmbeddingRepository(BaseRepository[FaceEmbedding]):
    """Repository for face embedding CRUD and custom queries."""

    def __init__(self) -> None:
        super().__init__(FaceEmbedding)

    def get_active_by_user(self, db: Session, user_uuid: str) -> FaceEmbedding | None:
        """Return the latest active embedding for a user, or ``None``."""
        stmt = (
            select(FaceEmbedding)
            .where(
                FaceEmbedding.utilisateur_uuid == user_uuid,
                FaceEmbedding.active.is_(True),
            )
            .order_by(FaceEmbedding.id.desc())
            .limit(1)
        )
        return db.execute(stmt).scalar_one_or_none()

    def get_all_active(self, db: Session) -> list[FaceEmbedding]:
        """Return templates belonging to active, non-deleted employees."""
        stmt = (
            select(FaceEmbedding)
            .join(User, FaceEmbedding.utilisateur_uuid == User.uuid)
            .where(
                FaceEmbedding.active.is_(True),
                User.type == TypeUtilisateur.EMPLOYE,
                User.statut == StatutUtilisateur.ACTIF,
                User.date_suppression.is_(None),
            )
        )
        return list(db.execute(stmt).scalars().all())

    def deactivate_all_for_user(self, db: Session, user_uuid: str) -> int:
        """Set ``active=False`` on every active embedding for a user.

        :returns: The number of embeddings that were deactivated.
        """
        stmt = select(FaceEmbedding).where(
            FaceEmbedding.utilisateur_uuid == user_uuid,
            FaceEmbedding.active.is_(True),
        )
        embeddings = list(db.execute(stmt).scalars().all())
        for emb in embeddings:
            emb.active = False
        db.flush()
        return len(embeddings)

    def delete_all_for_user(self, db: Session, user_uuid: str) -> int:
        """Permanently erase every biometric template owned by a user."""
        stmt = delete(FaceEmbedding).where(
            FaceEmbedding.utilisateur_uuid == user_uuid,
        )
        result = cast(CursorResult[Any], db.execute(stmt))
        db.flush()
        return result.rowcount or 0
