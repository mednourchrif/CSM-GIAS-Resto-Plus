import '../../domain/entities/dashboard_stats.dart';

class StatisticsState {
  final DashboardStats? stats;
  final bool isLoading;
  final String? error;

  const StatisticsState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  StatisticsState copyWith({
    DashboardStats? stats,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return StatisticsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}
