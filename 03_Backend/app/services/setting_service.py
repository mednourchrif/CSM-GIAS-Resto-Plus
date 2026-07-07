from typing import Any

from sqlalchemy import inspect, text
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.database.base import Base
from app.repositories.setting import SettingRepository
from app.schemas.setting import (
    DatabaseStatusResponse,
    SettingResponse,
    SettingsGroupResponse,
    SettingsResponse,
    VersionInfoResponse,
)
from app.services.base import BaseService

CATEGORY_LABELS = {
    "restaurant": "Restaurant",
    "recognition": "Reconnaissance",
    "qr_codes": "QR Codes",
    "application": "Application",
    "security": "Sécurité",
    "maintenance": "Maintenance",
}

DEFAULT_SETTINGS: list[dict[str, Any]] = [
    # Restaurant
    {"key": "opening_hour", "value": "12:30", "category": "restaurant", "label": "Heure d'ouverture", "field_type": "time", "default_value": "12:30", "order": 1},
    {"key": "closing_hour", "value": "20:00", "category": "restaurant", "label": "Heure de fermeture", "field_type": "time", "default_value": "20:00", "order": 2},
    {"key": "working_days", "value": "[1,2,3,4,5,6]", "category": "restaurant", "label": "Jours d'ouverture", "description": "Jours de la semaine (1=Lun…7=Dim)", "field_type": "select", "options": '["1","2","3","4","5","6","7"]', "default_value": "[1,2,3,4,5,6]", "order": 3},
    {"key": "time_zone", "value": "Africa/Douala", "category": "restaurant", "label": "Fuseau horaire", "field_type": "text", "default_value": "Africa/Douala", "order": 4},
    {"key": "auto_return_delay", "value": "5", "category": "restaurant", "label": "Délai retour accueil (s)", "field_type": "number", "default_value": "5", "order": 5},
    # Recognition
    {"key": "face_similarity_threshold", "value": "0.75", "category": "recognition", "label": "Seuil de similarité", "description": "Entre 0.0 et 1.0", "field_type": "number", "default_value": "0.75", "order": 1},
    {"key": "face_detection_timeout", "value": "30", "category": "recognition", "label": "Délai détection (s)", "field_type": "number", "default_value": "30", "order": 2},
    {"key": "max_recognition_attempts", "value": "3", "category": "recognition", "label": "Tentatives max", "field_type": "number", "default_value": "3", "order": 3},
    {"key": "camera_quality", "value": "high", "category": "recognition", "label": "Qualité caméra", "field_type": "select", "options": '["low","medium","high"]', "default_value": "high", "order": 4},
    {"key": "face_recognition_enabled", "value": "true", "category": "recognition", "label": "Reconnaissance faciale", "field_type": "boolean", "default_value": "true", "order": 5},
    # QR Codes
    {"key": "qr_default_expiration", "value": "0", "category": "qr_codes", "label": "Expiration par défaut (j)", "description": "0 = fin de journée", "field_type": "number", "default_value": "0", "order": 1},
    {"key": "qr_auto_revoke_expired", "value": "true", "category": "qr_codes", "label": "Révoquer automatiquement", "field_type": "boolean", "default_value": "true", "order": 2},
    {"key": "qr_image_size", "value": "300", "category": "qr_codes", "label": "Taille image QR (px)", "field_type": "number", "default_value": "300", "order": 3},
    {"key": "qr_error_correction", "value": "M", "category": "qr_codes", "label": "Correction d'erreur", "field_type": "select", "options": '["L","M","Q","H"]', "default_value": "M", "order": 4},
    # Application
    {"key": "language", "value": "fr", "category": "application", "label": "Langue", "field_type": "select", "options": '["fr","en","ar"]', "default_value": "fr", "order": 1},
    {"key": "theme", "value": "system", "category": "application", "label": "Thème", "field_type": "select", "options": '["light","dark","system"]', "default_value": "system", "order": 2},
    {"key": "company_name", "value": "CSM-GIAS Resto+", "category": "application", "label": "Nom de l'entreprise", "field_type": "text", "default_value": "CSM-GIAS Resto+", "order": 3},
    {"key": "company_logo", "value": "", "category": "application", "label": "Logo", "description": "URL ou base64 du logo", "field_type": "text", "default_value": "", "order": 4},
    {"key": "welcome_message", "value": "Bienvenue au restaurant", "category": "application", "label": "Message d'accueil", "field_type": "text", "default_value": "Bienvenue au restaurant", "order": 5},
    {"key": "success_message", "value": "Repas enregistré avec succès", "category": "application", "label": "Message de succès", "field_type": "text", "default_value": "Repas enregistré avec succès", "order": 6},
    # Security
    {"key": "session_timeout", "value": "30", "category": "security", "label": "Expiration session (min)", "field_type": "number", "default_value": "30", "order": 1},
    {"key": "password_policy", "value": "default", "category": "security", "label": "Politique mot de passe", "field_type": "select", "options": '["default","strict","very_strict"]', "default_value": "default", "order": 2},
    {"key": "force_logout", "value": "false", "category": "security", "label": "Forcer la déconnexion", "field_type": "boolean", "default_value": "false", "order": 3},
    {"key": "audit_logs_enabled", "value": "true", "category": "security", "label": "Journaux d'audit", "field_type": "boolean", "default_value": "true", "order": 4},
]


