import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/app_providers.dart';

void main() async {
  // 1. Flutter'ın native motoru ile bağlantısını kuruyoruz.
  // Asenkron (await) işlemlere başlamadan önce bu zorunludur.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. SharedPreferences örneğini cihazdan asenkron olarak okuyoruz.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    // 3. Tüm uygulamayı Riverpod'un ProviderScope'u ile sarıyoruz.
    ProviderScope(
      overrides: [
        // 4. app_providers.dart içindeki boş provider'ı, burada yüklediğimiz gerçek nesne ile eziyoruz.
        // Çökmeyi engelleyen asıl satır burasıdır.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SmartHomeApp(),
    ),
  );
}
