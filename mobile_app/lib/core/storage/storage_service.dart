import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'web_storage.dart';

abstract class StorageService {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}

final class SecureStorageService implements StorageService {
  final FlutterSecureStorage _storage;
  final Map<String, String> _ephemeralFallback = {};

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
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      final webStorage = getWebStorage();
      if (webStorage != null) {
        webStorage[key] = value;
      } else {
        _ephemeralFallback[key] = value;
      }
    }
  }

  @override
  Future<String?> read({required String key}) async {
    try {
      final val = await _storage.read(key: key);
      if (val != null) return val;
      final webStorage = getWebStorage();
      return webStorage?[key] ?? _ephemeralFallback[key];
    } catch (_) {
      final webStorage = getWebStorage();
      return webStorage?[key] ?? _ephemeralFallback[key];
    }
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
    getWebStorage()?.remove(key);
    _ephemeralFallback.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
    getWebStorage()?.clear();
    _ephemeralFallback.clear();
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
