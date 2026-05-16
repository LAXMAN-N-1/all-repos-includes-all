import 'package:flutter/material.dart';

class AlertsPanel extends StatelessWidget {
  const AlertsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {'icon': '🔴', 'text': '5 Vendor applications pending approval (>3 days)'},
      {'icon': '🟡', 'text': '3 Disputes require immediate attention'},
      {'icon': '🟠', 'text': '12 Quotations awaiting admin review (>48 hours)'},
      {'icon': '🔵', 'text': '8 Customer refund requests pending'},
      {'icon': '🟢', 'text': 'Payment release due for 15 completed bookings'},
    ];

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
          const Row(
             children: [
               Icon(Icons.warning_amber_rounded, color: Colors.orange),
               SizedBox(width: 8),
               Text('ALERTS & ACTIONS REQUIRED', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
             ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = alerts[index];
              return Row(
                children: [
                  Text(item['icon'] as String, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item['text'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
