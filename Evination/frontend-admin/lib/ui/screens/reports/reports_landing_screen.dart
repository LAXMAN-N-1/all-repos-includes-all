import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_theme.dart';

class ReportsLandingScreen extends StatelessWidget {
  const ReportsLandingScreen({super.key});

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
                const Text('Reports & Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => context.go('/admin/reports/builder'),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create Custom Report'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Dashboard Link
            InkWell(
              onTap: () => context.go('/admin/reports/dashboard'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primary800, AppTheme.primary600]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                     Icon(Icons.analytics, color: Colors.white, size: 48),
                     SizedBox(width: 24),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('Business Intelligence Dashboard', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                         SizedBox(height: 8),
                         Text('View real-time KPIs, revenue trends, and operational insights.', style: TextStyle(color: Colors.white70)),
                       ],
                     ),
                     Spacer(),
                     Icon(Icons.arrow_forward_ios, color: Colors.white70),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text('Standard Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildReportCard(Icons.calendar_today, 'Daily Operations', 'New bookings, cancellations, and active events.'),
                _buildReportCard(Icons.attach_money, 'Revenue Summary', 'Detailed revenue breakdown by category and source.'),
                _buildReportCard(Icons.people, 'Vendor Performance', 'Top vendors, ratings, and commission earnings.'),
                _buildReportCard(Icons.receipt_long, 'Tax Report (GST)', 'Input/Output tax liability and filing status.'),
                _buildReportCard(Icons.warning, 'Dispute Log', 'History of refund requests and resolutions.'),
                _buildReportCard(Icons.campaign, 'Campaign ROI', 'Performance of marketing campaigns.'),
              ],
            ),
            
             const SizedBox(height: 32),
             const Text('My Saved Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 16),
             _buildSavedReportItem('Monthly Wedding Revenue', 'Last run: 2 hours ago', true),
             _buildSavedReportItem('Low Rated Vendors List', 'Last run: Yesterday', true),
             _buildSavedReportItem('Customer Retention Analysis', 'Last run: 3 days ago', false),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary600),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildSavedReportItem(String title, String subtitle, bool emailEnabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          const Icon(Icons.description, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          if (emailEnabled)
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(4)),
               child: const Row(children: [Icon(Icons.email, size: 12, color: Colors.green), SizedBox(width: 4), Text('Email', style: TextStyle(color: Colors.green, fontSize: 10))]),
             ),
          const SizedBox(width: 16),
          IconButton(onPressed: (){}, icon: const Icon(Icons.play_arrow)),
          IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert)),
        ],
      ),
    );
  }
}
