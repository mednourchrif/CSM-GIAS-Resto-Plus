"""Intern schemas."""

from datetime import date

from pydantic import Field

from app.schemas.base import BaseResponse, BaseSchema


class InternCreate(BaseSchema):
    """Payload for creating an intern."""

    matricule: str = Field(
        ...,
        min_length=1,
        max_length=20,
        description="Unique HR intern number.",
    )
    date_debut_stage: date = Field(
        ...,
        description="First day of the internship.",
    )
    date_fin_stage: date = Field(
        ...,
        description="Last day of the internship.",
    )


class InternUpdate(BaseSchema):
    """Payload for updating an intern."""

    matricule: str | None = Field(None, min_length=1, max_length=20)
    date_debut_stage: date | None = None
    date_fin_stage: date | None = None


class InternResponse(BaseResponse):
    """Schema returned by intern CRUD endpoints."""

    nom: str
    prenom: str
    email: str | None = None
    matricule: str
    date_debut_stage: date
    date_fin_stage: date
