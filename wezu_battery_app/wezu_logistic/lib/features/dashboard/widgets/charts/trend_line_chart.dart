import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_styles.dart';

class TrendLineChart extends StatelessWidget {
  final List<dynamic> data; // List<TimePoint>
  final String title;
  final Color lineColor;
  final bool showPoints;

  const TrendLineChart({
    super.key,
    required this.data,
    required this.title,
    this.lineColor = AppColors.primary,
    this.showPoints = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text('No data available', style: AppTextStyles.bodyMedium),
      );
    }

    // Sort by date just in case
    data.sort((a, b) => a.date.compareTo(b.date));

    // Calculate Y min/max for better scaling
    double minY = data.map((e) => e.value).reduce((a, b) => a < b ? a : b) as double;
    double maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b) as double;
    double yMargin = (maxY - minY) * 0.2;
    if (yMargin == 0) yMargin = 10;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(title, style: AppTextStyles.titleMedium),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.70,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _calculateInterval(minY, maxY),
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    strokeWidth: 1,
                    dashArray: [4, 4], // Dashed line
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) => bottomTitleWidgets(value, meta, context),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => leftTitleWidgets(value, meta, context),
                    reservedSize: 42,
                    interval: _calculateInterval(minY, maxY),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false), // No border
              minX: 0,
              maxX: data.length.toDouble() - 1,
              minY: (minY - yMargin).clamp(0, double.infinity),
              maxY: maxY + yMargin,
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.value);
                  }).toList(),
                  isCurved: true,
                  curveSmoothness: 0.35,
                  gradient: LinearGradient(
                    colors: [
                      lineColor,
                      lineColor.withValues(alpha: 0.8),
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false), // Hide dots
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        lineColor.withValues(alpha: 0.2),
                        lineColor.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    if (value < 0 || value >= data.length) return const SizedBox.shrink();
    
    final date = data[value.toInt()].date;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 10,
      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
    );
    
    // Show only first, middle, last or limited labels if too many
    if (data.length > 7 && value % 2 != 0) return const SizedBox.shrink();

    return SideTitleWidget(
      meta: meta,
      child: Text(DateFormat('MM/dd').format(date), style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 10,
      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
    );
    String text;
    if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      text = value.toInt().toString();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  double _calculateInterval(double min, double max) {
    double range = max - min;
    if (range <= 0) return 1;
    double interval = range / 5;
    if (interval < 1) return 1;
    return interval; // Return raw interval, fl_chart handles rounding reasonably well or logic can be improved
  }
}
