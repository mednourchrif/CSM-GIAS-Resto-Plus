from pydantic import Field

from app.schemas.base import BaseSchema


class SettingUpdate(BaseSchema):
    value: str = Field(..., min_length=0, description="Setting value")


class SettingsBatchUpdate(BaseSchema):
    settings: dict[str, str] = Field(..., description="Key-value map of settings to update")


class SettingResponse(BaseSchema):
    key: str
    value: str
    category: str
    label: str
    description: str | None = None
    field_type: str
    options: list[str] | None = None
    default_value: str
    order: int = 0


class SettingsGroupResponse(BaseSchema):
    category: str
    label: str
    settings: list[SettingResponse]


class SettingsResponse(BaseSchema):
    groups: list[SettingsGroupResponse]
    raw: dict[str, str]


class DatabaseStatusResponse(BaseSchema):
    status: str
    total_tables: int
    total_records: int
    size_mb: float | None = None


class VersionInfoResponse(BaseSchema):
    application_version: str
    backend_version: str
    environment: str


class DatabasePurgeRequest(BaseSchema):
    mot_de_passe: str = Field(..., min_length=1, description="Mot de passe administrateur")
    confirmation: str = Field(..., description="Phrase de confirmation, doit être 'PURGER'")
    purger_audit_logs: bool = Field(False, description="Supprimer également les journaux d'audit")


class DatabasePurgeResponse(BaseSchema):
    repas_supprimes: int
    recus_supprimes: int
    grants_supprimes: int
    audit_logs_supprimes: int
    message: str
