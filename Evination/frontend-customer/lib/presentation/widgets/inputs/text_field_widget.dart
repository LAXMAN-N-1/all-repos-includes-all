import 'package:flutter/material.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import 'package:evination_customer_app/core/constants/app_sizes.dart';

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const TextFieldWidget({
    super.key,
    required this.hintText,
    required this.controller,
    this.labelText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
              fontSize: AppSizes.fontSizeSM,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
        ],
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.greyMedium),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.crimsonSilk) : null,
          ),
        ),
      ],
    );
  }
}
