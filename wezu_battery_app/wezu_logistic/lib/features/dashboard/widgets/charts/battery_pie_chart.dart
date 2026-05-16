import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../utils/formatters.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_styles.dart';
import '../../../../utils/app_haptics.dart';

class BatteryPieChart extends StatefulWidget {
  final List<dynamic> data; // List<PieChartDataPoint>
  final String title;

  const BatteryPieChart({
    super.key,
    required this.data,
    this.title = 'Battery Status',
  });

  @override
  State<BatteryPieChart> createState() => _BatteryPieChartState();
}

class _BatteryPieChartState extends State<BatteryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Center(
        child: Text('No data available', style: AppTextStyles.bodyMedium),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: Row(
            children: [
              const SizedBox(height: 18),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            final newIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                            
                            if (newIndex != touchedIndex && newIndex != -1) {
                              AppHaptics.selection();
                            }
                            touchedIndex = newIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 60, // Donut style
                      sections: _showingSections(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 28),
            ],
          ),
        ),
         // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.data.map((e) {
             final isTouched = widget.data.indexOf(e) == touchedIndex;
            return _Indicator(
              color: e.color,
              text: e.label,
              isSquare: false, // Circle indicators are more modern
              size: isTouched ? 18 : 16,
              textColor: isTouched 
                  ? Theme.of(context).textTheme.bodyLarge?.color 
                  : Theme.of(context).textTheme.bodyMedium?.color,
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _showingSections() {
    return List.generate(widget.data.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 30.0 : 25.0; // Thinner ring for donut
      // const shadows = [Shadow(color: Colors.black, blurRadius: 2)]; // Removed shadows
      final item = widget.data[i];

      return PieChartSectionData(
        color: item.color,
        value: item.value,
        title: '${(item.value as double).toInt()}',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
          // shadows: shadows,
        ),
      );
    });
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
            borderRadius: isSquare ? BorderRadius.circular(4) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
          ),
        )
      ],
    );
  }
}
