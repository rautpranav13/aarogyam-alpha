import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
          brightness: Brightness.light,
        ),
        textTheme: _buildTextTheme(Brightness.light),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
          brightness: Brightness.dark,
        ),
        textTheme: _buildTextTheme(Brightness.dark),
      );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor =
        brightness == Brightness.light ? const Color(0xFF1F2328) : const Color(0xFFE6EDF3);

    return TextTheme(
      displayLarge: GoogleFonts.poppins(
          fontSize: 57, fontWeight: FontWeight.w400, color: baseColor),
      displayMedium: GoogleFonts.poppins(
          fontSize: 45, fontWeight: FontWeight.w400, color: baseColor),
      displaySmall: GoogleFonts.poppins(
          fontSize: 36, fontWeight: FontWeight.w400, color: baseColor),
      headlineLarge: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.w600, color: baseColor),
      headlineMedium: GoogleFonts.poppins(
          fontSize: 28, fontWeight: FontWeight.w600, color: baseColor),
      headlineSmall: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w600, color: baseColor),
      titleLarge: GoogleFonts.manrope(
          fontSize: 22, fontWeight: FontWeight.w500, color: baseColor),
      titleMedium: GoogleFonts.manrope(
          fontSize: 16, fontWeight: FontWeight.w500, color: baseColor),
      titleSmall: GoogleFonts.manrope(
          fontSize: 14, fontWeight: FontWeight.w500, color: baseColor),
      bodyLarge: GoogleFonts.manrope(
          fontSize: 16, fontWeight: FontWeight.w400, color: baseColor),
      bodyMedium: GoogleFonts.manrope(
          fontSize: 14, fontWeight: FontWeight.w400, color: baseColor),
      bodySmall: GoogleFonts.manrope(
          fontSize: 12, fontWeight: FontWeight.w400, color: baseColor),
      labelLarge: GoogleFonts.manrope(
          fontSize: 14, fontWeight: FontWeight.w600, color: baseColor),
      labelMedium: GoogleFonts.manrope(
          fontSize: 12, fontWeight: FontWeight.w600, color: baseColor),
      labelSmall: GoogleFonts.manrope(
          fontSize: 11, fontWeight: FontWeight.w600, color: baseColor),
    );
  }
}
