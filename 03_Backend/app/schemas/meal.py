"""Meal schemas — request / response models.

The registration endpoint accepts either a QR token (current) or a
direct user UUID (future Face Recognition).  The service layer routes
to the appropriate internal method.
"""

from datetime import date, datetime

from pydantic import Field

from app.schemas.base import BaseResponse, BaseSchema


class MealCategoryResponse(BaseResponse):
    """A meal category (Plat, Pizza, Sandwich)."""

    nom: str
    description: str | None = None


class MealRegisterRequest(BaseSchema):
    """Register a meal using a QR token.

    Future identification methods (Face Recognition) will use a different
    schema or call the service directly.
    """

    token: str = Field(
        ...,
        description="Raw QR token to validate and register",
        examples=["a1b2c3d4-e5f6-7890-abcd-ef1234567890"],
    )
    categorie_uuid: str = Field(
        ...,
        description="UUID of the meal category",
        examples=["f47ac10b-58cc-4372-a567-0e02b2c3d479"],
    )


class MealRegisterResponse(BaseResponse):
    """Response after a successful meal registration."""

    utilisateur_uuid: str
    categorie_uuid: str
    type_identification: str
    date_repas: date
    heure_repas: datetime
    qr_uuid: str | None = None
    enregistre_par_uuid: str | None = None
    categorie_nom: str | None = None
    nom: str | None = None
    prenom: str | None = None


class MealResponse(BaseResponse):
    """Full meal representation returned by list / get endpoints."""

    utilisateur_uuid: str
    qr_uuid: str | None = None
    categorie_uuid: str
    type_identification: str
    date_repas: date
    heure_repas: datetime
    enregistre_par_uuid: str | None = None
    categorie_nom: str | None = None
    nom: str | None = None
    prenom: str | None = None
