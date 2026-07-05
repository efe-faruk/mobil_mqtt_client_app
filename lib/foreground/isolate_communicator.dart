import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tüm provider'ları tek merkezden (app_providers) çekiyoruz
import '../core/providers/app_providers.dart';

class IsolateCommunicator {
  final Ref ref;

  IsolateCommunicator(this.ref) {
    FlutterForegroundTask.addTaskDataCallback(_onDataReceived);
  }

  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onDataReceived);
  }

  void _onDataReceived(Object data) {
    print("💡 ISOLATE'TEN VERI GELDI: $data");

    if (data is Map) {
      try {
        final mapData = Map<String, dynamic>.from(data);
        final eventString = mapData['event'].toString();

        if (eventString.contains('connectionStatusChanged')) {
          final status = mapData['payload']?['status'] ?? 'disconnected';
          print("✅ DURUM GÜNCELLENIYOR: $status");

          // Artık app_providers.dart içindeki TEK VE ORTAK provider güncelleniyor!
          ref.read(mqttConnectionStatusProvider.notifier).setStatus(status);
        } else if (eventString.contains('mqttMessageReceived')) {
          final topic = mapData['payload']?['topic'] as String?;
          final payload = mapData['payload']?['payload'] as String?;

          if (topic != null && payload != null) {
            _processIncomingMqttMessage(topic, payload);
          }
        }
      } catch (e) {
        print("❌ ISOLATE VERISI OKUNURKEN HATA: $e");
      }
    }
  }

  Future<void> _processIncomingMqttMessage(
      String topic, String rawPayload) async {
    // 1. Gelen veriyi her türlü boşluk, sekme ve küçük harf hatasından temizliyoruz
    final cleanTopic = topic.trim();
    final cleanPayload = rawPayload.trim().toUpperCase();

    print(
        "📩 MQTT MESAJI GELDİ: Temiz Topic: '$cleanTopic', Temiz Payload: '$cleanPayload'");

    final deviceRepo = ref.read(deviceRepositoryProvider);

    try {
      final devices = await deviceRepo.getAllDevices();

      // 2. Veritabanındaki topic ile gelen topic'i güvenli bir şekilde eşleştiriyoruz
      final device =
          devices.firstWhere((d) => d.topicState.trim() == cleanTopic);

      // 3. Switch veya Sensör ayrımını yapıp veritabanını güncelliyoruz
      if (cleanPayload == 'ON' || cleanPayload == 'OFF') {
        await deviceRepo.updateSwitchState(device.id, cleanPayload == 'ON');
        print(
            "✅ BAŞARILI: ${device.name} durumu $cleanPayload olarak güncellendi.");
      } else {
        await deviceRepo.updateDeviceLastValue(device.id, cleanPayload);
        print(
            "✅ BAŞARILI: ${device.name} sensör verisi $cleanPayload olarak güncellendi.");
      }
    } catch (e) {
      // Eşleşme başarısız olursa tam olarak nedenini ekrana basıyoruz
      print(
          "⚠️ EŞLEŞME HATASI: Gelen topic '$cleanTopic' veritabanında bulunamadı! Detay: $e");
    }
  }
}
