class ReportOverview {
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

  const ReportOverview({
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
}

class ReportTimeSeriesItem {
  final String period;
  final int count;

  const ReportTimeSeriesItem({required this.period, required this.count});
}

class ReportPeakHourItem {
  final int hour;
  final int count;

  const ReportPeakHourItem({required this.hour, required this.count});
}

class ReportDistributionItem {
  final String label;
  final int count;

  const ReportDistributionItem({required this.label, required this.count});
}

class Report {
  final ReportOverview overview;
  final List<ReportTimeSeriesItem> mealsPerDay;
  final List<ReportPeakHourItem> mealsByHour;
  final List<ReportDistributionItem> mealsByCategory;
  final List<ReportDistributionItem> registrationMethods;
  final List<ReportDistributionItem> peopleByType;
  final String periodLabel;
  final String dateFrom;
  final String dateTo;
  final String generatedAt;

  const Report({
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
}
