"""Tests for the Face Recognition module.

Covers: enrollment, verification, identification, soft-delete,
image validation, and API auth gates.

The :class:`StubFaceRecognitionEngine` is used directly in service
tests so that real embeddings flow through the serialisation /
deserialisation pipeline.  For API-level tests the engine is mocked
to return predictable values.
"""

import base64
from io import BytesIO
from unittest.mock import patch

import numpy as np
import pytest
from fastapi.testclient import TestClient
from PIL import Image
from sqlalchemy.orm import Session

from app.ai.engine import FaceDetection, StubFaceRecognitionEngine
from app.models.employee import Employee
from app.models.face_embedding import FaceEmbedding
from app.repositories.face_repository import FaceEmbeddingRepository
from app.schemas.employee import EmployeeCreate
from app.schemas.face import FaceStatut
from app.services.employee_service import EmployeeService
from app.services.face_service import FaceService
from app.utils.image import decode_base64_image
from tests.test_auth import _auth_header, _login_payload, _seed_admin


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_PASSWORD = "Test1234!"


def _valid_image_base64() -> str:
    """Generate a valid 200×200 RGB image as a base64 data URI."""
    img = Image.new("RGB", (200, 200), color="blue")
    buf = BytesIO()
    img.save(buf, format="PNG")
    b64 = base64.b64encode(buf.getvalue()).decode()
    return f"data:image/png;base64,{b64}"


def _login(client: TestClient, db_session: Session) -> str:
    _seed_admin(db_session)
    resp = client.post("/api/v1/auth/login", json=_login_payload())
    return resp.json()["data"]["token"]["access_token"]


def _create_employee(db_session: Session) -> Employee:
    """Create an employee via the service layer (bypasses API auth)."""
    from app.models.admin import Admin

    admin = _seed_admin(db_session)

    service = EmployeeService()
    employee = service.create(
        db=db_session,
        data=EmployeeCreate(
            nom="Test",
            prenom="User",
            email="test.employee@example.com",
            matricule=f"FAC{np.random.randint(1000, 9999)}",
            statut="ACTIF",
        ),
        admin=admin,
    )
    db_session.flush()
    return employee


# ---------------------------------------------------------------------------
# Image utility tests
# ---------------------------------------------------------------------------


class TestDecodeBase64Image:
    def test_valid_png(self):
        img = _valid_image_base64()
        result = decode_base64_image(img)
        assert result.size == (200, 200)
        assert result.mode == "RGB"

    def test_invalid_format(self):
        from app.core.exceptions import ValidationException

        with pytest.raises(ValidationException):
            decode_base64_image("not-a-data-uri")

    def test_empty_string(self):
        from app.core.exceptions import ValidationException

        with pytest.raises(ValidationException):
            decode_base64_image("")


# ---------------------------------------------------------------------------
# Service tests — FaceService (with real stub engine)
# ---------------------------------------------------------------------------


@pytest.mark.usefixtures("app")
class TestFaceService:
    """Test face service business logic with the stub engine."""

    def test_enroll_success(self, db_session: Session):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))

        embedding, meal_registered = service.enroll(
            db=db_session,
            image_base64=_valid_image_base64(),
            user_uuid=employee.uuid,
        )

        assert embedding is not None
        assert embedding.active is True
        assert embedding.utilisateur_uuid == employee.uuid
        assert meal_registered is False

        repo = FaceEmbeddingRepository()
        stored = repo.get_active_by_user(db_session, employee.uuid)
        assert stored is not None
        assert stored.uuid == embedding.uuid

    def test_enroll_deactivates_previous(self, db_session: Session):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))

        service.enroll(db=db_session, image_base64=_valid_image_base64(), user_uuid=employee.uuid)
        service.enroll(db=db_session, image_base64=_valid_image_base64(), user_uuid=employee.uuid)

        repo = FaceEmbeddingRepository()
        all_embs = db_session.query(FaceEmbedding).filter(
            FaceEmbedding.utilisateur_uuid == employee.uuid,
        ).all()
        assert len(all_embs) == 2
        active = [e for e in all_embs if e.active]
        assert len(active) == 1

    def test_verify_match(self, db_session: Session):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))
        service.enroll(db=db_session, image_base64=_valid_image_base64(), user_uuid=employee.uuid)

        statut, confidence, uuid, nom, prenom, message = service.verify(
            db=db_session,
            image_base64=_valid_image_base64(),
            user_uuid=employee.uuid,
        )

        assert statut == FaceStatut.MATCH
        assert confidence is not None and confidence >= 0.5
        assert uuid == employee.uuid

    def test_verify_no_embedding(self, db_session: Session):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))

        statut, confidence, uuid, nom, prenom, message = service.verify(
            db=db_session,
            image_base64=_valid_image_base64(),
            user_uuid=employee.uuid,
        )

        assert statut == FaceStatut.NO_MATCH
        assert confidence is None

    def test_identify_no_embeddings(self, db_session: Session):
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))

        statut, confidence, uuid, nom, prenom, user_type, message = service.identify(
            db=db_session,
            image_base64=_valid_image_base64(),
        )

        assert statut == FaceStatut.NO_MATCH

    def test_identify_success(self, db_session: Session):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))
        service.enroll(db=db_session, image_base64=_valid_image_base64(), user_uuid=employee.uuid)

        statut, confidence, uuid, nom, prenom, user_type, message = service.identify(
            db=db_session,
            image_base64=_valid_image_base64(),
        )

        assert statut == FaceStatut.MATCH
        assert uuid == employee.uuid
        assert confidence is not None and confidence >= 0.5

    def test_delete_embedding(self, db_session: Session):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))
        embedding, _ = service.enroll(
            db=db_session, image_base64=_valid_image_base64(), user_uuid=employee.uuid,
        )

        service.delete_embedding(db_session, embedding.uuid)

        repo = FaceEmbeddingRepository()
        stored = repo.get_by_uuid(db_session, embedding.uuid)
        assert stored is not None
        assert stored.active is False

    def test_get_by_uuid_not_found(self, db_session: Session):
        service = FaceService()
        from app.core.exceptions import NotFoundException

        with pytest.raises(NotFoundException):
            service.get_by_uuid(db_session, "nonexistent-uuid")


