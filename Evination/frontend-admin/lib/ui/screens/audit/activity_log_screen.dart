import 'package:flutter/material.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light bg
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // KPI Bar
             Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  Expanded(child: _buildStat('Total Activities', '2,456')),
                  Expanded(child: _buildStat('Admin Actions', '456', color: Colors.blue)),
                  Expanded(child: _buildStat('System Events', '1,234')),
                  Expanded(child: _buildStat('Critical Events', '3', color: Colors.red)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: DropdownButtonFormField(items: const [DropdownMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days'))], value: 'Last 7 Days', onChanged: (v){}, decoration: const InputDecoration(labelText: 'Date Range', border: OutlineInputBorder()))),
                      const SizedBox(width: 16),
                      Expanded(child: DropdownButtonFormField(items: const [DropdownMenuItem(value: 'All', child: Text('All Severities'))], value: 'All', onChanged: (v){}, decoration: const InputDecoration(labelText: 'Severity', border: OutlineInputBorder()))),
                      const SizedBox(width: 16),
                      Expanded(child: DropdownButtonFormField(items: const [DropdownMenuItem(value: 'All', child: Text('All Users'))], value: 'All', onChanged: (v){}, decoration: const InputDecoration(labelText: 'User', border: OutlineInputBorder()))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logs List
            _buildLogEntry(
              'CRITICAL', 'Vendor Account Suspended', '5 mins ago',
              'Vendor account suspended for Elite Decorators (VND-1238) due to multiple complaints.',
              'Admin Manager (Priya Shah)', 'Vendor Mgmt', Colors.red
            ),
             const SizedBox(height: 16),
            _buildLogEntry(
              'WARNING', 'Commission Rate Changed', '20 mins ago',
              'Commission rate modified for ABC Events. Changed from 15% to 12%.',
              'Super Admin (Rajesh)', 'Finance', Colors.orange
            ),
             const SizedBox(height: 16),
            _buildLogEntry(
              'INFO', 'Support Ticket Resolved', '35 mins ago',
              'Ticket #T-12345 marked as resolved. Resolution Time: 3h 45m.',
              'Support Mgr (Karthik)', 'Support', Colors.blue
            ),
             const SizedBox(height: 16),
            _buildLogEntry(
              'INFO', 'Vendor Payout Processed', '50 mins ago',
              'Payout #PAY-67890 of ₹2,89,248 processed for ABC Events.',
              'Finance Mgr (Amit)', 'Finance', Colors.green
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildLogEntry(String type, String title, String time, String details, String user, String module, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4), right: BorderSide(color: Colors.grey.shade200), top: BorderSide(color: Colors.grey.shade200), bottom: BorderSide(color: Colors.grey.shade200))
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(type, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 12),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(details),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(user, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.view_module, size: 14, color: Colors.grey[600]),
               const SizedBox(width: 4),
              Text(module, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}
