import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';


class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.construction, size: 64, color: AppColors.crimsonSilk.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            '$title Coming Soon',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We are working hard to bring this feature to you.',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
