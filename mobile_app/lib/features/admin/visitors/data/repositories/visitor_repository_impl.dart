import 'package:dio/dio.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../shared/models/result.dart';
import '../../../../../shared/utils/dio_error_mapper.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/repositories/visitor_repository.dart';
import '../datasources/visitor_remote_datasource.dart';
import '../dto/create_visitor_request_dto.dart';
import '../dto/update_visitor_request_dto.dart';

class VisitorRepositoryImpl implements VisitorRepository {
  final VisitorRemoteDataSource _dataSource;

  VisitorRepositoryImpl({required VisitorRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<PaginatedVisitors>> getVisitors({
    required int page,
    required int pageSize,
    String? search,
    String? sort,
    String? order,
  }) async {
    try {
      final response = await _dataSource.getVisitors(
        page: page,
        pageSize: pageSize,
        search: search,
        sort: sort,
        order: order,
      );
      return Success(PaginatedVisitors(
        items: response.items.map((e) => e.toDomain()).toList(),
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
        totalPages: response.totalPages,
      ));
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'visiteur'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement des visiteurs.'));
    }
  }

  @override
  Future<Result<Visitor>> getVisitor(String uuid) async {
    try {
      final dto = await _dataSource.getVisitor(uuid);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'visiteur'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement du visiteur.'));
    }
  }

  @override
  Future<Result<Visitor>> createVisitor({
    required String nom,
    required String prenom,
    String? email,
    String? societe,
    required DateTime dateVisite,
    String? statut,
  }) async {
    try {
      final request = CreateVisitorRequestDto(
        nom: nom,
        prenom: prenom,
        email: email,
        societe: societe,
        dateVisite: _formatDate(dateVisite),
        statut: statut,
      );
      final dto = await _dataSource.createVisitor(request);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'visiteur'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la création du visiteur.'));
    }
  }

  @override
  Future<Result<Visitor>> updateVisitor(
    String uuid, {
    String? nom,
    String? prenom,
    String? email,
    String? societe,
    DateTime? dateVisite,
    String? statut,
  }) async {
    try {
      final request = UpdateVisitorRequestDto(
        nom: nom,
        prenom: prenom,
        email: email,
        societe: societe,
        dateVisite: dateVisite != null ? _formatDate(dateVisite) : null,
        statut: statut,
      );
      final dto = await _dataSource.updateVisitor(uuid, request);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'visiteur'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la modification du visiteur.'));
    }
  }

  @override
  Future<Result<void>> deleteVisitor(String uuid) async {
    try {
      await _dataSource.deleteVisitor(uuid);
      return const Success(null);
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'visiteur'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la suppression du visiteur.'));
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }
}
