"""Database seeding script for CSM-GIAS Resto+.

Idempotent — safe to run multiple times.  Never duplicates data.

Usage
-----
    python scripts/seed.py

This script must be executed from the ``03_Backend`` directory (the one
containing ``.env``, ``alembic.ini``, and the ``app/`` package).
"""

from __future__ import annotations

import sys
from pathlib import Path

# Add the project root to sys.path so the ``app`` package can be
# imported regardless of the working directory.
_project_root = Path(__file__).resolve().parent.parent
if str(_project_root) not in sys.path:
    sys.path.insert(0, str(_project_root))

from collections.abc import Mapping, Sequence
from typing import Any

from loguru import logger
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.models.admin import Admin, Receptionist
from app.models.meal_category import MealCategory
from app.models.role import Role
from app.models.user import StatutUtilisateur, User
from app.repositories.role import RoleRepository
from app.services.meal_service import MealService
from app.utils.password import hash_password

# =========================================================================
# Seed data definitions
# =========================================================================

ROLE_DEFINITIONS: list[dict[str, str | None]] = [
    {"nom": "ADMIN", "description": "Administrateur système"},
    {"nom": "RECEPTION", "description": "Agent de réception"},
]

ADMIN_EMAIL = "admin@csm-gias.tn"
ADMIN_PASSWORD = "Admin@123"

RECEPTION_EMAIL = "reception@csm-gias.tn"
RECEPTION_PASSWORD = "Reception@123"

# =========================================================================
# Seed implementation
# =========================================================================


def seed(db: Session | None = None) -> dict[str, Sequence[str]]:
    """Execute all seed steps in the correct order.

    Idempotent — safe to call repeatedly on the same database.

    Parameters
    ----------
    db:
        Optional SQLAlchemy session.  When ``None`` (the default) a new
        session is obtained via ``SessionLocal`` and committed on success
        or rolled back on failure.

    Returns
    -------
    dict[str, list[str]]
        A dictionary keyed by section label, each item carrying a list
        of status messages shown in the terminal summary.
    """
    close_session = False
    if db is None:
        db = SessionLocal()
        close_session = True

    results: dict[str, Sequence[str]] = {}

    try:
        results["Roles"] = _seed_roles(db)
        results["Administrateur"] = _seed_admin(db)
        results["R\u00e9ception"] = _seed_receptionist(db)
        results["Cat\u00e9gories"] = _seed_categories(db)

        db.commit()
        logger.info("Seed transaction committed.")
    except Exception:
        logger.exception("Seed failed — rolling back.")
        db.rollback()
        raise
    finally:
        if close_session:
            db.close()

    return results


def _seed_roles(db: Session) -> list[str]:
    """Create roles if they do not already exist."""
    repo = RoleRepository()
    messages: list[str] = []
    for definition in ROLE_DEFINITIONS:
        nom = definition["nom"]
        description = definition["description"]
        if repo.get_by_nom(db, nom) is not None:
            messages.append(f"{nom}: Existe")
        else:
            repo.create(db, nom=nom, description=description)
            messages.append(f"{nom}: Cr\u00e9\u00e9")
    return messages


def _seed_admin(db: Session) -> list[str]:
    """Create default administrator if absent."""
    stmt = select(User).where(User.email == ADMIN_EMAIL)
    existing = db.execute(stmt).scalar_one_or_none()
    if existing is not None:
        return ["Administrateur: Existe"]

    repo = RoleRepository()
    admin_role = repo.get_by_nom(db, "ADMIN")

    password_hash = hash_password(ADMIN_PASSWORD)
    admin = Admin(
        nom="System",
        prenom="Administrator",
        email=ADMIN_EMAIL,
        mot_de_passe=password_hash,
        statut=StatutUtilisateur.ACTIF,
        role_id=admin_role.id if admin_role is not None else None,
    )
    db.add(admin)
    db.flush()
    return ["Administrateur: Cr\u00e9\u00e9"]


def _seed_receptionist(db: Session) -> list[str]:
    """Create default receptionist if absent."""
    stmt = select(User).where(User.email == RECEPTION_EMAIL)
    existing = db.execute(stmt).scalar_one_or_none()
    if existing is not None:
        return ["R\u00e9ception: Existe"]

    password_hash = hash_password(RECEPTION_PASSWORD)
    receptionist = Receptionist(
        nom="Reception",
        prenom="Restaurant",
        email=RECEPTION_EMAIL,
        mot_de_passe=password_hash,
        statut=StatutUtilisateur.ACTIF,
    )
    db.add(receptionist)
    db.flush()
    return ["R\u00e9ception: Cr\u00e9\u00e9"]


def _seed_categories(db: Session) -> list[str]:
    """Seed the three static meal categories.

    Delegates to ``MealService.seed_categories`` to avoid duplicating
    business logic.
    """
    before = db.execute(select(MealCategory)).scalars().all()
    MealService.seed_categories(db)
    after = db.execute(select(MealCategory)).scalars().all()
    created = len(after) - len(before)
    if created > 0:
        return [f"Cat\u00e9gories: Cr\u00e9\u00e9es ({created})"]
    return ["Cat\u00e9gories: Existantes"]


# =========================================================================
# Terminal output
# =========================================================================


def _format_summary(results: Mapping[str, Sequence[str]]) -> str:
    """Build a human-readable summary string."""
    lines: list[str] = []
    lines.append("=" * 40)
    lines.append("          Database Seed")
    lines.append("=" * 40)
    for section, messages in results.items():
        for msg in messages:
            lines.append(f"  {msg}")
    lines.append("=" * 40)
    lines.append("  Seed completed successfully")
    lines.append("=" * 40)
    return "\n".join(lines)


# =========================================================================
# CLI entry point
# =========================================================================


def main() -> None:
    """Entry point for ``python scripts/seed.py``."""
    logger.info("Starting database seed ...")
    try:
        results = seed()
        summary = _format_summary(results)
        print(f"\n{summary}\n")
        logger.info("Database seed completed successfully.")
    except Exception:
        logger.exception("Database seed failed.")
        sys.exit(1)


if __name__ == "__main__":
    main()
