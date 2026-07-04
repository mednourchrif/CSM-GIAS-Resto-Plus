"""Repositories — data-access layer.

Each domain entity gets a concrete repository that inherits from
:class:`BaseRepository` and may add custom query methods.
"""

from app.repositories.base import BaseRepository
from app.repositories.employee import EmployeeRepository
from app.repositories.intern import InternRepository
from app.repositories.qr_code import QrCodeRepository
from app.repositories.role import RoleRepository
from app.repositories.user import UserRepository
from app.repositories.visitor import VisitorRepository

__all__ = [
    "BaseRepository",
    "QrCodeRepository",
    "RoleRepository",
    "UserRepository",
    "EmployeeRepository",
    "InternRepository",
    "VisitorRepository",
]
