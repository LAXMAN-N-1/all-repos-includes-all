import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

enum ButtonVariant { defaultVariant, destructive, outline, secondary, ghost, link }
enum ButtonSize { defaultSize, sm, lg, icon }

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.defaultVariant,
    this.size = ButtonSize.defaultSize,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;
    double? elevation = 0;
    EdgeInsetsGeometry padding;
    double height;
    double fontSize;

    Gradient? backgroundGradient;

    // Variant Styles
    switch (variant) {
      case ButtonVariant.destructive:
        backgroundColor = AppTheme.error;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppTheme.textPrimary;
        borderColor = AppTheme.primary200;
        break;
      case ButtonVariant.secondary:
        backgroundColor = Colors.transparent;
        foregroundColor = AppTheme.textPrimary;
        borderColor = AppTheme.primary200; // Border for secondary as per spec
        break;
      case ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppTheme.textPrimary;
        break;
      case ButtonVariant.link:
        backgroundColor = Colors.transparent;
        foregroundColor = AppTheme.primary700;
        break;
      case ButtonVariant.defaultVariant:
      default:
        // Gradient for Primary
        backgroundColor = Colors.transparent; // Handled by container
        backgroundGradient = const LinearGradient(
          colors: [AppTheme.primary600, AppTheme.primary500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        foregroundColor = Colors.white;
        break;
    }

    // Size Styles
    switch (size) {
      case ButtonSize.sm:
        height = 36;
        padding = const EdgeInsets.symmetric(horizontal: 12);
        fontSize = 12;
        break;
      case ButtonSize.lg:
        height = 44;
        padding = const EdgeInsets.symmetric(horizontal: 32);
        fontSize = 16;
        break;
      case ButtonSize.icon:
        height = 40;
        padding = EdgeInsets.zero;
        fontSize = 14;
        break;
      case ButtonSize.defaultSize:
      default:
        height = 40;
        padding = const EdgeInsets.symmetric(horizontal: 16);
        fontSize = 14;
        break;
    }

    if (size == ButtonSize.icon) {
      return Container(
        height: height,
        width: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: IconButton(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: foregroundColor))
              : Icon(icon, color: foregroundColor, size: 18),
          padding: EdgeInsets.zero,
        ),
      );
    }

    final  buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: backgroundGradient != null ? Colors.transparent : backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.5),
          disabledForegroundColor: foregroundColor.withOpacity(0.5),
          elevation: elevation,
          shadowColor: backgroundGradient != null ? Colors.transparent : null,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
          ),
    );

    return Container(
      height: height,
      width: fullWidth ? double.infinity : null,
      decoration: backgroundGradient != null ? BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary500.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ) : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: foregroundColor)),
              const SizedBox(width: 8),
            ] else if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.w500, decoration: variant == ButtonVariant.link ? TextDecoration.underline : null),
            ),
          ],
        ),
      ),
    );
  }
}
