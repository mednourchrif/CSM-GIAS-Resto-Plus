from typing import Any

from app.core.constants import (
    ERR_BUSINESS,
    ERR_CONFIGURATION,
    ERR_CONFLICT,
    ERR_FORBIDDEN,
    ERR_INTERNAL,
    ERR_NOT_FOUND,
    ERR_UNAUTHORIZED,
    ERR_VALIDATION,
)


class ApplicationException(Exception):
    """Base exception for all application-level errors."""

    def __init__(
        self,
        message: str,
        error_code: str = ERR_INTERNAL,
        status_code: int = 500,
        details: dict[str, Any] | None = None,
    ) -> None:
        self.message = message
        self.error_code = error_code
        self.status_code = status_code
        self.details = details or {}
        super().__init__(self.message)


class ValidationException(ApplicationException):
    """Raised when request data fails validation."""

    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            message=message,
            error_code=ERR_VALIDATION,
            status_code=422,
            details=details,
        )


class BusinessException(ApplicationException):
    """Raised when a business rule is violated."""

    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            message=message,
            error_code=ERR_BUSINESS,
            status_code=400,
            details=details,
        )


class NotFoundException(ApplicationException):
    """Raised when a requested resource does not exist."""

    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            message=message,
            error_code=ERR_NOT_FOUND,
            status_code=404,
            details=details,
        )


class ConflictException(ApplicationException):
    """Raised when a request conflicts with the current state."""

    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            message=message,
            error_code=ERR_CONFLICT,
            status_code=409,
            details=details,
        )


class UnauthorizedException(ApplicationException):
    """Raised when authentication is required or has failed."""

    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            message=message,
            error_code=ERR_UNAUTHORIZED,
            status_code=401,
            details=details,
        )


class ForbiddenException(ApplicationException):
    """Raised when the user lacks permission to access a resource."""

    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            message=message,
            error_code=ERR_FORBIDDEN,
            status_code=403,
            details=details,
        )


class ConfigurationException(ApplicationException):
    """Raised when the application configuration is invalid."""

    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            message=message,
            error_code=ERR_CONFIGURATION,
            status_code=500,
            details=details,
        )
