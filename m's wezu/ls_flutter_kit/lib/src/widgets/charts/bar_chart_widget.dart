import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartDataPoint {
  final int x;
  final double y;
  final String label;

  const BarChartDataPoint(this.x, this.y, this.label);
}

/// A clean, rounded bar chart for reporting.
class BarChartWidget extends StatelessWidget {
  final List<BarChartDataPoint> data;
  final double maxY;
  final Color? barColor;
  final double barWidth;

  const BarChartWidget({
    super.key,
    required this.data,
    required this.maxY,
    this.barColor,
    this.barWidth = 14,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('No data'));
    
    final theme = Theme.of(context);
    final color = barColor ?? theme.colorScheme.primary;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.round().toString(),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final point = data.firstWhere((p) => p.x == value.toInt(), orElse: () => const BarChartDataPoint(0, 0, ''));
                return SideTitleWidget(
                  meta: meta,
                  child: Text(point.label, style: theme.textTheme.labelSmall),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(value.toInt().toString(), style: theme.textTheme.labelSmall),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.dividerColor,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.map((point) {
          return BarChartGroupData(
            x: point.x,
            barRods: [
              BarChartRodData(
                toY: point.y,
                color: color,
                width: barWidth,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
