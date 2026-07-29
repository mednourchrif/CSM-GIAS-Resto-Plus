"""Data access for short-lived identification grants."""

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.identification_grant import IdentificationGrant
from app.repositories.base import BaseRepository


class IdentificationGrantRepository(BaseRepository[IdentificationGrant]):
    def __init__(self) -> None:
        super().__init__(IdentificationGrant)

    def get_by_hash_for_update(
        self,
        db: Session,
        token_hash: str,
    ) -> IdentificationGrant | None:
        stmt = (
            select(IdentificationGrant)
            .where(IdentificationGrant.token_hash == token_hash)
            .with_for_update()
        )
        return db.execute(stmt).scalar_one_or_none()
