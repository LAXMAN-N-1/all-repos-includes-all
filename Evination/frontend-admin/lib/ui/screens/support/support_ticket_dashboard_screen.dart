import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class SupportTicketDashboardScreen extends StatelessWidget {
  const SupportTicketDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // KPI Cards
            Row(
              children: [
                Expanded(child: _buildKpiCard('Open Tickets', '23', Colors.red, '↑ 3 vs YTD')),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('In Progress', '15', Colors.orange, '↓ 2 vs YTD')),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('Resolved (Mo)', '156', Colors.green, '↑ 12%')),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('Avg Response', '2.3h', Colors.blue, '↓ 0.5h')),
              ],
            ),
            const SizedBox(height: 24),

            // Toolbar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Support Tickets', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.add), label: const Text('Create Ticket'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white)),
              ],
            ),
            const SizedBox(height: 16),

            // Tickets List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == 0) return _buildTicketCard(
                  '#T-12345', 'Payment not received after event', 'Payment Issue',
                  'Rajesh Kumar', 'High', 'Open', Colors.red, '4h 15m remaining',
                );
                if (index == 1) return _buildTicketCard(
                   '#T-12344', 'How to change my event date?', 'General Inquiry',
                   'Priya Shah', 'Medium', 'In Progress', Colors.orange, '5h 45m remaining',
                );
                return _buildTicketCard(
                   '#T-12343', 'Vendor didn\'t show up', 'Service Complaint',
                   'Amit Verma', 'Critical', 'Overdue', Colors.red.shade900, 'SLA BREACHED',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, Color color, String sub) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTicketCard(String id, String subject, String cat, String user, String priority, String status, Color color, String sla) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$id • $priority Priority', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Category: $cat', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [const Icon(Icons.person, size: 16, color: Colors.grey), const SizedBox(width: 4), Text(user, style: const TextStyle(fontWeight: FontWeight.w500))]),
              Text(sla, style: TextStyle(color: sla.contains('BREACHED') ? Colors.red : Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: (){}, child: const Text('View Details')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: (){}, child: const Text('Add Response')),
            ],
          ),
        ],
      ),
    );
  }
}
