import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_styles.dart';
import '../../../../utils/app_haptics.dart';

class StationBarChart extends StatefulWidget {
  final List<dynamic> data; // List<CategoryValue>
  final String title;

  const StationBarChart({
    super.key,
    required this.data,
    this.title = 'Station Dispatch',
  });

  @override
  State<StationBarChart> createState() => _StationBarChartState();
}

class _StationBarChartState extends State<StationBarChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Center(
        child: Text('No data available', style: AppTextStyles.bodyMedium),
      );
    }

    double maxY = 0;
    if (widget.data.isNotEmpty) {
      maxY = widget.data.map((e) => e.value).reduce((a, b) => a > b ? a : b) as double;
    }
    double yMargin = maxY * 0.2;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.title, style: AppTextStyles.titleMedium),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.3,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      touchedIndex = -1;
                      return;
                    }
                    final newIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                    if (newIndex != touchedIndex && newIndex != -1) {
                      AppHaptics.selection();
                    }
                    touchedIndex = newIndex;
                  });
                },
                touchTooltipData: BarTouchTooltipData(
                   getTooltipColor: (_) => Theme.of(context).colorScheme.surfaceContainerHighest,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final category = widget.data[group.x.toInt()].category;
                    return BarTooltipItem(
                      '$category\n',
                      TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: (rod.toY).toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
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
                    getTitlesWidget: (value, meta) => _getTitles(value, meta, context),
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: _calculateInterval(maxY),
                    getTitlesWidget: (value, meta) => _leftTitles(value, meta, context),
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: widget.data.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.value,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 24, // Slightly wider for modern look
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY + yMargin, // Full height background track
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      ),
                    )
                  ],
                );
              }).toList(),
              maxY: maxY + yMargin,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                 horizontalInterval: _calculateInterval(maxY),
                 getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getTitles(double value, TitleMeta meta, BuildContext context) {
    if (value >= widget.data.length) return const SizedBox.shrink();
    
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text = widget.data[value.toInt()].category;
    // Truncate if too long
    if (text.length > 6) text = '${text.substring(0, 5)}...';

    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(text, style: style),
    );
  }
  
  Widget _leftTitles(double value, TitleMeta meta, BuildContext context) {
      if (value == meta.max) return const SizedBox.shrink(); // Hide top label if it clips
      final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 10,
      color: Theme.of(context).textTheme.labelSmall?.color?.withValues(alpha: 0.7),
    );
    return SideTitleWidget(
      meta: meta,
      child: Text(value.toInt().toString(), style: style),
    );
  }

    double _calculateInterval(double max) {
    if (max <= 0) return 1;
    double interval = max / 4;
    if (interval < 1) return 1;
    return interval;
  }
}
