import 'package:flutter/material.dart';
import '../../widgets/common_card.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_input.dart';
import '../../widgets/common_textarea.dart';
import '../../widgets/common_dialog.dart';

class VendorCategoriesScreen extends StatefulWidget {
  const VendorCategoriesScreen({super.key});

  @override
  State<VendorCategoriesScreen> createState() => _VendorCategoriesScreenState();
}

class _VendorCategoriesScreenState extends State<VendorCategoriesScreen> {
  final List<Map<String, dynamic>> categories = [
    {
      'id': 1,
      'name': 'Catering',
      'description': 'Food and beverage services for all types of events',
      'vendorsCount': 45,
      'color': 'pink',
      'icon': '🍽️',
    },
    {
      'id': 2,
      'name': 'Photography',
      'description': 'Professional photography and videography services',
      'vendorsCount': 38,
      'color': 'blue',
      'icon': '📸',
    },
    {
      'id': 3,
      'name': 'Decoration',
      'description': 'Event decoration, floral arrangements, and venue setup',
      'vendorsCount': 32,
      'color': 'yellow',
      'icon': '🎨',
    },
    {
      'id': 4,
      'name': 'Audio/Video',
      'description': 'Sound systems, lighting, and multimedia equipment',
      'vendorsCount': 28,
      'color': 'purple',
      'icon': '🎵',
    },
    {
      'id': 5,
      'name': 'Event Planning',
      'description': 'Full-service event planning and coordination',
      'vendorsCount': 24,
      'color': 'green',
      'icon': '📋',
    },
    {
      'id': 6,
      'name': 'Entertainment',
      'description': 'Live performers, DJs, and entertainment services',
      'vendorsCount': 19,
      'color': 'red',
      'icon': '🎭',
    },
  ];

  Map<String, Color> getCategoryColor(String colorName) {
    switch (colorName) {
      case 'pink':
        return {'bg': Colors.pink[50]!, 'text': Colors.pink[600]!, 'border': Colors.pink[200]!};
      case 'blue':
        return {'bg': Colors.blue[50]!, 'text': Colors.blue[600]!, 'border': Colors.blue[200]!};
      case 'yellow':
        return {'bg': Colors.yellow[50]!, 'text': Colors.yellow[800]!, 'border': Colors.yellow[200]!}; // Darker yellow for text visibility
      case 'purple':
        return {'bg': Colors.amber[50]!, 'text': Colors.amber[600]!, 'border': Colors.amber[200]!};
      case 'green':
        return {'bg': Colors.green[50]!, 'text': Colors.green[600]!, 'border': Colors.green[200]!};
      case 'red':
        return {'bg': Colors.red[50]!, 'text': Colors.red[600]!, 'border': Colors.red[200]!};
      default:
        return {'bg': Colors.grey[50]!, 'text': Colors.grey[600]!, 'border': Colors.grey[200]!};
    }
  }

  void _showCreateModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CommonDialog(
        title: 'Create Vendor Category',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CommonInput(
              label: 'Category Name',
              placeholder: 'e.g., Venue Providers',
            ),
            const SizedBox(height: 16),
            const CommonTextarea(
              label: 'Description',
              placeholder: 'Describe the category',
              minLines: 3,
            ),
            const SizedBox(height: 16),
            const CommonInput(
              label: 'Icon/Emoji',
              placeholder: '🏢',
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Color Theme', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['pink', 'blue', 'yellow', 'purple', 'green', 'red'].map((color) {
                final colors = getCategoryColor(color);
                return Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: colors['bg'],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors['border']!, width: 2),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          CommonButton(
            text: 'Cancel',
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.pop(context),
          ),
          CommonButton(
            text: 'Create Category',
            onPressed: () {
              // Add creation logic here
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientShaderCallback = (Rect bounds) {
        return const LinearGradient(
          colors: [Color(0xFFfdb913), Color(0xFFe5a711)],
        ).createShader(bounds);
      };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: gradientShaderCallback,
                      child: const Text(
                        'Vendor Categories',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Required for ShaderMask
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Organize vendors into meaningful categories',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
                CommonButton(
                  text: 'Create Category',
                  icon: Icons.add,
                  onPressed: () => _showCreateModal(context),
                  // We can't easily apply gradient to CommonButton directly without modification or wrapping,
                  // assuming default style is acceptable or we'd extend CommonButton.
                  // For now, using default primary button. 
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                _buildStatCard('Total Categories', '${categories.length}', gradientShaderCallback),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Total Vendors',
                  '${categories.fold(0, (sum, item) => sum + (item['vendorsCount'] as int))}',
                  gradientShaderCallback,
                ),
                const SizedBox(width: 16),
                _buildStatCard('Most Popular', '${categories[0]['name']}', gradientShaderCallback),
              ],
            ),
            const SizedBox(height: 32),

            // Categories Grid
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: categories.map((category) {
                    final colors = getCategoryColor(category['color']);
                    // Calculate width for grid items (responsive)
                    // Mobile: 100%, Tablet: 50%, Desktop: 33%
                    double width = constraints.maxWidth;
                    if (constraints.maxWidth > 1000) {
                      width = (constraints.maxWidth - 48) / 3;
                    } else if (constraints.maxWidth > 600) {
                      width = (constraints.maxWidth - 24) / 2;
                    }

                    return SizedBox(
                      width: width,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors['border']!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colors['bg'],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    category['icon'],
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      onPressed: () {},
                                      splashRadius: 20,
                                      color: Colors.grey[600],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18),
                                      onPressed: () {},
                                      splashRadius: 20,
                                      color: Colors.red[600],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              category['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category['description'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${category['vendorsCount']} vendors', style: TextStyle(color: Colors.grey[600])),
                                InkWell(
                                  onTap: () {},
                                  child: Text('View Vendors →', style: TextStyle(color: colors['text'], fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, ShaderCallback shaderCallback) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: shaderCallback,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
