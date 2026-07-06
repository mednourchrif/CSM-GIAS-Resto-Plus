import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/result.dart';
import '../../domain/entities/meal_category.dart';
import '../../domain/entities/meal_registration.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_remote_datasource.dart';

class MealRepositoryImpl implements MealRepository {
  final MealRemoteDataSource _remoteDataSource;

  MealRepositoryImpl({required MealRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<MealRegistration>> registerMeal({
    String? qrToken,
    String? userUuid,
    required String categorieUuid,
  }) async {
    try {
      final response = await _remoteDataSource.registerMeal(
        qrToken: qrToken,
        userUuid: userUuid,
        categorieUuid: categorieUuid,
      );
      return Success(response.toDomain());
    } on DioException catch (e) {
      return Fail(_mapError(e));
    } catch (e) {
      return Fail(
        const ApiFailure(message: 'Erreur lors de l\'enregistrement du repas.'),
      );
    }
  }

  @override
  Future<Result<List<MealCategory>>> getCategories() async {
    try {
      final dtos = await _remoteDataSource.getCategories();
      return Success(dtos.map((d) => d.toDomain()).toList());
    } on DioException catch (e) {
      return Fail(_mapError(e));
    } catch (e) {
      return Fail(
        const ApiFailure(message: 'Erreur lors du chargement des catégories.'),
      );
    }
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
        message:
            'Impossible de contacter le serveur. Vérifiez votre connexion.',
      );
    }

    if (statusCode == 400) {
      return ValidationFailure(
        message: message ?? 'Requête invalide.',
      );
    }

    if (statusCode == 409) {
      return ApiFailure(
        message: message ?? 'Vous avez déjà mangé aujourd\'hui.',
        statusCode: statusCode,
      );
    }

    if (statusCode == 403) {
      return ApiFailure(
        message: message ?? 'Le restaurant est fermé.',
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return ServerFailure(
        message: message ?? 'Erreur interne du serveur.',
        statusCode: statusCode,
      );
    }

    return const NetworkFailure(
      message: 'Erreur réseau. Veuillez réessayer.',
    );
  }
}
