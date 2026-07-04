"""Admin & Receptionist schemas."""

from datetime import datetime

from pydantic import Field

from app.schemas.base import BaseResponse, BaseSchema


class AdminCreate(BaseSchema):
    """Payload for creating an admin user.

    ``role_id`` links the admin to an operational tier (super-admin,
    manager, auditor).  If omitted the admin has no default role.
    """

    role_id: int | None = Field(
        None,
        description="FK to the ``role`` table.",
    )


class AdminUpdate(BaseSchema):
    """Payload for updating an admin."""

    role_id: int | None = None


class AdminResponse(BaseResponse):
    """Schema returned by admin CRUD endpoints."""

    nom: str
    prenom: str
    email: str | None = None
    role_id: int | None = None
    derniere_connexion: datetime | None = None
    tentatives_echouees: int = 0


class ReceptionistCreate(BaseSchema):
    """Payload for creating a receptionist user.

    The reception table is minimal—no additional columns are required
    beyond what ``utilisateur`` provides.
    """

    pass


class ReceptionistUpdate(BaseSchema):
    """Payload for updating a receptionist."""

    pass


class ReceptionistResponse(BaseResponse):
    """Schema returned by receptionist CRUD endpoints."""

    nom: str
    prenom: str
    email: str | None = None
