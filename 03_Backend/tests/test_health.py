"""End-to-end tests for the health and readiness endpoints."""

from fastapi.testclient import TestClient


class TestHealthEndpoint:
    """Test suite for ``GET /api/v1/health`` and ``GET /api/v1/ready``."""

    def test_health_returns_200(self, client: TestClient) -> None:
        """Health endpoint returns HTTP 200."""
        response = client.get("/api/v1/health")
        assert response.status_code == 200

    def test_health_contains_expected_fields(self, client: TestClient) -> None:
        """Health response includes app name, version, and status."""
        body = client.get("/api/v1/health").json()
        data = body["data"]
        assert data["name"] == "CSM-GIAS Resto+"
        assert data["version"] == "1.0.0"
        assert data["status"] in ("healthy", "degraded")
        assert data["environment"] == "testing"

    def test_ready_returns_200(self, client: TestClient) -> None:
        """Readiness endpoint returns HTTP 200."""
        response = client.get("/api/v1/ready")
        assert response.status_code == 200
