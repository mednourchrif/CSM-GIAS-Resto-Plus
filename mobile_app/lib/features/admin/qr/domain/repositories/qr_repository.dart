import 'package:mobile_app/shared/models/result.dart';
import '../entities/qr_code.dart';

abstract class QrRepository {
  Future<Result<PaginatedQrCodes>> getQrCodes({
    required int page,
    required int pageSize,
    String? search,
    String? typeFilter,
    String? statusFilter,
    String? sort,
    String? order,
  });

  Future<Result<QrCode>> getQrCode(String uuid);

  Future<Result<QrCode>> generateInternQr(String internUuid);

  Future<Result<QrCode>> generateVisitorQr(String visitorUuid);

  Future<Result<QrCode>> revokeQr(String uuid);

  Future<Result<QrCode>> regenerateQr(String ownerUuid, {String ownerType = 'STAGIAIRE'});

  Future<Result<List<int>>> downloadQr(String uuid);

  Future<Result<List<QrCode>>> getQrHistory(String ownerUuid);
}
