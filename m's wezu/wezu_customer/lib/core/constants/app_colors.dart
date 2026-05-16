import 'package:flutter/material.dart';

class AppColors {
  // ── Primary Apple/Cupertino Palette ───────────────────────────
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryDark = Color(0xFF0A84FF);
  static const Color primaryLight = Color(0xFF64D2FF);

  // ── Accent Palette (Luxury Gold) ─────────────────────────────
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentLight = Color(0xFFF3E5AB);
  static const Color accentDark = Color(0xFF996515);
  static const Color accentGold = Color(0xFFD4AF37);

  // ── Secondary/Utility Colors ─────────────────────────────────
  static const Color secondary = Color(0xFF5856D6);
  static const Color teal = Color(0xFF5AC8FA);
  static const Color pink = Color(0xFFFF2D55);
  static const Color indigo = Color(0xFF5E5CE6);

  // ── Status Colors ────────────────────────────────────────────
  static const Color success = Color(0xFF30D158);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color info = Color(0xFF007AFF);

  // ── Glass Surface Colors (VisionOS Inspired) ─────────────────
  static const Color glassWhite = Color(0x14FFFFFF);          // 8%
  static const Color glassWhiteStrong = Color(0x2EFFFFFF);    // 18%
  static const Color glassWhiteSubtle = Color(0x0AFFFFFF);    // 4%
  static const Color glassDark = Color(0x2EFFFFFF);           // 18% white (Changed from black for dark mode visibility)
  static const Color glassDarkStrong = Color(0x3DFFFFFF);     // 24% white (Changed from black for dark mode visibility)
  static const Color glassDarkSubtle = Color(0x14FFFFFF);     // 8% white
  static const Color glassBorder = Color(0x28FFFFFF);         // 16%
  static const Color glassBorderDark = Color(0x1CFFFFFF);     // 11%
  static const Color glassBorderLight = Color(0x14000000);    // 8%

  // ── Neutral Colors ───────────────────────────────────────────
  static const Color dark = Color(0xFF1C1C1E);
  static const Color darkDeep = Color(0xFF000000);
  static const Color gray = Color(0xFF8E8E93);
  static const Color lightGray = Color(0xFFF2F2F7);
  static const Color background = Color(0xFFF2F2F7);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF9F9FB);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  // ── Text Colors ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF3C3C43);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color textHint = Color(0x4D3C3C43);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textDarkPrimary = Color(0xFFFFFFFF);
  static const Color textDarkSecondary = Color(0xB3EBEBF5);

  // ── Border Colors ────────────────────────────────────────────
  static const Color border = Color(0x1F000000);
  static const Color borderLight = Color(0x14000000);

  // ── Gradients ────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5E5CE6), Color(0xFFBF5AF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF5E6A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF0A0A0F), Color(0xFF000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightBgGradient = LinearGradient(
    colors: [Color(0xFFF2F2F7), Color(0xFFFAFAFF), Color(0xFFF2F2F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient profileGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5856D6), Color(0xFFBF5AF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Mesh Background Ambient Colors
  static const Color meshBlue = Color(0xFF007AFF);
  static const Color meshPurple = Color(0xFF5856D6);
  static const Color meshPink = Color(0xFFBF5AF2);
  static const Color meshTeal = Color(0xFF5AC8FA);
}
