import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'foreground_message_models.dart';

/*
  ÖNEMLİ ANDROID İZİNLERİ (android/app/src/main/AndroidManifest.xml)
  Bu servisin sorunsuz çalışması için `<manifest>` etiketinin içine şu izinleri eklemelisin:

  <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
  <uses-permission android:name="android.permission.WAKE_LOCK" />
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
  <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

  Ayrıca `<application>` etiketi içine servisi tanımlamalısın:
  <service
      android:name="com.pravera.flutter_foreground_task.models.ForegroundService"
      android:foregroundServiceType="dataSync"
      android:exported="false" />
*/

class ForegroundServiceManager {
  // Singleton pattern kullanımı
  static final ForegroundServiceManager _instance =
      ForegroundServiceManager._internal();
  factory ForegroundServiceManager() => _instance;
  ForegroundServiceManager._internal();

  /// Foreground task ve bildirim ayarlarını başlatır.
  void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'mqtt_smart_home_channel',
        channelName: 'Smart Home Service',
        channelDescription: 'Arka planda MQTT bağlantısını canlı tutar.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        // iconData kaldırıldı, uygulama varsayılan ikonunu kullanacak.
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        // interval ve isOnceEvent yerine yeni API'ye uygun eventAction eklendi
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  /// Uygulamanın arka planda çalışabilmesi için gerekli izinleri talep eder.
  Future<void> requestPermissions() async {
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  /// Foreground servisi başlatır.
  /// Dönüş tipi yeni paket yapısına uygun olarak ServiceRequestResult yapıldı.
  Future<ServiceRequestResult> startService(Function callback) async {
    if (await isServiceRunning()) {
      return FlutterForegroundTask.restartService();
    }

    return await FlutterForegroundTask.startService(
      notificationTitle: 'Akıllı Ev: Başlatılıyor...',
      notificationText: 'MQTT servisi hazırlanıyor.',
      callback: callback,
    );
  }

  /// Foreground servisi durdurur.
  /// Dönüş tipi yeni paket yapısına uygun olarak ServiceRequestResult yapıldı.
  Future<ServiceRequestResult> stopService() async {
    return await FlutterForegroundTask.stopService();
  }

  /// Servisin o an çalışıp çalışmadığını kontrol eder.
  Future<bool> isServiceRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }

  /// UI'dan Foreground Servise (Arka plan izolatına) mesaj gönderir.
  void sendMessageToService(UiToServiceMessage message) {
    FlutterForegroundTask.sendDataToTask(message.toMap());
  }
}
