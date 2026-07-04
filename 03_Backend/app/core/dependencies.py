from collections.abc import Generator
from typing import Any

from fastapi import Request
from loguru import logger as loguru_logger
from sqlalchemy.orm import Session

from app.core.config import BaseAppSettings, get_settings
from app.database.session import get_db as _get_db


def get_settings_dependency() -> BaseAppSettings:
    """Provide the application settings singleton via DI."""
    return get_settings()


def get_db() -> Generator[Session]:
    """Provide a database session, auto-closed on request completion."""
    yield from _get_db()


def get_request_id(request: Request) -> str:
    """Extract the request ID from the request state."""
    return getattr(request.state, "request_id", "unknown")


def get_logger() -> Any:
    """Provide the configured Loguru logger."""
    return loguru_logger
