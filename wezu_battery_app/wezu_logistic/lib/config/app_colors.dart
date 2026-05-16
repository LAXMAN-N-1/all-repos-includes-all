import 'package:flutter/material.dart';

/// Centralized color palette for the Wezu Battery Logistics app.
/// All colors used across the app should be referenced from here
/// to ensure visual consistency.
class AppColors {
  AppColors._();

  // ─── Primary Palette ───────────────────────────────────────────────
  static const Color primary = Color(0xFF0D47A1);       // Deep Blue
  static const Color primaryLight = Color(0xFF5472D3);
  static const Color primaryDark = Color(0xFF002171);
  static const Color onPrimary = Colors.white;
  static const Color white = Colors.white;

  // ─── Secondary / Accent ────────────────────────────────────────────
  static const Color secondary = Color(0xFF00897B);      // Teal
  static const Color secondaryLight = Color(0xFF4EBAAA);
  static const Color secondaryDark = Color(0xFF005B4F);
  static const Color onSecondary = Colors.white;

  // ─── Surface & Background (Light) ──────────────────────────────────
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEEF1F6);
  static const Color scaffoldBackground = Color(0xFFF5F7FA);

  // ─── Surface & Background (Dark) ───────────────────────────────────
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  static const Color scaffoldBackgroundDark = Color(0xFF121212);

  // ─── Text (Light) ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnDark = Colors.white;

  // ─── Text (Dark) ───────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFA0A0A0);
  static const Color textHintDark = Color(0xFF707070);

  // ─── Semantic ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ─── Borders & Dividers ───────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color inputBorder = Color(0xFFD1D5DB);
  static const Color focusBorder = primary;
  
  static const Color borderDark = Color(0xFF333333);
  static const Color dividerDark = Color(0xFF333333);
  static const Color inputBorderDark = Color(0xFF444444);

  // ─── Shimmer ──────────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFF0F2F5);
  static const Color shimmerHighlight = Color(0xFFFAFBFC);
  
  static const Color shimmerBaseDark = Color(0xFF202020);
  static const Color shimmerHighlightDark = Color(0xFF2D2D2D);

  // ─── Bottom Nav ───────────────────────────────────────────────────
  static const Color navBarBackground = Colors.white;
  static const Color navBarSelected = primary;
  static const Color navBarUnselected = Color(0xFF9CA3AF);
  
  static const Color navBarBackgroundDark = Color(0xFF1E1E1E);
  static const Color navBarSelectedDark = primaryLight;
  static const Color navBarUnselectedDark = Color(0xFF707070);

  // ─── Battery Status Colors ────────────────────────────────────────
  static const Color batteryFull = Color(0xFF16A34A);
  static const Color batteryMedium = Color(0xFFF59E0B);
  static const Color batteryLow = Color(0xFFEF4444);
  static const Color batteryCritical = Color(0xFFDC2626);
}
