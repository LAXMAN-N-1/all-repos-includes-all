import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_constants.dart';

/// Custom page transition builders for GoRouter.
/// Each returns a [CustomTransitionPage] with a unique animation style.
class AppTransitions {
  AppTransitions._();

  // ─── Fade ─────────────────────────────────────────────────────────

  /// Smooth crossfade — used for tab switches within the bottom nav.
  static CustomTransitionPage fade({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.animNormal,
      reverseTransitionDuration: AppConstants.animNormal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  // ─── Slide Up ─────────────────────────────────────────────────────

  /// Slide up from bottom — used for detail screens and modals.
  static CustomTransitionPage slideUp({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.animNormal,
      reverseTransitionDuration: AppConstants.animNormal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: CurveTween(curve: Curves.easeIn).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  // ─── Slide Right ──────────────────────────────────────────────────

  /// Slide in from right — standard push-style navigation.
  static CustomTransitionPage slideRight({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.animNormal,
      reverseTransitionDuration: AppConstants.animNormal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  // ─── Scale Fade ───────────────────────────────────────────────────

  /// Scale + fade — used for modals and overlays.
  static CustomTransitionPage scaleFade({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.animNormal,
      reverseTransitionDuration: AppConstants.animFast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: CurveTween(curve: Curves.easeIn).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  // ─── No Transition ────────────────────────────────────────────────

  /// Instant swap — used for redirects and initial routes.
  static CustomTransitionPage none({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}
