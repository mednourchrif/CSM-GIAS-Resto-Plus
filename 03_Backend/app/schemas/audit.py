from datetime import date, datetime

from pydantic import Field

from app.schemas.base import BaseResponse, BaseSchema


class AuditLogResponse(BaseResponse):
    timestamp: datetime
    user_uuid: str | None = None
    user_name: str
    user_role: str
    action: str
    entity_type: str | None = None
    entity_uuid: str | None = None
    entity_name: str | None = None
    description: str | None = None
    http_method: str | None = None
    endpoint: str | None = None
    ip_address: str | None = None
    user_agent: str | None = None
    status: str = "SUCCESS"
    metadata_json: str | None = None


class AuditLogExportResponse(BaseSchema):
    timestamp: datetime
    user_name: str
    user_role: str
    action: str
    entity_type: str | None = None
    entity_name: str | None = None
    description: str | None = None
    status: str = "SUCCESS"


class AuditLogFilterParams(BaseSchema):
    page: int = Field(1, ge=1)
    page_size: int = Field(50, ge=1, le=200)
    date_from: datetime | None = Field(None)
    date_to: datetime | None = Field(None)
    user_uuid: str | None = Field(None)
    role: str | None = Field(None)
    action: str | None = Field(None)
    entity_type: str | None = Field(None)
    status: str | None = Field(None)
    search: str | None = Field(None, max_length=200)


class AuditLogFiltersResponse(BaseSchema):
    actions: list[str]
    entity_types: list[str]
