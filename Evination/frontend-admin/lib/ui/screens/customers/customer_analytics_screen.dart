import 'package:flutter/material.dart';


class CustomerAnalyticsScreen extends StatelessWidget {
  const CustomerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Customer Analytics'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OutlinedButton.icon(
              onPressed: (){}, 
              icon: const Icon(Icons.calendar_today, size: 16), 
              label: const Text('Last 30 Days'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Top Metrics
            Row(
              children: [
                _buildMetricCard('New Customers', '234', '+12%', Colors.blue),
                const SizedBox(width: 16),
                _buildMetricCard('Retention Rate', '78%', '-2%', Colors.amber),
                const SizedBox(width: 16),
                _buildMetricCard('Avg. CLV', '₹8.5L', '+5%', Colors.green),
              ],
            ),
            const SizedBox(height: 24),

            // Charts Row 1
            Row(
              children: [
                Expanded(child: _buildChartCard('Customer Acquisition', 'Line Chart Placeholder')),
                const SizedBox(width: 24),
                Expanded(child: _buildChartCard('Customer Segments', 'Pie Chart Placeholder')),
              ],
            ),
            const SizedBox(height: 24),
            
            // Charts Row 2
             Row(
              children: [
                Expanded(child: _buildChartCard('Geographic Distribution', 'Map Placeholder')),
                const SizedBox(width: 24),
                Expanded(child: _buildChartCard('Satisfaction Scores', 'Bar Chart Placeholder')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String trend, Color color) {
    final isPositive = trend.startsWith('+');
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text(trend, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: 0.7, minHeight: 4, color: color, backgroundColor: color.withOpacity(0.1)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, String placeholder) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              alignment: Alignment.center,
              child: Text(placeholder, style: TextStyle(color: Colors.grey[400])),
            ),
          ),
        ],
      ),
    );
  }
}
