"""Comprehensive tests for the Meal Registration module.

Covers: opening hours, duplicate prevention, valid QR registration,
intern workflow, visitor workflow, pagination, history, auth.
"""

from datetime import UTC, date, datetime, timedelta

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import select as _select
from sqlalchemy.orm import Session

from app.models.meal_category import MealCategory
from app.services.meal_service import MealService, is_restaurant_open
from tests.test_auth import _auth_header, _login_payload, _seed_admin
from tests.test_qr_codes import _seed_intern, _seed_visitor

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_WITHIN_HOURS = datetime(2026, 7, 4, 12, 0, tzinfo=UTC)  # 13:00 Casablanca


def _login(client: TestClient, db_session: Session) -> str:
    _seed_admin(db_session)
    resp = client.post("/api/v1/auth/login", json=_login_payload())
    return resp.json()["data"]["token"]["access_token"]


def _seed_categories(db: Session) -> dict[str, str]:
    """Seed the three static meal categories and return a {nom: uuid} map."""
    MealService.seed_categories(db)
    cats = {}
    for nom in ("Plat", "Pizza", "Sandwich"):
        cat = db.execute(_select(MealCategory).where(MealCategory.nom == nom)).scalar_one()
        cats[nom] = cat.uuid
    return cats


def _generate_qr_for_intern(client, token, intern_uuid):
    resp = client.post(
        f"/api/v1/qr/generate/intern/{intern.uuid}",
        headers=_auth_header(token),
    )
    return resp.json()["data"]["qr_token"]


def _register_meal(client, token, qr_token, categorie_uuid):
    return client.post(
        "/api/v1/meals/register",
        json={"token": qr_token, "categorie_uuid": categorie_uuid},
        headers=_auth_header(token),
    )


# ---------------------------------------------------------------------------
# Test is_restaurant_open
# ---------------------------------------------------------------------------


class TestRestaurantHours:
    """Verify the opening-hours check logic."""

    def test_open_during_service(self):
        assert is_restaurant_open(datetime(2026, 7, 4, 11, 30, tzinfo=UTC)) is True

    def test_open_just_before_close(self):
        assert is_restaurant_open(datetime(2026, 7, 4, 12, 59, tzinfo=UTC)) is True

    def test_closed_before_opening(self):
        assert is_restaurant_open(datetime(2026, 7, 4, 11, 29, tzinfo=UTC)) is False

    def test_closed_after_closing(self):
        assert is_restaurant_open(datetime(2026, 7, 4, 13, 0, tzinfo=UTC)) is False

    def test_closed_at_midnight(self):
        assert is_restaurant_open(datetime(2026, 7, 4, 0, 0, tzinfo=UTC)) is False

    def test_open_edge_start(self):
        assert is_restaurant_open(datetime(2026, 7, 4, 11, 30, 0, tzinfo=UTC)) is True

    def test_closed_edge_end(self):
        assert is_restaurant_open(datetime(2026, 7, 4, 13, 0, 0, tzinfo=UTC)) is False


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------


