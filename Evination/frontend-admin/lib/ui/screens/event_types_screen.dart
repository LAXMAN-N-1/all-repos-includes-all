import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers/event_type_provider.dart';
import '../../data/models/event_type_model.dart';
import '../../theme/app_theme.dart';

class EventTypesScreen extends ConsumerWidget {
  const EventTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(eventTypesProvider);
    final stats = ref.watch(eventTypeStatsProvider);

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFDB913), Color(0xFFE5A711)],
                      ).createShader(bounds),
                      child: const Text('Event Types', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    Text('Define different types of events within categories', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                ElevatedButton.icon(
                   onPressed: () { /* TODO: Add Type Dialog */ },
                   icon: const Icon(Icons.add, color: Colors.white),
                   label: const Text('Add Type', style: TextStyle(color: Colors.white)),
                   style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFDB913), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                 ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                _StatCard(title: 'Total Types', value: '${stats['totalTypes']}'),
                const SizedBox(width: 16),
                _StatCard(title: 'Most Used', value: '${stats['mostUsed']}'),
                const SizedBox(width: 16),
                _StatCard(title: 'Events Tagged', value: '${stats['tagged']}'),
              ],
            ),
            const SizedBox(height: 24),

            // Grid
            typesAsync.when(
              data: (types) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisExtent: 240,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: types.length,
                itemBuilder: (context, index) => _TypeCard(type: types[index]),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardDecoration,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
           Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
           const SizedBox(height: 4),
           ShaderMask(
             shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]).createShader(bounds),
             child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
           ),
        ]),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final EventType type;
  const _TypeCard({required this.type});

  Color _getColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'purple': return Colors.amber;
      case 'yellow': return Colors.orange; // Material yellow is too light for text
      case 'orange': return Colors.deepOrange;
      case 'pink': return Colors.pink;
      case 'red': return Colors.red;
      case 'indigo': return Colors.amber;
      default: return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(type.color);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.label_outline, color: color, size: 24),
              ),
              Row(
                children: [
                   IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: (){}),
                   IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), onPressed: (){}),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(type.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(type.category ?? 'Uncategorized', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 8),
          Text('${type.count} events', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }
}
