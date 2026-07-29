import '../../../../shared/models/result.dart';
import '../entities/identification_grant.dart';

abstract class IdentificationRepository {
  Future<Result<IdentificationGrant>> identifyByQr(String qrToken);
}
