import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ThemeData terpusat untuk seluruh aplikasi.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: const Color(0xFFDDF5D0),
      onPrimaryContainer: AppColors.onPrimary,
      secondary: AppColors.teal,
      onSecondary: Colors.white,
      tertiary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.textDark,
    );

    final radius = BorderRadius.circular(14);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: AppColors.teal),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
        titleSmall: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyMedium: TextStyle(color: AppColors.textDark, height: 1.4),
        bodySmall: TextStyle(color: AppColors.textMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.teal,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.teal,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: const Color(0xFFDADFDC),
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.teal,
          side: const BorderSide(color: AppColors.teal, width: 1.2),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.teal),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Color(0xFFD7E2DC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Color(0xFFD7E2DC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.teal, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        floatingLabelStyle: const TextStyle(color: AppColors.teal),
        prefixIconColor: AppColors.teal,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE3ECE6)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
        secondaryLabelStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.onPrimary),
        side: const BorderSide(color: Color(0xFFD7E2DC)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        checkmarkColor: AppColors.onPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0xFFDDF5D0),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? AppColors.teal : AppColors.textMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? AppColors.teal : AppColors.textMuted,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      dividerTheme: const DividerThemeData(color: Color(0xFFE3ECE6), thickness: 1),
    );
  }
}
