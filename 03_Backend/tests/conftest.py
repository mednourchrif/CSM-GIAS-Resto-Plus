"""Global test fixtures and configuration.

All tests in this directory inherit the fixtures defined here.  The key
design decisions are:

* **SQLite in-memory** — tests run against an isolated SQLite database
  that is created from scratch for each session.  No MySQL required.
* **Dependency override** — the FastAPI ``get_db`` dependency is
  overridden so that every endpoint receives the test session.
* **Transaction rollback** (optional) — use the ``db_session`` fixture
  for per-test isolation; the transaction is rolled back after each test.
"""

from collections.abc import Generator
from typing import Any

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from loguru import logger as loguru_logger
from sqlalchemy import Engine, create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.database.base import Base
from app.database.session import get_db as production_get_db
from app.main import create_app

# Bind a default ``request_id`` to all log records so that the file
# sink format does not raise ``KeyError`` when the middleware has not
# run (e.g. during test client requests).
loguru_logger = loguru_logger.bind(request_id="test")

# ---------------------------------------------------------------------------
# SQLite in-memory engine & session factory for tests
# ---------------------------------------------------------------------------

TEST_DATABASE_URL = "sqlite://"  # in-memory, no file needed

_test_engine: Engine = create_engine(
    TEST_DATABASE_URL,
    echo=False,
    connect_args={"check_same_thread": False},
)

_test_session_factory: sessionmaker[Session] = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=_test_engine,
    expire_on_commit=False,
)


# ---------------------------------------------------------------------------
# Module-level event: create all tables once per test run
# ---------------------------------------------------------------------------


def _create_tables() -> None:
    """Create all registered model tables in the test database."""
    Base.metadata.create_all(bind=_test_engine)


def _drop_tables() -> None:
    """Drop all tables (cleanup between test modules if needed)."""
    Base.metadata.drop_all(bind=_test_engine)


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


@pytest.fixture(scope="session")
def app() -> FastAPI:
    """Build the FastAPI application once per test session.

    Tables are created before the first test and dropped after the last
    test in the session.
    """
    _create_tables()
    yield create_app()
    _drop_tables()


@pytest.fixture(scope="session")
def client(app: FastAPI) -> Generator[TestClient, Any, None]:
    """Provide a FastAPI TestClient bound to the in-memory database.

    The ``get_db`` dependency is overridden so that every request uses
    the test session factory instead of the production MySQL connection.
    """

    def _override_get_db() -> Generator[Session, Any, None]:
        """Override that provides a test session."""
        db = _test_session_factory()
        try:
            yield db
        except Exception:
            db.rollback()
            raise
        finally:
            db.close()

    app.dependency_overrides[production_get_db] = _override_get_db

    with TestClient(app) as tc:
        yield tc

    app.dependency_overrides.clear()


@pytest.fixture(scope="function")
def db_session() -> Generator[Session, Any, None]:
    """Provide a clean database session with per-test isolation.

    The session is rolled back after each test, ensuring no test
    pollutes the state of another.
    """
    connection = _test_engine.connect()
    transaction = connection.begin()
    session = _test_session_factory(bind=connection)

    yield session

    session.close()
    transaction.rollback()
    connection.close()


@pytest.fixture(scope="function")
def override_get_db(db_session: Session) -> Any:
    """Return a ``get_db`` override that injects the per-test session.

    Use this fixture when you need fine-grained control over the
    session lifecycle (e.g. for testing transaction rollback).
    """

    def _get_db() -> Generator[Session, Any, None]:
        yield db_session

    return _get_db
