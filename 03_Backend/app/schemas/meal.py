"""Meal schemas — request / response models."""

from datetime import date, datetime

from pydantic import Field

from app.schemas.base import BaseResponse, BaseSchema
from app.schemas.receipt import ReceiptResponse


class MealCategoryResponse(BaseResponse):
    """A meal category (Plat, Pizza, Sandwich)."""

    nom: str
    description: str | None = None


class MealRegisterRequest(BaseSchema):
    """Confirm a meal using a short-lived identification proof."""

    identification_token: str = Field(
        ...,
        min_length=32,
        max_length=256,
        description="One-use token returned by face or QR identification",
    )
    categorie_uuid: str = Field(
        ...,
        description="UUID of the meal category",
        examples=["f47ac10b-58cc-4372-a567-0e02b2c3d479"],
    )


class MealRegisterResponse(BaseResponse):
    """Response after a successful meal registration."""

    categorie_uuid: str
    type_identification: str
    date_repas: date
    heure_repas: datetime
    categorie_nom: str | None = None
    receipt: ReceiptResponse


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
