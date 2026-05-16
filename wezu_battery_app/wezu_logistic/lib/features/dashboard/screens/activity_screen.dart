import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../config/app_text_styles.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_loader.dart';
import '../../fleet/providers/logistics_providers.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(logisticsAnalyticsProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Logistics Performance'),
      ),
      body: analyticsAsync.when(
        loading: () => const Center(child: AppLoader()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) => _buildDashboard(context, data),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, Map<String, dynamic> data) {
    // Extract data with safe defaults
    final onTimeRate = (data['onTimeRate'] as num?)?.toDouble() ?? 0.0;
    final avgDeliveryTime = (data['avgDeliveryTime'] as num?)?.toDouble() ?? 0.0;
    final failedCount = (data['failedCount'] as num?)?.toInt() ?? 0;
    final fleetRating = (data['fleetRating'] as num?)?.toDouble() ?? 0.0;
    final trendList = (data['deliveryTrend'] as List?) ?? [];

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4 Key Metrics
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _MetricCard(
                title: 'On-Time Rate',
                value: '${onTimeRate.toStringAsFixed(1)}%',
                icon: Icons.timer_outlined,
                color: onTimeRate >= 90 ? AppColors.success : (onTimeRate >= 75 ? AppColors.warning : AppColors.error),
                trend: onTimeRate >= 95 ? '+2.5%' : null,
              ),
              _MetricCard(
                title: 'Avg Time',
                value: '${avgDeliveryTime.toStringAsFixed(0)} min',
                icon: Icons.schedule,
                color: AppColors.primary,
              ),
              _MetricCard(
                title: 'Fleet Rating',
                value: fleetRating.toStringAsFixed(1),
                icon: Icons.star_border,
                color: AppColors.warning,
              ),
              _MetricCard(
                title: 'Failed',
                value: failedCount.toString(),
                icon: Icons.error_outline,
                color: failedCount > 0 ? AppColors.error : AppColors.success,
              ),
            ],
          ),
          
          AppSpacing.gapH24,
          Text('Delivery Volume (Last 7 Days)', style: AppTextStyles.titleMedium),
          AppSpacing.gapH12,
          _DeliveryTrendChart(trendList: trendList),

          // Failure Reasons (Placeholder for now as we didn't implement aggregation yet)
          // We could list recent failures if we fetched them.
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              if (trend != null)
                Text(
                  trend!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}



class _DeliveryTrendChart extends StatelessWidget {
  final List trendList;

  const _DeliveryTrendChart({required this.trendList});

  @override
  Widget build(BuildContext context) {
    if (trendList.isEmpty) {
      return const Center(child: Text('No trend data available'));
    }

    // Parse trendList to FlSpot
    final spots = <FlSpot>[];
    double maxY = 0;
    
    for (int i = 0; i < trendList.length; i++) {
      final count = (trendList[i]['count'] as num).toDouble();
      if (count > maxY) maxY = count;
      spots.add(FlSpot(i.toDouble(), count));
    }
    
    maxY = (maxY * 1.2).ceilToDouble();
    if (maxY == 0) maxY = 5;

    return AspectRatio(
      aspectRatio: 1.7,
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.border,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < trendList.length) {
                      final dateStr = trendList[index]['date'];
                      if (dateStr == null) return const SizedBox.shrink();
                      final date = DateTime.tryParse(dateStr.toString());
                      if (date == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('E').format(date),
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (trendList.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
