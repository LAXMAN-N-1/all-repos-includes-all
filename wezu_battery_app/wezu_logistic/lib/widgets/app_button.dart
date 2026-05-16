import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';
import '../config/app_constants.dart';
import '../utils/app_haptics.dart';

/// Variants for the AppButton widget.
enum AppButtonVariant { primary, secondary, outlined, text }

/// Sizes for the AppButton widget.
enum AppButtonSize { small, medium, large }

/// A versatile, design-system-consistent button widget.
/// Supports primary, secondary, outlined, and text variants with
/// optional loading state and icon.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double? width;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed =
        widget.isEnabled && !widget.isLoading
            ? () {
                AppHaptics.impact();
                widget.onPressed?.call();
              }
            : null;

    final double scale = _isPressed
        ? 0.97
        : _isHovered
            ? 1.05 // Slightly larger scale for buttons to invite clicks
            : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: effectiveOnPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: SizedBox(
            width: widget.width, // Allow null for intrinsic width
            height: _height,
            child: AnimatedSwitcher(
              duration: AppConstants.animFast,
              child: _buildButton(effectiveOnPressed),
            ),
          ),
        ),
      ),
    );
  }

  double get _height {
    switch (widget.size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 44;
      case AppButtonSize.large:
        return 52;
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case AppButtonSize.small:
        return AppTextStyles.buttonSmall;
      case AppButtonSize.medium:
        return AppTextStyles.buttonMedium;
      case AppButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
  }

  Widget _buildButton(VoidCallback? onPressed) {
    // We wrap onPressed to ensure we don't break the gesture detector above,
    // but ElevatedButton consumes gestures.
    // To make the scaling work with ElevatedButton, we need to let the button handle the click
    // but the GestureDetector/Listener above handle the visual state.
    // However, ElevatedButton fills the space.
    // Verified approach: Keep standard button logic. The transform is on the parent.
    
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: _padding,
            textStyle: _textStyle,
            minimumSize: Size.zero,
            // Remove splash if it conflicts, but usually it's fine.
          ),
          child: _buildChild(AppColors.onPrimary),
        );
      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.onSecondary,
            padding: _padding,
            textStyle: _textStyle,
            minimumSize: Size.zero,
          ),
          child: _buildChild(AppColors.onSecondary),
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: _padding,
            textStyle: _textStyle,
            minimumSize: Size.zero,
          ),
          child: _buildChild(AppColors.primary),
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: _padding,
            textStyle: _textStyle,
            minimumSize: Size.zero,
          ),
          child: _buildChild(AppColors.primary),
        );
    }
  }

  Widget _buildChild(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: AppSpacing.iconSm),
          AppSpacing.gapW8,
          Text(widget.label),
        ],
      );
    }

    return Text(widget.label);
  }
}
