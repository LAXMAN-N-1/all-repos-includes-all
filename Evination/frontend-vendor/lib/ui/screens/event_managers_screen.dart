import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers/event_manager_provider.dart';
import '../../data/models/event_manager_model.dart';
import '../../theme/app_theme.dart';

class EventManagersScreen extends ConsumerWidget {
  const EventManagersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managersAsync = ref.watch(eventManagersProvider);
    final stats = ref.watch(managerStatsProvider);

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
                      child: const Text('Event Managers', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    Text('Manage and assign event managers to events', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                ElevatedButton.icon(
                   onPressed: () { 
                      // TODO: Add Manager Dialog
                   },
                   icon: const Icon(Icons.add, color: Colors.white),
                   label: const Text('Add Manager', style: TextStyle(color: Colors.white)),
                   style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFDB913), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                 ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                _StatCard(title: 'Total Managers', value: '${stats['total']}'),
                const SizedBox(width: 16),
                _StatCard(title: 'Available Now', value: '${stats['available']}'),
                const SizedBox(width: 16),
                _StatCard(title: 'Active Events', value: '${stats['activeEvents']}'),
                const SizedBox(width: 16),
                _StatCard(title: 'Avg Rating', value: (stats['avgRating'] as double).toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 24),

            // Search
             Container(
               width: 400, // Limit width of search bar
               child: TextField(
                  decoration: InputDecoration(
                     prefixIcon: const Icon(Icons.search),
                     hintText: 'Search managers...',
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => ref.read(managerSearchProvider.notifier).update(val),
                ),
             ),
            const SizedBox(height: 24),

            // Grid
            managersAsync.when(
              data: (managers) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 280, // Fixed height for cards
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: managers.length,
                itemBuilder: (context, index) => _ManagerCard(manager: managers[index]),
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

class _ManagerCard extends StatelessWidget {
  final EventManager manager;
  const _ManagerCard({required this.manager});

  @override
  Widget build(BuildContext context) {
    final isAvailable = manager.status == 'Available';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration, // Reuse common decoration
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Info
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(manager.avatar ?? '?', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(manager.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(manager.email, style: TextStyle(color: Colors.grey[600], fontSize: 12), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.green[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(manager.status, style: TextStyle(color: isAvailable ? Colors.green[700] : Colors.orange[700], fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(icon: Icons.calendar_today, label: 'Active', value: '${manager.activeEvents}'),
              _MiniStat(icon: Icons.check_circle_outline, label: 'Completed', value: '${manager.completedEvents}'),
              _MiniStat(icon: Icons.star_border, label: 'Rating', value: '${manager.rating}'),
            ],
          ),
          const Spacer(),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDB913),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Assign'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFFDB913)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
