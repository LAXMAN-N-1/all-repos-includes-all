import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class BannerListScreen extends StatelessWidget {
  const BannerListScreen({super.key});

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
                const Text('Banners & Promotions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () {}, // Navigate to Create Banner
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add New Banner'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('ACTIVE HOMEPAGE BANNERS (3 of 5 slots used)'),
            const SizedBox(height: 16),

            _buildBannerCard(
              'BANNER #1 (Main Hero Banner)', 'Flash Sale - 15% Off', 'Active', Colors.green,
              'Slot 1 (Main/Top)', '1920x600px', '5-Feb to 11-Feb', '8,456 (14.6% CTR)',
              Colors.purple.shade900
            ),
             const SizedBox(height: 16),
            _buildBannerCard(
              'BANNER #2 (Secondary)', 'Trending: Destination Weddings', 'Active', Colors.green,
              'Slot 2', '800x400px', '1-Feb to 29-Feb', '456 (8.2% CTR)',
              Colors.blue.shade800
            ),
             const SizedBox(height: 16),
            _buildBannerCard(
              'BANNER #3 (Promotional)', 'Summer Wedding Carnival', 'Scheduled', Colors.orange,
              'Slot 3', 'Starts in 38 days', '15-Mar to 31-May', '0',
              Colors.teal
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.1));
  }

  Widget _buildBannerCard(String title, String name, String status, Color statusColor, String slot, String size, String schedule, String performance, Color bannerColor) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
             decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                 Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold))),
               ],
             ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 200, 
                  color: bannerColor,
                  child: Center(
                    child: Icon(Icons.image, size: 48, color: Colors.white.withOpacity(0.5)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                             _buildInfoItem('Position', slot),
                             const SizedBox(width: 24),
                             _buildInfoItem('Size', size),
                             const SizedBox(width: 24),
                             _buildInfoItem('Schedule', schedule),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text('Performance: $performance', style: const TextStyle(fontWeight: FontWeight.bold)),
                             Row(
                               children: [
                                 TextButton(onPressed: (){}, child: const Text('Edit')),
                                 TextButton(onPressed: (){}, child: const Text('Analytics')),
                                  TextButton(onPressed: (){}, child: const Text('Pause')),
                               ],
                             )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
