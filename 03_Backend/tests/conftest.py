"""Global test fixtures and configuration.

All tests in this directory inherit the fixtures defined here.  The key
design decisions are:

* **SQLite in-memory** — tests run against an isolated SQLite database
  that is created from scratch for each session.  No MySQL required.
* **Dependency override** — the FastAPI ``get_db`` dependency is
  overridden so that every request receives the test session.
* **Per-test isolation** -- each test gets a fresh database session via
  the ``db_session`` fixture; changes are rolled back after the test.
"""

import os

# Set APP_ENVIRONMENT to testing before any application code is imported.
# This ensures the ``TestingSettings`` class is used and the health
# endpoint reports ``environment: "testing"`` correctly.
os.environ.setdefault("APP_ENVIRONMENT", "testing")

from collections.abc import Generator
from typing import Any

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from loguru import logger as loguru_logger
from sqlalchemy import Engine, create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.dependencies import get_db as production_get_db
from app.database.base import Base
from app.main import create_app

# Bind a default ``request_id`` to all log records so that the file
# sink format does not raise ``KeyError`` when the middleware has not
# run (e.g. during test client requests).
loguru_logger = loguru_logger.bind(request_id="test")

# ---------------------------------------------------------------------------
# SQLite in-memory engine & session factory for tests
# ---------------------------------------------------------------------------


_test_engine: Engine = create_engine(
    "sqlite:///file::memory:?cache=shared&uri=true",
    echo=False,
    connect_args={"check_same_thread": False},
)

_test_session_factory: sessionmaker[Session] = sessionmaker(
    autocommit=False,
    autoflush=True,
    bind=_test_engine,
    expire_on_commit=False,
)


# ---------------------------------------------------------------------------
# Tables
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
    app_instance = create_app()
    yield app_instance
    _drop_tables()


@pytest.fixture(scope="function")
def db_session() -> Generator[Session, Any]:
    """Provide a clean database session with per-test isolation.

    The session is rolled back after each test, ensuring no test
    pollutes the state of another.
    """
    session = _test_session_factory()
    try:
        yield session
    finally:
        session.rollback()
        session.close()


@pytest.fixture(scope="function")
def client(app: FastAPI, db_session: Session) -> Generator[TestClient, Any]:
    """Provide a FastAPI TestClient with per-test database isolation.

    The ``get_db`` dependency is overridden to return the same session
    used by ``db_session``, so data seeded in the test is visible to
    every request within that test.
    """

    def _override_get_db() -> Generator[Session, Any]:
        """Override that returns the per-test session."""
        yield db_session

    app.dependency_overrides[production_get_db] = _override_get_db

    with TestClient(app) as tc:
        yield tc

    app.dependency_overrides.clear()


@pytest.fixture(scope="function", autouse=True)
def _mock_restaurant_hours() -> Generator[None]:
    """Mock restaurant hours to be open for all API-level tests.

    The ``from app.services.meal_service import is_restaurant_open``
    statement in ``test_meals.py`` creates a *local* reference to the
    original function, so ``TestRestaurantHours`` still tests the real
    function.  Calls that look up ``app.services.meal_service.is_restaurant_open``
    dynamically (e.g. inside ``MealService._register``) find the mock.
    """
    from unittest.mock import patch

    with patch("app.services.meal_service.is_restaurant_open", return_value=True):
        yield


@pytest.fixture(scope="function")
def override_get_db(db_session: Session) -> Any:
    """Return a ``get_db`` override that injects the per-test session.

    Use this fixture when you need fine-grained control over the
    session lifecycle (e.g. for testing transaction rollback outside
    of the default ``client`` fixture).
    """

    def _get_db() -> Generator[Session, Any]:
        yield db_session

    return _get_db
