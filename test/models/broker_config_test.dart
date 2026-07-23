import 'package:flutter_test/flutter_test.dart';

import 'package:final_home_v1/models/broker_config.dart';

void main() {
  test('BrokerConfig map dönüşümünde tüm alanları korur', () {
    final config = BrokerConfig(
      host: 'broker.example.com',
      port: 8883,
      clientId: 'mobile-client',
      keepAliveSeconds: 45,
      useAuth: true,
      username: 'mqtt-user',
      password: 'mqtt-password',
    );

    final decoded = BrokerConfig.fromMap(config.toMap());

    expect(decoded, config);
  });
}
