"""Role schemas — administration tiers."""

from pydantic import Field

from app.schemas.base import BaseResponse, BaseSchema


class RoleCreate(BaseSchema):
    """Payload for creating a new role."""

    nom: str = Field(
        ...,
        min_length=1,
        max_length=50,
        description="Unique role name (e.g. super-admin, manager, auditor).",
    )
    description: str | None = Field(
        None,
        max_length=255,
        description="Human-readable description of the role's permissions.",
    )
    actif: bool = Field(
        True,
        description="Whether the role is currently in use.",
    )


class RoleUpdate(BaseSchema):
    """Payload for updating an existing role (all fields optional)."""

    nom: str | None = Field(
        None,
        min_length=1,
        max_length=50,
    )
    description: str | None = Field(
        None,
        max_length=255,
    )
    actif: bool | None = Field(
        None,
    )


class RoleResponse(RoleCreate, BaseResponse):
    """Schema returned by role CRUD endpoints."""

    pass
