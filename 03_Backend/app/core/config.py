from __future__ import annotations

import os
from functools import lru_cache
from pathlib import Path
from typing import ClassVar
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from pydantic import ValidationInfo, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

from app.core.constants import (
    BCRYPT_MAX_ROUNDS,
    BCRYPT_MIN_ROUNDS,
    DEFAULT_MAX_OVERFLOW,
    DEFAULT_POOL_SIZE,
    JWT_MAX_EXPIRE_MINUTES,
    JWT_MIN_EXPIRE_MINUTES,
    Environment,
)
from app.core.exceptions import ConfigurationException


class BaseAppSettings(BaseSettings):
    """Base settings with common configuration for all environments.

    Loads values from .env file. All secrets and environment-specific
    values MUST be set via environment variables, never hardcoded.
    """

    model_config: ClassVar[SettingsConfigDict] = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ── Application ──────────────────────────────────────────────────────
    APP_NAME: str = "CSM-GIAS Resto+"
    APP_VERSION: str = "1.0.0"
    APP_DEBUG: bool = False
    APP_ENVIRONMENT: Environment = Environment.DEVELOPMENT
    APP_SECRET_KEY: str = ""

    # ── Server ───────────────────────────────────────────────────────────
    SERVER_HOST: str = "0.0.0.0"
    SERVER_PORT: int = 8000
    SERVER_WORKERS: int = 4
    SERVER_TIMEOUT_KEEPALIVE: int = 5
    TRUSTED_HOSTS: list[str] = ["localhost", "127.0.0.1"]

    # ── Database ─────────────────────────────────────────────────────────
    DB_HOST: str = "localhost"
    DB_PORT: int = 3306
    DB_USER: str = "resto_user"
    DB_PASSWORD: str = ""
    DB_NAME: str = "resto_plus"
    DB_POOL_SIZE: int = DEFAULT_POOL_SIZE
    DB_MAX_OVERFLOW: int = DEFAULT_MAX_OVERFLOW
    DB_ECHO_SQL: bool = False

    # ── Authentication ───────────────────────────────────────────────────
    JWT_SECRET_KEY: str = ""
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    BCRYPT_ROUNDS: int = 12
    LOGIN_RATE_LIMIT_ATTEMPTS: int = 5
    LOGIN_RATE_LIMIT_WINDOW_SECONDS: int = 900

    # ── Tablet ───────────────────────────────────────────────────────────
    TABLET_API_KEY: str = ""
    FACE_ENGINE: str = "stub"
    BIOMETRIC_ENCRYPTION_KEY: str = ""

    # ── Logging ──────────────────────────────────────────────────────────
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"
    LOG_FILE_PATH: str = "logs/app.log"
    LOG_ROTATION: str = "1 day"
    LOG_RETENTION: str = "30 days"

    # ── CORS ─────────────────────────────────────────────────────────────
    CORS_ORIGINS: list[str] = ["http://localhost:3000", "http://localhost:8000"]

    # ── Email ────────────────────────────────────────────────────────────
    SMTP_HOST: str | None = None
    SMTP_PORT: int = 587
    SMTP_USER: str | None = None
    SMTP_PASSWORD: str | None = None
    SMTP_FROM: str = "noreply@csm-gias.resto"
    SMTP_STARTTLS: bool = True

    # ── Timezone ─────────────────────────────────────────────────────────
    TZ: str = "Africa/Casablanca"

    # ── Validators ───────────────────────────────────────────────────────

    @field_validator("APP_SECRET_KEY", "JWT_SECRET_KEY")
    @classmethod
    def _validate_secret_keys(cls, value: str, info: ValidationInfo) -> str:
        if not value:
            raise ValueError(f"{info.field_name} is required and cannot be empty")
        return value

    @field_validator("BCRYPT_ROUNDS")
    @classmethod
    def _validate_bcrypt_rounds(cls, value: int) -> int:
        if value < BCRYPT_MIN_ROUNDS or value > BCRYPT_MAX_ROUNDS:
            raise ValueError(
                f"BCRYPT_ROUNDS must be between {BCRYPT_MIN_ROUNDS} and {BCRYPT_MAX_ROUNDS}"
            )
        return value

    @field_validator("JWT_ACCESS_TOKEN_EXPIRE_MINUTES")
    @classmethod
    def _validate_jwt_expiry(cls, value: int) -> int:
        if value < JWT_MIN_EXPIRE_MINUTES or value > JWT_MAX_EXPIRE_MINUTES:
            raise ValueError(
                f"JWT expiry must be between {JWT_MIN_EXPIRE_MINUTES} "
                f"and {JWT_MAX_EXPIRE_MINUTES} minutes"
            )
        return value

    @field_validator("TZ")
    @classmethod
    def _validate_timezone(cls, value: str) -> str:
        if not value:
            return value
        try:
            ZoneInfo(value)
        except ZoneInfoNotFoundError as exc:
            raise ValueError("TZ must be a valid IANA timezone name") from exc
        return value

    # ── Computed Properties ──────────────────────────────────────────────

    @property
    def database_url(self) -> str:
        """Build the SQLAlchemy database URL from individual settings."""
        return (
            f"mysql+pymysql://{self.DB_USER}:{self.DB_PASSWORD}"
            f"@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
            f"?charset=utf8mb4"
        )

    @property
    def is_development(self) -> bool:
        return self.APP_ENVIRONMENT == Environment.DEVELOPMENT

    @property
    def is_testing(self) -> bool:
        return self.APP_ENVIRONMENT == Environment.TESTING

    @property
    def is_production(self) -> bool:
        return self.APP_ENVIRONMENT == Environment.PRODUCTION

    @property
    def log_path(self) -> Path:
        path = Path(self.LOG_FILE_PATH)
        if not path.is_absolute():
            path = Path(__file__).resolve().parent.parent.parent / path
        return path


