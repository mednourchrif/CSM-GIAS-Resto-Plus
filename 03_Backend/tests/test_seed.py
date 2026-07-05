"""Tests for the database seed script (``scripts/seed.py``).

Verifies:
- Correct data is created on an empty database.
- Re-running the seed does not duplicate rows (idempotency).
- Password hashes are verifiable.
- Summary structure and content.

Each test runs against an isolated in-memory SQLite database with
tables recreated before every test function.
"""

from __future__ import annotations

import os

os.environ.setdefault("APP_ENVIRONMENT", "testing")

from sqlalchemy import create_engine, func, select
from sqlalchemy.orm import Session

from app.database.base import Base
from app.models.meal_category import MealCategory
from app.models.role import Role
from app.models.user import User
from app.utils.password import hash_password, verify_password
from scripts.seed import seed

import pytest  # noqa: E402 — must come after os.environ

# =========================================================================
# Test engine (in-memory SQLite, shared cache)
# =========================================================================

_TEST_ENGINE = create_engine(
    "sqlite:///file::memory:?cache=shared&uri=true",
    connect_args={"check_same_thread": False},
)


# =========================================================================
# Fixtures
# =========================================================================


@pytest.fixture(autouse=True)
def _clean_db() -> None:
    """Drop and recreate all tables before every test.

    This guarantees full isolation: no test can see committed data
    from another test.
    """
    Base.metadata.drop_all(bind=_TEST_ENGINE)
    Base.metadata.create_all(bind=_TEST_ENGINE)


@pytest.fixture
def db_session() -> Session:
    """Provide a clean SQLAlchemy session for each test."""
    session = Session(bind=_TEST_ENGINE)
    try:
        yield session
    finally:
        session.rollback()
        session.close()


# =========================================================================
# Tests — empty database
# =========================================================================


class TestSeedEmptyDatabase:
    """Verify that ``seed()`` populates an empty database correctly."""

    def test_creates_roles(self, db_session: Session) -> None:
        seed(db_session)
        count = db_session.execute(select(func.count()).select_from(Role)).scalar()
        assert count == 2

    def test_creates_admin(self, db_session: Session) -> None:
        seed(db_session)
        stmt = select(User).where(User.email == "admin@csm-gias.tn")
        admin = db_session.execute(stmt).scalar_one_or_none()
        assert admin is not None
        assert admin.nom == "System"
        assert admin.prenom == "Administrator"
        assert verify_password("Admin@123", admin.mot_de_passe)

    def test_creates_receptionist(self, db_session: Session) -> None:
        seed(db_session)
        stmt = select(User).where(User.email == "reception@csm-gias.tn")
        receptionist = db_session.execute(stmt).scalar_one_or_none()
        assert receptionist is not None
        assert receptionist.nom == "Reception"
        assert receptionist.prenom == "Restaurant"
        assert verify_password("Reception@123", receptionist.mot_de_passe)

    def test_creates_categories(self, db_session: Session) -> None:
        seed(db_session)
        count = db_session.execute(select(func.count()).select_from(MealCategory)).scalar()
        assert count == 3

    def test_returns_summary(self, db_session: Session) -> None:
        results = seed(db_session)
        assert "Roles" in results
        assert "Administrateur" in results
        assert "R\u00e9ception" in results
        assert "Cat\u00e9gories" in results

    def test_summary_contains_created_messages(self, db_session: Session) -> None:
        results = seed(db_session)
        all_messages = [msg for msgs in results.values() for msg in msgs]
        assert any("Cr\u00e9\u00e9" in m for m in all_messages)


# =========================================================================
# Tests — idempotency
# =========================================================================


class TestSeedIdempotent:
    """Verify that re-running ``seed()`` does not duplicate data."""

    def test_double_seed_does_not_duplicate_roles(self, db_session: Session) -> None:
        seed(db_session)
        seed(db_session)
        count = db_session.execute(select(func.count()).select_from(Role)).scalar()
        assert count == 2

    def test_double_seed_does_not_duplicate_admin(self, db_session: Session) -> None:
        seed(db_session)
        seed(db_session)
        stmt = select(func.count()).select_from(User).where(  # type: ignore[arg-type]
            User.email == "admin@csm-gias.tn",
        )
        count = db_session.execute(stmt).scalar()
        assert count == 1

    def test_double_seed_does_not_duplicate_receptionist(self, db_session: Session) -> None:
        seed(db_session)
        seed(db_session)
        stmt = select(func.count()).select_from(User).where(  # type: ignore[arg-type]
            User.email == "reception@csm-gias.tn",
        )
        count = db_session.execute(stmt).scalar()
        assert count == 1

    def test_double_seed_does_not_duplicate_categories(self, db_session: Session) -> None:
        seed(db_session)
        seed(db_session)
        count = db_session.execute(select(func.count()).select_from(MealCategory)).scalar()
        assert count == 3

    def test_double_seed_reports_existing(self, db_session: Session) -> None:
        seed(db_session)  # first call
        results = seed(db_session)  # second call
        for section, messages in results.items():
            for msg in messages:
                assert "Cr\u00e9\u00e9" not in msg  # should not create anything new


