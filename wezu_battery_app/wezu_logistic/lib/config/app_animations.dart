import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Centralized animation presets for the Wezu app.
/// Every animation in the app should use these presets to maintain
/// consistency in feel, timing, and easing.
///
/// Usage:
/// ```dart
/// // Apply a screen entrance:
/// Widget build(context) => Column(...).animate().screenEntrance();
///
/// // Stagger a list:
/// children.asMap().entries.map((e) =>
///   MyWidget().animate().listItem(index: e.key)
/// )
/// ```
class AppAnimations {
  AppAnimations._();

  // ─── Durations ────────────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 200);   // M3 Short 2
  static const Duration normal = Duration(milliseconds: 400); // M3 Medium 2
  static const Duration slow = Duration(milliseconds: 600);   // M3 Long 2
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration staggerDelay = Duration(milliseconds: 50);

  // ─── Curves ───────────────────────────────────────────────────────
  static const Curve defaultCurve = Curves.easeInOutCubicEmphasized;
  static const Curve bouncyCurve = Curves.linearToEaseOut; // M3 Decelerate
  static const Curve sharpCurve = Curves.easeInToLinear;   // M3 Accelerate
  static const Curve entranceCurve = Curves.linearToEaseOut;

  // ─── Offsets ──────────────────────────────────────────────────────
  static const Offset slideUpOffset = Offset(0, 20);
  static const Offset slideDownOffset = Offset(0, -20);
  static const Offset slideLeftOffset = Offset(-20, 0);
  static const Offset slideRightOffset = Offset(20, 0);
}

/// Extension on Widget to add consistent animation presets.
/// These compose `flutter_animate` effects into reusable combos.
extension AppAnimateExtensions on Widget {
  /// Standard screen entrance — fade + slide up.
  Widget screenEntrance({Duration? delay}) {
    return animate(delay: delay)
        .fadeIn(
          duration: AppAnimations.normal,
          curve: AppAnimations.defaultCurve,
        )
        .slideY(
          begin: 0.02,
          end: 0,
          duration: AppAnimations.normal,
          curve: AppAnimations.defaultCurve,
        );
  }

  /// Staggered list item animation — each item slides up and fades in
  /// with an increasing delay based on [index].
  /// Items beyond [maxStaggerIndex] skip animation entirely for
  /// smooth fast-scrolling performance.
  Widget listItem({required int index, Duration? staggerDelay, int maxStaggerIndex = 5}) {
    // Skip animation entirely for items beyond the initial viewport
    if (index > maxStaggerIndex) return this;

    final delay = (staggerDelay ?? AppAnimations.staggerDelay) * index;
    return animate(delay: delay)
        .fadeIn(
          duration: AppAnimations.fast,
          curve: AppAnimations.defaultCurve,
        )
        .slideY(
          begin: 0.03,
          end: 0,
          duration: AppAnimations.fast,
          curve: AppAnimations.defaultCurve,
        );
  }

  /// Card entrance with subtle scale + fade.
  Widget cardEntrance({Duration? delay}) {
    return animate(delay: delay)
        .fadeIn(
          duration: AppAnimations.normal,
          curve: AppAnimations.defaultCurve,
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: AppAnimations.normal,
          curve: AppAnimations.bouncyCurve,
        );
  }

  /// Metric card entrance — fade + scale + slight bounce.
  Widget metricEntrance({required int index}) {
    final delay = AppAnimations.staggerDelay * index;
    return animate(delay: delay + const Duration(milliseconds: 100))
        .fadeIn(
          duration: AppAnimations.slow,
          curve: AppAnimations.defaultCurve,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: AppAnimations.slow,
          curve: AppAnimations.bouncyCurve,
        );
  }

  /// Heading / section title entrance — fade in from left.
  Widget sectionEntrance({Duration? delay}) {
    return animate(delay: delay ?? const Duration(milliseconds: 200))
        .fadeIn(
          duration: AppAnimations.normal,
          curve: AppAnimations.defaultCurve,
        )
        .slideX(
          begin: -0.03,
          end: 0,
          duration: AppAnimations.normal,
          curve: AppAnimations.defaultCurve,
        );
  }

  /// Button press micro-interaction — scale down then up.
  Widget tapScale() {
    return animate(
      autoPlay: false,
      onPlay: (controller) => controller.forward(),
    ).scale(
      begin: const Offset(1, 1),
      end: const Offset(0.96, 0.96),
      duration: AppAnimations.fast,
      curve: AppAnimations.sharpCurve,
    );
  }

  /// Shimmer loading effect.
  Widget shimmerEffect() {
    return animate(
      onPlay: (controller) => controller.repeat(),
    ).shimmer(
      duration: const Duration(milliseconds: 1500),
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  /// Status badge pop-in.
  Widget badgeEntrance({Duration? delay}) {
    return animate(delay: delay ?? const Duration(milliseconds: 300))
        .fadeIn(duration: AppAnimations.fast)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: AppAnimations.normal,
          curve: AppAnimations.bouncyCurve,
        );
  }
}
