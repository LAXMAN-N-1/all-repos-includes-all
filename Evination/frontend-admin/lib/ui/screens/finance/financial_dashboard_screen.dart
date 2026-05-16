import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class FinancialDashboardScreen extends StatelessWidget {
  const FinancialDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Financial Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Overview of platform revenue and cash flow', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.calendar_today, size: 16), label: const Text('Feb 2024')),
              ],
            ),
            const SizedBox(height: 24),

            // Key Metrics
            Row(
              children: [
                _buildFinanceMetric('Total Revenue', '₹1.45 Cr', '+15%', Colors.blue),
                const SizedBox(width: 16),
                _buildFinanceMetric('Platform Revenue', '₹23.7 L', '+12%', Colors.green),
                const SizedBox(width: 16),
                _buildFinanceMetric('Vendor Payouts', '₹1.15 Cr', '+16%', Colors.orange),
                const SizedBox(width: 16),
                 _buildFinanceMetric('Profit Margin', '12.8%', '+0.8%', Colors.purple),
              ],
            ),
            const SizedBox(height: 24),

            // Charts Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildChartSection('Revenue Trend', 'Line Chart')),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildChartSection('Payment Status', 'Donut Chart')),
              ],
            ),
            const SizedBox(height: 24),

            // Cash Flow Summary
            _buildCashFlowCard(),
            const SizedBox(height: 24),

            // Alerts
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alerts & Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildAlertItem(Icons.warning, '15 vendor payouts due today (₹12.5 L)', 'Process Now', Colors.red),
                  _buildAlertItem(Icons.error_outline, '8 failed payments need retry', 'Retry', Colors.orange),
                  _buildAlertItem(Icons.info_outline, 'GST filing due in 5 days', 'Prepare', Colors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildFinanceMetric(String title, String value, String trend, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text('$trend MoM', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(String title, String placeholder) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Center(child: Text(placeholder))),
        ],
      ),
    );
  }

  Widget _buildCashFlowCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cash Flow Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          Row(
            children: [
               Expanded(child: _buildFlowItem('Inflows', '₹1.44 Cr', Colors.green)),
               Container(width: 1, height: 60, color: Colors.grey[300]),
               Expanded(child: _buildFlowItem('Outflows', '₹1.20 Cr', Colors.red)),
               Container(width: 1, height: 60, color: Colors.grey[300]),
               Expanded(child: _buildFlowItem('Net Cash Flow', '+ ₹23.7 L', Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlowItem(String label, String value, Color color) {
    return Column(
      children: [
         Text(label, style: const TextStyle(color: Colors.grey)),
         const SizedBox(height: 8),
         Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildAlertItem(IconData icon, String msg, String action, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(msg)),
          TextButton(onPressed: (){}, child: Text(action)),
        ],
      ),
    );
  }
}
