import 'package:flutter/material.dart';

class AppColors {
  // Primary action (buttons, active states)
  static const Color primary = Color(0xFF000000); // Black
  static const Color primaryLight = Color(0xFF1A1A1A);

  // Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF5F5F5);
  static const Color cardBg = Color(0xFFF8F8F8);

  // Text
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFAAAAAA);

  // Dividers & borders
  static const Color divider = Color(0xFFE5E5E5);
  static const Color border = Color(0xFFDDDDDD);

  // Status colors
  static const Color online = Color(0xFF00AA44);
  static const Color offline = Color(0xFF6B6B6B);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF00AA44);

  // Accent (kept for highlights/badges only)
  static const Color accent = Color(0xFFFD802E); // Orange accent

  // Legacy aliases (for backward compat with existing screens)
  static const Color secondary = Color(0xFF1A1A1A);
  static const Color white = Colors.white;
}
