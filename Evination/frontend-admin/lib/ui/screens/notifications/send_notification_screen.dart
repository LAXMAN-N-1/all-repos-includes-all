import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  // Simple state for checkboxes
  bool pushEnabled = true;
  bool emailEnabled = true;
  bool smsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
       appBar: AppBar(title: const Text('Send Notification'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
       body: SingleChildScrollView(
         padding: const EdgeInsets.all(24),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             _buildSectionHeader('NOTIFICATION TYPE & CHANNELS'),
             const SizedBox(height: 16),
             Row(
               children: [
                 Expanded(child: CheckboxListTile(value: pushEnabled, onChanged: (v)=>setState(()=>pushEnabled=v!), title: const Text('Push Notification'), subtitle: const Text('Reach: 4,890 users'))),
                 Expanded(child: CheckboxListTile(value: emailEnabled, onChanged: (v)=>setState(()=>emailEnabled=v!), title: const Text('Email'), subtitle: const Text('Reach: 5,678 users'))),
               ],
             ),
             Row(
               children: [
                  Expanded(child: CheckboxListTile(value: smsEnabled, onChanged: (v)=>setState(()=>smsEnabled=v!), title: const Text('SMS'), subtitle: const Text('Cost: ₹0.25/msg'))),
                  const Spacer(),
               ],
             ),

             const SizedBox(height: 32),
             _buildSectionHeader('TARGET AUDIENCE'),
             const SizedBox(height: 16),
             DropdownButtonFormField(
               items: const [DropdownMenuItem(value: 'All', child: Text('All Customers')), DropdownMenuItem(value: 'Vendors', child: Text('All Vendors'))],
               value: 'All',
               onChanged: (v){},
               decoration: const InputDecoration(labelText: 'Recipient Group', border: OutlineInputBorder()),
             ),
             const SizedBox(height: 16),
             const Text('Estimated Recipients: 5,678 users', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),

             const SizedBox(height: 32),
             _buildSectionHeader('CONTENT'),
             const SizedBox(height: 16),
             const TextField(decoration: InputDecoration(labelText: 'Title *', hintText: 'e.g. Flash Sale!', border: OutlineInputBorder(), counterText: '32/50')),
             const SizedBox(height: 16),
             const TextField(maxLines: 4, decoration: InputDecoration(labelText: 'Message *', hintText: 'Enter your message...', border: OutlineInputBorder(), counterText: '98/150')),
             const SizedBox(height: 16),
             const TextField(decoration: InputDecoration(labelText: 'Link / Action URL', border: OutlineInputBorder())),

             const SizedBox(height: 32),
             _buildSectionHeader('SCHEDULING'),
             const SizedBox(height: 16),
             RadioListTile(value: 'now', groupValue: 'now', onChanged: (v){}, title: const Text('Send Immediately')),
             RadioListTile(value: 'later', groupValue: 'now', onChanged: (v){}, title: const Text('Schedule for Later')),

             const SizedBox(height: 40),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: (){}, 
                 style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                 child: const Text('Send Notification'),
               ),
             ),
           ],
         ),
       ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.2));
  }
}
