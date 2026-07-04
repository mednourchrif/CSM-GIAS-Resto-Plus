"""Base Pydantic schemas for domain entities.

Every domain request/response schema inherits from one of the base classes
defined here.  They provide the common fields (``id``, ``uuid``,
``created_at``, ``updated_at``) that every entity shares, so individual
schemas only need to declare domain-specific fields.

Usage::

    from app.schemas.base import BaseSchema, BaseResponse

    class RoleCreate(BaseSchema):
        nom: str
        description: str | None = None

    class RoleResponse(RoleCreate, BaseResponse):
        pass
"""

from datetime import datetime

from pydantic import BaseModel, ConfigDict


class BaseSchema(BaseModel):
    """Base for all **request** schemas (create/update).

    No common fields are imposed here because create requests may only
    include a subset of entity fields.  This class primarily serves as a
    convenience anchor for shared configuration.
    """

    model_config = ConfigDict(
        from_attributes=True,
        str_strip_whitespace=True,
        extra="forbid",
    )


class BaseResponse(BaseSchema):
    """Base for all **response** schemas.

    Includes the identity and timestamp columns that every entity exposes
    via the API.
    """

    id: int
    uuid: str
    created_at: datetime | None = None
    updated_at: datetime | None = None