class SettingService(BaseService[SettingRepository]):
    def __init__(self) -> None:
        super().__init__(SettingRepository())

    def seed_defaults(self, db: Session) -> None:
        for attrs in DEFAULT_SETTINGS:
            existing = self._repository.get_by_key(db, attrs["key"])
            if existing is None:
                self._repository.create(db, **attrs)

    def get_settings(self, db: Session) -> SettingsResponse:
        self.seed_defaults(db)
        grouped = self._repository.get_grouped(db)
        raw = self._repository.get_all_as_dict(db)
        groups = []
        for category in sorted(grouped.keys()):
            settings = grouped[category]
            groups.append(
                SettingsGroupResponse(
                    category=category,
                    label=CATEGORY_LABELS.get(category, category),
                    settings=[
                        SettingResponse(
                            key=s.key,
                            value=s.value,
                            category=s.category,
                            label=s.label,
                            description=s.description,
                            field_type=s.field_type,
                            options=(
                                [o.strip('"') for o in s.options.strip("[]").split(",") if o.strip()]
                                if s.options
                                else None
                            ),
                            default_value=s.default_value,
                            order=s.order,
                        )
                        for s in settings
                    ],
                )
            )
        return SettingsResponse(groups=groups, raw=raw)

    def update_settings(self, db: Session, settings: dict[str, str]) -> SettingsResponse:
        for key, value in settings.items():
            self._repository.upsert(db, key, value)
        return self.get_settings(db)

    def reset_to_defaults(self, db: Session) -> SettingsResponse:
        for attrs in DEFAULT_SETTINGS:
            self._repository.reset_to_default(db, attrs["key"])
        return self.get_settings(db)

    def get_version_info(self) -> VersionInfoResponse:
        cfg = get_settings()
        return VersionInfoResponse(
            application_version="1.0.0",
            backend_version="1.0.0",
            environment=cfg.ENVIRONMENT,
        )

    def get_database_status(self, db: Session) -> DatabaseStatusResponse:
        try:
            db.execute(text("SELECT 1"))
            status = "connected"
        except Exception:
            status = "disconnected"

        total_tables = len(Base.metadata.tables)
        total_records = 0
        for table_name in Base.metadata.tables:
            try:
                count = db.execute(text(f"SELECT COUNT(*) FROM {table_name}")).scalar() or 0
                total_records += count
            except Exception:
                pass

        return DatabaseStatusResponse(
            status=status,
            total_tables=total_tables,
            total_records=total_records,
        )
