"""Models — SQLAlchemy ORM entities.

Every entity inherits from :class:`BaseModel` which provides the common
primary-key, UUID, and timestamp columns automatically.

Importing any model file from this package registers its ``__tablename__``
and columns in ``Base.metadata``, which is the ``target_metadata`` that
Alembic watches for auto-generating migrations.
"""

from app.models.admin import Admin, Receptionist

# Audit
from app.models.audit_log import AuditLog
from app.models.base import BaseModel
from app.models.employee import Employee, StatutEnrolement

# Face Recognition
from app.models.face_embedding import FaceEmbedding
from app.models.identification_grant import IdentificationGrant
from app.models.intern import Intern

# Meal Domain
from app.models.meal import Meal

# Identity Domain
from app.models.meal_category import MealCategory
from app.models.qr_code import QrCode
from app.models.role import Role

# Settings
from app.models.setting import Setting
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
    "IdentificationGrant",
    "Meal",
    "MealCategory",
    "QrCode",
    "Visitor",
    # Face Recognition
    "FaceEmbedding",
    # Settings
    "Setting",
    # Audit
    "AuditLog",
]
