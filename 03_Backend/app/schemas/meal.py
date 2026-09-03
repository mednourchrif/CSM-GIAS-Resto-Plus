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


class OfflineMealSyncItem(BaseSchema):
    """A meal record queued offline on the kiosk."""

    offline_id: str = Field(..., description="Client-generated unique ID for idempotency")
    qr_token: str = Field(..., min_length=32, description="Scanned raw QR token")
    categorie_uuid: str = Field(..., description="UUID of the meal category")
    registered_at: datetime = Field(
        ..., description="Timestamp when the meal was registered offline"
    )
    identification_type: str = Field(default="QR", description="Identification method")


class OfflineMealSyncRequest(BaseSchema):
    """Batch of meals to synchronize from offline storage."""

    items: list[OfflineMealSyncItem] = Field(
        default_factory=list,
        description="List of offline meals to synchronize",
    )


class OfflineSyncItemResult(BaseSchema):
    """Result of synchronizing a single offline meal."""

    offline_id: str
    statut: str = Field(description="SYNCED, ALREADY_REGISTERED, or ERROR")
    meal_uuid: str | None = None
    receipt_number: str | None = None
    message: str | None = None


class OfflineMealSyncResponse(BaseSchema):
    """Summary of batch synchronization."""

    synced_count: int
    failed_count: int
    results: list[OfflineSyncItemResult]


class OfflineUserManifestItem(BaseSchema):
    """Summary of an active user and active QR code hash for offline verification."""

    qr_hash: str
    user_uuid: str
    nom: str
    prenom: str
    matricule: str | None = None
    type: str


class OfflineManifestResponse(BaseSchema):
    """Manifest data downloaded by kiosk for offline operation."""

    categories: list[MealCategoryResponse]
    users: list[OfflineUserManifestItem]

