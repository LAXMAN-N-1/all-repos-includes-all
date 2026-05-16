import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class AddAdminUserScreen extends StatelessWidget {
  const AddAdminUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Add New Admin User'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('PERSONAL INFORMATION'),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Full Name *', hintText: 'e.g. Karthik Rao', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Email Address *', hintText: 'Will be used as username', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Phone Number *', prefixText: '+91 ', border: OutlineInputBorder()))),
                SizedBox(width: 16),
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Employee ID', border: OutlineInputBorder()))),
              ],
            ),
             
            const SizedBox(height: 32),
            _buildSectionHeader('ROLE & DEPARTMENT'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  _buildRadioItem('Super Administrator', 'Full platform access'),
                  _buildRadioItem('Admin Manager', 'Vendor & customer management'),
                  _buildRadioItem('Finance Manager', 'Financial operations'),
                  _buildRadioItem('Support Manager', 'Customer support & tickets', selected: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(items: const [DropdownMenuItem(value: 'Support', child: Text('Customer Support'))], value: 'Support', onChanged: (v){}, decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Reports To', hintText: 'e.g. Sneha Reddy', border: OutlineInputBorder())),
            
            const SizedBox(height: 32),
            _buildSectionHeader('PERMISSIONS SUMMARY (Support Manager)'),
            const SizedBox(height: 16),
             Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.withOpacity(0.05),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ CAN ACCESS:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  Text('• Customer support tickets (View, Edit, Resolve)'),
                  Text('• Customer profiles'),
                  Text('• Bookings & Disputes'),
                  SizedBox(height: 12),
                  Text('❌ CANNOT ACCESS:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  Text('• Financial management (Payments, Payouts)'),
                  Text('• Platform settings'),
                  Text('• Vendor approval/rejection'),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('ACCOUNT SETTINGS'),
            const SizedBox(height: 16),
            SwitchListTile(value: true, onChanged: (v){}, title: const Text('Require 2FA on first login'), activeColor: AppTheme.primary600),
            SwitchListTile(value: true, onChanged: (v){}, title: const Text('Restrict to office IPs only'), subtitle: const Text('Allowed: 103.xxx.xxx.xxx'), activeColor: AppTheme.primary600),

            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: (){}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)), child: const Text('Cancel')),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)), child: const Text('Create User & Send Invite')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.2));
  }

  Widget _buildRadioItem(String title, String subtitle, {bool selected = false}) {
    return RadioListTile(
      value: title, 
      groupValue: selected ? title : null, 
      onChanged: (v){},
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      activeColor: AppTheme.primary600,
    );
  }
}
