"""Comprehensive tests for the Receptionist management module.

Covers: CRUD, soft-delete, pagination, search, auth.
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


def _receptionist_payload(**overrides: object) -> dict:
    payload = {
        "nom": "Petit",
        "prenom": "Marie",
        "email": "marie.petit@example.com",
        "statut": "ACTIF",
    }
    payload.update(overrides)
    return payload


class TestReceptionistCRUD:
    """Full CRUD lifecycle for receptionists."""

    def test_create_receptionist(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.post(
            "/api/v1/receptionists",
            json=_receptionist_payload(),
            headers=_auth_header(token),
        )
        assert resp.status_code == 201
        body = resp.json()
        assert body["success"] is True
        assert body["data"]["nom"] == "Petit"
        assert body["data"]["uuid"] is not None

    def test_get_receptionist(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/receptionists",
            json=_receptionist_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.get(f"/api/v1/receptionists/{uuid}", headers=_auth_header(token))
        assert resp.status_code == 200
        assert resp.json()["data"]["uuid"] == uuid

    def test_get_receptionist_not_found(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.get("/api/v1/receptionists/nonexistent-uuid", headers=_auth_header(token))
        assert resp.status_code == 404

    def test_update_receptionist(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/receptionists",
            json=_receptionist_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.put(
            f"/api/v1/receptionists/{uuid}",
            json={"nom": "Moreau", "prenom": "Luc"},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["nom"] == "Moreau"

    def test_patch_receptionist(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/receptionists",
            json=_receptionist_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.patch(
            f"/api/v1/receptionists/{uuid}",
            json={"prenom": "Updated"},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["prenom"] == "Updated"

    def test_delete_receptionist_soft_delete(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/receptionists",
            json=_receptionist_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.delete(f"/api/v1/receptionists/{uuid}", headers=_auth_header(token))
        assert resp.status_code == 204

        get_resp = client.get(f"/api/v1/receptionists/{uuid}", headers=_auth_header(token))
        assert get_resp.status_code == 404


class TestReceptionistValidation:
    """Business rule validation for receptionists."""

    def test_duplicate_email(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        client.post(
            "/api/v1/receptionists",
            json=_receptionist_payload(),
            headers=_auth_header(token),
        )
        resp = client.post(
            "/api/v1/receptionists",
            json=_receptionist_payload(nom="Autre"),
            headers=_auth_header(token),
        )
        assert resp.status_code == 409

    def test_create_without_required_fields(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.post("/api/v1/receptionists", json={}, headers=_auth_header(token))
        assert resp.status_code == 422


class TestReceptionistPagination:
    """Pagination, sorting, and search."""

    def _seed_many(self, client: TestClient, token: str, count: int = 5) -> None:
        for i in range(count):
            client.post(
                "/api/v1/receptionists",
                json=_receptionist_payload(
                    nom=f"Nom{i+1}",
                    email=f"recept{i+1}@example.com",
                ),
                headers=_auth_header(token),
            )

    def test_pagination_defaults(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        self._seed_many(client, token)
        resp = client.get("/api/v1/receptionists", headers=_auth_header(token))
        assert resp.status_code == 200
        assert resp.json()["total"] >= 5

    def test_search_by_name(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        self._seed_many(client, token)
        resp = client.get("/api/v1/receptionists?search=Nom1", headers=_auth_header(token))
        assert resp.status_code == 200
        assert len(resp.json()["data"]) >= 1


class TestReceptionistAuth:
    """Authentication and authorization for receptionist endpoints."""

    def test_without_token_returns_401(self, client: TestClient) -> None:
        resp = client.get("/api/v1/receptionists")
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

        resp = client.get("/api/v1/receptionists", headers=_auth_header(token))
        assert resp.status_code == 401
