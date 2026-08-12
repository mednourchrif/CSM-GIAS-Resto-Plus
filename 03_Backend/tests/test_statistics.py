"""Tests for the statistics dashboard endpoints."""

from datetime import UTC, date, datetime, timedelta

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.models.meal import Meal
from tests.test_auth import _auth_header, _login_payload, _seed_admin
from tests.test_meals import _seed_categories, _seed_intern


def _login(client: TestClient, db_session: Session) -> str:
    _seed_admin(db_session)
    resp = client.post("/api/v1/auth/login", json=_login_payload())
    return resp.json()["data"]["token"]["access_token"]


class TestDashboardStats:
    """GET /api/v1/stats/dashboard"""

    def test_dashboard_includes_next_day_forecast(
        self,
        client: TestClient,
        db_session: Session,
        monkeypatch,
    ) -> None:
        token = _login(client, db_session)
        cats = _seed_categories(db_session)
        intern = _seed_intern(db_session)

        today = date(2026, 7, 10)
        monkeypatch.setattr("app.api.v1.stats.today_local", lambda: today)

        for offset in range(1, 8):
            meal_date = today - timedelta(days=offset)
            db_session.add(
                Meal(
                    utilisateur_uuid=intern.uuid,
                    categorie_uuid=cats["Plat"],
                    type_identification="QR",
                    date_repas=meal_date,
                    heure_repas=datetime.combine(meal_date, datetime.min.time(), tzinfo=UTC),
                )
            )
        db_session.flush()

        resp = client.get("/api/v1/stats/dashboard", headers=_auth_header(token))
        assert resp.status_code == 200
        assert resp.json()["data"]["overview"]["forecast_meals_next_day"] == 1