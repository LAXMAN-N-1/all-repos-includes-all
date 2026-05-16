import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class AuditReportScreen extends StatelessWidget {
  const AuditReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
       appBar: AppBar(title: const Text('Generate Audit Report'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
       body: SingleChildScrollView(
         padding: const EdgeInsets.all(24),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             _buildHeader('REPORT TYPE'),
             RadioListTile(value: 0, groupValue: 0, onChanged: (v){}, title: const Text('Activity Audit Report')),
             RadioListTile(value: 1, groupValue: 0, onChanged: (v){}, title: const Text('Security Audit Report')),
             RadioListTile(value: 2, groupValue: 0, onChanged: (v){}, title: const Text('Financial Audit Report')),

             const SizedBox(height: 24),
             _buildHeader('TIME PERIOD'),
             const SizedBox(height: 8),
              Row(
               children: [
                 Expanded(child: DropdownButtonFormField(items: const [DropdownMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days'))], value: 'Last 7 Days', onChanged: (v){}, decoration: const InputDecoration(labelText: 'Preset', border: OutlineInputBorder()))),
                 const SizedBox(width: 16),
                 const Expanded(child: TextField(decoration: InputDecoration(labelText: 'Custom Start', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)))),
               ],
             ),

             const SizedBox(height: 24),
             _buildHeader('INCLUDE IN REPORT'),
             CheckboxListTile(value: true, onChanged: (v){}, title: const Text('Admin Activities')),
             CheckboxListTile(value: true, onChanged: (v){}, title: const Text('System Events')),
             CheckboxListTile(value: true, onChanged: (v){}, title: const Text('Login/Logout Records')),
             CheckboxListTile(value: true, onChanged: (v){}, title: const Text('Financial Transactions')),

             const SizedBox(height: 24),
             _buildHeader('OUTPUT FORMAT'),
             Row(
               children: [
                 Expanded(child: RadioListTile(value: 'PDF', groupValue: 'PDF', onChanged: (v){}, title: const Text('PDF'))),
                 Expanded(child: RadioListTile(value: 'Excel', groupValue: 'PDF', onChanged: (v){}, title: const Text('Excel'))),
               ],
             ),

             const SizedBox(height: 40),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton.icon(
                 onPressed: (){}, 
                 icon: const Icon(Icons.download), 
                 label: const Text('Generate Report'),
                 style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
               ),
             ),
           ],
         ),
       ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])),
    );
  }
}
