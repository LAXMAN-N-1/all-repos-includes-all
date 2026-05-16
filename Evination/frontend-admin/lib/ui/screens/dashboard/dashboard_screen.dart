import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_theme.dart';
import 'widgets/key_metrics_card.dart';
import 'widgets/quick_stats_card.dart';
import 'widgets/dashboard_charts.dart';
import 'widgets/activity_feed_widget.dart';
import 'widgets/alerts_panel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              colors: [AppTheme.primary800, AppTheme.primary500],
            ).createShader(bounds),
            child: const Text(
              'Welcome back, Admin!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Text(
            "Overview of your platform's performance today.",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),

          // 1. Key Metrics Cards (Top Row)
          LayoutBuilder(
            builder: (context, constraints) {
              int cols = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
              double spacing = 16;
              double width = (constraints.maxWidth - (cols - 1) * spacing) / cols;
              width = width.floorToDouble(); // Avoid pixel snap issues

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: width,
                    child: const KeyMetricsCard(
                      title: 'Total Revenue',
                      value: '₹12,45,670', // Hardcoded from user req
                      subValue: 'Today',
                      icon: Icons.attach_money,
                      color: Colors.green,
                      trend: '12% vs ytd',
                      isPositive: true,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: const KeyMetricsCard(
                      title: 'New Requests',
                      value: '23',
                      subValue: 'Pending Review',
                      icon: Icons.new_releases,
                      color: Colors.blue,
                      trend: '5% vs ytd',
                      isPositive: false,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: const KeyMetricsCard(
                      title: 'Active Bookings',
                      value: '156',
                      subValue: 'Ongoing/Upcoming',
                      icon: Icons.calendar_today,
                      color: Colors.orange,
                      trend: '8% vs ytd',
                      isPositive: true,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: const KeyMetricsCard(
                      title: 'Pending Approvals',
                      value: '17', // 5 Vendors + 12 Customers
                      subValue: 'Vendors: 5',
                      subValue2: 'Customers: 12',
                      icon: Icons.pending_actions,
                      color: Colors.amber,
                      trend: 'Stable',
                      isPositive: true,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 2. Quick Stats (Second Row)
          LayoutBuilder(
            builder: (context, constraints) {
              int cols = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
              double spacing = 16;
              double width = (constraints.maxWidth - (cols - 1) * spacing) / cols;
              width = width.floorToDouble();

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(width: width, child: const QuickStatsCard(title: 'Total Vendors', value: '1,234', subTitle: 'Active', subValue: '1,180', subTitle2: 'Suspended', subValue2: '31')),
                  SizedBox(width: width, child: const QuickStatsCard(title: 'Total Customers', value: '5,678', subTitle: 'New This Month', subValue: '+45', subTitle2: 'Active', subValue2: '4,200')),
                  SizedBox(width: width, child: const QuickStatsCard(title: 'Quotations', value: 'Pending: 45', subTitle: 'Created Today', subValue: '89', subTitle2: 'Accepted', subValue2: '12')),
                  SizedBox(width: width, child: const QuickStatsCard(title: 'Disputes', value: 'Open: 3', subTitle: 'Resolved', subValue: '127', subTitle2: 'Escalated', subValue2: '0')),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 3. Charts Section
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1200) {
                 return const Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Expanded(child: RevenueTrendChart()),
                     SizedBox(width: 24),
                     Expanded(child: CategoryPieChart()),
                   ],
                 );
              } else {
                return const Column(
                  children: [
                    RevenueTrendChart(),
                    SizedBox(height: 24),
                    CategoryPieChart(),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),
          
          LayoutBuilder(
             builder: (context, constraints) {
               if (constraints.maxWidth > 1200) {
                 return const Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Expanded(child: VendorPerformanceChart()),
                     SizedBox(width: 24),
                     Expanded(child: CustomerSatisfactionWidget()),
                   ],
                 );
               } else {
                 return const Column(
                   children: [
                     VendorPerformanceChart(),
                     SizedBox(height: 24),
                     CustomerSatisfactionWidget(),
                   ],
                 );
               }
             },
           ),
           const SizedBox(height: 24),

           // 4. Activity & Alerts
           LayoutBuilder(
             builder: (context, constraints) {
               if (constraints.maxWidth > 1200) {
                 return const Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Expanded(child: ActivityFeedWidget()),
                     SizedBox(width: 24),
                     Expanded(child: AlertsPanel()),
                   ],
                 );
               } else {
                 return const Column(
                   children: [
                     ActivityFeedWidget(),
                     SizedBox(height: 24),
                     AlertsPanel(),
                   ],
                 );
               }
             },
           ),
           const SizedBox(height: 24),

           // Quick Actions
           Wrap(
             spacing: 16,
             children: [
               ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('New Vendor')),
               ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add_circle_outline), label: const Text('Add Category')),
               OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.bar_chart), label: const Text('View Reports')),
               OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.settings), label: const Text('Settings')),
             ],
           ),
        ],
      ),
    );
  }
}

