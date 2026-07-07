import 'package:dio/dio.dart';

import '../dto/meal_history_dto.dart';

class MealHistoryRemoteDataSource {
  final Dio _dio;

  MealHistoryRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<PaginatedMealHistoryDto> getMealHistory({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? dateFrom,
    String? dateTo,
    String? categorieUuid,
    String? typeIdentification,
    String? userType,
    String? sort,
    String order = 'desc',
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'order': order,
    };
    if (search != null) params['search'] = search;
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    if (categorieUuid != null) params['categorie_uuid'] = categorieUuid;
    if (typeIdentification != null) {
      params['type_identification'] = typeIdentification;
    }
    if (userType != null) params['user_type'] = userType;
    if (sort != null) params['sort'] = sort;

    final response = await _dio.get('/meals', queryParameters: params);
    final body = response.data as Map<String, dynamic>;
    return PaginatedMealHistoryDto.fromJson(body);
  }

  Future<MealStatsDto> getMealStats({
    String? dateFrom,
    String? dateTo,
  }) async {
    final params = <String, dynamic>{};
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;

    final response = await _dio.get('/meals/stats', queryParameters: params);
    final body = response.data['data'] as Map<String, dynamic>;
    return MealStatsDto.fromJson(body);
  }
}
