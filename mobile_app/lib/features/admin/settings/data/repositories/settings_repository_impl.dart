import 'package:dio/dio.dart';
import 'package:mobile_app/core/errors/failures.dart';
import 'package:mobile_app/shared/models/result.dart';
import 'package:mobile_app/shared/utils/dio_error_mapper.dart';

import '../../domain/entities/setting.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _dataSource;

  SettingsRepositoryImpl({required SettingsRemoteDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<Result<AppSettings>> getSettings() async {
    try {
      final dto = await _dataSource.getSettings();
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'paramètres'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement des paramètres.'));
    }
  }

  @override
  Future<Result<AppSettings>> updateSettings(Map<String, String> settings) async {
    try {
      final dto = await _dataSource.updateSettings(settings);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'paramètres'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la mise à jour des paramètres.'));
    }
  }

  @override
  Future<Result<AppSettings>> resetToDefaults() async {
    try {
      final dto = await _dataSource.resetToDefaults();
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'paramètres'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la réinitialisation des paramètres.'));
    }
  }

  @override
  Future<Result<VersionInfo>> getVersion() async {
    try {
      final dto = await _dataSource.getVersion();
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'version'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la récupération de la version.'));
    }
  }

  @override
  Future<Result<DatabaseStatus>> getDatabaseStatus() async {
    try {
      final dto = await _dataSource.getDatabaseStatus();
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'base de données'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la récupération du statut.'));
    }
  }
}
