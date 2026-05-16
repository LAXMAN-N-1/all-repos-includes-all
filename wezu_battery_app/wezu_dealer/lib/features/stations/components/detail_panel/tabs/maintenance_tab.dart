import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../../core/theme/colors.dart';

class MaintenanceRecordDto {
  final String type;
  final String performedAt;
  final String description;
  final double cost;

  const MaintenanceRecordDto({
    required this.type,
    required this.performedAt,
    required this.description,
    this.cost = 0.0,
  });
}

class MaintenanceTab extends StatelessWidget {
  final List<MaintenanceRecordDto> history;
  final String? lastMaintenance;

  const MaintenanceTab({
    super.key,
    required this.history,
    this.lastMaintenance,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          _SummaryCard(lastDate: lastMaintenance ?? 'N/A'),
          const SizedBox(height: 24),

          const Text('MAINTENANCE HISTORY', 
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 1.0)),
          const SizedBox(height: 16),

          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.scrollText, size: 40, color: AppColors.textTertiary.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    const Text('No maintenance records found.', 
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final h = history[index];
                return _MaintenanceItem(record: h);
              },
            ),

          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(LucideIcons.calendarPlus, size: 16),
              label: const Text('Schedule Maintenance'),
              onPressed: () {
                // Implementation for scheduling
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String lastDate;

  const _SummaryCard({required this.lastDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.wrench, size: 24, color: AppColors.primary),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LAST SERVICE', 
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
              const SizedBox(height: 4),
              Text(lastDate, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaintenanceItem extends StatelessWidget {
  final MaintenanceRecordDto record;

  const _MaintenanceItem({required this.record});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dot
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 16),

        // Record content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(record.type.toUpperCase(), 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                  Text(record.performedAt, 
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 4),
              Text(record.description, 
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
              if (record.cost > 0) ...[
                const SizedBox(height: 8),
                Text('Cost: \$${record.cost.toStringAsFixed(2)}', 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
