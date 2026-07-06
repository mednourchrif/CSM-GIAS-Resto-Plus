"""QR Code schemas — request / response models.

Validation
----------
Every QR validation returns a :class:`ValidationStatut` that tells the
caller exactly why a QR was accepted or rejected::

    VALID          — QR exists, not expired, not revoked, owner active.
    EXPIRED        — Current time is past ``date_expiration``.
    REVOKED        — ``statut == REVOQUE`` (lost / regenerated / …).
    NOT_FOUND      — No QR record matches the given hash.
    OWNER_DISABLED — Owner account is ``INACTIF`` or soft-deleted.
    INVALID        - Token format is invalid.
"""

from datetime import datetime
from enum import StrEnum

from pydantic import Field

from app.schemas.base import BaseResponse, BaseSchema


class ValidationStatut(StrEnum):
    VALID = "VALID"
    EXPIRED = "EXPIRED"
    REVOKED = "REVOKED"
    NOT_FOUND = "NOT_FOUND"
    OWNER_DISABLED = "OWNER_DISABLED"
    INVALID = "INVALID"


# ---------------------------------------------------------------------------
# Request schemas
# ---------------------------------------------------------------------------


class QrValidateRequest(BaseSchema):
    """Request body for QR validation."""

    token: str = Field(
        ...,
        description="Raw QR token to validate",
        examples=["a1b2c3d4-e5f6-7890-abcd-ef1234567890"],
    )


# ---------------------------------------------------------------------------
# Response schemas
# ---------------------------------------------------------------------------


class QrCodeResponse(BaseResponse):
    """Full QR code representation returned by the API."""

    qr_hash: str
    proprietaire_uuid: str
    type_proprietaire: str
    statut: str
    date_expiration: datetime
    cree_par_uuid: str | None = None
    date_revocation: datetime | None = None
    revoque_par_uuid: str | None = None
    motif_revocation: str | None = None
    derniere_validation: datetime | None = None
    nombre_validations: int = 0
    metadata_json: str | None = None
    qr_base64: str | None = None
    proprietaire_nom: str | None = None
    proprietaire_prenom: str | None = None


class QrGenerateResponse(BaseResponse):
    """Response returned when a QR code is generated.

    Includes the raw ``qr_token`` that must be embedded in the QR image.
    This is the **only** time the raw token is returned — subsequent
    ``GET`` responses omit it.
    """

    qr_hash: str
    proprietaire_uuid: str
    type_proprietaire: str
    statut: str
    date_expiration: datetime
    qr_token: str
    qr_base64: str
    cree_par_uuid: str | None = None


class QrValidationResponse(BaseSchema):
    """Standardised validation result.

    The calling module (meal registration, mobile scanner) can inspect
    ``statut`` to decide whether to allow the operation.
    """

    statut: ValidationStatut
    qr_uuid: str | None = None
    proprietaire_uuid: str | None = None
    type_proprietaire: str | None = None
    nom: str | None = None
    prenom: str | None = None
    date_expiration: datetime | None = None
    nombre_validations: int = 0
    message: str | None = None
