import '../datasources/meal_history_remote_datasource.dart';
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
      pageSize: dto.page_size,
      totalPages: dto.total_pages,
    );
  }

  @override
  Future<MealStats> getMealStats({
    String? dateFrom,
    String? dateTo,
  }) async {
    final dto = await _dataSource.getMealStats(dateFrom: dateFrom, dateTo: dateTo);
    return MealStats(
      totalMeals: dto.total_meals,
      totalEmployees: dto.total_employees,
      totalInterns: dto.total_interns,
      totalVisitors: dto.total_visitors,
      faceRegistrations: dto.face_registrations,
      qrRegistrations: dto.qr_registrations,
    );
  }

  MealHistory _toEntity(dto) {
    return MealHistory(
      uuid: dto.uuid,
      utilisateurUuid: dto.utilisateur_uuid,
      nom: dto.nom,
      prenom: dto.prenom,
      email: dto.email,
      typeIdentification: _parseTypeIdentification(dto.type_identification),
      categorieUuid: dto.categorie_uuid,
      categorieNom: dto.categorie_nom,
      dateRepas: DateTime.parse(dto.date_repas),
      heureRepas: dto.heure_repas,
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
