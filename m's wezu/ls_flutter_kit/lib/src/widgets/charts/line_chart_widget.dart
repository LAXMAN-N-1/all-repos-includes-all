import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartDataPoint {
  final double x;
  final double y;
  final String labelX;

  const LineChartDataPoint(this.x, this.y, this.labelX);
}

/// Dynamic, gradient filled line chart for admin dashboards.
class LineChartWidget extends StatelessWidget {
  final List<LineChartDataPoint> data;
  final Color? lineColor;
  final Color? gradientStartColor;
  final double maxY;
  final String leftAxisTitle;
  final String bottomAxisTitle;

  const LineChartWidget({
    super.key,
    required this.data,
    this.lineColor,
    this.gradientStartColor,
    required this.maxY,
    this.leftAxisTitle = '',
    this.bottomAxisTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No chart data available'));
    }

    final theme = Theme.of(context);
    final primaryColor = lineColor ?? theme.colorScheme.primary;
    final startGradColor = gradientStartColor ?? primaryColor.withOpacity(0.3);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5 > 0 ? maxY / 5 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.dividerColor,
              strokeWidth: 1,
              dashArray: [4, 4],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            axisNameWidget: bottomAxisTitle.isNotEmpty 
                ? Text(bottomAxisTitle, style: theme.textTheme.bodySmall) 
                : null,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final point = data.firstWhere((e) => e.x == value, orElse: () => const LineChartDataPoint(0, 0, ''));
                return SideTitleWidget(
                  meta: meta,
                  child: Text(point.labelX, style: theme.textTheme.labelSmall),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: leftAxisTitle.isNotEmpty 
                ? Text(leftAxisTitle, style: theme.textTheme.bodySmall) 
                : null,
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 5 > 0 ? maxY / 5 : 1,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(value.toInt().toString(), style: theme.textTheme.labelSmall),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: theme.dividerColor),
            left: BorderSide(color: theme.dividerColor),
          ),
        ),
        minX: data.first.x,
        maxX: data.last.x,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: data.map((e) => FlSpot(e.x, e.y)).toList(),
            isCurved: true,
            color: primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [startGradColor, primaryColor.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
