import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureSettingsStorage {
  Future<String?> read({required String key});

  Future<void> write({
    required String key,
    required String value,
  });

  Future<void> delete({required String key});
}

final class FlutterSecureSettingsStorage implements SecureSettingsStorage {
  final FlutterSecureStorage _storage;

  const FlutterSecureSettingsStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  @override
  Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<void> write({
    required String key,
    required String value,
  }) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }
}
