import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Floating action button that smoothly morphs between extended and icon-only.
class ScrollMorphFab extends StatelessWidget {
  const ScrollMorphFab({
    super.key,
    required this.progress,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 4,
  });

  /// 0.0 = fully extended, 1.0 = fully collapsed.
  final double progress;
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fg = foregroundColor ?? theme.colorScheme.onPrimaryContainer;
    final target = progress.clamp(0.0, 1.0);
    final textStyle =
        theme.textTheme.labelLarge?.copyWith(color: fg) ??
        TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w600);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: target),
      duration: const Duration(milliseconds: 110),
      curve: Curves.linear,
      builder: (context, t, _) {
        final eased = Curves.easeOutCubic.transform(t);
        final labelFactor = 1.0 - eased;
        final horizontalPadding = lerpDouble(20, 16, eased)!;
        final labelGap = lerpDouble(10, 0, eased)!;
        return Material(
          color: bg,
          elevation: elevation,
          shadowColor: theme.shadowColor.withValues(alpha: 0.28),
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              height: 56,
              constraints: const BoxConstraints(minWidth: 56),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(color: fg),
                    child: icon,
                  ),
                  ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: labelFactor,
                      child: Opacity(
                        opacity: labelFactor,
                        child: Padding(
                          padding: EdgeInsets.only(left: labelGap),
                          child: Text(label, style: textStyle),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
