import 'package:flutter/material.dart';

/// Border radius tokens.
class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double pill = 999;

  static BorderRadius get cardRadius => BorderRadius.circular(base);
  static BorderRadius get chipRadius => BorderRadius.circular(pill);
  static BorderRadius get sheetRadius => const BorderRadius.vertical(top: Radius.circular(xl));
  static BorderRadius get dialogRadius => BorderRadius.circular(xxl);
}

/// Elevation / shadow tokens.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get sm => [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
      ];

  static List<BoxShadow> get glow => [
        BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 20, spreadRadius: -4),
      ];
}
