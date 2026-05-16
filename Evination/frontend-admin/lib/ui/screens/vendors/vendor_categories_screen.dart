import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common_card.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_input.dart';
import '../../widgets/common_textarea.dart';
import '../../widgets/common_dialog.dart';
import '../../../logic/providers/category_provider.dart';
import '../../../data/models/category_model.dart';

class VendorCategoriesScreen extends ConsumerStatefulWidget {
  const VendorCategoriesScreen({super.key});

  @override
  ConsumerState<VendorCategoriesScreen> createState() => _VendorCategoriesScreenState();
}

class _VendorCategoriesScreenState extends ConsumerState<VendorCategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descController = TextEditingController();
  final _iconController = TextEditingController();
  String _selectedColor = 'purple';

  Map<String, Color> getCategoryColor(String? colorName) {
    switch (colorName) {
      case 'pink':
        return {'bg': Colors.pink[50]!, 'text': Colors.pink[600]!, 'border': Colors.pink[200]!};
      case 'blue':
        return {'bg': Colors.blue[50]!, 'text': Colors.blue[600]!, 'border': Colors.blue[200]!};
      case 'yellow':
        return {'bg': Colors.yellow[50]!, 'text': Colors.yellow[800]!, 'border': Colors.yellow[200]!};
      case 'purple':
        return {'bg': Colors.purple[50]!, 'text': Colors.purple[600]!, 'border': Colors.purple[200]!};
      case 'green':
        return {'bg': Colors.green[50]!, 'text': Colors.green[600]!, 'border': Colors.green[200]!};
      case 'red':
        return {'bg': Colors.red[50]!, 'text': Colors.red[600]!, 'border': Colors.red[200]!};
      default:
        return {'bg': Colors.grey[50]!, 'text': Colors.grey[600]!, 'border': Colors.grey[200]!};
    }
  }

  void _showModal(BuildContext context, {Category? category}) {
    if (category != null) {
      _nameController.text = category.name;
      _codeController.text = category.code;
      _descController.text = category.description ?? '';
      _iconController.text = category.icon ?? '';
      _selectedColor = category.color ?? 'purple';
    } else {
      _nameController.clear();
      _codeController.clear();
      _descController.clear();
      _iconController.clear();
      _selectedColor = 'purple';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => CommonDialog(
          title: category != null ? 'Edit Vendor Category' : 'Create Vendor Category',
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonInput(
                  label: 'Category Name',
                  placeholder: 'e.g., Catering',
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                CommonInput(
                  label: 'Category Code',
                  placeholder: 'CATERING',
                  controller: _codeController,
                  enabled: category == null,
                ),
                const SizedBox(height: 16),
                CommonTextarea(
                  label: 'Description',
                  placeholder: 'Describe the category',
                  controller: _descController,
                  minLines: 3,
                ),
                const SizedBox(height: 16),
                CommonInput(
                  label: 'Icon/Emoji',
                  placeholder: '🍽️',
                  controller: _iconController,
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
                    final isSelected = _selectedColor == color;
                    return InkWell(
                      onTap: () => setModalState(() => _selectedColor = color),
                      child: Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: colors['bg'],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.black : colors['border']!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            CommonButton(
              text: 'Cancel',
              variant: ButtonVariant.outline,
              onPressed: () => Navigator.pop(context),
            ),
            CommonButton(
              text: category != null ? 'Update Category' : 'Create Category',
              onPressed: () async {
                if (category != null) {
                  await ref.read(categoryListProvider.notifier).updateCategory(
                    category.id,
                    _nameController.text,
                    _descController.text,
                    _iconController.text,
                    _selectedColor,
                  );
                } else {
                  await ref.read(categoryListProvider.notifier).addCategory(
                    _nameController.text,
                    _codeController.text,
                    _descController.text,
                    _iconController.text,
                    _selectedColor,
                  );
                }
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => CommonDialog(
        title: 'Delete Category',
        content: Text('Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          CommonButton(
            text: 'Cancel',
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.pop(context),
          ),
          CommonButton(
            text: 'Delete',
            variant: ButtonVariant.destructive,
            onPressed: () async {
              try {
                await ref.read(categoryListProvider.notifier).deleteCategory(category.id);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final gradientShaderCallback = (Rect bounds) {
      return const LinearGradient(
        colors: [Color(0xFFfdb913), Color(0xFFe5a711)],
      ).createShader(bounds);
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: categoriesAsync.when(
        data: (categories) => SingleChildScrollView(
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
                            color: Colors.white,
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
                    onPressed: () => _showModal(context),
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
                    '${categories.fold(0, (sum, item) => sum + (item.vendorsCount ?? 0))}',
                    gradientShaderCallback,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    'Most Popular',
                    categories.isEmpty ? 'N/A' : (categories..sort((a,b) => (b.vendorsCount ?? 0).compareTo(a.vendorsCount ?? 0))).first.name,
                    gradientShaderCallback,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Categories Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  if (categories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No categories found', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                        ],
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: categories.map((category) {
                      final colors = getCategoryColor(category.color);
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
                                      category.icon ?? '📁',
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        onPressed: () => _showModal(context, category: category),
                                        splashRadius: 20,
                                        color: Colors.grey[600],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 18),
                                        onPressed: () => _confirmDelete(context, category),
                                        splashRadius: 20,
                                        color: Colors.red[600],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.description ?? 'No description provided',
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
                                  Text('${category.vendorsCount ?? 0} vendors', style: TextStyle(color: Colors.grey[600])),
                                  InkWell(
                                    onTap: () => context.push('/admin/vendors/list?category_id=${category.id}'),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
