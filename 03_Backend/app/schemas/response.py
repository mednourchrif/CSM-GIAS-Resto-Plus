from datetime import datetime, timezone
from typing import Any, Generic, TypeVar

from pydantic import BaseModel, Field

T = TypeVar("T")


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


class SuccessResponse(BaseModel, Generic[T]):  # noqa: UP046
    """Standard success response wrapper."""

    success: bool = True
    data: T | None = None
    message: str | None = None


class ErrorResponse(BaseModel):
    """Standard error response wrapper."""

    success: bool = False
    error_code: str
    message: str
    details: dict[str, Any] | None = None
    timestamp: datetime = Field(default_factory=_utcnow)


class PaginatedResponse(BaseModel, Generic[T]):  # noqa: UP046
    """Standard paginated response wrapper."""

    success: bool = True
    data: list[T]
    total: int
    page: int
    page_size: int
    total_pages: int


class MetadataResponse(BaseModel):
    """Application metadata response."""

    name: str
    version: str
    environment: str
    status: str
    timestamp: datetime = Field(default_factory=_utcnow)
