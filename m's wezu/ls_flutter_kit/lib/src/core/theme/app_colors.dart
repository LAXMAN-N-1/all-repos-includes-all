import 'dart:ui';
import 'package:flutter/material.dart';

/// Design tokens for the LS Flutter Kit color system.
/// Supports both light and dark modes with curated palettes.
class AppColors {
  AppColors._();

  // ── Brand ──
  static const Color primary = Color(0xFF6366F1);       // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8);   // Indigo 400
  static const Color primaryDark = Color(0xFF4F46E5);    // Indigo 600
  static const Color secondary = Color(0xFF06B6D4);      // Cyan 500
  static const Color accent = Color(0xFFF59E0B);         // Amber 500

  // ── Semantic ──
  static const Color success = Color(0xFF10B981);        // Emerald 500
  static const Color warning = Color(0xFFF59E0B);        // Amber 500
  static const Color error = Color(0xFFEF4444);          // Red 500
  static const Color info = Color(0xFF3B82F6);           // Blue 500

  // ── Neutrals ──
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // ── Glass ──
  static const Color glassDark = Color(0x33FFFFFF);
  static const Color glassDarkStrong = Color(0x55FFFFFF);
  static const Color glassLight = Color(0xCCFFFFFF);
  static const Color glassLightStrong = Color(0xE6FFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x55FFFFFF);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkSurface = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
