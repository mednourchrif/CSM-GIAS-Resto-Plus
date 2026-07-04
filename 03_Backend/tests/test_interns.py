"""Comprehensive tests for the Intern management module.

Covers: CRUD, soft-delete, pagination, search, date validation, auth.
"""

from datetime import UTC, datetime, timedelta

import jwt
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.user import StatutUtilisateur
from app.security.password import PasswordService
from tests.test_auth import _auth_header, _login_payload, _seed_admin

_PASSWORD = PasswordService()


def _login(client: TestClient, db_session: Session) -> str:
    _seed_admin(db_session)
    resp = client.post("/api/v1/auth/login", json=_login_payload())
    return resp.json()["data"]["token"]["access_token"]


def _intern_payload(**overrides: object) -> dict:
    payload = {
        "nom": "Martin",
        "prenom": "Sophie",
        "email": "sophie.martin@example.com",
        "matricule": "INT001",
        "date_debut_stage": "2026-01-01",
        "date_fin_stage": "2026-06-30",
        "statut": "ACTIF",
    }
    payload.update(overrides)
    return payload


class TestInternCRUD:
    """Full CRUD lifecycle for interns."""

    def test_create_intern(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.post(
            "/api/v1/interns",
            json=_intern_payload(),
            headers=_auth_header(token),
        )
        assert resp.status_code == 201
        body = resp.json()
        assert body["success"] is True
        assert body["data"]["nom"] == "Martin"
        assert body["data"]["matricule"] == "INT001"

    def test_get_intern(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/interns",
            json=_intern_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.get(f"/api/v1/interns/{uuid}", headers=_auth_header(token))
        assert resp.status_code == 200
        assert resp.json()["data"]["uuid"] == uuid

    def test_get_intern_not_found(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.get("/api/v1/interns/nonexistent-uuid", headers=_auth_header(token))
        assert resp.status_code == 404

    def test_update_intern(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/interns",
            json=_intern_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.put(
            f"/api/v1/interns/{uuid}",
            json={
                "nom": "Durand",
                "prenom": "Luc",
                "matricule": "INT002",
                "date_debut_stage": "2026-03-01",
                "date_fin_stage": "2026-09-30",
            },
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["nom"] == "Durand"

    def test_patch_intern(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/interns",
            json=_intern_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.patch(
            f"/api/v1/interns/{uuid}",
            json={"prenom": "Updated"},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["prenom"] == "Updated"

    def test_delete_intern_soft_delete(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/interns",
            json=_intern_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.delete(f"/api/v1/interns/{uuid}", headers=_auth_header(token))
        assert resp.status_code == 204

        get_resp = client.get(f"/api/v1/interns/{uuid}", headers=_auth_header(token))
        assert get_resp.status_code == 404


class TestInternValidation:
    """Business rule validation for interns."""

    def test_duplicate_matricule(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        client.post("/api/v1/interns", json=_intern_payload(), headers=_auth_header(token))
        resp = client.post("/api/v1/interns", json=_intern_payload(), headers=_auth_header(token))
        assert resp.status_code == 409

    def test_duplicate_email(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        client.post("/api/v1/interns", json=_intern_payload(), headers=_auth_header(token))
        resp = client.post(
            "/api/v1/interns",
            json=_intern_payload(matricule="INT002"),
            headers=_auth_header(token),
        )
        assert resp.status_code == 409

    def test_end_date_before_start_date(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.post(
            "/api/v1/interns",
            json=_intern_payload(
                date_debut_stage="2026-06-30",
                date_fin_stage="2026-01-01",
            ),
            headers=_auth_header(token),
        )
        assert resp.status_code == 422

    def test_create_without_required_fields(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.post("/api/v1/interns", json={}, headers=_auth_header(token))
        assert resp.status_code == 422


class TestInternPagination:
    """Pagination, sorting, and search."""

    def _seed_many(self, client: TestClient, token: str, count: int = 5) -> None:
        for i in range(count):
            client.post(
                "/api/v1/interns",
                json=_intern_payload(
                    matricule=f"INT{i+1:03d}",
                    nom=f"Nom{i+1}",
                    email=f"int{i+1}@example.com",
                ),
                headers=_auth_header(token),
            )

    def test_pagination_defaults(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        self._seed_many(client, token)
        resp = client.get("/api/v1/interns", headers=_auth_header(token))
        assert resp.status_code == 200
        assert resp.json()["total"] >= 5

    def test_search_by_name(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        self._seed_many(client, token)
        resp = client.get("/api/v1/interns?search=Nom1", headers=_auth_header(token))
        assert resp.status_code == 200
        assert len(resp.json()["data"]) >= 1


class TestInternAuth:
    """Authentication and authorization for intern endpoints."""

    def test_without_token_returns_401(self, client: TestClient) -> None:
        resp = client.get("/api/v1/interns")
        assert resp.status_code == 401

    def test_receptionist_cannot_access(self, client: TestClient, db_session: Session) -> None:
        from app.models.admin import Receptionist

        reception = Receptionist(
            nom="Recept",
            prenom="Test",
            email="recept@test.com",
            mot_de_passe=_PASSWORD.hash("StrongPass1!"),
            type="RECEPTION",
            statut=StatutUtilisateur.ACTIF,
        )
        db_session.add(reception)
        db_session.flush()

        now = datetime.now(UTC)
        token = jwt.encode(
            {
                "sub": str(reception.id),
                "uuid": reception.uuid,
                "role": None,
                "type": "RECEPTION",
                "iat": now,
                "exp": now + timedelta(minutes=30),
            },
            settings.JWT_SECRET_KEY,
            algorithm=settings.JWT_ALGORITHM,
        )

        resp = client.get("/api/v1/interns", headers=_auth_header(token))
        assert resp.status_code == 401
