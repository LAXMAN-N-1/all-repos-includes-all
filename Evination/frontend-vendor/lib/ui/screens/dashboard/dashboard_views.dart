import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

// ==============================================================================
// SUPER ADMIN DASHBOARD
// ==============================================================================
class SuperAdminDashboard extends StatelessWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildWelcomeHeader(
          "Welcome back, Super Admin!", 
          "Here is your platform-wide overview."
        ),
        const SizedBox(height: 32),
        _buildStatsGrid(context, [
          _StatData("Total Events", "156", "+12%", Icons.calendar_today_rounded, AppTheme.primaryGold),
          _StatData("Active Vendors", "89", "+8%", Icons.storefront_rounded, Colors.orange),
          _StatData("Total Revenue", "₹2.84Cr", "+18%", Icons.trending_up_rounded, Colors.green),
          _StatData("Pending Bids", "24", "-5%", Icons.gavel_rounded, Colors.red, isNegative: true),
          _StatData("Active Bookings", "45", "+22%", Icons.schedule_rounded, Colors.amber),
          _StatData("Avg Event Value", "₹1.82L", "+9%", Icons.donut_large_rounded, Colors.amber),
          _StatData("Conversion Rate", "68%", "+4%", Icons.pie_chart_rounded, Colors.teal),
          _StatData("Completed Events", "128", "+15%", Icons.check_circle_outline_rounded, Colors.amber),
        ]),
        const SizedBox(height: 32),
        _buildQuickActions(context, [
          _ActionData("Create Event", Icons.add_circle_outline),
          _ActionData("Add User", Icons.person_add_outlined),
          _ActionData("Add Branch", Icons.domain_add),
          _ActionData("Reports", Icons.bar_chart),
          _ActionData("Approve Vendors", Icons.verified_user_outlined),
        ]),
        const SizedBox(height: 32),
        _buildChartsRow(context, "Revenue Trend (Platform)", "Event Status Distribution"),
      ],
    );
  }
}

// ==============================================================================
// EVENT MANAGER DASHBOARD
// ==============================================================================
class EventManagerDashboard extends StatelessWidget {
  const EventManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildWelcomeHeader(
          "Welcome, Event Manager!", 
          "Here are your assigned events and tasks."
        ),
        const SizedBox(height: 32),
        _buildStatsGrid(context, [
          _StatData("My Events", "12", "Active", Icons.event, Colors.blue),
          _StatData("My Pending Bids", "5", "Action Req", Icons.gavel, Colors.orange),
          _StatData("My Active Bookings", "8", "+2 this week", Icons.bookmark_added, Colors.teal),
          _StatData("Branch Revenue", "₹45L", "+5%", Icons.attach_money, Colors.green),
        ]),
        const SizedBox(height: 32),
         _buildQuickActions(context, [
          _ActionData("Create Event", Icons.add_circle_outline),
          _ActionData("My Events", Icons.list_alt),
          _ActionData("Review Bids", Icons.gavel),
        ]),
        const SizedBox(height: 32),
        // Custom Charts for Event Manager
         SizedBox(
          height: 350,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text('My Events Timeline', style: AppTheme.heading.copyWith(fontSize: 18)),
                 const SizedBox(height: 24),
                 Expanded(
                   child: LineChart(
                     LineChartData(
                       gridData: const FlGridData(show: true),
                       titlesData: const FlTitlesData(show: false),
                       borderData: FlBorderData(show: false),
                       lineBarsData: [
                         LineChartBarData(
                           spots: const [FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 5), FlSpot(4, 4)],
                           color: Colors.blue,
                           barWidth: 3,
                           isCurved: true,
                           belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                         ),
                       ],
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
}

// ==============================================================================
// VENDOR COORDINATOR DASHBOARD
// ==============================================================================
class VendorCoordinatorDashboard extends StatelessWidget {
  const VendorCoordinatorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildWelcomeHeader(
          "Vendor Coordinator Panel", 
          "Manage vendor onboarding and performance."
        ),
        const SizedBox(height: 32),
        _buildStatsGrid(context, [
          _StatData("Total Vendors", "120", "+10", Icons.store, Colors.amber),
          _StatData("Pending Verification", "15", "Urgent", Icons.pending_actions, Colors.red),
          _StatData("Active Vendors", "98", "Verified", Icons.verified, Colors.green),
          _StatData("Avg Vendor Rating", "4.5", "★", Icons.star, AppTheme.primaryGold),
        ]),
        const SizedBox(height: 32),
        _buildQuickActions(context, [
          _ActionData("Add Vendor", Icons.storefront),
          _ActionData("Review Pending", Icons.rate_review),
          _ActionData("Vendor Performance", Icons.insights),
        ]),
        const SizedBox(height: 32),
        _buildChartsRow(context, "Vendor Onboarding Trend", "Category Distribution"),
      ],
    );
  }
}

