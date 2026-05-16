import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_analytics.dart';
import 'package:google_fonts/google_fonts.dart';

class UsageStatsScreen extends StatelessWidget {
  const UsageStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("System Usage Stats", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text("Monitor resource consumption across the platform.", style: TextStyle(color: Colors.white60)),
                ],
              ),
              OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.refresh), label: const Text("Refresh Data"))
            ],
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 1.5,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: mockUsageStats.length,
              itemBuilder: (context, index) {
                return _buildUsageCard(mockUsageStats[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard(UsageMetric usage) {
    Color color = usage.percentage > 0.8 ? Colors.red : (usage.percentage > 0.5 ? Colors.orange : Colors.blue);
    
    return Container(
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
              Text(usage.metric, style: const TextStyle(color: Colors.white60, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                child: Text(usage.trend, style: const TextStyle(color: Colors.white, fontSize: 10)),
              )
            ],
          ),
          const Spacer(),
          Text(usage.value, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("of ${usage.limit} limit", style: const TextStyle(color: Colors.white30, fontSize: 12)),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: usage.percentage,
            backgroundColor: Colors.white10,
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}
