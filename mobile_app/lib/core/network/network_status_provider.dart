import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/meal_registration/presentation/providers/meal_registration_provider.dart';
import '../../providers.dart';

class NetworkStatus {
  final bool isOnline;
  final bool isSyncing;
  final int offlineQueueCount;
  final DateTime? lastChecked;

  const NetworkStatus({
    this.isOnline = true,
    this.isSyncing = false,
    this.offlineQueueCount = 0,
    this.lastChecked,
  });

  NetworkStatus copyWith({
    bool? isOnline,
    bool? isSyncing,
    int? offlineQueueCount,
    DateTime? lastChecked,
  }) {
    return NetworkStatus(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      offlineQueueCount: offlineQueueCount ?? this.offlineQueueCount,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

class NetworkStatusNotifier extends StateNotifier<NetworkStatus> {
  final Ref _ref;
  Timer? _checkTimer;
  bool _wasOffline = false;

  NetworkStatusNotifier(this._ref) : super(const NetworkStatus()) {
    _init();
  }

  void _init() {
    _checkHealth();
    _checkTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkHealth();
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkHealth() async {
    final dio = _ref.read(apiClientProvider).dio;
    final queueService = _ref.read(mealOfflineQueueServiceProvider);
    final count = await queueService.count();

    bool online = state.isOnline;
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/health',
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      online = response.statusCode == 200;
    } catch (_) {
      online = false;
    }

    final justReconnected = _wasOffline && online;
    _wasOffline = !online;

    state = state.copyWith(
      isOnline: online,
      offlineQueueCount: count,
      lastChecked: DateTime.now(),
    );

    // Auto-sync trigger: if online and items exist in queue, or if just reconnected
    if (online && count > 0 && !state.isSyncing) {
      unawaited(triggerAutoSync());
    } else if (justReconnected) {
      // Refresh manifest when network recovers
      try {
        final manifestService = _ref.read(offlineManifestServiceProvider);
        unawaited(manifestService.fetchAndCacheManifest(dio));
      } catch (_) {}
    }
  }

  Future<int> triggerAutoSync() async {
    if (state.isSyncing) return 0;
    state = state.copyWith(isSyncing: true);

    try {
      final syncService = _ref.read(mealSyncServiceProvider);
      final syncedCount = await syncService.syncNow();
      final remaining = await _ref.read(mealOfflineQueueServiceProvider).count();

      state = state.copyWith(
        isSyncing: false,
        offlineQueueCount: remaining,
      );

      // Refresh meal registration provider status
      unawaited(_ref.read(mealRegistrationProvider.notifier).refreshOfflineQueueStatus());

      return syncedCount;
    } catch (e) {
      state = state.copyWith(isSyncing: false);
      return 0;
    }
  }
}

final networkStatusProvider =
    StateNotifierProvider<NetworkStatusNotifier, NetworkStatus>((ref) {
  return NetworkStatusNotifier(ref);
});
