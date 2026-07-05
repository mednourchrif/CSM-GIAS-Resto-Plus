"""Pydantic schemas for the face recognition module.

Defines the API contract for enrollment, verification, and identification
endpoints.
"""

from enum import StrEnum

from pydantic import Field

from app.schemas.base import BaseResponse, BaseSchema


class FaceStatut(StrEnum):
    """Possible face recognition outcomes."""

    MATCH = "MATCH"
    NO_MATCH = "NO_MATCH"
    NO_FACE = "NO_FACE"
    MULTIPLE_FACES = "MULTIPLE_FACES"
    LOW_QUALITY = "LOW_QUALITY"


# -- Requests -----------------------------------------------------------------

class FaceEnrollRequest(BaseSchema):
    """Enroll a face embedding for a user."""

    image_base64: str = Field(
        ...,
        description="Image JPEG/PNG encodée en Base64.",
        examples=["/9j/4AAQSkZJRg...<base64-encoded-image>..."],
    )
    utilisateur_uuid: str = Field(
        ...,
        description="UUID de l'utilisateur à enrôler.",
        examples=["f47ac10b-58cc-4372-a567-0e02b2c3d479"],
    )
    categorie_uuid: str | None = Field(
        None,
        description="UUID optionnel de la catégorie de repas (enrôlement + repas automatique).",
        examples=None,
    )


class FaceVerifyRequest(BaseSchema):
    """Verify a user by face against their stored embedding."""

    image_base64: str = Field(
        ...,
        description="Image JPEG/PNG encodée en Base64.",
        examples=["/9j/4AAQSkZJRg...<base64-encoded-image>..."],
    )
    utilisateur_uuid: str = Field(
        ...,
        description="UUID de l'utilisateur présumé.",
        examples=["f47ac10b-58cc-4372-a567-0e02b2c3d479"],
    )
    categorie_uuid: str | None = Field(
        None,
        description="UUID optionnel de la catégorie de repas (vérification + repas automatique).",
        examples=None,
    )


class FaceIdentifyRequest(BaseSchema):
    """Identify a user by face against all stored embeddings."""

    image_base64: str = Field(
        ...,
        description="Image JPEG/PNG encodée en Base64.",
        examples=["/9j/4AAQSkZJRg...<base64-encoded-image>..."],
    )
    categorie_uuid: str | None = Field(
        None,
        description="UUID optionnel de la catégorie de repas (identification + repas automatique).",
        examples=None,
    )


# -- Responses ----------------------------------------------------------------

class FaceEmbeddingResponse(BaseResponse):
    """Face embedding metadata (embedding vector is never exposed)."""

    utilisateur_uuid: str
    model_name: str
    model_version: str
    quality_score: float | None = None
    active: bool = True


class FaceEnrollResponse(BaseResponse):
    """Result of a face enrollment."""

    utilisateur_uuid: str
    model_name: str
    model_version: str
    quality_score: float | None = None
    active: bool = True
    meal_registered: bool = False


class FaceMatchData(BaseSchema):
    """Base data returned by verify / identify operations."""

    statut: FaceStatut = FaceStatut.NO_MATCH
    confidence: float | None = None
    utilisateur_uuid: str | None = None
    nom: str | None = None
    prenom: str | None = None
    message: str | None = None


class FaceVerifyResponse(FaceMatchData):
    """Result of a face verification."""


class FaceIdentifyResponse(FaceMatchData):
    """Result of a face identification (includes user type)."""

    type: str | None = None
