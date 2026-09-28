import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

const kThemeModeKey = '__theme_mode__';
SharedPreferences? _prefs;

abstract class AppTheme {
  static Future<void> initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          hintStyle: GoogleFonts.manrope(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            textStyle: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textTheme: _buildTextTheme(Brightness.light),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF101716),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: _buildTextTheme(Brightness.dark),
      );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor =
        brightness == Brightness.light ? AppColors.textPrimary : const Color(0xFFF1F5F9);

    return TextTheme(
      displayLarge: GoogleFonts.manrope(
          fontSize: 48, fontWeight: FontWeight.w700, color: baseColor, height: 1.2),
      displayMedium: GoogleFonts.manrope(
          fontSize: 36, fontWeight: FontWeight.w700, color: baseColor, height: 1.25),
      displaySmall: GoogleFonts.manrope(
          fontSize: 30, fontWeight: FontWeight.w700, color: baseColor, height: 1.3),
      headlineLarge: GoogleFonts.manrope(
          fontSize: 26, fontWeight: FontWeight.w700, color: baseColor, height: 1.3),
      headlineMedium: GoogleFonts.manrope(
          fontSize: 22, fontWeight: FontWeight.w700, color: baseColor, height: 1.35),
      headlineSmall: GoogleFonts.manrope(
          fontSize: 18, fontWeight: FontWeight.w700, color: baseColor, height: 1.4),
      titleLarge: GoogleFonts.manrope(
          fontSize: 18, fontWeight: FontWeight.w600, color: baseColor, height: 1.4),
      titleMedium: GoogleFonts.manrope(
          fontSize: 16, fontWeight: FontWeight.w600, color: baseColor, height: 1.4),
      titleSmall: GoogleFonts.manrope(
          fontSize: 14, fontWeight: FontWeight.w600, color: baseColor, height: 1.4),
      bodyLarge: GoogleFonts.manrope(
          fontSize: 16, fontWeight: FontWeight.w400, color: baseColor, height: 1.5),
      bodyMedium: GoogleFonts.manrope(
          fontSize: 14, fontWeight: FontWeight.w400, color: baseColor, height: 1.5),
      bodySmall: GoogleFonts.manrope(
          fontSize: 12, fontWeight: FontWeight.w400, color: baseColor, height: 1.5),
      labelLarge: GoogleFonts.manrope(
          fontSize: 14, fontWeight: FontWeight.w700, color: baseColor, height: 1.4),
      labelMedium: GoogleFonts.manrope(
          fontSize: 12, fontWeight: FontWeight.w700, color: baseColor, height: 1.4),
      labelSmall: GoogleFonts.manrope(
          fontSize: 11, fontWeight: FontWeight.w700, color: baseColor, height: 1.4),
    );
  }
}

