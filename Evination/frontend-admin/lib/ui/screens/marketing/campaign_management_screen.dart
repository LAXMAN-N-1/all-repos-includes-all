import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_theme.dart';

class CampaignManagementScreen extends StatelessWidget {
  const CampaignManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Marketing Campaigns', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => context.go('/admin/marketing/campaigns/create'),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create Campaign'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Stats
            Row(
              children: [
                Expanded(child: _buildHeaderStat('Active Campaigns', '5', Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildHeaderStat('Total Reach', '45.6K', Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildHeaderStat('Conversions', '1,234', Colors.purple)),
                const SizedBox(width: 16),
                Expanded(child: _buildHeaderStat('Avg ROI', '850%', Colors.orange)),
              ],
            ),
            const SizedBox(height: 32),

            const Row(
               children: [
                 Text('Active Campaigns', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 Spacer(),
                 Icon(Icons.filter_list, color: Colors.grey),
               ],
            ),
            const SizedBox(height: 16),
            
            _buildCampaignCard(
              'VALENTINE\'S SPECIAL 2024',
              'Active',
              '10% Off on Weddings',
              'Ends in 9 days',
              ['Push', 'Email', 'SMS'],
              '14.6%', '890%',
            ),
            const SizedBox(height: 16),
            _buildCampaignCard(
              'BIRTHDAY BASH BONANZA',
              'Active',
              'Flat ₹5000 Off',
              'Ends in 24 days',
              ['Push', 'In-App'],
              '13.0%', '520%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(String title, String status, String offer, String duration, List<String> channels, String ctr, String roi) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.pink[50], borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.favorite, color: Colors.pink),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(4)),
                            child: Text(status.toUpperCase(), style: TextStyle(color: Colors.green[700], fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('$offer • $duration', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 12),
                      Row(children: channels.map((c) => Padding(padding: const EdgeInsets.only(right: 8), child: Chip(label: Text(c, style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact))).toList()),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(roi, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    const Text('ROI', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(ctr, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('CTR', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(onPressed: (){}, icon: const Icon(Icons.analytics_outlined, size: 16), label: const Text('View Analytics')),
                Row(
                  children: [
                    OutlinedButton(onPressed: (){}, child: const Text('Pause')),
                    const SizedBox(width: 12),
                    OutlinedButton(onPressed: (){}, child: const Text('Edit')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