// ==============================================================================
// FINANCE MANAGER DASHBOARD
// ==============================================================================
class FinanceManagerDashboard extends StatelessWidget {
  const FinanceManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildWelcomeHeader(
          "Finance Dashboard", 
          "Track revenue, invoices, and payments."
        ),
        const SizedBox(height: 32),
        _buildStatsGrid(context, [
          _StatData("Total Revenue", "₹5.2Cr", "+8%", Icons.account_balance_wallet, Colors.green),
          _StatData("Outstanding", "₹12L", "Pending", Icons.warning_amber, Colors.red),
          _StatData("Processed (Month)", "₹45L", "Cleared", Icons.check_circle, Colors.teal),
          _StatData("Pending Invoices", "8", "Action Req", Icons.receipt_long, Colors.orange),
        ]),
        const SizedBox(height: 32),
        _buildQuickActions(context, [
          _ActionData("Generate Invoice", Icons.receipt),
          _ActionData("Process Payment", Icons.payment),
          _ActionData("Transaction Reports", Icons.summarize),
        ]),
        const SizedBox(height: 32),
        _buildChartsRow(context, "Payment Collection Trend", "Revenue by Method"),
      ],
    );
  }
}


// ==============================================================================
// SHARED WIDGETS & HELPERS
// ==============================================================================

Widget _buildWelcomeHeader(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTheme.heading),
      const SizedBox(height: 8),
      Text(subtitle, style: AppTheme.subHeading),
    ],
  );
}

Widget _buildStatsGrid(BuildContext context, List<_StatData> stats) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final double width = constraints.maxWidth;
      int crossAxisCount = width > 1100 ? 4 : (width > 700 ? 2 : 1);
      double childAspectRatio = width > 1100 ? 1.4 : 1.6;
      
      return GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: childAspectRatio,
        children: stats.map((stat) => _StatsCard(data: stat)).toList(),
      );
    },
  );
}

Widget _buildQuickActions(BuildContext context, List<_ActionData> actions) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: AppTheme.cardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: AppTheme.heading.copyWith(fontSize: 18)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: actions.map((action) => ElevatedButton.icon(
            onPressed: () {}, 
            icon: Icon(action.icon, size: 18),
            label: Text(action.label),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )).toList(),
        ),
      ],
    ),
  );
}

Widget _buildChartsRow(BuildContext context, String chart1Title, String chart2Title) {
  return SizedBox(
    height: 350,
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(chart1Title, style: AppTheme.heading.copyWith(fontSize: 18)),
                 const SizedBox(height: 24),
                 Expanded(
                   child: LineChart(
                     LineChartData(
                       gridData: const FlGridData(show: true, drawVerticalLine: false),
                       titlesData: const FlTitlesData(
                         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                       ),
                       borderData: FlBorderData(show: false),
                       lineBarsData: [
                         LineChartBarData(
                           spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5), FlSpot(4, 4), FlSpot(5, 6)],
                           color: AppTheme.primaryGold,
                           barWidth: 4,
                           isCurved: true,
                           dotData: const FlDotData(show: false),
                           belowBarData: BarAreaData(show: true, color: AppTheme.primaryGold.withOpacity(0.1)),
                         ),
                       ],
                     ),
                   ),
                 ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(chart2Title, style: AppTheme.heading.copyWith(fontSize: 18)),
                 const SizedBox(height: 24),
                 Expanded(
                   child: PieChart(
                     PieChartData(
                       sectionsSpace: 0,
                       centerSpaceRadius: 40,
                       sections: [
                         PieChartSectionData(color: Colors.green, value: 40, showTitle: false, radius: 25),
                         PieChartSectionData(color: Colors.blue, value: 30, showTitle: false, radius: 25),
                         PieChartSectionData(color: Colors.orange, value: 15, showTitle: false, radius: 25),
                          PieChartSectionData(color: Colors.red, value: 15, showTitle: false, radius: 25),
                       ],
                     ),
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

class _StatData {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final bool isNegative;
  _StatData(this.title, this.value, this.change, this.icon, this.color, {this.isNegative = false});
}

class _ActionData {
  final String label;
  final IconData icon;
  _ActionData(this.label, this.icon);
}

class _StatsCard extends StatelessWidget {
  final _StatData data;
  const _StatsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(data.title, style: AppTheme.subHeading.copyWith(fontSize: 14), overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.color, size: 24),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.value, style: AppTheme.heading.copyWith(fontSize: 28)),
              const SizedBox(height: 4),
              Text(data.change, style: TextStyle(color: data.isNegative ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
