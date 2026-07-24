import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/broker_config.dart';
import '../storage/secure_settings_storage.dart';

class SettingsRepository {
  final SharedPreferences _prefs;
  final SecureSettingsStorage _secureStorage;

  SettingsRepository(this._prefs, this._secureStorage);

  static const String _keyBrokerConfig = 'mqtt_broker_config';
  static const String _keyPassword = 'mqtt_broker_password';

  // Eski sürümlerde kullanılan anahtarlar. Kayıtlı ayarları kaybetmemek için
  // load ve clear işlemlerinde desteklenmeye devam edilir.
  static const String _keyHost = 'mqtt_host';
  static const String _keyPort = 'mqtt_port';
  static const String _keyClientId = 'mqtt_client_id';
  static const String _keyKeepAlive = 'mqtt_keep_alive';
  static const String _keyUseAuth = 'mqtt_use_auth';
  static const String _keyUsername = 'mqtt_username';

  Future<BrokerConfig> loadBrokerConfig() async {
    final configMap = _loadNonSensitiveConfig();
    final hadPlaintextPassword = configMap.containsKey('password');
    final plaintextPassword = configMap.remove('password') as String? ?? '';
    final useAuth = configMap['useAuth'] as bool? ?? false;

    var securePassword = await _secureStorage.read(key: _keyPassword);

    // Önceki sürüm parolayı SharedPreferences JSON'u içinde tutuyordu.
    // Güvenli depoda parola yoksa bir kez taşı ve ardından düz metni sil.
    if (useAuth &&
        (securePassword == null || securePassword.isEmpty) &&
        plaintextPassword.isNotEmpty) {
      await _secureStorage.write(
        key: _keyPassword,
        value: plaintextPassword,
      );
      securePassword = plaintextPassword;
    }

    if (hadPlaintextPassword) {
      await _persistNonSensitiveConfig(configMap);
    }

    return BrokerConfig.fromMap({
      ...configMap,
      'password': useAuth ? securePassword ?? '' : '',
    });
  }

  Map<String, dynamic> _loadNonSensitiveConfig() {
    final encodedConfig = _prefs.getString(_keyBrokerConfig);
    if (encodedConfig != null) {
      try {
        final decoded = jsonDecode(encodedConfig);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        // Bozuk yeni kayıt varsa eski anahtarlara geri dön.
      }
    }

    return {
      'host': _prefs.getString(_keyHost) ?? '192.168.1.100',
      'port': _prefs.getInt(_keyPort) ?? 1883,
      'clientId':
          _prefs.getString(_keyClientId) ?? 'flutter_home_client',
      'keepAliveSeconds': _prefs.getInt(_keyKeepAlive) ?? 60,
      'useAuth': _prefs.getBool(_keyUseAuth) ?? false,
      'username': _prefs.getString(_keyUsername) ?? '',
    };
  }

  Future<void> saveBrokerConfig(BrokerConfig config) async {
    if (config.useAuth && config.password.isEmpty) {
      throw ArgumentError('Kimlik doğrulama parolası boş olamaz.');
    }

    final previousPassword = await _secureStorage.read(key: _keyPassword);
    var secureStorageChanged = false;

    try {
      if (config.useAuth) {
        await _secureStorage.write(
          key: _keyPassword,
          value: config.password,
        );
      } else {
        await _secureStorage.delete(key: _keyPassword);
      }
      secureStorageChanged = true;

      await _persistNonSensitiveConfig({
        'host': config.host,
        'port': config.port,
        'clientId': config.clientId,
        'keepAliveSeconds': config.keepAliveSeconds,
        'useAuth': config.useAuth,
        'username': config.username,
      });
    } catch (_) {
      if (secureStorageChanged) {
        if (previousPassword == null) {
          await _secureStorage.delete(key: _keyPassword);
        } else {
          await _secureStorage.write(
            key: _keyPassword,
            value: previousPassword,
          );
        }
      }
      rethrow;
    }
  }

  Future<void> clearBrokerConfig() async {
    await Future.wait([
      _prefs.remove(_keyBrokerConfig),
      _prefs.remove(_keyHost),
      _prefs.remove(_keyPort),
      _prefs.remove(_keyClientId),
      _prefs.remove(_keyKeepAlive),
      _prefs.remove(_keyUseAuth),
      _prefs.remove(_keyUsername),
    ]);
    await _secureStorage.delete(key: _keyPassword);
  }

  Future<void> _persistNonSensitiveConfig(
    Map<String, dynamic> config,
  ) async {
    final sanitizedConfig = Map<String, dynamic>.from(config)
      ..remove('password');
    final didPersist = await _prefs.setString(
      _keyBrokerConfig,
      jsonEncode(sanitizedConfig),
    );

    if (!didPersist) {
      throw StateError('Broker ayarları kalıcı depoya yazılamadı.');
    }
  }
}
