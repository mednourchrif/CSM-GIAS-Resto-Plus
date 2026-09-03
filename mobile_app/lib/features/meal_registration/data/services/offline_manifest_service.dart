import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../../core/storage/storage_service.dart';
import '../../../../../core/utils/crypto_utils.dart';
import '../../domain/entities/meal_category.dart';

class OfflineCachedUser {
  final String qrHash;
  final String userUuid;
  final String nom;
  final String prenom;
  final String? matricule;
  final String type;

  const OfflineCachedUser({
    required this.qrHash,
    required this.userUuid,
    required this.nom,
    required this.prenom,
    this.matricule,
    required this.type,
  });

  String get fullName => '$prenom $nom'.trim();

  factory OfflineCachedUser.fromJson(Map<String, dynamic> json) {
    return OfflineCachedUser(
      qrHash: json['qr_hash'] as String? ?? '',
      userUuid: json['user_uuid'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      matricule: json['matricule'] as String?,
      type: json['type'] as String? ?? 'EMPLOYE',
    );
  }

  Map<String, dynamic> toJson() => {
    'qr_hash': qrHash,
    'user_uuid': userUuid,
    'nom': nom,
    'prenom': prenom,
    'matricule': matricule,
    'type': type,
  };
}

class OfflineManifestService {
  static const String _categoriesKey = 'offline_cached_categories_v1';
  static const String _usersKey = 'offline_cached_users_v1';
  static const String _dailyLogPrefix = 'offline_daily_qr_';

  final StorageService _storage;

  OfflineManifestService(this._storage);

  /// Default fallback categories if the tablet has never connected to the backend.
  static final List<MealCategory> defaultCategories = [
    const MealCategory(
      uuid: 'c1000000-0000-0000-0000-000000000001',
      nom: 'Plat',
      description: 'Plat principal du jour',
    ),
    const MealCategory(
      uuid: 'c2000000-0000-0000-0000-000000000002',
      nom: 'Pizza',
      description: 'Pizza du jour',
    ),
    const MealCategory(
      uuid: 'c3000000-0000-0000-0000-000000000003',
      nom: 'Sandwich',
      description: 'Sandwich du jour',
    ),
  ];

  /// Download and persist categories and active user QR hashes.
  Future<bool> fetchAndCacheManifest(Dio dio) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/meals/offline-manifest');
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) return false;

      final categoriesRaw = data['categories'] as List<dynamic>? ?? [];
      final usersRaw = data['users'] as List<dynamic>? ?? [];

      await _storage.write(
        key: _categoriesKey,
        value: jsonEncode(categoriesRaw),
      );
      await _storage.write(
        key: _usersKey,
        value: jsonEncode(usersRaw),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get cached categories with fallback to default categories so the UI never breaks.
  Future<List<MealCategory>> getCachedCategories() async {
    final raw = await _storage.read(key: _categoriesKey);
    if (raw == null || raw.isEmpty) {
      return defaultCategories;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final list = decoded.map((e) {
        final map = e as Map<String, dynamic>;
        return MealCategory(
          uuid: map['uuid'] as String,
          nom: map['nom'] as String,
          description: map['description'] as String?,
        );
      }).toList();
      return list.isEmpty ? defaultCategories : list;
    } catch (_) {
      return defaultCategories;
    }
  }

  /// Cache categories directly (e.g. from /meals/categories).
  Future<void> cacheCategories(List<MealCategory> categories) async {
    final mapped = categories
        .map((c) => {
              'uuid': c.uuid,
              'nom': c.nom,
              'description': c.description,
            })
        .toList();
    await _storage.write(key: _categoriesKey, value: jsonEncode(mapped));
  }

  /// Look up user by scanned QR token hash.
  Future<OfflineCachedUser?> findUserByQrToken(String qrToken) async {
    final qrHash = sha256Hex(qrToken);
    final raw = await _storage.read(key: _usersKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      for (final item in decoded) {
        final user = OfflineCachedUser.fromJson(item as Map<String, dynamic>);
        if (user.qrHash.toLowerCase() == qrHash.toLowerCase()) {
          return user;
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Check if this QR code has already been used today while offline.
  Future<bool> hasMealToday(String qrToken) async {
    final qrHash = sha256Hex(qrToken);
    final dateKey = _todayKey();
    final raw = await _storage.read(key: dateKey);
    if (raw == null || raw.isEmpty) return false;

    try {
      final decoded = (jsonDecode(raw) as List<dynamic>).cast<String>();
      return decoded.contains(qrHash);
    } catch (_) {
      return false;
    }
  }

  /// Record a QR code as used today in local storage.
  Future<void> recordLocalMealToday(String qrToken) async {
    final qrHash = sha256Hex(qrToken);
    final dateKey = _todayKey();
    final raw = await _storage.read(key: dateKey);
    List<String> list = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        list = (jsonDecode(raw) as List<dynamic>).cast<String>().toList();
      } catch (_) {
        list = [];
      }
    }
    if (!list.contains(qrHash)) {
      list.add(qrHash);
      await _storage.write(key: dateKey, value: jsonEncode(list));
    }
  }

  String _todayKey() {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return '$_dailyLogPrefix$todayStr';
  }
}
