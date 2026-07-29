"""Issue and consume one-use proofs for the kiosk meal flow."""

import hashlib
import secrets
from datetime import timedelta

from sqlalchemy.orm import Session

from app.core.exceptions import UnauthorizedException
from app.models.identification_grant import IdentificationGrant
from app.repositories.identification_grant import IdentificationGrantRepository
from app.utils.date_utils import is_expired, now_utc

_GRANT_LIFETIME = timedelta(minutes=2)


class IdentificationService:
    def __init__(
        self,
        repository: IdentificationGrantRepository | None = None,
    ) -> None:
        self._repository = repository or IdentificationGrantRepository()

    def issue(
        self,
        db: Session,
        *,
        user_uuid: str,
        identification_type: str,
        qr_uuid: str | None = None,
    ) -> tuple[IdentificationGrant, str]:
        raw_token = secrets.token_urlsafe(32)
        grant = self._repository.create(
            db,
            token_hash=self._hash(raw_token),
            utilisateur_uuid=user_uuid,
            identification_type=identification_type.upper(),
            qr_uuid=qr_uuid,
            expires_at=now_utc() + _GRANT_LIFETIME,
        )
        return grant, raw_token

    def consume(self, db: Session, raw_token: str) -> IdentificationGrant:
        grant = self._repository.get_by_hash_for_update(
            db,
            self._hash(raw_token),
        )
        if grant is None or grant.consumed_at is not None or is_expired(grant.expires_at):
            raise UnauthorizedException(
                message="Identification expirée ou déjà utilisée.",
            )
        grant.consumed_at = now_utc()
        db.flush()
        return grant

    @staticmethod
    def _hash(raw_token: str) -> str:
        return hashlib.sha256(raw_token.encode("utf-8")).hexdigest()
