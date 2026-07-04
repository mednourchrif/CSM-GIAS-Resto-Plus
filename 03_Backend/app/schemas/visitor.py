"""Visitor schemas."""

from datetime import date

from pydantic import Field

from app.schemas.base import BaseResponse, BaseSchema


class VisitorCreate(BaseSchema):
    """Payload for creating a visitor."""

    societe: str | None = Field(
        None,
        max_length=255,
        description="Company or organisation the visitor represents.",
    )
    date_visite: date = Field(
        ...,
        description="The date of the visit.",
    )


class VisitorUpdate(BaseSchema):
    """Payload for updating a visitor."""

    societe: str | None = Field(None, max_length=255)
    date_visite: date | None = None


class VisitorResponse(BaseResponse):
    """Schema returned by visitor CRUD endpoints."""

    nom: str
    prenom: str
    email: str | None = None
    societe: str | None = None
    date_visite: date
