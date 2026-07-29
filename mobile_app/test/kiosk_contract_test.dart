import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/face_recognition/data/dto/face_identify_response_dto.dart';
import 'package:mobile_app/features/identification/data/dto/identification_grant_dto.dart';
import 'package:mobile_app/features/identification/domain/entities/identification_grant.dart';
import 'package:mobile_app/features/meal_registration/data/dto/register_meal_request_dto.dart';
import 'package:mobile_app/features/meal_registration/data/dto/register_meal_response_dto.dart';

void main() {
  group('secured kiosk contract', () {
    test('meal registration sends only grant and category', () {
      const request = RegisterMealRequestDto(
        identificationToken: 'grant-token',
        categorieUuid: 'category-uuid',
      );

      expect(request.toJson(), {
        'identification_token': 'grant-token',
        'categorie_uuid': 'category-uuid',
      });
      expect(request.toJson(), isNot(contains('utilisateur_uuid')));
      expect(request.toJson(), isNot(contains('qr_token')));
    });

    test('identification grant detects expiry', () {
      final valid = IdentificationGrant(
        token: 'valid',
        type: 'QR',
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );
      final expired = IdentificationGrant(
        token: 'expired',
        type: 'FACE',
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );

      expect(valid.isExpired, isFalse);
      expect(expired.isExpired, isTrue);
    });

    test('face response parses privacy-safe grant fields', () {
      final response = FaceIdentifyResponseDto.fromJson({
        'statut': 'MATCH',
        'confidence': 0.97,
        'type': 'FACE',
        'identification_token': 'opaque-token',
        'identification_expires_at': '2026-07-25T12:31:00Z',
      }).toDomain();

      expect(response.isMatch, isTrue);
      expect(response.identificationToken, 'opaque-token');
      expect(response.identificationExpiresAt, isNotNull);
    });

    test('timezone-less backend grant expiration is interpreted as UTC', () {
      final qrGrant = IdentificationGrantDto.fromJson({
        'identification_token': 'qr-token',
        'identification_type': 'QR',
        'expires_at': '2026-07-29T10:29:01',
      }).toDomain();
      final faceResult = FaceIdentifyResponseDto.fromJson({
        'statut': 'MATCH',
        'identification_token': 'face-token',
        'identification_expires_at': '2026-07-29T10:29:01',
      }).toDomain();

      expect(qrGrant.expiresAt.isUtc, isTrue);
      expect(qrGrant.expiresAt, DateTime.utc(2026, 7, 29, 10, 29, 1));
      expect(faceResult.identificationExpiresAt?.isUtc, isTrue);
      expect(
        faceResult.identificationExpiresAt,
        DateTime.utc(2026, 7, 29, 10, 29, 1),
      );
    });

    test('meal response does not derive a user name', () {
      final response = RegisterMealResponseDto.fromJson({
        'categorie_nom': 'Plat',
        'heure_repas': '2026-07-25T12:45:00Z',
        'type_identification': 'QR',
        'nom': 'must not be read',
      }).toDomain();

      expect(response.userName, isNull);
      expect(response.mealLabel, 'Plat');
      expect(response.identificationMethod, 'QR');
    });
  });
}
