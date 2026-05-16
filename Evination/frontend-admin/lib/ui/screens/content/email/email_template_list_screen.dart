import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class EmailTemplateListScreen extends StatelessWidget {
  const EmailTemplateListScreen({super.key});

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
                 const Text('Email Templates', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                 ElevatedButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create Template'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white),
                ),
              ],
             ),
             const SizedBox(height: 24),
             
             // Tabs (simulated)
             Row(
               children: [
                 Chip(label: const Text('Transactional (20)'), backgroundColor: AppTheme.primary600, labelStyle: const TextStyle(color: Colors.white)),
                 const SizedBox(width: 8),
                 const Chip(label: Text('Marketing')),
                 const SizedBox(width: 8),
                 const Chip(label: Text('Notification')),
               ],
             ),
             const SizedBox(height: 16),

             _buildTemplateCard(
               'WELCOME EMAIL - New Customer Registration', 'welcome-customer-001',
               'When customer completes registration',
               'Welcome to Evination, {{first_name}}! 🎉',
               'Sent 234 times | 68% open rate'
             ),
             const SizedBox(height: 16),
             _buildTemplateCard(
               'BOOKING CONFIRMATION - Payment Received', 'booking-confirmation-001',
               'When customer payment is successful',
               'Booking Confirmed! {{booking_id}}',
               'Sent 186 times | 92% open rate'
             ),
              const SizedBox(height: 16),
             _buildTemplateCard(
               'QUOTATION RECEIVED', 'quotation-received-001',
               'When admin sends quotations',
               '{{quotation_count}} Quotes for Your Event!',
               'Sent 156 times | 78% open rate'
             ),
           ],
         ),
      ),
    );
  }

  Widget _buildTemplateCard(String title, String id, String trigger, String subject, String stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
               Row(
                children: [
                  OutlinedButton(onPressed: (){}, child: const Text('Preview')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[100], foregroundColor: Colors.black, elevation: 0), child: const Text('Edit')),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          Text('ID: $id | Trigger: $trigger', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
            child: Row(children: [const Icon(Icons.subject, size: 16, color: Colors.blue), const SizedBox(width: 8), Expanded(child: Text('Subject: $subject', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blue)))]),
          ),
          const SizedBox(height: 12),
          Text(stats, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
        ],
      ),
    );
  }
}
