import 'package:flutter/material.dart';

/// Responsive breakpoint definitions.
class Breakpoints {
  Breakpoints._();

  static const double mobile = 0;
  static const double tablet = 600;
  static const double desktop = 1024;
  static const double wide = 1440;
}

/// Build different layouts per breakpoint.
///
/// ```dart
/// ResponsiveBuilder(
///   mobile: (ctx) => MobileLayout(),
///   tablet: (ctx) => TabletLayout(),
///   desktop: (ctx) => DesktopLayout(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= Breakpoints.desktop && desktop != null) return desktop!(context);
        if (width >= Breakpoints.tablet && tablet != null) return tablet!(context);
        return mobile(context);
      },
    );
  }
}

/// BuildContext extensions for responsive checks.
extension ResponsiveExtension on BuildContext {
  double get _width => MediaQuery.sizeOf(this).width;

  bool get isMobile => _width < Breakpoints.tablet;
  bool get isTablet => _width >= Breakpoints.tablet && _width < Breakpoints.desktop;
  bool get isDesktop => _width >= Breakpoints.desktop;
  bool get isWide => _width >= Breakpoints.wide;

  /// Returns the appropriate value based on current breakpoint.
  T responsive<T>(T mobile, {T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Number of grid columns for the current breakpoint.
  int get gridColumns => responsive(1, tablet: 2, desktop: 3);
}
