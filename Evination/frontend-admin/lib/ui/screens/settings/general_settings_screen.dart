import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('General Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            _buildSection('Platform Information', [
              const TextField(decoration: InputDecoration(labelText: 'Platform Name', hintText: 'Evination', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'Tagline', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              const TextField(maxLines: 3, decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
            ]),
            const SizedBox(height: 24),
            
            _buildSection('Contact Information', [
               const TextField(decoration: InputDecoration(labelText: 'Support Email', border: OutlineInputBorder())),
               const SizedBox(height: 16),
               const TextField(decoration: InputDecoration(labelText: 'Support Phone', border: OutlineInputBorder())),
               const SizedBox(height: 16),
               const TextField(maxLines: 2, decoration: InputDecoration(labelText: 'Business Address', border: OutlineInputBorder())),
            ]),
            const SizedBox(height: 24),

            _buildSection('Regional Settings', [
                DropdownButtonFormField(value: 'English', items: const [DropdownMenuItem(value: 'English', child: Text('English'))], onChanged: (v){}, decoration: const InputDecoration(labelText: 'Default Language', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                DropdownButtonFormField(value: 'INR', items: const [DropdownMenuItem(value: 'INR', child: Text('INR (₹)'))], onChanged: (v){}, decoration: const InputDecoration(labelText: 'Currency', border: OutlineInputBorder())),
            ]),
             const SizedBox(height: 32),
             ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white, minimumSize: const Size(120, 48)), child: const Text('Save Changes')),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
