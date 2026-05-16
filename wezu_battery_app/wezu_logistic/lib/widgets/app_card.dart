import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_animations.dart';
import '../utils/app_haptics.dart';

/// A consistent card component with built-in tap micro-interaction.
/// Scales down subtly on press for a polished, responsive feel.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.width,
    this.height,
    this.onTap,
    this.hoverEffect,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  /// Whether to enable hover animation (scale/border) event if onTap is null.
  /// Defaults to true if onTap is set, false otherwise.
  final bool? hoverEffect;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _shouldHover => widget.hoverEffect ?? (widget.onTap != null);

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    if (widget.onTap != null) setState(() => _isPressed = false);
  }

  void _onEnter(PointerEnterEvent event) {
    if (_shouldHover) setState(() => _isHovered = true);
  }

  void _onExit(PointerExitEvent event) {
    if (_shouldHover) setState(() => _isHovered = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine border color
    final Color defaultBorderColor = widget.borderColor ?? theme.colorScheme.outlineVariant;
    final Color hoverBorderColor = theme.colorScheme.primary.withValues(alpha: isDark ? 0.5 : 0.3);
    final Color borderColor = _isHovered ? hoverBorderColor : defaultBorderColor;

    // Use Material elevation (GPU-accelerated) instead of BoxShadow (CPU-rasterized)
    final double elevation = _isHovered ? 4 : (widget.elevation ?? 1);

    final cardContent = Material(
      type: MaterialType.card,
      color: widget.color ?? theme.cardTheme.color,
      elevation: _isPressed ? 0 : elevation,
      shadowColor: isDark ? Colors.transparent : null,
      surfaceTintColor: Colors.transparent,
      borderRadius: widget.borderRadius ?? AppSpacing.borderRadiusMd,
      clipBehavior: Clip.none,
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? AppSpacing.cardPadding,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? AppSpacing.borderRadiusMd,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: widget.child,
      ),
    );

    Widget card = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap != null 
          ? () {
              AppHaptics.impact();
              widget.onTap!();
            }
          : null,
      child: cardContent,
    );

    return RepaintBoundary(
      child: Padding(
        padding: widget.margin ?? EdgeInsets.zero,
        child: card,
      ),
    );
  }
}
