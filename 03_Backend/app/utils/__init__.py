"""Utility modules — shared helpers for the application.

Each sub-module provides a focused set of pure functions or classes
that can be used across repository, service, and API layers without
importing the full application context.
"""

from app.utils.date_utils import (
    end_of_day,
    format_datetime,
    is_expired,
    now_utc,
    parse_date,
    today_utc,
)
from app.utils.password import hash_password, verify_password
from app.utils.validators import (
    sanitize_search_query,
    validate_date_range,
    validate_email_format,
    validate_matricule_format,
)

__all__ = [
    # Date utils
    "end_of_day",
    "format_datetime",
    "is_expired",
    "now_utc",
    "parse_date",
    "today_utc",
    # Password
    "hash_password",
    "verify_password",
    # Validators
    "sanitize_search_query",
    "validate_date_range",
    "validate_email_format",
    "validate_matricule_format",
]
