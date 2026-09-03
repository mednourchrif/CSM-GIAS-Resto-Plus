import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'meal_offline_queue_service.dart';
import 'offline_manifest_service.dart';

class MealSyncService {
  final Dio dio;
  final MealOfflineQueueService queueService;
  final OfflineManifestService manifestService;
  final void Function(int count)? onQueueCountChanged;

  Timer? _syncTimer;
  bool _isSyncing = false;

  MealSyncService({
    required this.dio,
    required this.queueService,
    required this.manifestService,
    this.onQueueCountChanged,
  });

  bool get isSyncing => _isSyncing;

  void startPeriodicSync({Duration interval = const Duration(seconds: 30)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => syncNow());
    // Trigger initial sync attempt on start
    unawaited(syncNow());
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<int> syncNow() async {
    if (_isSyncing) return 0;
    _isSyncing = true;

    try {
      final items = await queueService.load();
      final pending = items.where((i) => i.syncStatus == 'pending').toList();

      if (pending.isEmpty) {
        // Queue is empty, attempt to refresh offline manifest while online
        unawaited(manifestService.fetchAndCacheManifest(dio));
        _notifyCount(0);
        return 0;
      }

      final payload = {
        'items': pending
            .map(
              (i) => {
                'offline_id': i.offlineId,
                'qr_token': i.qrToken,
                'categorie_uuid': i.categorieUuid,
                'registered_at': i.registeredAt.toIso8601String(),
                'identification_type': 'QR',
              },
            )
            .toList(),
      };

      final response = await dio.post<Map<String, dynamic>>(
        '/meals/sync-offline',
        data: payload,
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        return 0;
      }

      final results = data['results'] as List<dynamic>? ?? [];
      final syncedIds = <String>[];

      for (final raw in results) {
        final res = raw as Map<String, dynamic>;
        final offlineId = res['offline_id'] as String? ?? '';
        final status = res['statut'] as String? ?? '';

        if (status == 'SYNCED' || status == 'ALREADY_REGISTERED') {
          syncedIds.add(offlineId);
        }
      }

      if (syncedIds.isNotEmpty) {
        await queueService.removeByOfflineIds(syncedIds);
      }

      final remainingCount = await queueService.count();
      _notifyCount(remainingCount);

      // Refresh manifest in the background after sync
      unawaited(manifestService.fetchAndCacheManifest(dio));

      return syncedIds.length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MealSyncService: sync failed: $e');
      }
      return 0;
    } finally {
      _isSyncing = false;
    }
  }

  void _notifyCount(int count) {
    if (onQueueCountChanged != null) {
      onQueueCountChanged!(count);
    }
  }
}

