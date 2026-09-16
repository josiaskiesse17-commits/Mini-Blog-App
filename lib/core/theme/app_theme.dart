import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppPalette.primary,
      onPrimary: Colors.white,
      secondary: AppPalette.primaryLight,
      surface: AppPalette.surface,
      error: AppPalette.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.background,

      appBarTheme: AppBarTheme(
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: AppPalette.textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppPalette.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppPalette.border,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppPalette.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppPalette.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppPalette.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppPalette.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppPalette.error,
            width: 2,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(
            color: AppPalette.border,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppPalette.border,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppPalette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppPalette.textPrimary,
        ),
        bodyMedium: TextStyle(
          color: AppPalette.textSecondary,
        ),
        bodySmall: TextStyle(
          color: AppPalette.textSecondary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.primaryLight,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppPalette.primaryLight,
      onPrimary: AppPalette.darkBackground,
      secondary: AppPalette.primary,
      surface: AppPalette.darkSurface,
      error: Colors.red.shade300,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.darkBackground,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.darkBackground,
        foregroundColor: AppPalette.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: AppPalette.darkTextPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppPalette.darkSurface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppPalette.darkBorder,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppPalette.darkBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppPalette.darkBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppPalette.primaryLight,
            width: 2,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(
            color: AppPalette.darkBorder,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppPalette.primaryLight,
        foregroundColor: AppPalette.darkBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppPalette.darkBorder,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppPalette.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppPalette.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: AppPalette.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: AppPalette.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppPalette.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppPalette.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AppPalette.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppPalette.darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          color: AppPalette.darkTextSecondary,
        ),
        bodySmall: TextStyle(
          color: AppPalette.darkTextSecondary,
        ),
      ),
    );
  }
}