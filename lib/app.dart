import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router kullanarak GoRouter konfigürasyonunu bağlıyoruz
    return MaterialApp.router(
      title: 'Flutter MQTT Smart Home',
      debugShowCheckedModeBanner: false,

      // Temalar
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Koyu tema öncelikli

      // go_router parametreleri
      routerConfig: AppRouter.router,
    );
  }
}
