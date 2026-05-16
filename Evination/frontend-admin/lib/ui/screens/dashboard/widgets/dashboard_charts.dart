import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../theme/app_theme.dart';

class RevenueTrendChart extends StatelessWidget {
  const RevenueTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('REVENUE TREND (Last 30 Days)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Peak: ₹8.5L on 5th Feb | Avg: ₹4.2L/day', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['1 Feb', '5 Feb', '10 Feb', '15 Feb', '20 Feb', '25 Feb'];
                        if (value.toInt() >= 0 && value.toInt() < titles.length) {
                           return Padding(padding: const EdgeInsets.only(top: 8), child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)));
                        }
                        return const Text('');
                      },
                      interval: 1,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 4.0), FlSpot(1, 8.5), FlSpot(2, 5.2), FlSpot(3, 3.8), FlSpot(4, 6.1), FlSpot(5, 4.5)
                    ],
                    isCurved: true,
                    color: AppTheme.primary500,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary500.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BOOKINGS BY CATEGORY', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(color: AppTheme.primary600, value: 45, radius: 40, showTitle: false),
                        PieChartSectionData(color: Colors.blue[400], value: 25, radius: 40, showTitle: false),
                        PieChartSectionData(color: Colors.amber[400], value: 15, radius: 40, showTitle: false),
                        PieChartSectionData(color: Colors.grey[400], value: 15, radius: 40, showTitle: false),
                      ],
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(AppTheme.primary600, 'Weddings (45%)'),
                    _buildLegendItem(Colors.blue[400]!, 'Corporate (25%)'),
                    _buildLegendItem(Colors.amber[400]!, 'Birthdays (15%)'),
                    _buildLegendItem(Colors.grey[400]!, 'Others (15%)'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class VendorPerformanceChart extends StatelessWidget {
  const VendorPerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VENDOR PERFORMANCE (Top 5)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['ABC', 'XYZ', 'Roy.', 'Dre.', 'Elite'];
                        if (value.toInt() >= 0 && value.toInt() < titles.length) {
                           return Padding(padding: const EdgeInsets.only(top: 8), child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 10)));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 45, color: Colors.blue, width: 16)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 38, color: Colors.blue[400], width: 16)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 32, color: Colors.blue[300], width: 16)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 28, color: Colors.blue[200], width: 16)]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 25, color: Colors.blue[100], width: 16)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerSatisfactionWidget extends StatelessWidget {
  const CustomerSatisfactionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
       height: 300,
       padding: const EdgeInsets.all(24),
       decoration: BoxDecoration(
         color: Theme.of(context).cardColor,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Theme.of(context).dividerColor),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text('CUSTOMER SATISFACTION', style: TextStyle(fontWeight: FontWeight.bold)),
           const SizedBox(height: 24),
           Center(
             child: Column(
               children: [
                 const Text('4.7', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.amber)),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 24)),
                 ),
                 const SizedBox(height: 24),
                 _buildRatingRow('Service', '4.8'),
                 _buildRatingRow('Value', '4.5'),
               ],
             ),
           ),
         ],
       ),
    );
  }

  Widget _buildRatingRow(String label, String rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
