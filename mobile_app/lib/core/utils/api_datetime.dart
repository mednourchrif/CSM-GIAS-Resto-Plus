/// Parses an API timestamp using the backend contract that timezone-less
/// values are UTC.
///
/// Some database drivers remove the `+00:00` suffix from UTC timestamps.
/// Dart otherwise treats those values as device-local time, which can make a
/// newly issued short-lived identification grant appear already expired.
DateTime? tryParseApiUtcDateTime(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;

  final parsed = DateTime.tryParse(value.trim());
  if (parsed == null) return null;
  return parsed.isUtc
      ? parsed
      : parsed.timeZoneOffset == Duration.zero &&
            _hasExplicitTimezone(value.trim())
      ? parsed.toUtc()
      : _hasExplicitTimezone(value.trim())
      ? parsed.toUtc()
      : DateTime.utc(
          parsed.year,
          parsed.month,
          parsed.day,
          parsed.hour,
          parsed.minute,
          parsed.second,
          parsed.millisecond,
          parsed.microsecond,
        );
}

bool _hasExplicitTimezone(String value) {
  return value.endsWith('Z') || RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(value);
}
