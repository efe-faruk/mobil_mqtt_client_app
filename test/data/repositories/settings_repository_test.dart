import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:final_home_v1/data/repositories/settings_repository.dart';
import 'package:final_home_v1/data/storage/secure_settings_storage.dart';
import 'package:final_home_v1/models/broker_config.dart';

final class InMemorySecureSettingsStorage implements SecureSettingsStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({
    required String key,
    required String value,
  }) async {
    values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'kullanıcı adını normal, parolayı güvenli depoda kalıcılaştırır',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final secureStorage = InMemorySecureSettingsStorage();
      final repository = SettingsRepository(
        preferences,
        secureStorage,
      );
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

      expect(await repository.loadBrokerConfig(), config);

      final encodedConfig = preferences.getString('mqtt_broker_config');
      final storedConfig = jsonDecode(encodedConfig!) as Map<String, dynamic>;
      expect(storedConfig['username'], 'test-user');
      expect(storedConfig, isNot(contains('password')));
      expect(encodedConfig, isNot(contains('test-password')));
      expect(
        secureStorage.values['mqtt_broker_password'],
        'test-password',
      );
      expect(preferences.getString('mqtt_host'), isNull);
    },
  );

  test('eski SharedPreferences anahtarlarını okumaya devam eder', () async {
    SharedPreferences.setMockInitialValues({
      'mqtt_host': 'legacy-broker.local',
      'mqtt_port': 1884,
      'mqtt_client_id': 'legacy-client',
      'mqtt_keep_alive': 90,
      'mqtt_use_auth': false,
      'mqtt_username': 'legacy-user',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = SettingsRepository(
      preferences,
      InMemorySecureSettingsStorage(),
    );

    final config = await repository.loadBrokerConfig();

    expect(config.host, 'legacy-broker.local');
    expect(config.port, 1884);
    expect(config.clientId, 'legacy-client');
    expect(config.keepAliveSeconds, 90);
    expect(config.useAuth, isFalse);
    expect(config.username, 'legacy-user');
    expect(config.password, isEmpty);
  });

  test('eski düz metin parolayı güvenli depoya bir kez taşır', () async {
    SharedPreferences.setMockInitialValues({
      'mqtt_broker_config': jsonEncode({
        'host': 'legacy-broker.local',
        'port': 1883,
        'clientId': 'legacy-client',
        'keepAliveSeconds': 60,
        'useAuth': true,
        'username': 'legacy-user',
        'password': 'legacy-password',
      }),
    });
    final preferences = await SharedPreferences.getInstance();
    final secureStorage = InMemorySecureSettingsStorage();
    final repository = SettingsRepository(
      preferences,
      secureStorage,
    );

    final config = await repository.loadBrokerConfig();

    expect(config.username, 'legacy-user');
    expect(config.password, 'legacy-password');
    expect(
      secureStorage.values['mqtt_broker_password'],
      'legacy-password',
    );

    final migratedConfig = jsonDecode(
      preferences.getString('mqtt_broker_config')!,
    ) as Map<String, dynamic>;
    expect(migratedConfig, isNot(contains('password')));
  });

  test('kimlik doğrulama kapatılınca güvenli parolayı siler', () async {
    final preferences = await SharedPreferences.getInstance();
    final secureStorage = InMemorySecureSettingsStorage()
      ..values['mqtt_broker_password'] = 'old-password';
    final repository = SettingsRepository(
      preferences,
      secureStorage,
    );

    await repository.saveBrokerConfig(
      BrokerConfig(
        host: 'mqtt.example.com',
        port: 1883,
        clientId: 'settings-test',
        keepAliveSeconds: 60,
        useAuth: false,
        username: '',
        password: '',
      ),
    );

    expect(
      secureStorage.values,
      isNot(contains('mqtt_broker_password')),
    );
    expect((await repository.loadBrokerConfig()).password, isEmpty);
  });
}
