import '../../domain/entities/identification_grant.dart';
import '../../../../core/utils/api_datetime.dart';

class IdentificationGrantDto {
  final String token;
  final String type;
  final DateTime expiresAt;

  const IdentificationGrantDto({
    required this.token,
    required this.type,
    required this.expiresAt,
  });

  factory IdentificationGrantDto.fromJson(Map<String, dynamic> json) {
    final expiresAt = tryParseApiUtcDateTime(json['expires_at']);
    if (expiresAt == null) {
      throw const FormatException('Invalid identification expiration.');
    }
    return IdentificationGrantDto(
      token: json['identification_token'] as String,
      type: json['identification_type'] as String,
      expiresAt: expiresAt,
    );
  }

  IdentificationGrant toDomain() =>
      IdentificationGrant(token: token, type: type, expiresAt: expiresAt);
}
