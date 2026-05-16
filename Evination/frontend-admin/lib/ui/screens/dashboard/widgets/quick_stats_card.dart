import 'package:flutter/material.dart';

class QuickStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subTitle;
  final String subValue;
  final String subTitle2;
  final String subValue2;

  const QuickStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subTitle,
    required this.subValue,
    required this.subTitle2,
    required this.subValue2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubStat(subTitle, subValue),
              _buildSubStat(subTitle2, subValue2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubStat(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
