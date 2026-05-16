import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/app_navigator.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_spacing.dart';
import '../../../../config/app_text_styles.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../widgets/app_loader.dart';
import '../../../models/driver_model.dart';
import '../providers/logistics_providers.dart';
import '../widgets/driver_status_chip.dart';

class DriverDetailScreen extends ConsumerWidget {
  final String driverId;

  const DriverDetailScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can reuse fleetListProvider and find the driver, or create a specific single-driver provider.
    // For simplicity/caching, we'll select from the list or fetch if not present.
    final driverAsync = ref.watch(
      fleetListProvider.select(
        (value) => value.whenData(
          (drivers) => drivers.cast<DriverModel?>().firstWhere(
            (d) => d?.id == driverId,
            orElse: () => null,
          ),
        ),
      ),
    );

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final updated =
                  await AppNavigator.toEditDriverProfile<DriverModel>(
                    context,
                    driverId: driverId,
                  );
              if (!context.mounted) return;
              if (updated != null) {
                await ref.read(fleetListProvider.notifier).refresh();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Driver profile updated.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: driverAsync.when(
        data: (driver) {
          if (driver == null) {
            return const Center(child: Text('Driver not found'));
          }
          return _buildContent(context, ref, driver);
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const AppLoader(),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    DriverModel driver,
  ) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(context, ref, driver),
          AppSpacing.gapH24,
          _buildStatsGrid(context, driver),
          AppSpacing.gapH24,
          _buildPerformanceChart(context),
          AppSpacing.gapH24,
          _buildActions(context, driver),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    WidgetRef ref,
    DriverModel driver,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  driver.name[0],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              AppSpacing.gapW16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name, style: AppTextStyles.headingSmall),
                    const SizedBox(height: 4),
                    Text(
                      '${driver.vehicleType} • ${driver.vehiclePlate}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DriverStatusChip(status: driver.status),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat(
                context,
                'Rating',
                driver.rating.toString(),
                Icons.star,
                AppColors.warning,
              ),
              _buildHeaderStat(
                context,
                'Deliveries',
                '${driver.completedDeliveries}',
                Icons.inventory_2,
                AppColors.success,
              ),
              _buildHeaderStat(
                context,
                'Battery',
                '${driver.currentBatteryLevel}%',
                Icons.battery_full,
                AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, DriverModel driver) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current Status', style: AppTextStyles.titleMedium),
        AppSpacing.gapH12,
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                context,
                title: 'Online Status',
                value: driver.status == DriverStatus.offline
                    ? 'Offline'
                    : 'Online',
                icon: Icons.wifi,
                color: driver.status != DriverStatus.offline
                    ? AppColors.success
                    : Colors.grey,
              ),
            ),
            AppSpacing.gapW12,
            Expanded(
              child: _buildInfoCard(
                context,
                title: 'GPS Accuracy',
                value: '${driver.locationAccuracy.toStringAsFixed(1)}m',
                icon: Icons.gps_fixed,
                color: AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              AppSpacing.gapW8,
              Text(title, style: AppTextStyles.labelMedium),
            ],
          ),
          AppSpacing.gapH12,
          Text(value, style: AppTextStyles.headingSmall),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(BuildContext context) {
    // Mock data for last 7 days
    final List<int> weeklyDeliveries = [12, 15, 8, 20, 18, 5, 0];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Activity', style: AppTextStyles.titleMedium),
              Text(
                'Total: ${weeklyDeliveries.reduce((a, b) => a + b)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.gapH24,
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 25,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[value.toInt() % days.length],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: weeklyDeliveries.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        color: AppColors.primary,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, DriverModel driver) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () async {
              final uri = Uri.parse('tel:${driver.phoneNumber}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch dialer')),
                  );
                }
              }
            },
            icon: const Icon(Icons.call),
            label: const Text('Call Driver'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
