import 'package:mobile_app/shared/models/result.dart';
import '../entities/visitor.dart';

abstract class VisitorRepository {
  Future<Result<PaginatedVisitors>> getVisitors({
    required int page,
    required int pageSize,
    String? search,
    String? sort,
    String? order,
  });

  Future<Result<Visitor>> getVisitor(String uuid);

  Future<Result<Visitor>> createVisitor({
    required String nom,
    required String prenom,
    String? email,
    String? societe,
    required DateTime dateVisite,
    String? statut,
  });

  Future<Result<Visitor>> updateVisitor(
    String uuid, {
    String? nom,
    String? prenom,
    String? email,
    String? societe,
    DateTime? dateVisite,
    String? statut,
  });

  Future<Result<void>> deleteVisitor(String uuid);
}
