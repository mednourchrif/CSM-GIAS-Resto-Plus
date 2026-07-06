import 'package:mobile_app/shared/models/result.dart';
import '../entities/intern.dart';

abstract class InternRepository {
  Future<Result<PaginatedInterns>> getInterns({
    required int page,
    required int pageSize,
    String? search,
    String? sort,
    String? order,
  });

  Future<Result<Intern>> getIntern(String uuid);

  Future<Result<Intern>> createIntern({
    required String nom,
    required String prenom,
    required String matricule,
    required DateTime dateDebutStage,
    required DateTime dateFinStage,
    String? statut,
  });

  Future<Result<Intern>> updateIntern(
    String uuid, {
    String? nom,
    String? prenom,
    String? matricule,
    DateTime? dateDebutStage,
    DateTime? dateFinStage,
    String? statut,
  });

  Future<Result<void>> deleteIntern(String uuid);
}