# =========================================================================
# Tests — standalone mode (session created internally)
# =========================================================================


class TestSeedStandalone:
    """Smoke-test that ``seed(None)`` works (creates its own session).

    These tests use a temporary engine injected by altering the
    global ``SessionLocal`` — only possible because the test runs
    against SQLite and the connection URL is set at import time.
    """

    def test_standalone_does_not_crash(self) -> None:
        """Call seed() without a session — just verify no exception."""
        from app.database import session as db_session_module

        original_url = db_session_module.engine.url
        db_session_module.engine = _TEST_ENGINE
        db_session_module.SessionLocal.configure(bind=_TEST_ENGINE)

        try:
            results = seed()
            assert results is not None
        finally:
            db_session_module.engine = create_engine(original_url)
            db_session_module.SessionLocal.configure(bind=db_session_module.engine)


# =========================================================================
# Tests — persistence across sessions (regression)
# =========================================================================


class TestPersistenceAcrossSessions:
    """Verify that committed data survives ``close()`` + new session.

    These tests guard against the root cause where data was flushed but
    never committed, causing it to disappear when the session closed.
    """

    def test_intern_persists_after_commit_and_close(
        self,
        db_session: Session,
    ) -> None:
        from datetime import date

        from app.models.intern import Intern
        from app.models.user import StatutUtilisateur
        from app.repositories.intern import InternRepository

        repo = InternRepository()
        intern = repo.create(
            db_session,
            nom="Persist",
            prenom="Test",
            email="persist.intern@test.tn",
            mot_de_passe=hash_password("Test@123"),
            statut=StatutUtilisateur.ACTIF,
            matricule="PERSIST001",
            date_debut_stage=date(2026, 1, 1),
            date_fin_stage=date(2026, 12, 31),
        )

        db_session.commit()
        db_session.close()

        new_session = Session(bind=_TEST_ENGINE)
        try:
            stmt = select(Intern).where(Intern.email == "persist.intern@test.tn")
            found = new_session.execute(stmt).scalar_one_or_none()
            assert found is not None
            assert found.nom == "Persist"
        finally:
            new_session.close()

    def test_employee_persists_after_commit_and_close(
        self,
        db_session: Session,
    ) -> None:
        from app.models.employee import Employee
        from app.models.user import StatutUtilisateur
        from app.repositories.employee import EmployeeRepository

        repo = EmployeeRepository()
        employee = repo.create(
            db_session,
            nom="Persist",
            prenom="Employee",
            email="persist.employee@test.tn",
            mot_de_passe=hash_password("Test@123"),
            statut=StatutUtilisateur.ACTIF,
            matricule="PERSIST002",
        )

        db_session.commit()
        db_session.close()

        new_session = Session(bind=_TEST_ENGINE)
        try:
            stmt = select(Employee).where(
                Employee.email == "persist.employee@test.tn",
            )
            found = new_session.execute(stmt).scalar_one_or_none()
            assert found is not None
            assert found.nom == "Persist"
        finally:
            new_session.close()

    def test_visitor_persists_after_commit_and_close(
        self,
        db_session: Session,
    ) -> None:
        from app.models.visitor import Visitor
        from app.models.user import StatutUtilisateur
        from app.repositories.visitor import VisitorRepository
        from datetime import date

        repo = VisitorRepository()
        visitor = repo.create(
            db_session,
            nom="Persist",
            prenom="Visitor",
            email="persist.visitor@test.tn",
            mot_de_passe=hash_password("Test@123"),
            statut=StatutUtilisateur.ACTIF,
            societe="Test Corp",
            date_visite=date(2026, 7, 5),
        )

        db_session.commit()
        db_session.close()

        new_session = Session(bind=_TEST_ENGINE)
        try:
            stmt = select(Visitor).where(
                Visitor.email == "persist.visitor@test.tn",
            )
            found = new_session.execute(stmt).scalar_one_or_none()
            assert found is not None
            assert found.nom == "Persist"
        finally:
            new_session.close()
