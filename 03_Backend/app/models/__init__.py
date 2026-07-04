"""Models — SQLAlchemy ORM entities.

Every entity inherits from :class:`BaseModel` which provides the common
primary-key, UUID, and timestamp columns automatically.

Importing any model file from this package registers its ``__tablename__``
and columns in ``Base.metadata``, which is the ``target_metadata`` that
Alembic watches for auto-generating migrations.
"""

from app.models.admin import Admin, Receptionist
from app.models.base import BaseModel
from app.models.employee import Employee, StatutEnrolement
from app.models.intern import Intern

# Identity Domain
from app.models.role import Role
from app.models.user import Langue, StatutUtilisateur, TypeUtilisateur, User
from app.models.visitor import Visitor

__all__ = [
    # Base
    "BaseModel",
    # Identity
    "Role",
    "User",
    "TypeUtilisateur",
    "StatutUtilisateur",
    "Langue",
    "Admin",
    "Receptionist",
    "Employee",
    "StatutEnrolement",
    "Intern",
    "Visitor",
]
