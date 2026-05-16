import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../../core/theme/colors.dart';
import '../../../models/station_state.dart';

class OverviewTab extends StatelessWidget {
  final StationDto station;
  final Function(String, dynamic)? onUpdate;

  const OverviewTab({super.key, required this.station, this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final bool isOperational = station.status.toUpperCase() == 'OPERATIONAL';
    final Color statusColor = isOperational 
      ? AppColors.primary 
      : station.status.toUpperCase() == 'MAINTENANCE' 
        ? AppColors.amber 
        : AppColors.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sections: System Status & Capacity
          _SectionCard(
            title: 'System Status',
            icon: LucideIcons.activity,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current State', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3))
                        ),
                        child: Text(
                          station.status.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Last Heartbeat', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        station.lastHeartbeat ?? 'Unknown',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Capacity',
            icon: LucideIcons.battery,
            child: Column(
              children: [
                _infoRow('Available Batteries', '${station.availableBatteries}'),
                const SizedBox(height: 10),
                _infoRow('Empty Slots', '${station.availableSlots}'),
                const SizedBox(height: 10),
                _infoRow('Total Slots', '${station.totalSlots}'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Row 2: Performance Metrics
          _SectionCard(
            title: 'Performance Metrics',
            icon: LucideIcons.trendingUp,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Utilization', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('${station.utilizationPercent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: station.utilizationPercent / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(station.utilizationPercent > 80 ? AppColors.primary : AppColors.cyan),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _metricBox('Active Swaps', '${station.activeSwaps}')),
                    const SizedBox(width: 12),
                    Expanded(child: _metricBox('Average Rating', '${station.rating.toStringAsFixed(1)} / 5.0')),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          
          // Quick Actions
          const Text('QUICK ACTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 1.0)),
          const SizedBox(height: 16),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                icon: const Icon(LucideIcons.settings, size: 16),
                label: const Text('Configure Slots'),
                onPressed: () => _showConfigDialog(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: Icon(isOperational ? LucideIcons.powerOff : LucideIcons.power, size: 16),
                label: Text(isOperational ? 'Take Offline' : 'Bring Online'),
                onPressed: () {
                  final newStatus = isOperational ? 'OFFLINE' : 'OPERATIONAL';
                  onUpdate?.call('status', newStatus);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOperational ? AppColors.amber : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _metricBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.pageBg, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _showConfigDialog(BuildContext context) {
    final slotController = TextEditingController(text: station.totalSlots.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Configure Station', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: slotController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Total Slots',
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.pageBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final slots = int.tryParse(slotController.text) ?? station.totalSlots;
              Navigator.pop(ctx);
              onUpdate?.call('total_slots', slots);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
