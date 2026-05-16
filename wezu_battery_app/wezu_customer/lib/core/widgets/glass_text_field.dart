import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../theme/app_theme.dart';

/// Unified luxury glass text field used across all auth and form screens.
/// Provides consistent styling with Apple-inspired design.
class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;
  final bool isPhone;
  final bool isEmail;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onVisibilityToggle;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool useTextFormField;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    this.isPhone = false,
    this.isEmail = false,
    this.isPassword = false,
    this.isVisible = false,
    this.onVisibilityToggle,
    this.validator,
    this.keyboardType,
    this.useTextFormField = false,
  });

  @override
  Widget build(BuildContext context) {
    final inputKeyboardType = keyboardType ??
        (isPhone
            ? TextInputType.phone
            : isEmail
                ? TextInputType.emailAddress
                : isPassword
                    ? TextInputType.visiblePassword
                    : TextInputType.text);

    final decoration = InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
        color: isDark ? Colors.white38 : AppColors.textTertiary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 16, right: 12),
        child: Icon(icon, color: AppColors.accent.withValues(alpha: 0.7), size: 20),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      prefixText: isPhone ? "+91 " : null,
      prefixStyle: GoogleFonts.inter(
        color: isDark ? Colors.white70 : AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: isDark ? Colors.white30 : AppColors.textHint,
                size: 20,
              ),
              onPressed: onVisibilityToggle,
            )
          : null,
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        borderSide: BorderSide(
          color: isDark ? AppColors.primaryDark : AppColors.primary,
          width: 1.5,
        ),
      ),
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );

    final textStyle = GoogleFonts.inter(
      color: isDark ? Colors.white : AppColors.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );

    Widget field;
    if (useTextFormField || validator != null) {
      field = TextFormField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        keyboardType: inputKeyboardType,
        validator: validator,
        style: textStyle,
        decoration: decoration,
      );
    } else {
      field = TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        keyboardType: inputKeyboardType,
        style: textStyle,
        decoration: decoration,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: field,
    );
  }
}
