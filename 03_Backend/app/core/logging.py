import logging
import sys
from pathlib import Path

from loguru import logger

from app.core.config import settings


class InterceptHandler(logging.Handler):
    """Redirect standard Python logging to Loguru.

    This ensures that logs from third-party libraries (Uvicorn,
    SQLAlchemy, etc.) are captured by Loguru and follow its
    formatting, rotation, and retention policies.
    """

    def emit(self, record: logging.LogRecord) -> None:
        try:
            level = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno

        frame, depth = sys._getframe(6), 6
        while frame and frame.f_code.co_filename == logging.__file__:
            frame = frame.f_back
            depth += 1

        logger.opt(depth=depth, exception=record.exc_info).log(level, record.getMessage())


def configure_logging() -> None:
    """Configure Loguru sinks and intercept Python's logging.

    Two sinks are always configured:
    1. Console (stdout) — coloured in development, plain in production.
    2. File — with daily rotation, retention, and compression.

    All existing Python loggers are patched to route through Loguru.
    """
    logger.remove()

    console_format = (
        "<green>{time:YYYY-MM-DD HH:mm:ss}</green> | "
        "<level>{level: <8}</level> | "
        "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> | "
        "<level>{message}</level>"
    )
    file_format = (
        "{time:YYYY-MM-DD HH:mm:ss} | "
        "{level: <8} | "
        "{name}:{function}:{line} | "
        "{extra[request_id]: <36} | "
        "{message}"
    )

    if settings.is_development:
        logger.add(
            sys.stdout,
            format=console_format,
            level=settings.LOG_LEVEL,
            colorize=True,
            backtrace=True,
            diagnose=True,
        )
    else:
        logger.add(
            sys.stdout,
            format=console_format,
            level=settings.LOG_LEVEL,
            colorize=False,
            backtrace=False,
            diagnose=False,
        )

    log_path: Path = settings.log_path
    log_path.parent.mkdir(parents=True, exist_ok=True)
    logger.add(
        str(log_path),
        format=file_format,
        level=settings.LOG_LEVEL,
        rotation=settings.LOG_ROTATION,
        retention=settings.LOG_RETENTION,
        compression="zip",
        backtrace=False,
        diagnose=False,
    )

    logging.basicConfig(handlers=[InterceptHandler()], level=0, force=True)

    for name in ("uvicorn", "uvicorn.access", "sqlalchemy.engine"):
        logging.getLogger(name).handlers = [InterceptHandler()]
        logging.getLogger(name).propagate = False

    logger.info("Logging initialized — level={} | file={}", settings.LOG_LEVEL, log_path)
