import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../logic/providers/category_provider.dart';
import '../../data/models/category_model.dart';
import '../../theme/app_theme.dart';

class EventCategoriesScreen extends ConsumerStatefulWidget {
  const EventCategoriesScreen({super.key});

  @override
  ConsumerState<EventCategoriesScreen> createState() => _EventCategoriesScreenState();
}

class _EventCategoriesScreenState extends ConsumerState<EventCategoriesScreen> {
  bool _showCreateModal = false;
  Category? _editingCategory;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Header
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]).createShader(bounds),
                      child: const Text('Event Categories', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Text('Organize events into meaningful categories', style: TextStyle(color: Colors.grey[600])),
                 ]),
                 ElevatedButton.icon(
                   onPressed: () => setState(() { _editingCategory = null; _showCreateModal = true; }),
                   icon: const Icon(Icons.add, color: Colors.white),
                   label: const Text('Create Category', style: TextStyle(color: Colors.white)),
                   style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFDB913), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                 ),
               ],
             ),
             const SizedBox(height: 24),

             categoriesAsync.when(
               data: (categories) {
                 final totalEvents = categories.fold(0, (sum, c) => sum + (c.eventsCount ?? 0));
                 final sortedCats = List<Category>.from(categories)..sort((a,b) => (b.eventsCount??0).compareTo(a.eventsCount??0));
                 final popular = sortedCats.isNotEmpty ? sortedCats.first.name : 'N/A';
                 
                 return Column(
                   children: [
                     // Stats
                     Row(
                       children: [
                         _statCard('Total Categories', '${categories.length}'),
                         const SizedBox(width: 16),
                         _statCard('Total Events', '$totalEvents'),
                         const SizedBox(width: 16),
                         _statCard('Most Popular', popular),
                       ],
                     ),
                     const SizedBox(height: 24),
                     
                     // Grid
                     GridView.builder(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                         crossAxisCount: 3,
                         childAspectRatio: 1.1,
                         crossAxisSpacing: 24,
                         mainAxisSpacing: 24,
                       ),
                       itemCount: categories.length,
                       itemBuilder: (context, index) => _CategoryCard(
                         category: categories[index], 
                         onEdit: () => setState(() { _editingCategory = categories[index]; _showCreateModal = true; }),
                         onDelete: () => _confirmDelete(context, categories[index]),
                       ),
                     ),
                   ],
                 );
               },
               loading: () => const Center(child: CircularProgressIndicator()),
               error: (err, stack) => Center(child: Text('Error: $err')),
             ),
          ],
        ),
      ),
      
      // Dialog
      floatingActionButton: null,
      bottomSheet: _showCreateModal ? _CategoryModal(
         category: _editingCategory,
         onClose: () => setState(() => _showCreateModal = false),
         onSave: (data) async {
            try {
               if (_editingCategory != null) {
                  await ref.read(categoryListProvider.notifier).updateCategory(_editingCategory!.id, data['name'], data['description'], data['icon'], data['color']);
               } else {
                  // Generate code from name roughly
                  String code = data['name'].toLowerCase().replaceAll(' ', '-');
                  await ref.read(categoryListProvider.notifier).addCategory(data['name'], code, data['description'], data['icon'], data['color']);
               }
               setState(() => _showCreateModal = false);
            } catch (e) {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
         },
      ) : null,
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardDecoration,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
           Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
           const SizedBox(height: 4),
           ShaderMask(
             shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]).createShader(bounds),
             child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
           ),
        ]),
      ),
    );
  }
  
  void _confirmDelete(BuildContext context, Category category) {
    if ((category.eventsCount ?? 0) > 0) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot delete category with active events')));
       return;
    }
    showDialog(context: context, builder: (ctx) => AlertDialog(
       title: const Text('Delete Category'),
       content: Text('Are you sure you want to delete "${category.name}"?'),
       actions: [
         TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
         TextButton(onPressed: () {
            ref.read(categoryListProvider.notifier).deleteCategory(category.id);
            Navigator.pop(ctx);
         }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
       ],
    ));
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({required this.category, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
     final colorMap = {
       'pink': Colors.pink, 'blue': Colors.blue, 'yellow': Colors.amber, 
       'purple': Colors.amber, 'green': Colors.green, 'red': Colors.red
     };
     final baseColor = colorMap[category.color ?? 'purple'] ?? Colors.amber;

     return Container(
       padding: const EdgeInsets.all(24),
       decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: baseColor.withOpacity(0.2)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: baseColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Text(category.icon ?? '📅', style: const TextStyle(fontSize: 24))),
                 Row(children: [
                    IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: onEdit),
                    IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), onPressed: onDelete),
                 ]),
              ],
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
               Text(category.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               const SizedBox(height: 4),
               Text(category.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${category.eventsCount ?? 0} events', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                TextButton(onPressed: (){}, child: Text('View Events →', style: TextStyle(color: baseColor, fontSize: 12))),
              ],
            )
         ],
       ),
     );
  }
}

class _CategoryModal extends StatefulWidget {
  final Category? category;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSave;

  const _CategoryModal({this.category, required this.onClose, required this.onSave});

  @override
  State<_CategoryModal> createState() => _CategoryModalState();
}

class _CategoryModalState extends State<_CategoryModal> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _iconCtrl;
  String _selectedColor = 'purple';
  
  final colors = ['pink', 'blue', 'yellow', 'purple', 'green', 'red'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category?.name ?? '');
    _descCtrl = TextEditingController(text: widget.category?.description ?? '');
    _iconCtrl = TextEditingController(text: widget.category?.icon ?? '');
    _selectedColor = widget.category?.color ?? 'purple';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
           width: 500,
           padding: const EdgeInsets.all(24),
           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
           child: Material(
             color: Colors.white,
             child: Column(
               mainAxisSize: MainAxisSize.min,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Text(widget.category == null ? 'Create Category' : 'Edit Category', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Category Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 16),
                  TextField(controller: _descCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 16),
                  TextField(controller: _iconCtrl, decoration: InputDecoration(labelText: 'Icon / Emoji', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 16),
                  const Text('Color Theme'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 12, children: colors.map((c) => GestureDetector(
                     onTap: () => setState(() => _selectedColor = c),
                     child: Container(
                       width: 40, height: 40,
                       decoration: BoxDecoration(
                         color: _getColor(c).withOpacity(0.2), 
                         border: Border.all(color: _selectedColor == c ? _getColor(c) : Colors.transparent, width: 2),
                         borderRadius: BorderRadius.circular(8)
                       ),
                       child: Center(child: Container(width: 20, height: 20, decoration: BoxDecoration(color: _getColor(c), shape: BoxShape.circle))),
                     ),
                  )).toList()),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                     TextButton(onPressed: widget.onClose, child: const Text('Cancel')),
                     const SizedBox(width: 16),
                     ElevatedButton(
                        onPressed: () => widget.onSave({
                           'name': _nameCtrl.text,
                           'description': _descCtrl.text,
                           'icon': _iconCtrl.text,
                           'color': _selectedColor,
                        }), 
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFDB913), foregroundColor: Colors.white),
                        child: Text(widget.category == null ? 'Create' : 'Save'),
                     ),
                  ])
               ],
             ),
           ),
        ),
      ),
    );
  }

  Color _getColor(String c) {
     switch (c) {
       case 'pink': return Colors.pink;
       case 'blue': return Colors.blue;
       case 'yellow': return Colors.amber; 
       case 'purple': return Colors.amber; 
       case 'green': return Colors.green; 
       case 'red': return Colors.red;
       default: return Colors.grey;
     }
  }
}
