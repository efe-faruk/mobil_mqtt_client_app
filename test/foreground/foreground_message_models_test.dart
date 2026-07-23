import 'package:flutter_test/flutter_test.dart';

import 'package:final_home_v1/foreground/foreground_message_models.dart';

void main() {
  test('foreground servis bilgi isteği protokol sürümünü taşır', () {
    final outgoing = ServiceToUiMessage(
      event: ServiceToUiEvent.serviceInfo,
      payload: {
        'requestId': 'service-request',
        'protocolVersion': foregroundServiceProtocolVersion,
      },
    );

    final incoming = ServiceToUiMessage.fromMap(outgoing.toMap());

    expect(incoming.event, ServiceToUiEvent.serviceInfo);
    expect(
      incoming.payload?['protocolVersion'],
      foregroundServiceProtocolVersion,
    );
  });

  test('broker güncelleme sonucu istek kimliğiyle ayrıştırılır', () {
    final outgoing = ServiceToUiMessage(
      event: ServiceToUiEvent.brokerConfigUpdateResult,
      payload: {
        'requestId': 'request-123',
        'success': true,
      },
    );

    final incoming = ServiceToUiMessage.fromMap(outgoing.toMap());

    expect(incoming.event, ServiceToUiEvent.brokerConfigUpdateResult);
    expect(incoming.payload?['requestId'], 'request-123');
    expect(incoming.payload?['success'], isTrue);
  });

  test('updateBrokerConfig komutu payload alanlarını korur', () {
    final outgoing = UiToServiceMessage(
      command: UiToServiceCommand.updateBrokerConfig,
      payload: {
        'requestId': 'request-456',
        'host': 'broker.local',
        'port': 1883,
      },
    );

    final incoming = UiToServiceMessage.fromMap(outgoing.toMap());

    expect(incoming.command, UiToServiceCommand.updateBrokerConfig);
    expect(incoming.payload?['requestId'], 'request-456');
    expect(incoming.payload?['host'], 'broker.local');
  });
}