class DevelopmentSettings(BaseAppSettings):
    """Settings for local development with relaxed security and verbose logging."""

    APP_DEBUG: bool = True
    DB_ECHO_SQL: bool = True
    LOG_LEVEL: str = "DEBUG"
    CORS_ORIGINS: list[str] = ["*"]
    TRUSTED_HOSTS: list[str] = ["*"]


class TestingSettings(BaseAppSettings):
    """Settings for automated test execution with isolated database."""

    APP_DEBUG: bool = True
    DB_ECHO_SQL: bool = False
    LOG_LEVEL: str = "DEBUG"
    DB_NAME: str = "resto_plus_test"
    BCRYPT_ROUNDS: int = BCRYPT_MIN_ROUNDS
    TRUSTED_HOSTS: list[str] = ["testserver", "localhost", "127.0.0.1"]


class ProductionSettings(BaseAppSettings):
    """Settings for production deployment with strict security."""

    APP_DEBUG: bool = False
    DB_ECHO_SQL: bool = False
    LOG_LEVEL: str = "INFO"
    SERVER_WORKERS: int = 4
    # The requirements specify "local time" but do not establish a country.
    # Production deployments must therefore select the restaurant IANA zone.
    TZ: str = ""

    @model_validator(mode="after")
    def _validate_production_integrations(self) -> ProductionSettings:
        unsafe_secrets = {
            "",
            "change-me",
            "change-me-to-a-random-64-char-string",
            "change-me-to-another-random-64-char-string",
        }
        if self.APP_SECRET_KEY.strip() in unsafe_secrets or len(self.APP_SECRET_KEY) < 32:
            raise ValueError("APP_SECRET_KEY must contain at least 32 random characters")
        if self.JWT_SECRET_KEY.strip() in unsafe_secrets or len(self.JWT_SECRET_KEY) < 32:
            raise ValueError("JWT_SECRET_KEY must contain at least 32 random characters")
        if "*" in self.CORS_ORIGINS:
            raise ValueError("Wildcard CORS origins are forbidden in production")
        if not self.TRUSTED_HOSTS or "*" in self.TRUSTED_HOSTS:
            raise ValueError("Explicit TRUSTED_HOSTS are required in production")
        unsafe_tablet_keys = {"", "change-me", "change-me-to-tablet-api-key"}
        if self.TABLET_API_KEY.strip() in unsafe_tablet_keys:
            raise ValueError(
                "TABLET_API_KEY must be configured with a strong, unique value " "in production"
            )
        if self.FACE_ENGINE.strip().lower() == "stub":
            raise ValueError(
                "FACE_ENGINE=stub is development-only; configure a reviewed "
                "face-recognition engine before production"
            )
        if not self.TZ.strip():
            raise ValueError("TZ must be explicitly configured in production")
        if (
            self.FACE_ENGINE.strip().lower() != "disabled"
            and not self.BIOMETRIC_ENCRYPTION_KEY.strip()
        ):
            raise ValueError("BIOMETRIC_ENCRYPTION_KEY must be configured in production")
        return self


class SettingsFactory:
    """Creates the appropriate settings class based on the environment variable."""

    _environments: dict[Environment, type[BaseAppSettings]] = {
        Environment.DEVELOPMENT: DevelopmentSettings,
        Environment.TESTING: TestingSettings,
        Environment.PRODUCTION: ProductionSettings,
    }

    @classmethod
    def _read_env_file(cls) -> dict[str, str]:
        """Read the .env file and return a {key: value} map.

        This allows the factory to peek at APP_ENVIRONMENT before any
        Pydantic model is constructed, avoiding the chicken-and-egg
        problem of needing to know the environment to pick the right
        settings class.
        """
        env_path = Path(".env")
        if not env_path.exists():
            return {}
        result: dict[str, str] = {}
        for raw_line in env_path.read_text(encoding="utf-8").splitlines():
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            result[key.strip()] = value.strip().strip('"').strip("'")
        return result

    @classmethod
    def _resolve_environment(cls) -> Environment:
        """Resolve APP_ENVIRONMENT from OS environ or .env file.

        Priority: OS environment > .env file > default ``development``.

        :raises ConfigurationException: If the value is not one of the
            valid ``Environment`` members.
        """
        env_name = os.environ.get("APP_ENVIRONMENT")

        if env_name is None:
            env_file = cls._read_env_file()
            env_name = env_file.get("APP_ENVIRONMENT")

        if env_name is None:
            env_name = "development"

        valid_values = [e.value for e in Environment]

        if env_name not in valid_values:
            raise ConfigurationException(
                message=(
                    f"Invalid APP_ENVIRONMENT='{env_name}'. "
                    f"Must be one of: {', '.join(valid_values)}. "
                    f"Check your .env file or OS environment variable."
                ),
                details={
                    "provided": env_name,
                    "valid_values": valid_values,
                },
            )

        return Environment(env_name)

    @classmethod
    def create(cls) -> BaseAppSettings:
        """Read APP_ENVIRONMENT and return the matching settings class instance."""
        env = cls._resolve_environment()
        settings_class = cls._environments[env]
        return settings_class()


@lru_cache
def get_settings() -> BaseAppSettings:
    """Return a cached singleton of the application settings.

    Cached so that .env is read only once per process lifetime.
    Use this function for dependency injection instead of importing
    the module-level ``settings`` object directly.
    """
    return SettingsFactory.create()


settings = get_settings()
