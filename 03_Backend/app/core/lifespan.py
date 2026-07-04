from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI
from loguru import logger

from app.core.config import settings
from app.core.logging import configure_logging
from app.database.session import check_database_health


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    """Application lifespan context manager.

    Startup phase (before ``yield``):
    - Configure Loguru
    - Validate environment configuration
    - Verify database connectivity
    - Log startup banner

    Shutdown phase (after ``yield``):
    - Flush remaining logs
    - Log graceful shutdown
    """
    # ── Startup ──────────────────────────────────────────────────────────
    configure_logging()

    _validate_environment()

    db_healthy = check_database_health()
    if db_healthy:
        logger.info("Database connection — OK")
    else:
        logger.warning("Database connection — UNAVAILABLE (starting in degraded mode)")

    _log_startup_banner(db_healthy)

    yield

    # ── Shutdown ─────────────────────────────────────────────────────────
    logger.info("Shutting down — flushing logs...")
    logger.complete()


def _validate_environment() -> None:
    """Check critical configuration values and warn if insecure defaults are
    detected in production."""
    if settings.is_production:
        if settings.APP_DEBUG:
            logger.warning("APP_DEBUG is enabled in production — this is a security risk")
        if settings.CORS_ORIGINS == ["*"]:
            logger.warning("CORS_ORIGINS allows all origins in production")
        if settings.APP_SECRET_KEY == "":
            logger.critical("APP_SECRET_KEY is not set")

    logger.info(
        "Environment validated — mode={} debug={}",
        settings.APP_ENVIRONMENT,
        settings.APP_DEBUG,
    )


def _log_startup_banner(db_healthy: bool) -> None:
    """Print a visible startup banner for operational clarity."""
    db_status = "Connected" if db_healthy else "Disconnected"
    banner = (
        f"\n{'═' * 54}"
        f"\n  CSM-GIAS Resto+ — Solution de Gestion du Restaurant"
        f"\n{'═' * 54}"
        f"\n  Version     : {settings.APP_VERSION}"
        f"\n  Environment : {settings.APP_ENVIRONMENT}"
        f"\n  Debug       : {settings.APP_DEBUG}"
        f"\n  Database    : {db_status}"
        f"\n  Server      : {settings.SERVER_HOST}:{settings.SERVER_PORT}"
        f"\n  API Prefix  : /api/v1"
        f"\n  Docs        : /docs"
        f"\n{'═' * 54}\n"
    )
    logger.info(banner)
