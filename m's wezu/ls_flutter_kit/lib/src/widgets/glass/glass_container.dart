import 'dart:ui';
import 'package:flutter/material.dart';

/// Apple VisionOS-inspired glassmorphism container with backdrop blur,
/// gradient borders, and dark/light mode support.
///
/// Unified from Wezu Customer & Meat Customer implementations.
///
/// ```dart
/// GlassContainer(
///   child: Text('Hello Glass'),
///   blur: 24,
///   borderRadius: 20,
/// )
/// ```
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final double borderWidth;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.blur = 20,
    this.backgroundColor,
    this.width,
    this.height,
    this.boxShadow,
    this.gradient,
    this.borderWidth = 0.5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.75);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.white.withOpacity(0.5);

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? defaultBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderWidth > 0
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
            gradient: gradient,
            boxShadow: boxShadow ??
                [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}
