import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Stats
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('EVENT CATEGORIES MANAGEMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Expanded(child: _buildStatItem('Total Categories', '6')),
                      Expanded(child: _buildStatItem('Active Categories', '5', color: Colors.green)),
                      Expanded(child: _buildStatItem('Total Subcategories', '24')),
                      Expanded(child: _buildStatItem('Most Popular', 'Weddings (45%)', color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 24),
                   Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {}, // Navigate to Add Category
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Category'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.sort, size: 16), label: const Text('Reorder Categories')),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.file_upload, size: 16), label: const Text('Import/Export')),
                    ],
                  ),
                ],
              ),
            ),
             const SizedBox(height: 24),

             // List
             const Text('CATEGORIES LIST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
             const SizedBox(height: 4),
             const Text('Drag to reorder categories (affects display order on website/app)', style: TextStyle(fontSize: 12, color: Colors.grey)),
             const SizedBox(height: 16),

             _buildCategoryCard(
               '1', 'WEDDINGS', 'Active', Colors.green, '💍', const Color(0xFFFFD700),
               'Complete wedding planning services including venue, decoration, catering, photography, and more.',
               ['Hindu Wedding', 'Christian Wedding', 'Muslim Wedding', 'Sikh Wedding', 'Destination Wedding', 'Court Marriage', 'Reception Party', 'Pre-Wedding Events'],
               '450', '45', '₹35.5 L', '↑ 15% MoM'
             ),
             const SizedBox(height: 16),
             _buildCategoryCard(
               '2', 'CORPORATE EVENTS', 'Active', Colors.green, '🏢', const Color(0xFF2E86C1),
               'Professional corporate event management for conferences, seminars, team building, and corporate parties.',
               ['Conferences & Seminars', 'Product Launches', 'Team Building Activities', 'Corporate Parties', 'Awards Ceremonies', 'Trade Shows & Exhibitions'],
               '280', '38', '₹14.4 L', '↑ 10% MoM'
             ),
              const SizedBox(height: 16),
             _buildCategoryCard(
               '3', 'BIRTHDAY PARTIES', 'Active', Colors.green, '🎂', const Color(0xFFE74C3C),
               'Kids, Teenage, Adult, and Theme Parties',
               ['Kids Birthday', 'Teenage Birthday', 'Adult Birthday', 'Theme Parties'],
               '180', '52', '₹9.1 L', '-'
             ),
              const SizedBox(height: 16),
             _buildCategoryCard(
               '6', 'OTHER EVENTS', 'Inactive', Colors.red, '🎪', const Color(0xFF95A5A6),
               'Miscellaneous events',
               [],
               '8', '3', '0', 'Disabled'
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildCategoryCard(String rank, String name, String status, Color statusColor, String icon, Color iconColor, String desc, List<String> subs, String vendors, String bookings, String revenue, String growth) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
             decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
            child: Row(
              children: [
                const Icon(Icons.drag_indicator, color: Colors.grey),
                const SizedBox(width: 16),
                Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                   child: Text(icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Text('$rank. $name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info & Subs
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DESCRIPTION:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(desc, style: const TextStyle(height: 1.4)),
                      const SizedBox(height: 16),
                       const Text('SUBCATEGORIES:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                       const SizedBox(height: 8),
                       if (subs.isEmpty) const Text('No subcategories', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                       Wrap(
                         spacing: 8,
                         runSpacing: 8,
                         children: subs.take(6).map((e) => Chip(
                           label: Text(e, style: const TextStyle(fontSize: 11)),
                           backgroundColor: Colors.grey[50], 
                           padding: EdgeInsets.zero,
                           visualDensity: VisualDensity.compact,
                           side: BorderSide(color: Colors.grey.shade300),
                         )).toList(),
                       ),
                       if (subs.length > 6) Padding(padding: const EdgeInsets.only(top: 8), child: Text('+ ${subs.length - 6} more', style: const TextStyle(fontSize: 11, color: Colors.blue))),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text('STATISTICS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                         const SizedBox(height: 12),
                         _buildMiniStat('Active Vendors', vendors),
                         _buildMiniStat('This Month Bookings', bookings),
                         _buildMiniStat('Total Revenue', revenue),
                         const SizedBox(height: 8),
                         Text(growth, style: TextStyle(color: growth.contains('↑') ? Colors.green : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                       ],
                     ),
                  ),
                ),
              ],
            ),
          ),
          // Actions
            Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                TextButton(onPressed: (){}, child: const Text('Edit Category')),
                const SizedBox(width: 8),
                TextButton(onPressed: (){}, child: const Text('Manage Subcategories')),
                const SizedBox(width: 8),
                TextButton(onPressed: (){}, child: const Text('View Vendors')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
