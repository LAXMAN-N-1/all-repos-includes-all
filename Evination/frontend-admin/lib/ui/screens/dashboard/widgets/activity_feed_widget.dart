import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class ActivityFeedWidget extends StatelessWidget {
  const ActivityFeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {'time': '2 mins ago', 'text': 'New event request: Wedding in Mumbai', 'color': Colors.blue},
      {'time': '5 mins ago', 'text': 'Booking confirmed: ABC Events (#BK12345)', 'color': Colors.green},
      {'time': '10 mins ago', 'text': 'Vendor submitted quotation (#QT67890)', 'color': Colors.orange},
      {'time': '15 mins ago', 'text': 'Payment received: ₹50,000 (#PAY445566)', 'color': Colors.purple},
      {'time': '20 mins ago', 'text': 'Dispute raised: Customer complaint (#DSP123)', 'color': Colors.red},
      {'time': '25 mins ago', 'text': 'New vendor registered: XYZ Photography', 'color': Colors.green},
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('RECENT ACTIVITIES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All →')),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final item = activities[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['text'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(item['time'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
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
