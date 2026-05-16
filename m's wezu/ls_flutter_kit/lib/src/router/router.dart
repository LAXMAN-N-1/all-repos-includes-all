import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Predefined page transitions for go_router.
class RouteTransitions {
  RouteTransitions._();

  /// Fade transition.
  static CustomTransitionPage<T> fade<T>({required Widget child, required GoRouterState state}) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
    );
  }

  /// Slide from right.
  static CustomTransitionPage<T> slideRight<T>({required Widget child, required GoRouterState state}) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, child) =>
          SlideTransition(position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)), child: child),
    );
  }

  /// Slide from bottom.
  static CustomTransitionPage<T> slideUp<T>({required Widget child, required GoRouterState state}) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, child) =>
          SlideTransition(position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)), child: child),
    );
  }

  /// Scale transition.
  static CustomTransitionPage<T> scale<T>({required Widget child, required GoRouterState state}) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, child) =>
          ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: FadeTransition(opacity: animation, child: child)),
    );
  }
}
