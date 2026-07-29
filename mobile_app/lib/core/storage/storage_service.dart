import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:universal_platform/universal_platform.dart';

import '../errors/exceptions.dart';
import '../errors/failures.dart';

abstract class StorageService {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}

final class SecureStorageService implements StorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({
    FlutterSecureStorage? storage,
    AndroidOptions androidOptions = const AndroidOptions(),
    IOSOptions iosOptions = const IOSOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    MacOsOptions macOsOptions = const MacOsOptions(),
    WebOptions webOptions = const WebOptions(),
  }) : _storage =
           storage ??
           FlutterSecureStorage(
             aOptions: androidOptions,
             iOptions: iosOptions,
             lOptions: linuxOptions,
             mOptions: macOsOptions,
             webOptions: webOptions,
           );

  @override
  Future<void> write({required String key, required String value}) async {
    if (UniversalPlatform.isWeb) {
      debugPrint(
        'Storage: write($key) on Web is not supported by '
        'flutter_secure_storage. Use a web-compatible implementation.',
      );
      return;
    }
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (e) {
      throw CacheException(
        CacheFailure(
          message: 'Impossible de sécuriser la session sur cet appareil.',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<String?> read({required String key}) async {
    if (UniversalPlatform.isWeb) {
      debugPrint(
        'Storage: read($key) on Web is not supported by '
        'flutter_secure_storage. Use a web-compatible implementation.',
      );
      return null;
    }
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      throw CacheException(
        CacheFailure(
          message: 'Impossible de lire la session sécurisée.',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<void> delete({required String key}) async {
    if (UniversalPlatform.isWeb) {
      return;
    }
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (e) {
      throw CacheException(
        CacheFailure(
          message: 'Impossible de supprimer la session sécurisée.',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<void> deleteAll() async {
    if (UniversalPlatform.isWeb) {
      return;
    }
    try {
      await _storage.deleteAll();
    } on PlatformException catch (e) {
      throw CacheException(
        CacheFailure(
          message: 'Impossible de réinitialiser le stockage sécurisé.',
          originalError: e,
        ),
      );
    }
  }
}

final class InMemoryStorageService implements StorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _store[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }
}
