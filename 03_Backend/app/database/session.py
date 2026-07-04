"""Database engine, session factory, and FastAPI dependency.

This module is the single point of configuration for SQLAlchemy's connection
pool and session lifecycle.  Every repository (and, transitively, every
service) obtains its ``Session`` through the ``get_db`` generator.
"""

from collections.abc import Generator

from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import settings
from app.core.constants import DEFAULT_POOL_RECYCLE, DEFAULT_POOL_TIMEOUT

# ---------------------------------------------------------------------------
# Engine
# ---------------------------------------------------------------------------

engine = create_engine(
    settings.database_url,
    pool_size=settings.DB_POOL_SIZE,
    max_overflow=settings.DB_MAX_OVERFLOW,
    pool_timeout=DEFAULT_POOL_TIMEOUT,
    pool_recycle=DEFAULT_POOL_RECYCLE,
    pool_pre_ping=True,
    echo=settings.DB_ECHO_SQL,
)

# ---------------------------------------------------------------------------
# Session factory
# ---------------------------------------------------------------------------

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    expire_on_commit=False,
)


# ---------------------------------------------------------------------------
# DI dependency
# ---------------------------------------------------------------------------


def get_db() -> Generator[Session]:
    """FastAPI dependency that yields a database session.

    The session is auto-closed when the request finishes.
    If an exception propagates out of the ``with`` block the transaction is
    rolled back before the session is returned to the pool.

    Usage::

        @router.get("/items")
        def list_items(db: Session = Depends(get_db)):
            ...
    """
    db = SessionLocal()
    try:
        yield db
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


# ---------------------------------------------------------------------------
# Health check
# ---------------------------------------------------------------------------


def check_database_health() -> bool:
    """Verify database connectivity by executing ``SELECT 1``.

    Uses a throw-away engine with a short connect timeout so that the
    health endpoint returns promptly when the database is unreachable.
    """
    health_engine = create_engine(
        settings.database_url,
        connect_args={"connect_timeout": 2},
        pool_pre_ping=False,
        pool_size=1,
        max_overflow=0,
    )
    try:
        with health_engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return True
    except Exception:
        return False
    finally:
        health_engine.dispose()
