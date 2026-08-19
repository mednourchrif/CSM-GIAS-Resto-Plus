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
    final token = json['identification_token'];
    final type = json['identification_type'];
    final expiresAt = tryParseApiUtcDateTime(json['expires_at']);
    if (token is! String || token.trim().isEmpty) {
      throw const FormatException('Invalid identification token.');
    }
    if (type is! String || type.trim().isEmpty) {
      throw const FormatException('Invalid identification type.');
    }
    if (expiresAt == null) {
      throw const FormatException('Invalid identification expiration.');
    }
    return IdentificationGrantDto(
      token: token,
      type: type,
      expiresAt: expiresAt,
    );
  }

  IdentificationGrant toDomain() =>
      IdentificationGrant(token: token, type: type, expiresAt: expiresAt);
}
