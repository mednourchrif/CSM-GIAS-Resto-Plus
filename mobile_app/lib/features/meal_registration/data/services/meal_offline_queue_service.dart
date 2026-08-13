import 'dart:convert';

import '../../../../../core/storage/storage_service.dart';

class MealOfflineQueueItem {
  final String identificationToken;
  final String categorieUuid;
  final String mealLabel;
  final DateTime queuedAt;

  const MealOfflineQueueItem({
    required this.identificationToken,
    required this.categorieUuid,
    required this.mealLabel,
    required this.queuedAt,
  });

  factory MealOfflineQueueItem.fromJson(Map<String, dynamic> json) {
    return MealOfflineQueueItem(
      identificationToken: json['identification_token'] as String,
      categorieUuid: json['categorie_uuid'] as String,
      mealLabel: json['meal_label'] as String? ?? '',
      queuedAt:
          DateTime.tryParse(json['queued_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'identification_token': identificationToken,
    'categorie_uuid': categorieUuid,
    'meal_label': mealLabel,
    'queued_at': queuedAt.toIso8601String(),
  };
}

class MealOfflineQueueService {
  static const String _storageKey = 'meal_registration_offline_queue_v1';

  final StorageService _storage;

  MealOfflineQueueService(this._storage);

  Future<List<MealOfflineQueueItem>> load() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (entry) =>
              MealOfflineQueueItem.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> save(List<MealOfflineQueueItem> items) async {
    await _storage.write(
      key: _storageKey,
      value: jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  Future<int> count() async => (await load()).length;

  Future<void> enqueue(MealOfflineQueueItem item) async {
    final items = await load();
    items.add(item);
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
