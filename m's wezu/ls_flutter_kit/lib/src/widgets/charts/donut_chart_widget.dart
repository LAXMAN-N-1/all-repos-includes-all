import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutChartData {
  final String label;
  final double value;
  final Color color;

  const DonutChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

/// A stylish donut chart with a custom interactive legend.
class DonutChartWidget extends StatefulWidget {
  final List<DonutChartData> data;
  final double centerRadius;
  final double strokeWidth;

  const DonutChartWidget({
    super.key,
    required this.data,
    this.centerRadius = 60,
    this.strokeWidth = 30,
  });

  @override
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const Center(child: Text('No data'));

    final totalValue = widget.data.fold<double>(0, (sum, item) => sum + item.value);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: widget.centerRadius,
              sections: widget.data.asMap().entries.map((entry) {
                final isTouched = entry.key == _touchedIndex;
                final data = entry.value;
                return PieChartSectionData(
                  color: data.color,
                  value: data.value,
                  title: isTouched ? '${((data.value / totalValue) * 100).toStringAsFixed(1)}%' : '',
                  radius: isTouched ? widget.strokeWidth + 10 : widget.strokeWidth,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Interactive custom legend Below
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: widget.data.asMap().entries.map((entry) {
            final isTouched = entry.key == _touchedIndex;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: entry.value.color,
                    shape: BoxShape.circle,
                    border: isTouched ? Border.all(color: Colors.black, width: 2) : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.value.label,
                  style: TextStyle(
                    fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
