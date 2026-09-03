import 'dart:convert';

import '../../../../../core/storage/storage_service.dart';

class MealOfflineQueueItem {
  final String offlineId;
  final String qrToken;
  final String identificationToken;
  final String categorieUuid;
  final String mealLabel;
  final DateTime registeredAt;
  final String? userName;
  final String? userMatricule;
  final String? receiptNumber;
  final String syncStatus;
  final String? syncError;

  const MealOfflineQueueItem({
    required this.offlineId,
    required this.qrToken,
    this.identificationToken = '',
    required this.categorieUuid,
    required this.mealLabel,
    required this.registeredAt,
    this.userName,
    this.userMatricule,
    this.receiptNumber,
    this.syncStatus = 'pending',
    this.syncError,
  });

  factory MealOfflineQueueItem.fromJson(Map<String, dynamic> json) {
    return MealOfflineQueueItem(
      offlineId: json['offline_id'] as String? ?? json['identification_token'] as String? ?? '',
      qrToken: json['qr_token'] as String? ?? json['identification_token'] as String? ?? '',
      identificationToken: json['identification_token'] as String? ?? '',
      categorieUuid: json['categorie_uuid'] as String,
      mealLabel: json['meal_label'] as String? ?? '',
      registeredAt:
          DateTime.tryParse(json['registered_at'] as String? ?? json['queued_at'] as String? ?? '') ??
          DateTime.now(),
      userName: json['user_name'] as String?,
      userMatricule: json['user_matricule'] as String?,
      receiptNumber: json['receipt_number'] as String?,
      syncStatus: json['sync_status'] as String? ?? 'pending',
      syncError: json['sync_error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'offline_id': offlineId,
    'qr_token': qrToken,
    'identification_token': identificationToken,
    'categorie_uuid': categorieUuid,
    'meal_label': mealLabel,
    'registered_at': registeredAt.toIso8601String(),
    'user_name': userName,
    'user_matricule': userMatricule,
    'receipt_number': receiptNumber,
    'sync_status': syncStatus,
    'sync_error': syncError,
  };
}

class MealOfflineQueueService {
  static const String _storageKey = 'meal_registration_offline_queue_v2';

  final StorageService _storage;

  MealOfflineQueueService(this._storage);

  Future<List<MealOfflineQueueItem>> load() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (entry) =>
                MealOfflineQueueItem.fromJson(entry as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<MealOfflineQueueItem> items) async {
    await _storage.write(
      key: _storageKey,
      value: jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  Future<int> count() async {
    final items = await load();
    return items.where((i) => i.syncStatus == 'pending').length;
  }

  Future<void> enqueue(MealOfflineQueueItem item) async {
    final items = await load();
    items.add(item);
    await save(items);
  }

  Future<void> removeByOfflineIds(List<String> offlineIds) async {
    final items = await load();
    final idSet = offlineIds.toSet();
    items.removeWhere((item) => idSet.contains(item.offlineId));
    await save(items);
  }

  Future<List<MealOfflineQueueItem>> removeFirst() async {
    final items = await load();
    if (items.isNotEmpty) {
      items.removeAt(0);
      await save(items);
    }
    return items;
  }

  Future<void> clear() async {
    await _storage.delete(key: _storageKey);
  }
}
