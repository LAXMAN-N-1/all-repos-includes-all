import 'package:flutter/services.dart';

/// Centralised haptic feedback utility.
///
/// Uses Flutter's [HapticFeedback] for system-level vibrations.
/// Intensity levels map to standard iOS/Android haptic patterns:
/// - [tap]        → light impact — filter chips, toggles, selections
/// - [selection]  → selection click — tab changes, radio buttons, switches
/// - [impact]     → medium impact — button presses, FABs, navigation
/// - [heavy]      → heavy impact — swipe actions, destructive operations
/// - [success]    → light + delay + light — positive confirmations
/// - [warning]    → heavy — error/warning feedback
class AppHaptics {
  AppHaptics._();

  /// Light tap — chips, toggles, minor interactions.
  static void tap() => HapticFeedback.lightImpact();

  /// Selection change — tabs, radio buttons, segmented controls.
  static void selection() => HapticFeedback.selectionClick();

  /// Medium impact — primary button presses, FAB taps, navigation.
  static void impact() => HapticFeedback.mediumImpact();

  /// Heavy impact — swipe-to-dismiss, destructive actions.
  static void heavy() => HapticFeedback.heavyImpact();

  /// Success pattern — order confirmed, scan complete.
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Warning/error — failed actions, validation errors.
  static void warning() => HapticFeedback.heavyImpact();
}
