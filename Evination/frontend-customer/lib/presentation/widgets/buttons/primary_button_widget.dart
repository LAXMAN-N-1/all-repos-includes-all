import 'package:flutter/material.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import 'package:evination_customer_app/core/constants/app_sizes.dart';

class PrimaryButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.crimsonSilk,
        foregroundColor: textColor ?? AppColors.softBlush,
        disabledBackgroundColor: AppColors.greyMedium,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.softBlush),
              ),
            )
          : Text(text),
    );
  }
}
