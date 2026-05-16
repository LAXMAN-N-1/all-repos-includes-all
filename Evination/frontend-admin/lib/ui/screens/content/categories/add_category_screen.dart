import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class AddEventCategoryScreen extends StatelessWidget {
  const AddEventCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Add New Event Category'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // BASIC INFORMATION
            _buildSection(
              'BASIC INFORMATION',
              Column(
                children: [
                  const TextField(decoration: InputDecoration(labelText: 'Category Name *', hintText: 'Engagement Ceremonies', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  const TextField(decoration: InputDecoration(labelText: 'Display Name', hintText: 'If different from category name', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                        child: const Text('💍', style: TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(onPressed: (){}, child: const Text('Choose Emoji')),
                      const SizedBox(width: 16),
                      OutlinedButton(onPressed: (){}, child: const Text('Upload Icon')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const TextField(decoration: InputDecoration(labelText: 'Short Description *', hintText: 'Max 100 chars', border: OutlineInputBorder(), counterText: '48/100')),
                  const SizedBox(height: 16),
                  const TextField(maxLines: 4, decoration: InputDecoration(labelText: 'Full Description *', border: OutlineInputBorder())),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SUBCATEGORIES
            _buildSection(
              'SUBCATEGORIES',
              Column(
                children: [
                  _buildSubCatRow('Traditional Engagement'),
                  _buildSubCatRow('Ring Ceremony'),
                  _buildSubCatRow('Intimate Engagement'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.add), label: const Text('Add Subcategory')),
                ],
              ),
            ),
             const SizedBox(height: 24),

             // MEDIA
             _buildSection(
               'MEDIA',
               Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text('Category Featured Image *', style: TextStyle(fontWeight: FontWeight.bold)),
                         const SizedBox(height: 8),
                         Container(
                           height: 150,
                           decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
                           child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.cloud_upload, color: Colors.grey), Text('Upload Image', style: TextStyle(color: Colors.grey))])),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text('Category Banner Image', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                           height: 150,
                           decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
                           child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.image, color: Colors.grey), Text('Upload Banner', style: TextStyle(color: Colors.grey))])),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
             ),
             const SizedBox(height: 24),

             // SEO SETTINGS
             _buildSection(
               'SEO SETTINGS',
               const Column(
                 children: [
                   TextField(decoration: InputDecoration(labelText: 'URL Slug *', hintText: 'Auto-generated', border: OutlineInputBorder(), prefixText: 'evination.com/category/')),
                   SizedBox(height: 16),
                   TextField(decoration: InputDecoration(labelText: 'Meta Title *', border: OutlineInputBorder())),
                   SizedBox(height: 16),
                   TextField(maxLines: 2, decoration: InputDecoration(labelText: 'Meta Description *', border: OutlineInputBorder(), counterText: '98/160')),
                 ],
               ),
             ),
             const SizedBox(height: 24),

             // CATEGORY SETTINGS
             _buildSection(
               'CATEGORY SETTINGS',
               Column(
                 children: [
                   DropdownButtonFormField(items: const [DropdownMenuItem(value: 'Active', child: Text('Active'))], value: 'Active', onChanged: (v){}, decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder())),
                   const SizedBox(height: 16),
                   SwitchListTile(value: true, onChanged: (v){}, title: const Text('Show on Homepage')),
                   SwitchListTile(value: true, onChanged: (v){}, title: const Text('Show in Search Suggestions')),
                   const Divider(),
                   const Text('Customer Form Fields', style: TextStyle(fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Row(
                     children: [
                        _buildCheckBox('Event Date', true),
                        _buildCheckBox('Event Time', true),
                        _buildCheckBox('Budget Range', true),
                     ],
                   ),
                 ],
               ),
             ),
             const SizedBox(height: 40),
             Row(
               children: [
                 Expanded(child: OutlinedButton(onPressed: (){}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)), child: const Text('Save as Draft'))),
                 const SizedBox(width: 16),
                 Expanded(child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)), child: const Text('Publish Category'))),
               ],
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.2)),
        const SizedBox(height: 16),
        Container(
           padding: const EdgeInsets.all(24),
           decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
           child: content,
        ),
      ],
    );
  }

  Widget _buildSubCatRow(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: TextEditingController(text: name), decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)))),
          IconButton(onPressed: (){}, icon: const Icon(Icons.close, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildCheckBox(String label, bool val) {
    return Expanded(
      child: Row(
        children: [
          Transform.scale(scale: 0.9, child: Checkbox(value: val, onChanged: (v){})),
          Text(label),
        ],
      ),
    );
  }
}
