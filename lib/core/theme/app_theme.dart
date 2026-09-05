import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.primary,
      ),
      scaffoldBackgroundColor: AppPalette.background,
      cardTheme: const CardThemeData(
        color: AppPalette.surface,
      ),
    );
  }
}