import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers/event_provider.dart';
import '../../data/models/event_summary_model.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventListAsync = ref.watch(eventListProvider);
    final statsAsync = ref.watch(eventStatsProvider);

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
                      child: const Text('Event Management', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    Text('Manage and track all your events', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                ElevatedButton.icon(
                   onPressed: () { 
                      // TODO: Navigate to Create Event
                   },
                   icon: const Icon(Icons.add, color: Colors.white),
                   label: const Text('Create Event', style: TextStyle(color: Colors.white)),
                   style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFDB913), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                 ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Logic
            statsAsync.when(
              data: (stats) => Row(
                children: [
                  _StatCard(title: 'Total Events', value: '${stats.totalEvents}'),
                  const SizedBox(width: 16),
                  _StatCard(title: 'Active Events', value: '${stats.activeEvents}'),
                  const SizedBox(width: 16),
                  _StatCard(title: 'Total Attendees', value: '${stats.totalAttendees}'), // Todo formatted
                  const SizedBox(width: 16),
                  _StatCard(title: 'Total Budget', value: '₹${(stats.totalBudget/1000).toStringAsFixed(0)}K'),
                ],
              ),
              loading: () => const LinearProgressIndicator(), 
              error: (e, s) => Text('Error loading stats: $e'),
            ),
            const SizedBox(height: 24),

            // Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                       prefixIcon: const Icon(Icons.search),
                       hintText: 'Search events...',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => ref.read(eventSearchFilterProvider.notifier).update(val),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: ref.watch(eventStatusFilterProvider),
                      items: ['All Status', 'Planning', 'Confirmed', 'Active', 'Completed', 'Cancelled'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => ref.read(eventStatusFilterProvider.notifier).update(val!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Table
            eventListAsync.when(
              data: (events) => Container(
                decoration: AppTheme.cardDecoration,
                padding: const EdgeInsets.all(0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                    columns: const [
                      DataColumn(label: Text('Event', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Category/Type', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Date & Location', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Attendees', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Budget', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Manager', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: events.map((e) => DataRow(
                       cells: [
                          DataCell(Text(e.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                          DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                             Text(e.category, style: const TextStyle(fontSize: 13)),
                             Text(e.type, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ])),
                          DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                             Row(children: [const Icon(Icons.calendar_today, size: 12, color: Colors.grey), const SizedBox(width: 4), Text(e.date, style: const TextStyle(fontSize: 12))]),
                             const SizedBox(height: 2),
                             Row(children: [const Icon(Icons.location_on, size: 12, color: Colors.grey), const SizedBox(width: 4), Text(e.location, style: const TextStyle(fontSize: 12))]),
                          ])),
                          DataCell(Row(children: [const Icon(Icons.people, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('${e.attendees}')])),
                          DataCell(Text('₹${(e.budget/1000).toStringAsFixed(0)}K')),
                          DataCell(Text(e.manager ?? '-')),
                          DataCell(_StatusBadge(status: e.status)),
                          DataCell(Row(children: [
                             IconButton(icon: const Icon(Icons.visibility, size: 18), onPressed: (){}),
                             IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: (){}),
                             IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: (){}),
                          ])),
                       ]
                    )).toList(),
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, s) => Center(child: Text('Error: $err')),
            )
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    
    switch (status) {
      case 'Planning': color = Colors.blue[700]!; bg = Colors.blue[50]!; break;
      case 'Confirmed': color = Colors.green[700]!; bg = Colors.green[50]!; break;
      case 'Active': color = Colors.amber[700]!; bg = Colors.amber[50]!; break;
      case 'Completed': color = Colors.grey[700]!; bg = Colors.grey[50]!; break;
      case 'Cancelled': color = Colors.red[700]!; bg = Colors.red[50]!; break;
      default: color = Colors.grey[700]!; bg = Colors.grey[50]!; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
