"""Date and time utility functions.

All timestamps in the application are **timezone-aware UTC** by default.
These helpers abstract away the ``datetime`` module details so that the
rest of the codebase works with a consistent time model.
"""

from datetime import UTC, date, datetime, time, timezone


def now_utc() -> datetime:
    """Return the current UTC time as a timezone-aware datetime."""
    return datetime.now(UTC)


def today_utc() -> date:
    """Return today's date in the UTC timezone."""
    return now_utc().date()


def parse_date(value: str) -> date:
    """Parse an ISO-8601 date string (``YYYY-MM-DD``) into a ``date``.

    Raises ``ValueError`` if the string is not a valid date.
    """
    return date.fromisoformat(value)


def format_datetime(dt: datetime | None) -> str | None:
    """Format a UTC datetime as ``YYYY-MM-DD HH:MM:SS`` (ISO-like).

    Returns ``None`` if the input is ``None``.
    """
    if dt is None:
        return None
    return dt.strftime("%Y-%m-%d %H:%M:%S")


def _ensure_aware(dt: datetime) -> datetime:
    """If *dt* is offset-naive, assume UTC and attach timezone info.

    SQLite does not preserve timezone information, so datetimes stored
    with ``DateTime(timezone=True)`` are read back as naive.  This helper
    makes them aware so that comparisons with aware timestamps work.
    """
    if dt.tzinfo is None:
        return dt.replace(tzinfo=UTC)
    return dt


def is_expired(dt: datetime | None, reference: datetime | None = None) -> bool:
    """Check whether a given timestamp is in the past.

    :param dt: The timestamp to check (e.g. a QR-code expiration).
    :param reference: The reference time (defaults to ``now_utc()``).
    :returns: ``True`` if ``dt`` is ``None`` or earlier than
        ``reference``.
    """
    if dt is None:
        return True
    dt = _ensure_aware(dt)
    ref = _ensure_aware(reference or now_utc())
    return dt < ref


def end_of_day(dt: date | None = None) -> datetime:
    """Return the last moment of the given date (UTC, 23:59:59).

    Defaults to today if no date is provided.
    """
    target = dt or today_utc()
    return datetime.combine(target, time(23, 59, 59), tzinfo=UTC)
