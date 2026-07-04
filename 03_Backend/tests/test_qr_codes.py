"""Comprehensive tests for the QR Code management module.

Covers: generation, duplicate generation, validation, expiration,
revocation, regeneration, history, download, auth.
"""

from datetime import UTC, date, datetime, timedelta

import jwt
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.admin import Admin
from app.models.intern import Intern
from app.models.role import Role
from app.models.user import StatutUtilisateur
from app.models.visitor import Visitor
from app.security.password import PasswordService
from app.utils.qr_code import generate_token, hash_token
from tests.test_auth import _auth_header, _login_payload, _seed_admin

_PASSWORD = PasswordService()


# ---------------------------------------------------------------------------
# Seed helpers
# ---------------------------------------------------------------------------


def _seed_intern(db: Session, **overrides: object) -> Intern:
    intern = Intern(
        nom=overrides.get("nom", "Martin"),
        prenom=overrides.get("prenom", "Sophie"),
        email=overrides.get("email", "sophie.martin@example.com"),
        type="STAGIAIRE",
        statut=overrides.get("statut", StatutUtilisateur.ACTIF),
        matricule=overrides.get("matricule", "INT001"),
        date_debut_stage=overrides.get("date_debut_stage", date.today() - timedelta(days=30)),
        date_fin_stage=overrides.get("date_fin_stage", date.today() + timedelta(days=60)),
        langue="FR",
    )
    db.add(intern)
    db.flush()
    return intern


def _seed_visitor(db: Session, **overrides: object) -> Visitor:
    visitor = Visitor(
        nom=overrides.get("nom", "Bernard"),
        prenom=overrides.get("prenom", "Luc"),
        email=overrides.get("email", "luc.bernard@example.com"),
        type="VISITEUR",
        statut=overrides.get("statut", StatutUtilisateur.ACTIF),
        societe=overrides.get("societe", "Acme Corp"),
        date_visite=overrides.get("date_visite", date.today()),
        langue="FR",
    )
    db.add(visitor)
    db.flush()
    return visitor


def _login(client: TestClient, db_session: Session) -> str:
    _seed_admin(db_session)
    resp = client.post("/api/v1/auth/login", json=_login_payload())
    return resp.json()["data"]["token"]["access_token"]


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------


