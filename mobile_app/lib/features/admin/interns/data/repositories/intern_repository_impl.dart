import 'package:dio/dio.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../shared/models/result.dart';
import '../../domain/entities/intern.dart';
import '../../domain/repositories/intern_repository.dart';
import '../datasources/intern_remote_datasource.dart';
import '../dto/create_intern_request_dto.dart';
import '../dto/update_intern_request_dto.dart';

class InternRepositoryImpl implements InternRepository {
  final InternRemoteDataSource _dataSource;

  InternRepositoryImpl({required InternRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<PaginatedInterns>> getInterns({
    required int page,
    required int pageSize,
    String? search,
    String? sort,
    String? order,
  }) async {
    try {
      final response = await _dataSource.getInterns(
        page: page,
        pageSize: pageSize,
        search: search,
        sort: sort,
        order: order,
      );
      return Success(PaginatedInterns(
        items: response.items.map((e) => e.toDomain()).toList(),
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
        totalPages: response.totalPages,
      ));
    } on DioException catch (e) {
      return Fail(_mapError(e));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement des stagiaires.'));
    }
  }

  @override
  Future<Result<Intern>> getIntern(String uuid) async {
    try {
      final dto = await _dataSource.getIntern(uuid);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(_mapError(e));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement du stagiaire.'));
    }
  }

  @override
  Future<Result<Intern>> createIntern({
    required String nom,
    required String prenom,
    required String matricule,
    required DateTime dateDebutStage,
    required DateTime dateFinStage,
    String? statut,
  }) async {
    try {
      final request = CreateInternRequestDto(
        nom: nom,
        prenom: prenom,
        matricule: matricule,
        dateDebutStage: _formatDate(dateDebutStage),
        dateFinStage: _formatDate(dateFinStage),
        statut: statut,
      );
      final dto = await _dataSource.createIntern(request);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(_mapError(e));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la création du stagiaire.'));
    }
  }

  @override
  Future<Result<Intern>> updateIntern(
    String uuid, {
    String? nom,
    String? prenom,
    String? matricule,
    DateTime? dateDebutStage,
    DateTime? dateFinStage,
    String? statut,
  }) async {
    try {
      final request = UpdateInternRequestDto(
        nom: nom,
        prenom: prenom,
        matricule: matricule,
        dateDebutStage: dateDebutStage != null ? _formatDate(dateDebutStage) : null,
        dateFinStage: dateFinStage != null ? _formatDate(dateFinStage) : null,
        statut: statut,
      );
      final dto = await _dataSource.updateIntern(uuid, request);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(_mapError(e));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la modification du stagiaire.'));
    }
  }

  @override
  Future<Result<void>> deleteIntern(String uuid) async {
    try {
      await _dataSource.deleteIntern(uuid);
      return const Success(null);
    } on DioException catch (e) {
      return Fail(_mapError(e));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la suppression du stagiaire.'));
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  Failure _mapError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map ? (data['message'] as String?) : null;

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure(
        message: 'Impossible de contacter le serveur.',
      );
    }

    if (statusCode == 401) {
      return const UnauthorizedFailure();
    }

    if (statusCode == 404) {
      return NotFoundFailure(message: message ?? 'Stagiaire introuvable.');
    }

    if (statusCode == 409) {
      return ApiFailure(
        message: message ?? 'Conflit: ce stagiaire existe déjà.',
        statusCode: statusCode,
      );
    }

    if (statusCode == 422) {
      final errors = data is Map ? data['errors'] as Map<String, dynamic>? : null;
      return ValidationFailure(
        message: message ?? 'Données invalides.',
        fieldErrors: errors?.map(
              (k, v) => MapEntry(k, v is List ? v.join(', ') : v.toString()),
            ) ??
            {},
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return ServerFailure(
        message: message ?? 'Erreur interne du serveur.',
        statusCode: statusCode,
      );
    }

    return ApiFailure(
      message: message ?? 'Erreur lors de la communication avec le serveur.',
      statusCode: statusCode,
    );
  }
}
