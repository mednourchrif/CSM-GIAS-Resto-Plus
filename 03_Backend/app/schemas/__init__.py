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
from app.schemas.auth import AdminSummary, LoginRequest, TokenResponse
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
from app.schemas.meal import (
    MealCategoryResponse,
    MealRegisterRequest,
    MealRegisterResponse,
    MealResponse,
)
from app.schemas.qr_code import (
    QrCodeResponse,
    QrGenerateResponse,
    QrValidateRequest,
    QrValidationResponse,
    ValidationStatut,
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

# Settings
from app.schemas.setting import (
    DatabaseStatusResponse,
    SettingResponse,
    SettingsBatchUpdate,
    SettingsGroupResponse,
    SettingsResponse,
    SettingUpdate,
    VersionInfoResponse,
)

__all__ = [
    # Auth
    "LoginRequest",
    "TokenResponse",
    "AdminSummary",
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
    "MealCategoryResponse",
    "MealRegisterRequest",
    "MealRegisterResponse",
    "MealResponse",
    "QrCodeResponse",
    "QrGenerateResponse",
    "QrValidateRequest",
    "QrValidationResponse",
    "ValidationStatut",
    "InternResponse",
    "InternUpdate",
    "VisitorCreate",
    "VisitorResponse",
    "VisitorUpdate",
    # Settings
    "SettingResponse",
    "SettingsBatchUpdate",
    "SettingsGroupResponse",
    "SettingsResponse",
    "SettingUpdate",
    "DatabaseStatusResponse",
    "VersionInfoResponse",
]
