from enum import StrEnum
from pathlib import Path
from typing import Final

# =============================================================================
# Environment
# =============================================================================


class Environment(StrEnum):
    DEVELOPMENT = "development"
    TESTING = "testing"
    PRODUCTION = "production"


class AppStatus(StrEnum):
    HEALTHY = "healthy"
    DEGRADED = "degraded"
    UNHEALTHY = "unhealthy"


# =============================================================================
# Application Metadata
# =============================================================================

APP_NAME: Final[str] = "CSM-GIAS Resto+"
APP_DESCRIPTION: Final[str] = "Solution Intelligente de Gestion du Restaurant d'Entreprise"
APP_VERSION: Final[str] = "1.0.0"
CONTACT_NAME: Final[str] = "CSM-GIAS Resto+ Team"
CONTACT_EMAIL: Final[str] = "support@csm-gias.resto"
LICENSE_NAME: Final[str] = "Proprietary"

# =============================================================================
# API Configuration
# =============================================================================

API_V1_PREFIX: Final[str] = "/api/v1"
API_DOCS_PREFIX: Final[str] = "/docs"
API_REDOC_PREFIX: Final[str] = "/redoc"

# =============================================================================
# HTTP Headers
# =============================================================================

HEADER_REQUEST_ID: Final[str] = "X-Request-ID"
HEADER_CORRELATION_ID: Final[str] = "X-Correlation-ID"
HEADER_PROCESS_TIME: Final[str] = "X-Process-Time-MS"

# =============================================================================
# Error Codes
# =============================================================================

ERR_INTERNAL: Final[str] = "INTERNAL_ERROR"
ERR_VALIDATION: Final[str] = "VALIDATION_ERROR"
ERR_NOT_FOUND: Final[str] = "NOT_FOUND"
ERR_CONFLICT: Final[str] = "CONFLICT"
ERR_UNAUTHORIZED: Final[str] = "UNAUTHORIZED"
ERR_FORBIDDEN: Final[str] = "FORBIDDEN"
ERR_BUSINESS: Final[str] = "BUSINESS_ERROR"
ERR_CONFIGURATION: Final[str] = "CONFIGURATION_ERROR"

# =============================================================================
# Regular Expressions
# =============================================================================

EMAIL_PATTERN: Final[str] = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
PHONE_PATTERN: Final[str] = r"^\+?[1-9]\d{1,14}$"

# =============================================================================
# Paths
# =============================================================================

PROJECT_ROOT: Final[Path] = Path(__file__).resolve().parent.parent.parent
LOGS_DIR: Final[Path] = PROJECT_ROOT / "logs"

# =============================================================================
# Security
# =============================================================================

BCRYPT_MIN_ROUNDS: Final[int] = 10
BCRYPT_MAX_ROUNDS: Final[int] = 16
JWT_MIN_EXPIRE_MINUTES: Final[int] = 5
JWT_MAX_EXPIRE_MINUTES: Final[int] = 1440

# =============================================================================
# Business Constants
# =============================================================================

MAX_LOGIN_ATTEMPTS: Final[int] = 5
LOGIN_LOCKOUT_MINUTES: Final[int] = 15
MIN_PASSWORD_LENGTH: Final[int] = 8
MAX_PASSWORD_LENGTH: Final[int] = 128

# =============================================================================
# Database
# =============================================================================

DEFAULT_POOL_SIZE: Final[int] = 10
DEFAULT_MAX_OVERFLOW: Final[int] = 20
DEFAULT_POOL_TIMEOUT: Final[int] = 30
DEFAULT_POOL_RECYCLE: Final[int] = 3600
