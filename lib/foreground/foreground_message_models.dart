const int foregroundServiceProtocolVersion = 1;

/// UI'dan Foreground Service'e gönderilecek komutların tipleri
enum UiToServiceCommand {
  getServiceInfo,
  startMqtt,
  stopMqtt,
  publish,
  subscribeAllDevices,
  updateBrokerConfig,
  updateDeviceList,
}

/// Foreground Service'ten UI'a gönderilecek olayların tipleri
enum ServiceToUiEvent {
  serviceInfo,
  connectionStatusChanged,
  brokerConfigUpdateResult,
  mqttMessageReceived,
  error,
  log,
}

/// UI -> Service İletişim Modeli
class UiToServiceMessage {
  final UiToServiceCommand command;
  final Map<String, dynamic>? payload;

  UiToServiceMessage({
    required this.command,
    this.payload,
  });

  Map<String, dynamic> toMap() {
    return {
      'command': command.name,
      'payload': payload,
    };
  }

  factory UiToServiceMessage.fromMap(Map<String, dynamic> map) {
    // Enum parsing (Güvenli)
    final commandStr = map['command'] as String?;
    if (commandStr == null) {
      throw const FormatException(
          "UiToServiceMessage: 'command' anahtarı bulunamadı.");
    }

    final command = UiToServiceCommand.values.firstWhere(
      (e) => e.name == commandStr,
      orElse: () => throw FormatException("Geçersiz command tipi: $commandStr"),
    );

    // Payload parsing (Güvenli)
    Map<String, dynamic>? parsedPayload;
    final rawPayload = map['payload'];
    if (rawPayload != null && rawPayload is Map) {
      parsedPayload = Map<String, dynamic>.from(rawPayload);
    }

    return UiToServiceMessage(
      command: command,
      payload: parsedPayload,
    );
  }
}

/// Service -> UI İletişim Modeli
class ServiceToUiMessage {
  final ServiceToUiEvent event;
  final Map<String, dynamic>? payload;

  ServiceToUiMessage({
    required this.event,
    this.payload,
  });

  Map<String, dynamic> toMap() {
    return {
      'event': event.name,
      'payload': payload,
    };
  }

  factory ServiceToUiMessage.fromMap(Map<String, dynamic> map) {
    // Enum parsing (Güvenli)
    final eventStr = map['event'] as String?;
    if (eventStr == null) {
      throw const FormatException(
          "ServiceToUiMessage: 'event' anahtarı bulunamadı.");
    }

    final event = ServiceToUiEvent.values.firstWhere(
      (e) => e.name == eventStr,
      orElse: () => throw FormatException("Geçersiz event tipi: $eventStr"),
    );

    // Payload parsing (Güvenli)
    Map<String, dynamic>? parsedPayload;
    final rawPayload = map['payload'];
    if (rawPayload != null && rawPayload is Map) {
      parsedPayload = Map<String, dynamic>.from(rawPayload);
    }

    return ServiceToUiMessage(
      event: event,
      payload: parsedPayload,
    );
  }
}
