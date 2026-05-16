import 'package:flutter/material.dart';

/// Responsive utility class providing breakpoint helpers and adaptive values.
/// 
/// Breakpoints:
/// - Mobile:  width < 600
/// - Tablet:  600 ≤ width < 1024
/// - Desktop: width ≥ 1024
class Responsive {
  Responsive._();

  // ── Breakpoints ──────────────────────────────────────────────

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static bool isTabletOrDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  // ── Grid helpers ─────────────────────────────────────────────

  /// Returns adaptive grid column count: 2 (mobile), 3 (tablet), 4 (desktop).
  static int gridColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1024) return 4;
    if (w >= 600) return 3;
    return 2;
  }

  /// Returns quick actions grid columns: 3 (mobile), 4 (tablet), 6 (desktop).
  static int quickActionColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1024) return 6;
    if (w >= 600) return 4;
    return 3;
  }

  // ── Sizing helpers ───────────────────────────────────────────

  /// Max width for form-centric screens (login, checkout, etc.)
  static double formMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 520;
    if (isTablet(context)) return 480;
    return double.infinity; // full width on mobile
  }

  /// Max width for general content areas.
  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 900;
    if (isTablet(context)) return 700;
    return double.infinity;
  }

  /// Horizontal padding that scales with screen width.
  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1024) return 40;
    if (w >= 600) return 28;
    return 16;
  }

  /// Returns a proportional card width for horizontal list items.
  /// Ensures cards don't look tiny on large screens or overflow on small ones.
  static double horizontalCardWidth(BuildContext context,
      {double mobileRatio = 0.75, double maxWidth = 340}) {
    final screenW = MediaQuery.of(context).size.width;
    final raw = screenW * mobileRatio;
    return raw.clamp(200, maxWidth).toDouble();
  }

  /// Returns a proportional size, capped at [max].
  static double proportional(BuildContext context, double ratio,
      {double max = double.infinity}) {
    final screenW = MediaQuery.of(context).size.width;
    return (screenW * ratio).clamp(0, max).toDouble();
  }

  /// Returns an adaptive value based on the current breakpoint.
  static T value<T>(BuildContext context,
      {required T mobile, T? tablet, T? desktop}) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}
