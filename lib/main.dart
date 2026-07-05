import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'app.dart';
import 'core/providers/app_providers.dart';
import 'foreground/foreground_task_handler.dart';

void _initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'mqtt_smart_home',
      channelName: 'Akıllı Ev Bağlantısı',
      channelDescription: 'Arka planda MQTT iletişimi sağlar.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

// Bu fonksiyonu başındaki "_" (private) işaretini kaldırarak global yaptık.
// Artık app.dart içinden çağırabileceğiz.
Future<void> requestPermissionsAndStartService() async {
  final NotificationPermission notificationPermissionStatus =
      await FlutterForegroundTask.checkNotificationPermission();
  if (notificationPermissionStatus != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }

  if (!await FlutterForegroundTask.isRunningService) {
    await FlutterForegroundTask.startService(
      notificationTitle: 'Akıllı Ev Bağlantısı',
      notificationText: 'MQTT Servisi Başlatılıyor...',
      callback: startCallback,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterForegroundTask.initCommunicationPort();
  _initForegroundTask();

  // DİKKAT: startService() komutunu buradan kaldırdık! UI artık bloklanmayacak.

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SmartHomeApp(),
    ),
  );
}
