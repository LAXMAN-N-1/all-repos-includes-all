import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_app/logic/providers/vendor_bidding_provider.dart';
import 'package:vendor_app/data/models/notification_model.dart';
import '../leads/bid_submission_screen.dart'; // Ensure this import exists or relative path
import 'package:lucide_icons/lucide_icons.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppTheme.emeraldGreen, AppTheme.mintWhisper],
            ).createShader(bounds),
            child: const Text(
              'Welcome back, Vendor!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Text(
            "Manage your events, bids, and earnings in one place.",
            style: TextStyle(color: AppTheme.gray600, fontSize: 16),
          ),
          const SizedBox(height: 24),
          
          // Stats Grid
          _buildStatsGrid(context),
          const SizedBox(height: 24),

          // Charts Row 1
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                 return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildRevenueChart(context)),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildEventStatusChart(context)),
                  ],
                );
              } else {
                 return Column(
                  children: [
                    _buildRevenueChart(context),
                    const SizedBox(height: 24),
                    _buildEventStatusChart(context),
                  ],
                 );
              }
            },
          ),
          const SizedBox(height: 24),

          // Charts Row 2 & Lists
           LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1100) {
                 return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildBookingTrendChart(context)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildCategoryPieChart(context)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildUpcomingEvents(context)),
                  ],
                );
              } else {
                 return Column(
                  children: [
                    _buildBookingTrendChart(context),
                    const SizedBox(height: 24),
                    _buildCategoryPieChart(context),
                    const SizedBox(height: 24),
                    _buildUpcomingEvents(context),
                  ],
                 );
              }
            },
          ),
          const SizedBox(height: 24),
          
          // Top Vendors & Quick Actions
          _buildTopVendors(context),
          const SizedBox(height: 24),
          _buildQuickActions(context),
        ],
      ),
    );
  }



  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      {'title': 'Total Orders', 'value': '124', 'change': '+15%', 'icon': Icons.shopping_bag_outlined, 'color': AppTheme.emeraldGreen},
      {'title': 'Active Bids', 'value': '12', 'change': '+5%', 'icon': Icons.gavel_outlined, 'color': AppTheme.info},
      {'title': 'Total Earnings', 'value': '₹8.4L', 'change': '+22%', 'icon': Icons.account_balance_wallet_outlined, 'color': AppTheme.success},
      {'title': 'Avg. Rating', 'value': '4.8', 'change': 'Top 5%', 'icon': Icons.star_border, 'color': AppTheme.warning},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 600) crossAxisCount = 1;
        else if (constraints.maxWidth < 1000) crossAxisCount = 2;

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: stats.map((stat) {
             double width = (constraints.maxWidth - (crossAxisCount - 1) * 24) / crossAxisCount;
             // Fix for slight rounding errors causing overflow
             width = width.floorToDouble();
             
             return SizedBox(
              width: width,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                   boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(stat['title'] as String, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(stat['icon'] as IconData, color: (stat['color'] as Color?) ?? AppTheme.emeraldGreen, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(stat['value'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      '${stat['change']} from last month',
                      style: TextStyle(
                        color: (stat['change'] as String).startsWith('+') ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
             );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
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
          const Text('Earnings Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        if (value.toInt() >= 0 && value.toInt() < titles.length) {
                           return Padding(padding: const EdgeInsets.only(top: 8), child: Text(titles[value.toInt()], style: TextStyle(fontSize: 12, color: AppTheme.gray400)));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1.2),
                      FlSpot(1, 1.8),
                      FlSpot(2, 1.5),
                      FlSpot(3, 2.2),
                      FlSpot(4, 2.1),
                      FlSpot(5, 2.6),
                    ],
                    isCurved: true,
                    color: AppTheme.emeraldGreen,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                       color: AppTheme.emeraldGreen.withOpacity(0.1),
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

  Widget _buildEventStatusChart(BuildContext context) {
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
           const Text('Order Fulfillment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
           const SizedBox(height: 24),
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
                          const titles = ['UPC', 'ONG', 'COM', 'CAN'];
                          if (value.toInt() >= 0 && value.toInt() < titles.length) {
                             return Padding(padding: const EdgeInsets.only(top: 8), child: Text(titles[value.toInt()], style: TextStyle(fontSize: 12, color: AppTheme.gray600)));
                          }
                          return const Text('');
                        },
                     ),
                   ),
                 ),
                 borderData: FlBorderData(show: false),
                 barGroups: [
                   BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 12, color: AppTheme.info, width: 24)]),
                   BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: AppTheme.emeraldGreen, width: 24)]),
                   BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 45, color: AppTheme.success, width: 24)]),
                   BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 3, color: AppTheme.error, width: 24)]),
                 ],
               ),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildBookingTrendChart(BuildContext context) {
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
            const Text('Booking Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: const FlTitlesData(show: false), // Simplified for brevity
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 18), FlSpot(1, 22), FlSpot(2, 19), FlSpot(3, 28), FlSpot(4, 24), FlSpot(5, 31)
                      ],
                      isCurved: true,
                      color: AppTheme.emeraldGreen,
                      barWidth: 4,
                    ),
                  ],
                ),
              ),
            ),
         ],
       ),
    );
  }
  
  Widget _buildCategoryPieChart(BuildContext context) {
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
            const Text('Revenue by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(color: AppTheme.darkEvergreen, value: 44, title: '44%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 12)),
                    PieChartSectionData(color: AppTheme.emeraldGreen, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 12)),
                    PieChartSectionData(color: AppTheme.mintWhisper, value: 15, title: '15%', radius: 50, titleStyle: const TextStyle(color: AppTheme.gray900, fontSize: 12)),
                    PieChartSectionData(color: AppTheme.gray300, value: 11, title: '11%', radius: 50, titleStyle: const TextStyle(color: AppTheme.gray700, fontSize: 12)),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
         ],
       ),
     );
  }

  Widget _buildUpcomingEvents(BuildContext context) {
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
          const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildEventItem(context, 'Wedding Decor - Grand Hyatt', 'Decoration', 'Dec 15', AppTheme.success),
                _buildEventItem(context, 'Catering - Tech Summit', 'Catering', 'Dec 18', AppTheme.warning),
                _buildEventItem(context, 'DJ - Corporate Gala', 'Music', 'Dec 20', AppTheme.success),
                 _buildEventItem(context, 'Photo - Birthday Bash', 'Photography', 'Dec 22', AppTheme.success),
              ],
            ),
          ),
          InkWell(
            onTap: () => context.push('/vendor/orders/dashboard'),
            child: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text('View All Orders →', style: TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, String title, String type, String date, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              Text('$type • $date', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(statusColor == AppTheme.success ? 'Confirmed' : 'Action Required', style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopVendors(BuildContext context) {
     return Container(
       padding: const EdgeInsets.all(24),
       decoration: BoxDecoration(
         color: Theme.of(context).cardColor,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Theme.of(context).dividerColor),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text('Top Performing Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
           const SizedBox(height: 16),
           LayoutBuilder(
             builder: (context, constraints) {
               double itemWidth = 200;
               if (constraints.maxWidth > 500) itemWidth = (constraints.maxWidth - 4 * 16) / 5;
               if (itemWidth < 150) itemWidth = constraints.maxWidth; 
               
               return Wrap(
                 spacing: 16,
                 runSpacing: 16,
                 children: [
                   {'name': 'Decoration', 'val': '4.8L'},
                   {'name': 'Catering', 'val': '2.2L'},
                   {'name': 'Staging', 'val': '1.4L'},
                 ].map((v) {
                   return Container(
                     width: itemWidth,
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: Theme.of(context).cardColor,
                       border: Border.all(color: Theme.of(context).dividerColor),
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(v['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                         const SizedBox(height: 8),
                         Text('₹${v['val']}', style: const TextStyle(fontSize: 20, color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
                         const Text('Revenue', style: TextStyle(color: Colors.grey, fontSize: 12)),
                       ],
                     ),
                   );
                 }).toList(),
               );
             },
           ),
         ],
       ),
     );
  }

  Widget _buildQuickActions(BuildContext context) {
    // Similar to top stats but just clickable buttons
    return const SizedBox(); // Placeholder as it's just links
  }
}
