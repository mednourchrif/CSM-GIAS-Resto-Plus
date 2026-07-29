import '../datasources/meal_history_remote_datasource.dart';
import '../dto/meal_history_dto.dart';
import '../../domain/entities/meal_history.dart';
import '../../domain/repositories/meal_history_repository.dart';

class MealHistoryRepositoryImpl implements MealHistoryRepository {
  final MealHistoryRemoteDataSource _dataSource;

  MealHistoryRepositoryImpl(this._dataSource);

  @override
  Future<PaginatedMealResult> getMealHistory({
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
    final dto = await _dataSource.getMealHistory(
      page: page,
      pageSize: pageSize,
      search: search,
      dateFrom: dateFrom,
      dateTo: dateTo,
      categorieUuid: categorieUuid,
      typeIdentification: typeIdentification,
      userType: userType,
      sort: sort,
      order: order,
    );
    return PaginatedMealResult(
      items: dto.data.map(_toEntity).toList(),
      total: dto.total,
      page: dto.page,
      pageSize: dto.pageSize,
      totalPages: dto.totalPages,
    );
  }

  @override
  Future<MealStats> getMealStats({String? dateFrom, String? dateTo}) async {
    final dto = await _dataSource.getMealStats(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
    return MealStats(
      totalMeals: dto.totalMeals,
      totalEmployees: dto.totalEmployees,
      totalInterns: dto.totalInterns,
      totalVisitors: dto.totalVisitors,
      faceRegistrations: dto.faceRegistrations,
      qrRegistrations: dto.qrRegistrations,
    );
  }

  MealHistory _toEntity(MealHistoryDto dto) {
    return MealHistory(
      uuid: dto.uuid,
      utilisateurUuid: dto.utilisateurUuid,
      nom: dto.nom,
      prenom: dto.prenom,
      email: dto.email,
      typeIdentification: _parseTypeIdentification(dto.typeIdentification),
      categorieUuid: dto.categorieUuid,
      categorieNom: dto.categorieNom,
      dateRepas: DateTime.parse(dto.dateRepas),
      heureRepas: dto.heureRepas,
    );
  }

  TypeIdentification _parseTypeIdentification(String value) {
    switch (value.toUpperCase()) {
      case 'QR':
        return TypeIdentification.qr;
      case 'FACE':
        return TypeIdentification.face;
      default:
        return TypeIdentification.unknown;
    }
  }
}
