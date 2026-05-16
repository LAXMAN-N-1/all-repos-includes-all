import 'package:flutter/material.dart';

class CommonChartContainer extends StatelessWidget {
  final Widget child;
  final String? title;

  const CommonChartContainer({super.key, required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}
