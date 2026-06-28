import 'package:shared_preferences/shared_preferences.dart';
import '../../models/broker_config.dart';

/// Broker ayarlarını tutacak veri modeli.
/// İstersen bu sınıfı lib/models/broker_config.dart içine taşıyabilirsin.

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  // SharedPreferences için kullanılacak anahtarlar (keys)
  static const String _keyHost = 'mqtt_host';
  static const String _keyPort = 'mqtt_port';
  static const String _keyClientId = 'mqtt_client_id';
  static const String _keyKeepAlive = 'mqtt_keep_alive';
  static const String _keyUseAuth = 'mqtt_use_auth';

  /// Kayıtlı broker ayarlarını getirir.
  /// Eğer kayıtlı bir ayar yoksa, projede istenen varsayılan değerleri döndürür.
  BrokerConfig loadBrokerConfig() {
    return BrokerConfig(
      host: _prefs.getString(_keyHost) ?? '192.168.1.100',
      port: _prefs.getInt(_keyPort) ?? 1883,
      clientId: _prefs.getString(_keyClientId) ?? 'flutter_home_client',
      keepAliveSeconds: _prefs.getInt(_keyKeepAlive) ?? 60,
      useAuth: _prefs.getBool(_keyUseAuth) ?? false,
    );
  }

  /// Yeni broker ayarlarını cihaza kaydeder.
  Future<void> saveBrokerConfig(BrokerConfig config) async {
    await Future.wait([
      _prefs.setString(_keyHost, config.host),
      _prefs.setInt(_keyPort, config.port),
      _prefs.setString(_keyClientId, config.clientId),
      _prefs.setInt(_keyKeepAlive, config.keepAliveSeconds),
      _prefs.setBool(_keyUseAuth, config.useAuth),
    ]);
  }

  /// Kayıtlı tüm broker ayarlarını temizler.
  Future<void> clearBrokerConfig() async {
    await Future.wait([
      _prefs.remove(_keyHost),
      _prefs.remove(_keyPort),
      _prefs.remove(_keyClientId),
      _prefs.remove(_keyKeepAlive),
      _prefs.remove(_keyUseAuth),
    ]);
  }
}
