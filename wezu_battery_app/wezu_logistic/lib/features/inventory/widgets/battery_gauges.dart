import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_styles.dart';

class BatteryGaugesRow extends StatelessWidget {
  final double chargePercentage;
  final double healthPercentage;

  const BatteryGaugesRow({
    super.key,
    required this.chargePercentage,
    required this.healthPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CircularGauge(
          percentage: chargePercentage,
          label: 'Charge',
          icon: Icons.bolt_rounded,
          color: _getChargeColor(chargePercentage),
        ),
        _CircularGauge(
          percentage: healthPercentage,
          label: 'Health',
          icon: Icons.favorite_rounded,
          color: _getHealthColor(healthPercentage),
        ),
      ],
    );
  }

  Color _getChargeColor(double percentage) {
    if (percentage >= 80) return AppColors.success; // Green
    if (percentage >= 40) return AppColors.primary; // Blue
    if (percentage >= 20) return AppColors.warning; // Orange
    return AppColors.error; // Red
  }

  Color _getHealthColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 80) return AppColors.info;
    return AppColors.error;
  }
}

class _CircularGauge extends StatelessWidget {
  final double percentage;
  final String label;
  final IconData icon;
  final Color color;

  const _CircularGauge({
    required this.percentage,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Circle
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 10,
                color: isDark ? Colors.white24 : Colors.grey.shade200, // Increased opacity
                strokeCap: StrokeCap.round,
              ),
              // Value Circle
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: percentage / 100),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    color: color,
                    strokeCap: StrokeCap.round,
                  );
                },
              ),
              // Center Content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(height: 2),
                    Text(
                      '${percentage.toInt()}%',
                      style: AppTextStyles.headingLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
