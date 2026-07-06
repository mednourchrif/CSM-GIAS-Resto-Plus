import 'package:dio/dio.dart';

import '../../../../core/network/api_response.dart';
import '../dto/meal_category_dto.dart';
import '../dto/register_meal_request_dto.dart';
import '../dto/register_meal_response_dto.dart';

class MealRemoteDataSource {
  final Dio _dio;

  MealRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<RegisterMealResponseDto> registerMeal({
    String? qrToken,
    String? userUuid,
    required String categorieUuid,
  }) async {
    final request = RegisterMealRequestDto(
      token: qrToken,
      userUuid: userUuid,
      categorieUuid: categorieUuid,
    );

    final response = await _dio.post<Map<String, dynamic>>(
      '/meals/register',
      data: request.toJson(),
    );

    final apiResponse =
        ApiResponse<Map<String, dynamic>>.fromResponse(response);
    return RegisterMealResponseDto.fromJson(apiResponse.data ?? {});
  }

  Future<List<MealCategoryDto>> getCategories() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/meals/categories',
    );

    final apiResponse =
        ApiResponse<List<dynamic>>.fromResponse(response);
    final data = apiResponse.data ?? [];
    return data
        .map((e) => MealCategoryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
