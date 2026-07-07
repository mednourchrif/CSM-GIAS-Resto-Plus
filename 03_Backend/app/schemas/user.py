"""User schemas — central identity entity.

These schemas cover the base ``utilisateur`` table.  Extension schemas
(``AdminCreate``, ``EmployeeCreate``, etc.) are defined in sibling
modules and typically inherit from ``UserCreate``.
"""

from datetime import datetime

from pydantic import Field

from app.models.user import (
    Langue,
    StatutUtilisateur,
    TypeUtilisateur,
)
from app.schemas.base import BaseResponse, BaseSchema


class UserAdminCreate(BaseSchema):
    """Payload for creating an admin or receptionist user."""

    nom: str = Field(..., min_length=1, max_length=100)
    prenom: str = Field(..., min_length=1, max_length=100)
    email: str = Field(..., max_length=255)
    mot_de_passe: str = Field(..., min_length=8, max_length=128)
    type: TypeUtilisateur = Field(
        ...,
        description="ADMINISTRATEUR or RECEPTION",
    )
    statut: StatutUtilisateur = StatutUtilisateur.ACTIF
    role_id: int | None = Field(None, description="FK to role table (admins only)")


class UserAdminUpdate(BaseSchema):
    """Payload for updating an admin or receptionist user (all fields optional)."""

    nom: str | None = Field(None, min_length=1, max_length=100)
    prenom: str | None = Field(None, min_length=1, max_length=100)
    email: str | None = Field(None, max_length=255)
    statut: StatutUtilisateur | None = None
    role_id: int | None = Field(None, description="FK to role table (admins only)")


class UserAdminPasswordReset(BaseSchema):
    """Payload for resetting a user's password."""

    mot_de_passe: str = Field(..., min_length=8, max_length=128)


class UserAdminResponse(BaseSchema):
    """Response schema for admin/receptionist user management."""

    id: int
    uuid: str
    nom: str
    prenom: str
    email: str | None = None
    type: str
    statut: str
    role_name: str | None = Field(None, description="Role name for admins")
    derniere_connexion: datetime | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    created_by_id: str | None = None
    updated_by_id: str | None = None


class UserCreate(BaseSchema):
    """Payload for creating a new user.

    The ``type`` discriminator determines which extension table will
    receive the role-specific columns.  ``mot_de_passe`` is optional
    because intern / visitor accounts are created by an admin and the
    initial password may be generated automatically.
    """

    nom: str = Field(
        ...,
        min_length=1,
        max_length=100,
        description="Last name / family name.",
    )
    prenom: str = Field(
        ...,
        min_length=1,
        max_length=100,
        description="First name / given name.",
    )
    email: str | None = Field(
        None,
        max_length=255,
        description="Email address (unique).",
    )
    mot_de_passe: str | None = Field(
        None,
        min_length=8,
        max_length=128,
        description="Plain-text password (will be hashed before storage).",
    )
    type: TypeUtilisateur = Field(
        ...,
        description="Discriminator determining the user's profile type.",
    )
    statut: StatutUtilisateur = Field(
        StatutUtilisateur.ACTIF,
    )
    langue: Langue | None = Field(
        None,
        description="Preferred UI language on the tablet.",
    )


class UserUpdate(BaseSchema):
    """Payload for updating an existing user (all fields optional)."""

    nom: str | None = Field(None, min_length=1, max_length=100)
    prenom: str | None = Field(None, min_length=1, max_length=100)
    email: str | None = Field(None, max_length=255)
    mot_de_passe: str | None = Field(None, min_length=8, max_length=128)
    statut: StatutUtilisateur | None = None
    langue: Langue | None = None


class UserResponse(UserCreate, BaseResponse):
    """Schema returned by user CRUD endpoints.

    ``mot_de_passe`` is intentionally excluded from the response.
    """

    mot_de_passe: str | None = Field(
        None,
        exclude=True,
        description="Never exposed in responses.",
    )
    type: TypeUtilisateur
    statut: StatutUtilisateur
    date_suppression: datetime | None = Field(
        None,
        description="Soft-delete timestamp (null if active).",
    )
