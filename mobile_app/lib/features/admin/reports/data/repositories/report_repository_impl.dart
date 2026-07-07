import 'package:dio/dio.dart';
import 'package:mobile_app/shared/models/result.dart';
import 'package:mobile_app/shared/utils/dio_error_mapper.dart';

import '../../domain/entities/report_entity.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';
import '../dto/report_dto.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _dataSource;

  ReportRepositoryImpl({required ReportRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<Report>> generate(ReportFilter filter) async {
    try {
      final params = <String, dynamic>{
        if (filter.dateFrom != null) 'date_from': filter.dateFrom!.toIso8601String().split('T').first,
        if (filter.dateTo != null) 'date_to': filter.dateTo!.toIso8601String().split('T').first,
        if (filter.userType != null) 'user_type': filter.userType,
        if (filter.typeIdentification != null) 'type_identification': filter.typeIdentification,
        if (filter.categorieUuid != null) 'categorie_uuid': filter.categorieUuid,
      };

      final data = await _dataSource.generate(params);
      final reportDto = ReportDto.fromJson(data['data'] as Map<String, dynamic>);
      return Success(reportDto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'Rapport'));
    }
  }
}
