import 'package:flutter/material.dart';

class AppTheme {
  // Akıllı ev uygulamaları için modern, teknolojik bir ana renk (Örn: Elektrik Mavisi / Camgöbeği)
  static const Color _seedColor = Color(0xFF00ADB5);

  // Açık Tema Ayarları
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  // Koyu Tema Ayarları
  static ThemeData get darkTheme {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      // Koyu tema için daha derin ve modern bir arka plan rengi (Slate / Koyu Lacivert)
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      colorScheme: baseColorScheme.copyWith(
        surface: const Color(0xFF0F172A), // Kartlar ve yüzeyler için ana renk
        surfaceContainer: const Color(0xFF1E293B), // Hafif daha açık yüzeyler
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF0F172A),
        scrolledUnderElevation:
            0, // M3'te scroll yaparken renk değişimini engeller
      ),
    );
  }
}
