"""Validation helper functions for common business patterns.

These are **pure function** utilities used by schemas and services to
validate domain-specific invariants that are not easily expressed with
Pydantic field constraints alone.

Usage::

    from app.utils.validators import validate_email_format

    assert validate_email_format("user@example.com")  # True
    assert not validate_email_format("invalid")       # False
"""

import re

# Regex for basic email structure: local-part@domain.tld
_EMAIL_PATTERN = re.compile(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")


def validate_email_format(email: str) -> bool:
    """Check whether a string looks like a valid email address.

    This is a structural check (not a deliverability check).  It ensures
    the string has a local part, an ``@`` sign, a domain, and a TLD.

    :param email: The email string to validate.
    :returns: ``True`` if the format is plausible.
    """
    return bool(_EMAIL_PATTERN.match(email.strip()))


def validate_date_range(start, end) -> bool:
    """Check that the start date is before or equal to the end date.

    Used to validate internship periods (``date_debut_stage`` vs.
    ``date_fin_stage``) and visit dates.

    :param start: The start date (``date`` or ``datetime``).
    :param end: The end date.
    :returns: ``True`` if ``start <= end``.
    """
    if start is None or end is None:
        return False
    return start <= end


def validate_matricule_format(matricule: str) -> bool:
    """Check whether a matricule looks reasonable.

    Matricules are alphanumeric strings of 3–20 characters.  This is a
    conservative check; the exact format is defined by HR.

    :param matricule: The HR identifier string.
    :returns: ``True`` if the format is plausible.
    """
    return bool(re.match(r"^[A-Za-z0-9_-]{3,20}$", matricule.strip()))


def sanitize_search_query(query: str) -> str:
    """Sanitize a search string for LIKE-based queries.

    Escapes SQL wildcard characters (``%``, ``_``) and trims whitespace.

    :param query: The raw user-provided search string.
    :returns: A sanitised string safe for ``ILIKE`` patterns.
    """
    sanitized = query.strip()
    sanitized = sanitized.replace("%", r"\%").replace("_", r"\_")
    return sanitized
