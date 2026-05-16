import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_spacing.dart';
import '../models/route_model.dart';

class RouteStatsCard extends StatelessWidget {
  final DeliveryRouteModel route;
  final VoidCallback onClear;

  const RouteStatsCard({
    super.key,
    required this.route,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Optimized Route',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          AppSpacing.gapH12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                Icons.directions_car,
                '${(route.totalDistanceMeters / 1000).toStringAsFixed(1)} km',
                'Distance',
              ),
              _buildStat(
                Icons.schedule,
                '${(route.totalDurationSeconds / 60).toStringAsFixed(0)} min',
                'Duration',
              ),
              _buildStat(
                Icons.traffic,
                route.trafficCongestionLevel.toUpperCase(),
                'Traffic',
                color: _getTrafficColor(route.trafficCongestionLevel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppColors.primary, size: 24),
        AppSpacing.gapH4,
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textHint, fontSize: 12),
        ),
      ],
    );
  }

  Color _getTrafficColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return AppColors.success;
      case 'moderate':
        return AppColors.warning;
      case 'high':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }
}
