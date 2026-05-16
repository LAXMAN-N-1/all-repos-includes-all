import 'package:flutter/material.dart';
import '../../../models/dashboard_alert_model.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../widgets/app_card.dart';

class DashboardAlerts extends StatelessWidget {
  final List<DashboardAlert> alerts;
  final VoidCallback? onViewAll;

  const DashboardAlerts({
    super.key,
    required this.alerts,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by severity (Critical first)
    final sortedAlerts = List<DashboardAlert>.from(alerts)
      ..sort((a, b) => a.severity.index.compareTo(b.severity.index)); // enum index: critical=0

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alerts & Notifications',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        AppSpacing.gapH12,
        // Using a vertical list for prominent visibility
        // Could also be a carousel if space is tight
        ...sortedAlerts.map((alert) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AlertCard(alert: alert),
            )),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final DashboardAlert alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      color: alert.severity.backgroundColor.withValues(alpha: 0.1), // Subtle background based on severity
      borderColor: alert.severity.color.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              alert.severity.icon,
              color: alert.severity.color,
              size: 24,
            ),
            AppSpacing.gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleSmall?.color,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (alert.actionLabel != null) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Action: ${alert.actionLabel}')),
                        );
                      },
                      child: Text(
                        alert.actionLabel!.toUpperCase(),
                        style: TextStyle(
                          color: alert.severity.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
             // Optional dismissal X could go here
          ],
        ),
      ),
    );
  }
}
