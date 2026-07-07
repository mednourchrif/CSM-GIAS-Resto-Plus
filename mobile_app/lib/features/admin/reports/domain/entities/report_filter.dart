enum ReportGranularity { daily, weekly, monthly }

class ReportFilter {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ReportGranularity granularity;
  final String? userType;
  final String? typeIdentification;
  final String? categorieUuid;

  const ReportFilter({
    this.dateFrom,
    this.dateTo,
    this.granularity = ReportGranularity.daily,
    this.userType,
    this.typeIdentification,
    this.categorieUuid,
  });

  ReportFilter copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    ReportGranularity? granularity,
    String? userType,
    String? typeIdentification,
    String? categorieUuid,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    bool clearUserType = false,
    bool clearTypeIdentification = false,
    bool clearCategorieUuid = false,
  }) {
    return ReportFilter(
      dateFrom: clearDateFrom ? null : dateFrom ?? this.dateFrom,
      dateTo: clearDateTo ? null : dateTo ?? this.dateTo,
      granularity: granularity ?? this.granularity,
      userType: clearUserType ? null : userType ?? this.userType,
      typeIdentification: clearTypeIdentification ? null : typeIdentification ?? this.typeIdentification,
      categorieUuid: clearCategorieUuid ? null : categorieUuid ?? this.categorieUuid,
    );
  }
}
