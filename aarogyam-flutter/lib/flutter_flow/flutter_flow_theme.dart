// flutter_flow_theme.dart — compatibility shim.
//
// Maps legacy FF theme property names to their Material 3 equivalents.
// New code should use Theme.of(context) directly.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';
SharedPreferences? _prefs;

class FlutterFlowTheme {
  FlutterFlowTheme._(this._context);
  final BuildContext _context;

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

  static FlutterFlowTheme of(BuildContext context) =>
      FlutterFlowTheme._(context);

  ColorScheme get _cs => Theme.of(_context).colorScheme;
  TextTheme get _tt => Theme.of(_context).textTheme;

  // Colours
  Color get primary => _cs.primary;
  Color get secondary => _cs.secondary;
  Color get tertiary => _cs.tertiary;
  Color get primaryColor => _cs.primary;
  Color get secondaryColor => _cs.secondary;
  Color get tertiaryColor => _cs.tertiary;
  Color get alternate => _cs.primaryContainer;
  Color get primaryText => _cs.onSurface;
  Color get secondaryText => _cs.onSurfaceVariant;
  Color get primaryBackground => _cs.surface;
  Color get secondaryBackground => _cs.surfaceContainerHighest;
  Color get accent1 => _cs.primary.withValues(alpha: 0.15);
  Color get accent2 => _cs.secondary.withValues(alpha: 0.15);
  Color get accent3 => _cs.tertiary.withValues(alpha: 0.15);
  Color get accent4 => _cs.outline.withValues(alpha: 0.15);
  Color get success => const Color(0xFF4CAF50);
  Color get warning => const Color(0xFFFFC107);
  Color get error => _cs.error;
  Color get info => const Color(0xFF2196F3);

  // Text styles — Material 3 names
  TextStyle get displayLarge => _tt.displayLarge ?? const TextStyle();
  TextStyle get displayMedium => _tt.displayMedium ?? const TextStyle();
  TextStyle get displaySmall => _tt.displaySmall ?? const TextStyle();
  TextStyle get headlineLarge => _tt.headlineLarge ?? const TextStyle();
  TextStyle get headlineMedium => _tt.headlineMedium ?? const TextStyle();
  TextStyle get headlineSmall => _tt.headlineSmall ?? const TextStyle();
  TextStyle get titleLarge => _tt.titleLarge ?? const TextStyle();
  TextStyle get titleMedium => _tt.titleMedium ?? const TextStyle();
  TextStyle get titleSmall => _tt.titleSmall ?? const TextStyle();
  TextStyle get labelLarge => _tt.labelLarge ?? const TextStyle();
  TextStyle get labelMedium => _tt.labelMedium ?? const TextStyle();
  TextStyle get labelSmall => _tt.labelSmall ?? const TextStyle();
  TextStyle get bodyLarge => _tt.bodyLarge ?? const TextStyle();
  TextStyle get bodyMedium => _tt.bodyMedium ?? const TextStyle();
  TextStyle get bodySmall => _tt.bodySmall ?? const TextStyle();

  // Legacy names (deprecated aliases kept for shim compatibility)
  TextStyle get title1 => _tt.headlineLarge ?? const TextStyle();
  TextStyle get title2 => _tt.headlineMedium ?? const TextStyle();
  TextStyle get title3 => _tt.headlineSmall ?? const TextStyle();
  TextStyle get subtitle1 => _tt.titleLarge ?? const TextStyle();
  TextStyle get subtitle2 => _tt.titleMedium ?? const TextStyle();
  TextStyle get bodyText1 => _tt.bodyLarge ?? const TextStyle();
  TextStyle get bodyText2 => _tt.bodyMedium ?? const TextStyle();
  TextStyle get caption => _tt.bodySmall ?? const TextStyle();
  TextStyle get overline => _tt.labelSmall ?? const TextStyle();
}