# ---------------------------------------------------------------------------
# API tests — via TestClient
# ---------------------------------------------------------------------------


def _create_employee_via_api(client: TestClient, token: str) -> str:
    """Create an employee via the API and return its UUID."""
    resp = client.post(
        "/api/v1/employees",
        json={
            "nom": "Face",
            "prenom": "Test",
            "email": f"face.test.{np.random.randint(10000)}@example.com",
            "matricule": f"FCE{np.random.randint(1000, 9999)}",
            "statut": "ACTIF",
        },
        headers=_auth_header(token),
    )
    assert resp.status_code == 201
    return resp.json()["data"]["uuid"]


class TestFaceAPI:
    """Test face endpoints through the FastAPI TestClient."""

    _MOCK_EMBEDDING = np.random.default_rng(42).random(512).astype(np.float32)

    @pytest.fixture(autouse=True)
    def _patch_engine(self):
        with patch(
            "app.services.face_service.StubFaceRecognitionEngine.extract_embedding",
            return_value=self._MOCK_EMBEDDING,
        ):
            with patch(
                "app.services.face_service.StubFaceRecognitionEngine.detect_face",
                return_value=FaceDetection(bbox=(10, 10, 100, 100), confidence=0.95),
            ):
                yield

    def test_enroll_requires_auth(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        resp = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
        )
        assert resp.status_code == 401

    def test_enroll_success(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        resp = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )

        assert resp.status_code == 201
        data = resp.json()["data"]
        assert data["utilisateur_uuid"] == user_uuid
        assert data["active"] is True
        assert data["meal_registered"] is False

    def test_verify_success(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        enroll_resp = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        assert enroll_resp.status_code == 201

        resp = client.post(
            "/api/v1/face/verify",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert data["statut"] == "MATCH"

    def test_verify_no_embedding(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        resp = client.post(
            "/api/v1/face/verify",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert data["statut"] == "NO_MATCH"

    def test_identify_success(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )

        resp = client.post(
            "/api/v1/face/identify",
            json={"image_base64": _valid_image_base64()},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert data["statut"] == "MATCH"
        assert data["utilisateur_uuid"] == user_uuid

    def test_get_embedding(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        enroll_resp = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        embedding_uuid = enroll_resp.json()["data"]["uuid"]

        resp = client.get(
            f"/api/v1/face/{embedding_uuid}",
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert data["uuid"] == embedding_uuid
        assert data["utilisateur_uuid"] == user_uuid

    def test_delete_embedding(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        enroll_resp = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        embedding_uuid = enroll_resp.json()["data"]["uuid"]

        resp = client.delete(
            f"/api/v1/face/{embedding_uuid}",
            headers=_auth_header(token),
        )
        assert resp.status_code == 200

        get_resp = client.get(
            f"/api/v1/face/{embedding_uuid}",
            headers=_auth_header(token),
        )
        assert get_resp.json()["data"]["active"] is False

    def test_delete_requires_auth(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        enroll_resp = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        embedding_uuid = enroll_resp.json()["data"]["uuid"]

        resp = client.delete(
            f"/api/v1/face/{embedding_uuid}",
        )
        assert resp.status_code == 401
