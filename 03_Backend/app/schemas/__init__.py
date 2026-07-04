"""Pydantic schemas — request/response models.

Schemas define the wire format for every API endpoint.  Domain-specific
schemas are organized by module (``role``, ``user``, etc.) and typically
follow the pattern ``*Create``, ``*Update``, ``*Response``.
"""

from app.schemas.admin import (
    AdminCreate,
    AdminResponse,
    AdminUpdate,
    ReceptionistCreate,
    ReceptionistResponse,
    ReceptionistUpdate,
)
from app.schemas.base import BaseResponse, BaseSchema
from app.schemas.employee import (
    EmployeeCreate,
    EmployeeResponse,
    EmployeeUpdate,
)
from app.schemas.intern import (
    InternCreate,
    InternResponse,
    InternUpdate,
)
from app.schemas.response import (
    ErrorResponse,
    MetadataResponse,
    PaginatedResponse,
    SuccessResponse,
)
from app.schemas.role import (
    RoleCreate,
    RoleResponse,
    RoleUpdate,
)
from app.schemas.user import (
    UserCreate,
    UserResponse,
    UserUpdate,
)
from app.schemas.visitor import (
    VisitorCreate,
    VisitorResponse,
    VisitorUpdate,
)

__all__ = [
    # Base
    "BaseSchema",
    "BaseResponse",
    # Generic responses
    "SuccessResponse",
    "ErrorResponse",
    "PaginatedResponse",
    "MetadataResponse",
    # Identity domain
    "RoleCreate",
    "RoleResponse",
    "RoleUpdate",
    "UserCreate",
    "UserResponse",
    "UserUpdate",
    "AdminCreate",
    "AdminResponse",
    "AdminUpdate",
    "ReceptionistCreate",
    "ReceptionistResponse",
    "ReceptionistUpdate",
    "EmployeeCreate",
    "EmployeeResponse",
    "EmployeeUpdate",
    "InternCreate",
    "InternResponse",
    "InternUpdate",
    "VisitorCreate",
    "VisitorResponse",
    "VisitorUpdate",
]
