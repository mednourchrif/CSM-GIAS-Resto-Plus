import '../../domain/entities/report_entity.dart';

class ReportOverviewDto {
  final int totalMeals;
  final int totalEmployees;
  final int totalInterns;
  final int totalVisitors;
  final int qrRegistrations;
  final int faceRegistrations;
  final int failedRecognitions;
  final int failedQrScans;
  final double? averageProcessingTime;
  final String? peakHour;
  final String? mostSelectedMeal;

  const ReportOverviewDto({
    required this.totalMeals,
    required this.totalEmployees,
    required this.totalInterns,
    required this.totalVisitors,
    required this.qrRegistrations,
    required this.faceRegistrations,
    required this.failedRecognitions,
    required this.failedQrScans,
    this.averageProcessingTime,
    this.peakHour,
    this.mostSelectedMeal,
  });

  factory ReportOverviewDto.fromJson(Map<String, dynamic> json) {
    return ReportOverviewDto(
      totalMeals: json['total_meals'] as int,
      totalEmployees: json['total_employees'] as int,
      totalInterns: json['total_interns'] as int,
      totalVisitors: json['total_visitors'] as int,
      qrRegistrations: json['qr_registrations'] as int,
      faceRegistrations: json['face_registrations'] as int,
      failedRecognitions: json['failed_recognitions'] as int,
      failedQrScans: json['failed_qr_scans'] as int,
      averageProcessingTime: (json['average_processing_time'] as num?)?.toDouble(),
      peakHour: json['peak_hour'] as String?,
      mostSelectedMeal: json['most_selected_meal'] as String?,
    );
  }

  ReportOverview toDomain() {
    return ReportOverview(
      totalMeals: totalMeals,
      totalEmployees: totalEmployees,
      totalInterns: totalInterns,
      totalVisitors: totalVisitors,
      qrRegistrations: qrRegistrations,
      faceRegistrations: faceRegistrations,
      failedRecognitions: failedRecognitions,
      failedQrScans: failedQrScans,
      averageProcessingTime: averageProcessingTime,
      peakHour: peakHour,
      mostSelectedMeal: mostSelectedMeal,
    );
  }
}

class ReportTimeSeriesItemDto {
  final String period;
  final int count;

  const ReportTimeSeriesItemDto({required this.period, required this.count});

  factory ReportTimeSeriesItemDto.fromJson(Map<String, dynamic> json) {
    return ReportTimeSeriesItemDto(
      period: json['period'] as String,
      count: json['count'] as int,
    );
  }

  ReportTimeSeriesItem toDomain() {
    return ReportTimeSeriesItem(period: period, count: count);
  }
}

class ReportPeakHourItemDto {
  final int hour;
  final int count;

  const ReportPeakHourItemDto({required this.hour, required this.count});

  factory ReportPeakHourItemDto.fromJson(Map<String, dynamic> json) {
    return ReportPeakHourItemDto(
      hour: json['hour'] as int,
      count: json['count'] as int,
    );
  }

  ReportPeakHourItem toDomain() {
    return ReportPeakHourItem(hour: hour, count: count);
  }
}

class ReportDistributionItemDto {
  final String label;
  final int count;

  const ReportDistributionItemDto({required this.label, required this.count});

  factory ReportDistributionItemDto.fromJson(Map<String, dynamic> json) {
    return ReportDistributionItemDto(
      label: json['label'] as String,
      count: json['count'] as int,
    );
  }

  ReportDistributionItem toDomain() {
    return ReportDistributionItem(label: label, count: count);
  }
}

class ReportDto {
  final ReportOverviewDto overview;
  final List<ReportTimeSeriesItemDto> mealsPerDay;
  final List<ReportPeakHourItemDto> mealsByHour;
  final List<ReportDistributionItemDto> mealsByCategory;
  final List<ReportDistributionItemDto> registrationMethods;
  final List<ReportDistributionItemDto> peopleByType;
  final String periodLabel;
  final String dateFrom;
  final String dateTo;
  final String generatedAt;

  const ReportDto({
    required this.overview,
    required this.mealsPerDay,
    required this.mealsByHour,
    required this.mealsByCategory,
    required this.registrationMethods,
    required this.peopleByType,
    required this.periodLabel,
    required this.dateFrom,
    required this.dateTo,
    required this.generatedAt,
  });

  factory ReportDto.fromJson(Map<String, dynamic> json) {
    return ReportDto(
      overview: ReportOverviewDto.fromJson(json['overview'] as Map<String, dynamic>),
      mealsPerDay: (json['meals_per_day'] as List<dynamic>)
          .map((e) => ReportTimeSeriesItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      mealsByHour: (json['meals_by_hour'] as List<dynamic>)
          .map((e) => ReportPeakHourItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      mealsByCategory: (json['meals_by_category'] as List<dynamic>)
          .map((e) => ReportDistributionItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      registrationMethods: (json['registration_methods'] as List<dynamic>)
          .map((e) => ReportDistributionItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      peopleByType: (json['people_by_type'] as List<dynamic>)
          .map((e) => ReportDistributionItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      periodLabel: json['period_label'] as String,
      dateFrom: json['date_from'] as String,
      dateTo: json['date_to'] as String,
      generatedAt: json['generated_at'] as String,
    );
  }

  Report toDomain() {
    return Report(
      overview: overview.toDomain(),
      mealsPerDay: mealsPerDay.map((e) => e.toDomain()).toList(),
      mealsByHour: mealsByHour.map((e) => e.toDomain()).toList(),
      mealsByCategory: mealsByCategory.map((e) => e.toDomain()).toList(),
      registrationMethods: registrationMethods.map((e) => e.toDomain()).toList(),
      peopleByType: peopleByType.map((e) => e.toDomain()).toList(),
      periodLabel: periodLabel,
      dateFrom: dateFrom,
      dateTo: dateTo,
      generatedAt: generatedAt,
    );
  }
}
