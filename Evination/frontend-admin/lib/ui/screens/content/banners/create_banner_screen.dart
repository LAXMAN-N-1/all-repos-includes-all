import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class CreateBannerScreen extends StatelessWidget {
  const CreateBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Create New Banner'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // BANNER TYPE
             _buildSectionHeader('BANNER TYPE'),
             const SizedBox(height: 12),
             Wrap(
               spacing: 12,
               children: [
                 _buildTypeChip('Homepage Hero', true),
                 _buildTypeChip('Secondary', false),
                 _buildTypeChip('Popup', false),
                 _buildTypeChip('Mobile App', false),
               ],
             ),
             const SizedBox(height: 24),

             // CONTENT
             _buildSectionHeader('CONTENT'),
             const SizedBox(height: 16),
             const TextField(decoration: InputDecoration(labelText: 'Banner Title', hintText: 'Internal reference', border: OutlineInputBorder())),
             const SizedBox(height: 16),
             Container(
               height: 180,
               decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12)),
               child: Center(
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.blue.shade200),
                     const SizedBox(height: 8),
                     const Text('Drag & Drop or Click to Upload Image', style: TextStyle(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 4),
                     Text('Recommended: 1920x600px', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                   ],
                 ),
               ),
             ),
             const SizedBox(height: 16),
             const TextField(decoration: InputDecoration(labelText: 'Target URL', hintText: 'https://...', border: OutlineInputBorder())),

             const SizedBox(height: 24),
             
             // SCHEDULING
             _buildSectionHeader('SCHEDULING'),
             const SizedBox(height: 16),
             Row(
               children: [
                 Expanded(child: TextField(decoration: InputDecoration(labelText: 'Start Date', prefixIcon: const Icon(Icons.calendar_today), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), controller: TextEditingController(text: '14-Feb-2024'))),
                 const SizedBox(width: 16),
                 Expanded(child: TextField(decoration: InputDecoration(labelText: 'End Date', prefixIcon: const Icon(Icons.calendar_today), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), controller: TextEditingController(text: '14-Feb-2024'))),
               ],
             ),
             const SizedBox(height: 12),
             SwitchListTile(value: false, onChanged: (v){}, title: const Text('No End Date (Run Indefinitely)')),

             const SizedBox(height: 24),

             // DISPLAY SETTINGS
             _buildSectionHeader('DISPLAY SETTINGS'),
             const SizedBox(height: 16),
             CheckboxListTile(value: true, onChanged: (v){}, title: const Text('Website Homepage')),
             CheckboxListTile(value: true, onChanged: (v){}, title: const Text('Mobile App Home Screen')),
             
             const SizedBox(height: 32),
             Row(
               children: [
                 Expanded(child: OutlinedButton(onPressed: (){}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)), child: const Text('Save Draft'))),
                 const SizedBox(width: 16),
                 Expanded(child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)), child: const Text('Publish Banner'))),
               ],
             ),
           ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600]));
  }

  Widget _buildTypeChip(String label, bool selected) {
    return ChoiceChip(
      label: Text(label), 
      selected: selected,
      onSelected: (v){},
      selectedColor: AppTheme.primary600.withOpacity(0.1),
      labelStyle: TextStyle(color: selected ? AppTheme.primary600 : Colors.black),
      // side: selected ? const BorderSide(color: AppTheme.primary600) : null,
    );
  }
}
