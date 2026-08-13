from datetime import time
from typing import Any

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.exceptions import ValidationException
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

RUNTIME_SETTING_KEYS = {
    "opening_hour",
    "closing_hour",
    "auto_return_delay",
    "face_similarity_threshold",
    "face_detection_timeout",
    "max_recognition_attempts",
    "camera_quality",
    "face_recognition_enabled",
    "qr_validation_enabled",
    "language",
    "theme",
    "welcome_message",
    "success_message",
}

DEFAULT_SETTINGS: list[dict[str, Any]] = [
    # Restaurant
    {
        "key": "opening_hour",
        "value": "12:30",
        "category": "restaurant",
        "label": "Heure d'ouverture",
        "field_type": "time",
        "default_value": "12:30",
        "order": 1,
    },
    {
        "key": "closing_hour",
        "value": "14:00",
        "category": "restaurant",
        "label": "Heure de fermeture",
        "field_type": "time",
        "default_value": "14:00",
        "order": 2,
    },
    {
        "key": "working_days",
        "value": "[1,2,3,4,5,6]",
        "category": "restaurant",
        "label": "Jours d'ouverture",
        "description": "Jours de la semaine (1=Lun…7=Dim)",
        "field_type": "select",
        "options": '["1","2","3","4","5","6","7"]',
        "default_value": "[1,2,3,4,5,6]",
        "order": 3,
    },
    {
        "key": "time_zone",
        "value": "Africa/Casablanca",
        "category": "restaurant",
        "label": "Fuseau horaire",
        "field_type": "text",
        "default_value": "Africa/Casablanca",
        "order": 4,
    },
    {
        "key": "auto_return_delay",
        "value": "5",
        "category": "restaurant",
        "label": "Délai retour accueil (s)",
        "field_type": "number",
        "default_value": "5",
        "order": 5,
    },
    # Recognition
    {
        "key": "face_similarity_threshold",
        "value": "0.75",
        "category": "recognition",
        "label": "Seuil de similarité",
        "description": "Entre 0.0 et 1.0",
        "field_type": "number",
        "default_value": "0.75",
        "order": 1,
    },
    {
        "key": "face_detection_timeout",
        "value": "30",
        "category": "recognition",
        "label": "Délai détection (s)",
        "field_type": "number",
        "default_value": "30",
        "order": 2,
    },
    {
        "key": "max_recognition_attempts",
        "value": "3",
        "category": "recognition",
        "label": "Tentatives max",
        "field_type": "number",
        "default_value": "3",
        "order": 3,
    },
    {
        "key": "camera_quality",
        "value": "high",
        "category": "recognition",
        "label": "Qualité caméra",
        "field_type": "select",
        "options": '["low","medium","high"]',
        "default_value": "high",
        "order": 4,
    },
    {
        "key": "face_recognition_enabled",
        "value": "true",
        "category": "recognition",
        "label": "Reconnaissance faciale",
        "field_type": "boolean",
        "default_value": "true",
        "order": 5,
    },
    {
        "key": "qr_validation_enabled",
        "value": "true",
        "category": "recognition",
        "label": "Identification par QR Code",
        "field_type": "boolean",
        "default_value": "true",
        "order": 6,
    },
    # QR Codes
    {
        "key": "qr_default_expiration",
        "value": "0",
        "category": "qr_codes",
        "label": "Expiration par défaut (j)",
        "description": "0 = fin de journée",
        "field_type": "number",
        "default_value": "0",
        "order": 1,
    },
    {
        "key": "qr_auto_revoke_expired",
        "value": "true",
        "category": "qr_codes",
        "label": "Révoquer automatiquement",
        "field_type": "boolean",
        "default_value": "true",
        "order": 2,
    },
    {
        "key": "qr_image_size",
        "value": "300",
        "category": "qr_codes",
        "label": "Taille image QR (px)",
        "field_type": "number",
        "default_value": "300",
        "order": 3,
    },
    {
        "key": "qr_error_correction",
        "value": "M",
        "category": "qr_codes",
        "label": "Correction d'erreur",
        "field_type": "select",
        "options": '["L","M","Q","H"]',
        "default_value": "M",
        "order": 4,
    },
    # Application
    {
        "key": "language",
        "value": "fr",
        "category": "application",
        "label": "Langue",
        "field_type": "select",
        "options": '["fr","en","ar"]',
        "default_value": "fr",
        "order": 1,
    },
    {
        "key": "theme",
        "value": "system",
        "category": "application",
        "label": "Thème",
        "field_type": "select",
        "options": '["light","dark","system"]',
        "default_value": "system",
        "order": 2,
    },
    {
        "key": "company_name",
        "value": "CSM-GIAS Resto+",
        "category": "application",
        "label": "Nom de l'entreprise",
        "field_type": "text",
        "default_value": "CSM-GIAS Resto+",
        "order": 3,
    },
    {
        "key": "company_logo",
        "value": "",
        "category": "application",
        "label": "Logo",
        "description": "URL ou base64 du logo",
        "field_type": "text",
        "default_value": "",
        "order": 4,
    },
    {
        "key": "welcome_message",
        "value": "Bienvenue au restaurant",
        "category": "application",
        "label": "Message d'accueil",
        "field_type": "text",
        "default_value": "Bienvenue au restaurant",
        "order": 5,
    },
    {
        "key": "success_message",
        "value": "Repas enregistré avec succès",
        "category": "application",
        "label": "Message de succès",
        "field_type": "text",
        "default_value": "Repas enregistré avec succès",
        "order": 6,
    },
    # Security
    {
        "key": "session_timeout",
        "value": "30",
        "category": "security",
        "label": "Expiration session (min)",
        "field_type": "number",
        "default_value": "30",
        "order": 1,
    },
    {
        "key": "password_policy",
        "value": "default",
        "category": "security",
        "label": "Politique mot de passe",
        "field_type": "select",
        "options": '["default","strict","very_strict"]',
        "default_value": "default",
        "order": 2,
    },
    {
        "key": "force_logout",
        "value": "false",
        "category": "security",
        "label": "Forcer la déconnexion",
        "field_type": "boolean",
        "default_value": "false",
        "order": 3,
    },
    {
        "key": "audit_logs_enabled",
        "value": "true",
        "category": "security",
        "label": "Journaux d'audit",
        "field_type": "boolean",
        "default_value": "true",
        "order": 4,
    },
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
        if get_settings().FACE_ENGINE.strip().lower() == "disabled":
            raw["face_recognition_enabled"] = "false"
        groups = []
        for category in sorted(grouped.keys()):
            settings = [item for item in grouped[category] if item.key in RUNTIME_SETTING_KEYS]
            if not settings:
                continue
            groups.append(
                SettingsGroupResponse(
                    category=category,
                    label=CATEGORY_LABELS.get(category, category),
                    settings=[
                        SettingResponse(
                            key=s.key,
                            value=raw.get(s.key, s.value),
                            category=s.category,
                            label=s.label,
                            description=s.description,
                            field_type=s.field_type,
                            options=(
                                [
                                    o.strip('"')
                                    for o in s.options.strip("[]").split(",")
                                    if o.strip()
                                ]
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
        return SettingsResponse(
            groups=groups,
            raw={key: value for key, value in raw.items() if key in RUNTIME_SETTING_KEYS},
        )

    def update_settings(self, db: Session, settings: dict[str, str]) -> SettingsResponse:
        self.seed_defaults(db)
        for key, value in settings.items():
            if key not in RUNTIME_SETTING_KEYS:
                raise ValidationException(
                    message=f"Paramètre non modifiable : {key}.",
                )
            setting = self._repository.get_by_key(db, key)
            if setting is None:
                raise ValidationException(
                    message=f"Paramètre inconnu : {key}.",
                )
            if (
                key == "face_recognition_enabled"
                and value.lower() == "true"
                and get_settings().FACE_ENGINE.strip().lower() == "disabled"
            ):
                raise ValidationException(
                    message="Aucun moteur facial n'est configuré sur le serveur.",
                )
            self._validate_runtime_value(key, value)
            self._repository.upsert(db, key, value)
        return self.get_settings(db)

    def get_runtime_value(self, db: Session, key: str, fallback: str) -> str:
        """Return one kiosk setting without exposing the administration API."""
        if (
            key == "face_recognition_enabled"
            and get_settings().FACE_ENGINE.strip().lower() == "disabled"
        ):
            return "false"
        setting = self._repository.get_by_key(db, key)
        return setting.value if setting is not None else fallback

    @staticmethod
    def _validate_runtime_value(  # noqa: PLR0912 - explicit setting-key validation
        key: str, value: str
    ) -> None:
        if SettingService._validate_restaurant_hour(key, value):
            return
        if key in {"face_recognition_enabled", "qr_validation_enabled"}:
            if value.lower() not in {"true", "false"}:
                raise ValidationException(message=f"Valeur booléenne invalide pour {key}.")
            return

        if key == "theme":
            if value not in {"light", "dark", "system"}:
                raise ValidationException(message="Thème invalide.")
            return
        if key == "language":
            if value not in {"fr", "en", "ar"}:
                raise ValidationException(message="Langue invalide.")
            return
        if key == "camera_quality":
            if value not in {"low", "medium", "high"}:
                raise ValidationException(message="Qualité de caméra invalide.")
            return

        numeric_bounds = {
            "auto_return_delay": (2.0, 30.0),
            "face_similarity_threshold": (0.5, 0.99),
            "face_detection_timeout": (5.0, 120.0),
            "max_recognition_attempts": (1.0, 10.0),
        }
        if key in numeric_bounds:
            try:
                number = float(value)
            except ValueError as exc:
                raise ValidationException(message=f"Valeur numérique invalide pour {key}.") from exc
            minimum, maximum = numeric_bounds[key]
            if not minimum <= number <= maximum:
                raise ValidationException(
                    message=f"{key} doit être compris entre {minimum:g} et {maximum:g}.",
                )
            if key != "face_similarity_threshold" and not number.is_integer():
                raise ValidationException(message=f"{key} doit être un nombre entier.")
            return

        if key in {"welcome_message", "success_message"} and (
            not value.strip() or len(value) > 120
        ):
            raise ValidationException(
                message=f"{key} doit contenir entre 1 et 120 caractères.",
            )

    @staticmethod
    def _validate_restaurant_hour(key: str, value: str) -> bool:
        if key not in {"opening_hour", "closing_hour"}:
            return False
        try:
            parsed = time.fromisoformat(value)
        except ValueError as exc:
            raise ValidationException(
                message=f"Horaire invalide pour {key}; utilisez HH:MM.",
            ) from exc
        if parsed.second or parsed.microsecond:
            raise ValidationException(
                message=f"Horaire invalide pour {key}; utilisez HH:MM.",
            )
        return True

    def reset_to_defaults(self, db: Session) -> SettingsResponse:
        for attrs in DEFAULT_SETTINGS:
            self._repository.reset_to_default(db, attrs["key"])
        return self.get_settings(db)

    def get_version_info(self) -> VersionInfoResponse:
        cfg = get_settings()
        return VersionInfoResponse(
            application_version="1.0.0",
            backend_version="1.0.0",
            environment=cfg.APP_ENVIRONMENT.value,
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
