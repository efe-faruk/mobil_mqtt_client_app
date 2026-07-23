import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/broker_config.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static const String _keyBrokerConfig = 'mqtt_broker_config';

  // Eski sürümlerde kullanılan anahtarlar. Kayıtlı ayarları kaybetmemek için
  // load ve clear işlemlerinde desteklenmeye devam edilir.
  static const String _keyHost = 'mqtt_host';
  static const String _keyPort = 'mqtt_port';
  static const String _keyClientId = 'mqtt_client_id';
  static const String _keyKeepAlive = 'mqtt_keep_alive';
  static const String _keyUseAuth = 'mqtt_use_auth';

  BrokerConfig loadBrokerConfig() {
    final encodedConfig = _prefs.getString(_keyBrokerConfig);
    if (encodedConfig != null) {
      try {
        final decoded = jsonDecode(encodedConfig);
        if (decoded is Map) {
          return BrokerConfig.fromMap(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {
        // Bozuk yeni kayıt varsa eski anahtarlara geri dön.
      }
    }

    return BrokerConfig(
      host: _prefs.getString(_keyHost) ?? '192.168.1.100',
      port: _prefs.getInt(_keyPort) ?? 1883,
      clientId: _prefs.getString(_keyClientId) ?? 'flutter_home_client',
      keepAliveSeconds: _prefs.getInt(_keyKeepAlive) ?? 60,
      useAuth: _prefs.getBool(_keyUseAuth) ?? false,
    );
  }

  Future<void> saveBrokerConfig(BrokerConfig config) async {
    final didPersist = await _prefs.setString(
      _keyBrokerConfig,
      jsonEncode(config.toMap()),
    );

    if (!didPersist) {
      throw StateError('Broker ayarları kalıcı depoya yazılamadı.');
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
    ]);
  }
}
