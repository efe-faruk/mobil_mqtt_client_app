import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../data/db/app_database.dart';
import '../data/repositories/device_repository.dart';
import '../foreground/foreground_message_models.dart';

class MqttDeviceController {
  final Ref _ref;
  final DeviceRepository _deviceRepository;

  MqttDeviceController({
    required Ref ref,
    required DeviceRepository deviceRepository,
  })  : _ref = ref,
        _deviceRepository = deviceRepository;

  /// Veritabanından tüm cihazları çeker ve topicState adreslerine
  /// abone olması için arka plan servisine komut (Command) gönderir.
  Future<void> initialize() async {
    final devices = await _deviceRepository.getAllDevices();
    final List<String> topics = [];

    for (var device in devices) {
      if (device.topicState.isNotEmpty) {
        topics.add(device.topicState);
      }
    }

    if (topics.isNotEmpty) {
      final message = UiToServiceMessage(
        command: UiToServiceCommand.subscribeAllDevices,
        payload: {'topics': topics},
      );

      // Arka plandaki TaskHandler'a abone olmasını emrediyoruz
      FlutterForegroundTask.sendDataToTask(message.toMap());
    }
  }

  /// UI üzerinden bir cihaza (switch) açma/kapama komutu fırlatır.
  void toggleSwitch(Device device, bool turnOn) {
    // Eğer cihazın bir SET topic'i yoksa (sadece sensörse) işlem yapma
    if (device.topicSet == null || device.topicSet!.isEmpty) return;

    final payload = turnOn ? 'ON' : 'OFF';

    final message = UiToServiceMessage(
      command: UiToServiceCommand.publish,
      payload: {
        'topic': device.topicSet,
        'payload': payload,
        'retain': false,
      },
    );

    // Mesajı UI iş parçacığını hiç yormadan arka plana fırlatıyoruz
    FlutterForegroundTask.sendDataToTask(message.toMap());

    // NOT: Veritabanını burada bilerek güncellemiyoruz!
    // Mesaj broker'a gidecek, donanım (Örn: ESP32) röleyi çekecek ve "state" topic'inden
    // cevap döndüğünde IsolateCommunicator veritabanını güncelleyecek.
    // Böylece uygulaman her zaman donanımın "gerçek" durumunu yansıtacak (Single Source of Truth).
  }

  /// Cihazlar güncellendiğinde (ekleme/silme vb.) abonelikleri yenilemek için çağrılabilir.
  Future<void> refreshDevices() async {
    await initialize();
  }

  void dispose() {
    // Artık bellek sızıntısı yapacak bir aboneliğimiz kalmadı
  }
}
