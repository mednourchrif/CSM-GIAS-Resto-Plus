"""Contracts for kiosk identification without exposing personal data."""

from datetime import datetime

from pydantic import Field

from app.schemas.base import BaseSchema


class QrIdentificationRequest(BaseSchema):
    token: str = Field(..., min_length=32, max_length=256)


class IdentificationGrantResponse(BaseSchema):
    identification_token: str
    identification_type: str
    expires_at: datetime
