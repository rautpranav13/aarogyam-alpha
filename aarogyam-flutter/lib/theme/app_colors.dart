import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Branding (Deep Medical Teal / Sage Green)
  static const Color primary = Color(0xFF00796B);       // Deep Teal
  static const Color primaryDark = Color(0xFF004D40);   // Dark Teal
  static const Color primaryLight = Color(0xFFE0F2F1);  // Mint Light Tint
  static const Color primaryAccent = Color(0xFF26A69A); // Vibrant Teal

  // Secondary & Accents
  static const Color accent = Color(0xFF26A69A);        // Accent Teal
  static const Color secondary = Color(0xFF1E88E5);     // Clinical Blue
  static const Color secondaryLight = Color(0xFFE3F2FD);
  static const Color accentIndigo = Color(0xFF3F51B5);

  // Status & Safety
  static const Color success = Color(0xFF2E7D32);       // Verified Safe Green
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57C00);       // Amber Caution
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFD32F2F);         // Mismatch / Expired Danger Red
  static const Color errorLight = Color(0xFFFFEBEE);

  // Neutrals & Surfaces
  static const Color background = Color(0xFFF4F7F6);    // Calming Light Slate
  static const Color surface = Color(0xFFFFFFFF);       // Card White
  static const Color surfaceAlt = Color(0xFFEDF4F2);
  static const Color textPrimary = Color(0xFF1B2A27);    // High Contrast Dark Green-Grey
  static const Color textSecondary = Color(0xFF5A716E);  // Legible Subtext
  static const Color textMuted = Color(0xFF8C9E9B);
  static const Color divider = Color(0xFFE2EBE8);

  // Pill & Dosage Visual Badges
  static const Color pillMorning = Color(0xFFFF9800);   // Sun Amber
  static const Color pillAfternoon = Color(0xFF0288D1); // Sky Blue
  static const Color pillNight = Color(0xFF5C6BC0);     // Moon Purple
  static const Color pillBeforeFood = Color(0xFF8E24AA);// Purple
  static const Color pillAfterFood = Color(0xFF00897B); // Teal
}