class TestQRGeneration:
    """POST /api/v1/qr/generate/intern/{uuid} and visitor variant."""

    def test_generate_intern_qr(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        assert resp.status_code == 201
        body = resp.json()
        assert body["success"] is True
        data = body["data"]
        assert data["type_proprietaire"] == "STAGIAIRE"
        assert data["proprietaire_uuid"] == intern.uuid
        assert data["statut"] == "ACTIF"
        assert data["qr_token"] is not None
        assert len(data["qr_token"]) == 64
        assert data["qr_base64"] is not None
        assert data["qr_base64"].startswith("data:image/png;base64,")

    def test_generate_visitor_qr(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        visitor = _seed_visitor(db_session)

        resp = client.post(
            f"/api/v1/qr/generate/visitor/{visitor.uuid}",
            headers=_auth_header(token),
        )
        assert resp.status_code == 201
        body = resp.json()
        assert body["success"] is True
        data = body["data"]
        assert data["type_proprietaire"] == "VISITEUR"
        assert data["proprietaire_uuid"] == visitor.uuid
        assert data["statut"] == "ACTIF"
        assert data["qr_token"] is not None
        assert len(data["qr_token"]) == 64

    def test_generate_intern_not_found(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)

        resp = client.post(
            "/api/v1/qr/generate/intern/nonexistent-uuid",
            headers=_auth_header(token),
        )
        assert resp.status_code == 404

    def test_generate_duplicate_revokes_previous(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        resp1 = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        assert resp1.status_code == 201
        first_uuid = resp1.json()["data"]["uuid"]

        resp2 = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        assert resp2.status_code == 201

        get_resp = client.get(f"/api/v1/qr/{first_uuid}", headers=_auth_header(token))
        assert get_resp.status_code == 200
        assert get_resp.json()["data"]["statut"] == "REVOQUE"


class TestQRValidation:
    """POST /api/v1/qr/validate"""

    def test_validate_valid_token(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        raw_token = gen_resp.json()["data"]["qr_token"]

        resp = client.post(
            "/api/v1/qr/validate",
            json={"token": raw_token},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        body = resp.json()
        assert body["data"]["statut"] == "VALID"
        assert body["data"]["qr_uuid"] is not None
        assert body["data"]["proprietaire_uuid"] == intern.uuid
        assert body["data"]["type_proprietaire"] == "STAGIAIRE"
        assert body["data"]["nom"] == "Martin"
        assert body["data"]["prenom"] == "Sophie"

    def test_validate_unknown_token(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)

        resp = client.post(
            "/api/v1/qr/validate",
            json={"token": "a" * 64},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["statut"] == "NOT_FOUND"

    def test_validate_revoked_qr(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_uuid = gen_resp.json()["data"]["uuid"]

        client.post(
            f"/api/v1/qr/revoke/{qr_uuid}",
            headers=_auth_header(token),
        )

        raw_token = gen_resp.json()["data"]["qr_token"]
        resp = client.post(
            "/api/v1/qr/validate",
            json={"token": raw_token},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["statut"] == "REVOKED"

    def test_validate_expired_qr(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(
            db_session,
            date_fin_stage=date.today() - timedelta(days=1),
        )

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        raw_token = gen_resp.json()["data"]["qr_token"]

        resp = client.post(
            "/api/v1/qr/validate",
            json={"token": raw_token},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["statut"] == "EXPIRED"

    def test_validate_owner_disabled(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        raw_token = gen_resp.json()["data"]["qr_token"]

        intern.statut = StatutUtilisateur.INACTIF
        db_session.flush()

        resp = client.post(
            "/api/v1/qr/validate",
            json={"token": raw_token},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["statut"] == "OWNER_DISABLED"

    def test_validate_invalid_token_format(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)

        resp = client.post(
            "/api/v1/qr/validate",
            json={"token": "short"},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["statut"] == "INVALID"


class TestQRRevocation:
    """POST /api/v1/qr/revoke/{uuid}"""

    def test_revoke_active_qr(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_uuid = gen_resp.json()["data"]["uuid"]

        resp = client.post(
            f"/api/v1/qr/revoke/{qr_uuid}",
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        body = resp.json()
        assert body["data"]["statut"] == "REVOQUE"
        assert body["data"]["motif_revocation"] == "Révoqué manuellement"
        assert body["data"]["date_revocation"] is not None

    def test_revoke_not_found(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)

        resp = client.post(
            "/api/v1/qr/revoke/nonexistent-uuid",
            headers=_auth_header(token),
        )
        assert resp.status_code == 404

    def test_revoke_already_revoked(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_uuid = gen_resp.json()["data"]["uuid"]

        client.post(f"/api/v1/qr/revoke/{qr_uuid}", headers=_auth_header(token))
        resp = client.post(f"/api/v1/qr/revoke/{qr_uuid}", headers=_auth_header(token))
        assert resp.status_code == 400


class TestQRRegeneration:
    """POST /api/v1/qr/regenerate/{uuid}"""

    def test_regenerate_intern_qr(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        old_uuid = gen_resp.json()["data"]["uuid"]

        resp = client.post(
            f"/api/v1/qr/regenerate/{intern.uuid}?owner_type=STAGIAIRE",
            headers=_auth_header(token),
        )
        assert resp.status_code == 201
        new_uuid = resp.json()["data"]["uuid"]
        assert new_uuid != old_uuid

        get_old = client.get(f"/api/v1/qr/{old_uuid}", headers=_auth_header(token))
        assert get_old.json()["data"]["statut"] == "REVOQUE"


class TestQRGet:
    """GET /api/v1/qr/{uuid}"""

    def test_get_qr(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_uuid = gen_resp.json()["data"]["uuid"]

        resp = client.get(f"/api/v1/qr/{qr_uuid}", headers=_auth_header(token))
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert data["uuid"] == qr_uuid
        assert data["proprietaire_uuid"] == intern.uuid
        assert data["statut"] == "ACTIF"
        assert data["qr_base64"] is not None
        assert data["qr_base64"].startswith("data:image/png;base64,")

    def test_get_qr_not_found(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)

        resp = client.get("/api/v1/qr/nonexistent-uuid", headers=_auth_header(token))
        assert resp.status_code == 404


class TestQRHistory:
    """GET /api/v1/qr/history/{owner_uuid}"""

    def test_get_qr_history(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )

        resp = client.get(
            f"/api/v1/qr/history/{intern.uuid}",
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert len(data) == 2

    def test_get_qr_history_unknown_owner(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)

        resp = client.get(
            "/api/v1/qr/history/nonexistent-uuid",
            headers=_auth_header(token),
        )
        assert resp.status_code == 404


class TestQRDownload:
    """GET /api/v1/qr/download/{uuid}"""

    def test_download_qr(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_uuid = gen_resp.json()["data"]["uuid"]

        resp = client.get(
            f"/api/v1/qr/download/{qr_uuid}",
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.headers["content-type"] == "image/png"
        assert resp.headers["content-disposition"] == f'attachment; filename=qr_{qr_uuid}.png'
        assert int(resp.headers["content-length"]) > 100


class TestQRWorkflows:
    """Integration workflows combining multiple QR operations."""

    def test_visitor_full_lifecycle(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        visitor = _seed_visitor(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/visitor/{visitor.uuid}",
            headers=_auth_header(token),
        )
        assert gen_resp.status_code == 201
        raw_token = gen_resp.json()["data"]["qr_token"]
        qr_uuid = gen_resp.json()["data"]["uuid"]

        valid_resp = client.post(
            "/api/v1/qr/validate",
            json={"token": raw_token},
            headers=_auth_header(token),
        )
        assert valid_resp.json()["data"]["statut"] == "VALID"

        revoke_resp = client.post(
            f"/api/v1/qr/revoke/{qr_uuid}",
            headers=_auth_header(token),
        )
        assert revoke_resp.json()["data"]["statut"] == "REVOQUE"

        valid_after = client.post(
            "/api/v1/qr/validate",
            json={"token": raw_token},
            headers=_auth_header(token),
        )
        assert valid_after.json()["data"]["statut"] == "REVOKED"

    def test_intern_regenerate_workflow(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        gen1 = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        first_token = gen1.json()["data"]["qr_token"]
        first_uuid = gen1.json()["data"]["uuid"]

        gen2 = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        second_token = gen2.json()["data"]["qr_token"]
        second_uuid = gen2.json()["data"]["uuid"]

        assert first_uuid != second_uuid
        assert first_token != second_token

        old_valid = client.post(
            "/api/v1/qr/validate",
            json={"token": first_token},
            headers=_auth_header(token),
        )
        assert old_valid.json()["data"]["statut"] == "REVOKED"

        new_valid = client.post(
            "/api/v1/qr/validate",
            json={"token": second_token},
            headers=_auth_header(token),
        )
        assert new_valid.json()["data"]["statut"] == "VALID"


class TestQRAuth:
    """Authentication and authorisation for QR endpoints."""

    def test_without_token_returns_401(self, client: TestClient, db_session: Session) -> None:
        resp = client.post("/api/v1/qr/generate/intern/some-uuid")
        assert resp.status_code == 401

    def test_with_invalid_token_returns_401(self, client: TestClient, db_session: Session) -> None:
        resp = client.post(
            "/api/v1/qr/generate/intern/some-uuid",
            headers={"Authorization": "Bearer invalidtoken"},
        )
        assert resp.status_code == 401

    def test_receptionist_cannot_generate_intern_qr(self, client: TestClient, db_session: Session) -> None:
        _seed_admin(db_session)
        role = db_session.query(Role).first()
        receptionist = Admin(
            nom="Recep",
            prenom="Test",
            email="recep@test.com",
            mot_de_passe=_PASSWORD.hash("StrongPass1!"),
            type="RECEPTION",
            statut=StatutUtilisateur.ACTIF,
            role_id=role.id,
            langue="FR",
        )
        db_session.add(receptionist)
        db_session.flush()

        payload = {
            "sub": str(receptionist.id),
            "uuid": receptionist.uuid,
            "type": "RECEPTION",
            "exp": datetime.now(UTC) + timedelta(hours=1),
        }
        recep_token = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)

        resp = client.post(
            "/api/v1/qr/generate/intern/some-uuid",
            headers=_auth_header(recep_token),
        )
        assert resp.status_code == 401
