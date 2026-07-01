import 'dart:async';

import '../data/db/app_database.dart';
import '../data/repositories/device_repository.dart';
import 'mqtt_service.dart';

class MqttDeviceController {
  final MqttService _mqttService;
  final DeviceRepository _deviceRepository;

  StreamSubscription<MqttMessage>? _messageSubscription;

  // Hızlı eşleştirme için topicState -> Device haritası tutuyoruz.
  final Map<String, Device> _deviceMap = {};

  MqttDeviceController({
    required MqttService mqttService,
    required DeviceRepository deviceRepository,
  })  : _mqttService = mqttService,
        _deviceRepository = deviceRepository;

  /// Veritabanından tüm cihazları çeker, topicState adreslerine abone olur
  /// ve gelen mesajları dinlemeye başlar.
  Future<void> initialize() async {
    // 1. Veritabanındaki kayıtlı tüm cihazları al
    final devices = await _deviceRepository.getAllDevices();

    // 2. Map'i temizle ve cihazları topicState değerlerine göre doldur
    _deviceMap.clear();
    for (var device in devices) {
      final topic = device.topicState;
      if (topic.isNotEmpty) {
        _deviceMap[topic] = device;
        // 3. Her bir topicState için MQTT servisine subscribe ol
        _mqttService.subscribe(topic);
      }
    }

    // 4. Eğer önceden başlatılmış bir dinleyici varsa iptal et ve yenisini başlat
    _messageSubscription?.cancel();
    _messageSubscription = _mqttService.messages.listen(_onMessageReceived);
  }

  /// Gelen MqttMessage nesnesini işler ve ilgili cihazın veritabanı kaydını günceller.
  Future<void> _onMessageReceived(MqttMessage message) async {
    // Topic üzerinden ilgili cihazı bul
    final device = _deviceMap[message.topic];

    // Eğer bu topic'e ait kayıtlı bir cihazımız yoksa işlemi sonlandır
    if (device == null) return;

    final payload = message.payload.trim();

    // Cihaz tipine göre veritabanı güncelleme işlemlerini yap
    if (device.type == 'switch') {
      bool? isTurnedOn;

      if (payload.toUpperCase() == 'ON') {
        isTurnedOn = true;
      } else if (payload.toUpperCase() == 'OFF') {
        isTurnedOn = false;
      }

      if (isTurnedOn != null) {
        await _deviceRepository.updateSwitchState(device.id, isTurnedOn);
      }
    } else if (device.type == 'sensor') {
      await _deviceRepository.updateDeviceLastValue(device.id, payload);
    }
  }

  /// Cihazlar güncellendiğinde (ekleme/silme vb.) abonelikleri yenilemek için çağrılabilir.
  Future<void> refreshDevices() async {
    // Tüm cihazları yeniden yükle ve abonelikleri güncelle
    await initialize();
  }

  /// Controller bellekten atılırken dinlemeyi durdurur.
  void dispose() {
    _messageSubscription?.cancel();
  }
}
