"""Acceptance checks for the complete Alembic chain and grant migration."""

import os
import subprocess
import sys
from pathlib import Path

import pytest
from sqlalchemy import create_engine, inspect

_PREVIOUS_REVISION = "ae9214788096"
_HEAD_REVISION = "b4d62f9c31a8"


def _alembic(project_root: Path, database_url: str, *args: str) -> None:
    environment = os.environ.copy()
    environment["ALEMBIC_DATABASE_URL"] = database_url
    subprocess.run(
        [sys.executable, "-m", "alembic", *args],
        cwd=project_root,
        env=environment,
        check=True,
        capture_output=True,
        text=True,
    )


def test_fresh_chain_grant_upgrade_and_targeted_downgrade() -> None:
    project_root = Path(__file__).resolve().parents[1]
    database_url = os.getenv("MIGRATION_TEST_DATABASE_URL")
    if not database_url:
        pytest.skip(
            "Set MIGRATION_TEST_DATABASE_URL to a disposable empty MySQL database; "
            "the historical chain uses ALTER CONSTRAINT operations unsupported by SQLite."
        )

    _alembic(project_root, database_url, "upgrade", _PREVIOUS_REVISION)
    engine = create_engine(database_url)
    assert "utilisateur" in inspect(engine).get_table_names()
    assert "identification_grant" not in inspect(engine).get_table_names()

    _alembic(project_root, database_url, "upgrade", "head")
    inspector = inspect(engine)
    assert inspector.get_table_names().count("identification_grant") == 1
    columns = {column["name"]: column for column in inspector.get_columns("identification_grant")}
    assert columns["token_hash"]["nullable"] is False
    assert columns["expires_at"]["nullable"] is False
    assert columns["consumed_at"]["nullable"] is True

    indexes = {index["name"]: index for index in inspector.get_indexes("identification_grant")}
    assert indexes["ix_identification_grant_token_hash"]["unique"] == 1
    assert "ix_identification_grant_expires_at" in indexes
    assert "ix_identification_grant_consumed_at" in indexes
    assert "ix_identification_grant_utilisateur_uuid" in indexes

    foreign_keys = {
        foreign_key["name"] for foreign_key in inspector.get_foreign_keys("identification_grant")
    }
    assert foreign_keys == {
        "fk_identification_grant_qr_uuid_qr_code",
        "fk_identification_grant_utilisateur_uuid_utilisateur",
    }

    _alembic(project_root, database_url, "downgrade", _PREVIOUS_REVISION)
    inspector = inspect(engine)
    assert "identification_grant" not in inspector.get_table_names()
    assert "utilisateur" in inspector.get_table_names()

    _alembic(project_root, database_url, "upgrade", _HEAD_REVISION)
    assert "identification_grant" in inspect(engine).get_table_names()
    engine.dispose()
