import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:final_home_v1/data/repositories/settings_repository.dart';
import 'package:final_home_v1/models/broker_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('broker yapılandırmasını tek kayıt olarak kalıcılaştırır', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = SettingsRepository(preferences);
    final config = BrokerConfig(
      host: 'mqtt.example.com',
      port: 8883,
      clientId: 'settings-test',
      keepAliveSeconds: 30,
      useAuth: true,
      username: 'test-user',
      password: 'test-password',
    );

    await repository.saveBrokerConfig(config);

    expect(repository.loadBrokerConfig(), config);
    expect(preferences.getString('mqtt_broker_config'), isNotNull);
    expect(preferences.getString('mqtt_host'), isNull);
  });

  test('eski SharedPreferences anahtarlarını okumaya devam eder', () async {
    SharedPreferences.setMockInitialValues({
      'mqtt_host': 'legacy-broker.local',
      'mqtt_port': 1884,
      'mqtt_client_id': 'legacy-client',
      'mqtt_keep_alive': 90,
      'mqtt_use_auth': false,
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = SettingsRepository(preferences);

    final config = repository.loadBrokerConfig();

    expect(config.host, 'legacy-broker.local');
    expect(config.port, 1884);
    expect(config.clientId, 'legacy-client');
    expect(config.keepAliveSeconds, 90);
    expect(config.useAuth, isFalse);
  });
}
