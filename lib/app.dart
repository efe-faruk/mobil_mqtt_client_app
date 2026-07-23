import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod eklendi
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_providers.dart'; // Provider'lar için eklendi
import 'foreground/foreground_message_models.dart'; // Mesaj modelleri için eklendi
import 'main.dart';

// Riverpod özelliklerini kullanabilmek için ConsumerStatefulWidget'a çevirdik
class SmartHomeApp extends ConsumerStatefulWidget {
  const SmartHomeApp({super.key});

  @override
  ConsumerState<SmartHomeApp> createState() => _SmartHomeAppState();
}

class _SmartHomeAppState extends ConsumerState<SmartHomeApp> {
  @override
  void initState() {
    super.initState();

    // Arayüz çizildikten hemen sonra çalışacak blok
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. İzinleri al ve arka plan servisini (Isolate) başlat
      await requestPermissionsAndStartService();

      // 2. Isolate'in tam olarak ayağa kalkması ve portların açılması için ufak bir pay
      await Future.delayed(const Duration(milliseconds: 500));

      final communicator = ref.read(isolateCommunicatorProvider);
      try {
        // Servis eski bir TaskHandler ile çalışıyorsa güncel handler'ı yükler.
        await communicator.ensureCompatibleService();
      } catch (e) {
        debugPrint('Foreground servis hazırlanamadı: $e');
        return;
      }

      // 3. SharedPreferences'tan kayıtlı broker ayarlarını Riverpod üzerinden oku
      final config = ref.read(brokerConfigProvider);

      // 4. Arka plandaki servise "Bağlan" komutunu ve broker bilgilerini paketle
      final message = UiToServiceMessage(
        command: UiToServiceCommand.startMqtt,
        payload: config.toMap(),
      );

      // 5. Komutu Isolate'e fırlat! (Bu komut gidince MqttService.connect çalışacak)
      FlutterForegroundTask.sendDataToTask(message.toMap());
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(isolateCommunicatorProvider);
    // KRİTİK: Orkestratörün uyanması için onu burada izliyoruz.
    // Bu sayede MQTT bağlandığı an, orkestratör veritabanındaki cihazları bulup 'subscribe' komutu atacak.
    ref.watch(mqttOrchestratorProvider);

    return WithForegroundTask(
      child: MaterialApp.router(
        title: 'Flutter MQTT Smart Home',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
