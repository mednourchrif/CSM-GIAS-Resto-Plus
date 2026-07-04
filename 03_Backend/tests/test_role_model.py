"""Minimal model tests — Role entity creation and querying."""

from sqlalchemy.orm import Session

from app.models.role import Role
from app.repositories.role import RoleRepository


class TestRoleRepository:
    """Test CRUD operations on ``Role`` via ``RoleRepository``."""

    def setup_method(self) -> None:
        self.repo = RoleRepository()

    def test_create_role(self, db_session: Session) -> None:
        """Creating a role persists it and assigns an id."""
        role = self.repo.create(db_session, nom="super-admin", description="Full access")
        assert role.id is not None
        assert role.nom == "super-admin"
        assert role.actif is True

    def test_get_role_by_id(self, db_session: Session) -> None:
        """Fetching a role by its primary key returns the correct object."""
        created = self.repo.create(db_session, nom="manager")
        fetched = self.repo.get(db_session, created.id)
        assert fetched is not None
        assert fetched.nom == "manager"

    def test_get_role_by_nom(self, db_session: Session) -> None:
        """Fetching a role by name works."""
        self.repo.create(db_session, nom="auditor")
        fetched = self.repo.get_by_nom(db_session, "auditor")
        assert fetched is not None
        assert fetched.nom == "auditor"

    def test_get_all_roles(self, db_session: Session) -> None:
        """Fetching all roles returns every persisted role."""
        self.repo.create(db_session, nom="admin")
        self.repo.create(db_session, nom="user")
        roles = self.repo.get_all(db_session)
        assert len(roles) >= 2

    def test_update_role(self, db_session: Session) -> None:
        """Updating a role modifies the correct fields."""
        role = self.repo.create(db_session, nom="old-name")
        updated = self.repo.update(db_session, role.id, nom="new-name")
        assert updated is not None
        assert updated.nom == "new-name"

    def test_delete_role(self, db_session: Session) -> None:
        """Deleting a role removes it from the database."""
        role = self.repo.create(db_session, nom="temp")
        deleted = self.repo.delete(db_session, role.id)
        assert deleted is True
        assert self.repo.get(db_session, role.id) is None
