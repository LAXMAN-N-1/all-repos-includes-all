import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_billing.dart';
import 'package:google_fonts/google_fonts.dart';

class RevenueAnalyticsScreen extends StatelessWidget {
  const RevenueAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Revenue Analytics", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text("Financial performance and growth metrics.", style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 32),

          // Top KPIs
          Row(
            children: [
              _buildSummaryCard("Total ARR", "\$1.2M", "+14.2%", true),
              const SizedBox(width: 24),
              _buildSummaryCard("Avg. Revenue / User", "\$45.20", "+2.1%", true),
              const SizedBox(width: 24),
              _buildSummaryCard("Churn Revenue", "\$2,400", "-5%", true), // Negative churn is good
            ],
          ),
          const SizedBox(height: 32),

          // Main Chart
          Container(
            height: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AuraColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AuraColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Revenue vs Expenses (Last 6 Months)", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: "6 Months",
                      dropdownColor: AuraColors.surface,
                      items: ["6 Months", "1 Year"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (_){},
                      underline: Container(),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: mockRevenueChart.map((data) => _buildBarPair(data)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String percentage, bool isPositive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AuraColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AuraColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(value, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(percentage, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarPair(RevenueDataPoint data) {
    final double maxRevenue = 70000;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Revenue Bar
            _buildBar(data.revenue, maxRevenue, AuraColors.primary),
            const SizedBox(width: 8),
            // Expense Bar
            _buildBar(data.expenses, maxRevenue, Colors.redAccent),
          ],
        ),
        const SizedBox(height: 12),
        Text(data.month, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildBar(double value, double max, Color color) {
    return Tooltip(
      message: "\$${value.toStringAsFixed(0)}",
      child: Container(
        width: 20,
        height: (value / max) * 250, // Scale height
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
    );
  }
}