class TestMealRegistration:
    """POST /api/v1/meals/register"""

    def test_register_intern_meal(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        cats = _seed_categories(db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_token = gen_resp.json()["data"]["qr_token"]

        resp = _register_meal(client, token, qr_token, cats["Plat"])
        assert resp.status_code == 201
        body = resp.json()
        assert body["success"] is True
        assert body["data"]["type_identification"] == "QR"
        assert body["data"]["categorie_uuid"] == cats["Plat"]
        assert body["data"]["utilisateur_uuid"] == intern.uuid
        assert body["data"]["date_repas"] == str(datetime.now(UTC).date())

    def test_register_visitor_meal(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        cats = _seed_categories(db_session)
        visitor = _seed_visitor(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/visitor/{visitor.uuid}",
            headers=_auth_header(token),
        )
        qr_token = gen_resp.json()["data"]["qr_token"]

        resp = _register_meal(client, token, qr_token, cats["Pizza"])
        assert resp.status_code == 201
        assert resp.json()["data"]["categorie_uuid"] == cats["Pizza"]

    def test_register_meal_different_categories(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        cats = _seed_categories(db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_token = gen_resp.json()["data"]["qr_token"]

        for cat_name in ("Plat", "Pizza", "Sandwich"):
            intern2 = _seed_intern(db_session, email=f"{cat_name}@test.com", matricule=f"INT{cat_name}")
            gen2 = client.post(
                f"/api/v1/qr/generate/intern/{intern2.uuid}",
                headers=_auth_header(token),
            )
            qr2 = gen2.json()["data"]["qr_token"]
            resp = _register_meal(client, token, qr2, cats[cat_name])
            assert resp.status_code == 201

    def test_register_duplicate_meal(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        cats = _seed_categories(db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_token = gen_resp.json()["data"]["qr_token"]

        resp1 = _register_meal(client, token, qr_token, cats["Plat"])
        assert resp1.status_code == 201

        resp2 = _register_meal(client, token, qr_token, cats["Pizza"])
        assert resp2.status_code == 409

    def test_register_with_invalid_qr(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        cats = _seed_categories(db_session)

        resp = _register_meal(client, token, "invalid-token-that-is-long-enough", cats["Plat"])
        assert resp.status_code == 400

    def test_register_with_unknown_category(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_token = gen_resp.json()["data"]["qr_token"]

        resp = _register_meal(client, token, qr_token, "nonexistent-category-uuid")
        assert resp.status_code == 404

    def test_register_revoked_qr(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        cats = _seed_categories(db_session)
        intern = _seed_intern(db_session)

        gen_resp = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_token = gen_resp.json()["data"]["qr_token"]
        qr_uuid = gen_resp.json()["data"]["uuid"]

        client.post(f"/api/v1/qr/revoke/{qr_uuid}", headers=_auth_header(token))

        resp = _register_meal(client, token, qr_token, cats["Plat"])
        assert resp.status_code == 400


class TestMealPagination:
    """GET /api/v1/meals"""

    def _seed_meals(self, client, token, db_session, cats, count: int):
        """Create *count* meals by seeding distinct interns."""
        meals = []
        for i in range(count):
            intern = _seed_intern(
                db_session,
                email=f"intern{i}@test.com",
                matricule=f"INT{i:03d}",
            )
            gen = client.post(
                f"/api/v1/qr/generate/intern/{intern.uuid}",
                headers=_auth_header(token),
            )
            qr_token = gen.json()["data"]["qr_token"]
            resp = _register_meal(client, token, qr_token, cats["Plat"])
            meals.append(resp.json()["data"]["uuid"])
        return meals

    def test_list_meals_default_pagination(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        cats = _seed_categories(db_session)
        self._seed_meals(client, token, db_session, cats, 5)

        resp = client.get("/api/v1/meals", headers=_auth_header(token))
        assert resp.status_code == 200
        body = resp.json()
        assert body["total"] == 5
        assert len(body["data"]) == 5

    def test_list_meals_pagination(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        cats = _seed_categories(db_session)
        self._seed_meals(client, token, db_session, cats, 10)

        resp = client.get("/api/v1/meals?page=1&page_size=3", headers=_auth_header(token))
        assert resp.status_code == 200
        body = resp.json()
        assert body["total"] == 10
        assert len(body["data"]) == 3
        assert body["page"] == 1
        assert body["page_size"] == 3
        assert body["total_pages"] == 4


class TestMealGet:
    """GET /api/v1/meals/{uuid}"""

    def test_get_meal(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        cats = _seed_categories(db_session)
        intern = _seed_intern(db_session)

        gen = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_token = gen.json()["data"]["qr_token"]
        reg = _register_meal(client, token, qr_token, cats["Plat"])
        meal_uuid = reg.json()["data"]["uuid"]

        resp = client.get(f"/api/v1/meals/{meal_uuid}", headers=_auth_header(token))
        assert resp.status_code == 200
        assert resp.json()["data"]["uuid"] == meal_uuid
        assert resp.json()["data"]["categorie_nom"] == "Plat"

    def test_get_meal_not_found(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)

        resp = client.get("/api/v1/meals/nonexistent-uuid", headers=_auth_header(token))
        assert resp.status_code == 404


class TestMealHistory:
    """GET /api/v1/meals/history/{user_uuid}"""

    def test_get_meal_history(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        cats = _seed_categories(db_session)
        intern = _seed_intern(db_session)

        gen = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_token = gen.json()["data"]["qr_token"]
        _register_meal(client, token, qr_token, cats["Plat"])

        resp = client.get(
            f"/api/v1/meals/history/{intern.uuid}",
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert len(resp.json()["data"]) == 1

    def test_get_meal_history_unknown_user(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)

        resp = client.get(
            "/api/v1/meals/history/nonexistent-uuid",
            headers=_auth_header(token),
        )
        assert resp.status_code == 404


class TestMealToday:
    """GET /api/v1/meals/today"""

    def test_get_today_meals(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        cats = _seed_categories(db_session)
        intern = _seed_intern(db_session)

        gen = client.post(
            f"/api/v1/qr/generate/intern/{intern.uuid}",
            headers=_auth_header(token),
        )
        qr_token = gen.json()["data"]["qr_token"]
        _register_meal(client, token, qr_token, cats["Plat"])

        resp = client.get("/api/v1/meals/today", headers=_auth_header(token))
        assert resp.status_code == 200
        assert len(resp.json()["data"]) >= 1


class TestMealAuth:
    """Authentication for meal endpoints."""

    def test_without_token_returns_401(self, client: TestClient, db_session: Session) -> None:
        resp = client.post("/api/v1/meals/register", json={"token": "x", "categorie_uuid": "x"})
        assert resp.status_code == 401

    def test_with_invalid_token_returns_401(self, client: TestClient, db_session: Session) -> None:
        resp = client.get(
            "/api/v1/meals",
            headers={"Authorization": "Bearer invalid"},
        )
        assert resp.status_code == 401


class TestMealServiceDirect:
    """Unit-style tests for MealService calling QR and user methods directly."""

    def test_register_by_user_uuid(self, db_session: Session) -> None:
        MealService.seed_categories(db_session)

        cat = db_session.execute(_select(MealCategory).where(MealCategory.nom == "Plat")).scalar_one()

        intern = _seed_intern(db_session)

        service = MealService()
        meal = service.register_by_user_uuid(
            db_session,
            user_uuid=intern.uuid,
            categorie_uuid=cat.uuid,
            type_identification="FACE",
            _now=_WITHIN_HOURS,
        )
        assert meal.type_identification == "FACE"
        assert meal.utilisateur_uuid == intern.uuid

    def test_register_by_user_uuid_duplicate(self, db_session: Session) -> None:
        MealService.seed_categories(db_session)

        cat = db_session.execute(_select(MealCategory).where(MealCategory.nom == "Plat")).scalar_one()
        intern = _seed_intern(db_session)

        service = MealService()
        service.register_by_user_uuid(db_session, intern.uuid, cat.uuid, _now=_WITHIN_HOURS)

        from app.core.exceptions import ConflictException

        with pytest.raises(ConflictException):
            service.register_by_user_uuid(db_session, intern.uuid, cat.uuid, _now=_WITHIN_HOURS)

    @staticmethod
    def test_register_outside_hours(db_session: Session) -> None:
        MealService.seed_categories(db_session)

        cat = db_session.execute(_select(MealCategory).where(MealCategory.nom == "Plat")).scalar_one()
        intern = _seed_intern(db_session)

        from unittest import mock

        from app.core.exceptions import BusinessException

        with mock.patch("app.services.meal_service.is_restaurant_open") as mock_open:
            mock_open.side_effect = lambda now=None: False
            service = MealService()
            closed_time = datetime(2026, 7, 4, 6, 0, tzinfo=UTC)  # 07:00 Casablanca

            with pytest.raises(BusinessException, match="fermé"):
                service.register_by_user_uuid(
                    db_session, intern.uuid, cat.uuid, _now=closed_time,
                )
