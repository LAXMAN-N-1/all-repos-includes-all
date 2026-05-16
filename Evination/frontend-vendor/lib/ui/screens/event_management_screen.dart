import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/event_provider.dart';
import '../../data/models/event_summary_model.dart';
import '../../theme/app_theme.dart';

class EventManagementScreen extends ConsumerWidget {
  const EventManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);

    return Padding(
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
                   Text(
                    'Event Management',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create and manage event portfolios.',
                    style: GoogleFonts.inter(color: AppTheme.gray600),
                  ),
                 ],
               ),
               ElevatedButton.icon(
                 onPressed: () {}, 
                 icon: const Icon(Icons.add, color: Colors.white),
                 label: const Text('Create Event', style: TextStyle(color: Colors.white)),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppTheme.primaryGold,
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                 ),
               ),
             ],
           ),
          const SizedBox(height: 24),

          // Filters (Placeholder)
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                  child: DropdownButton(hint: const Text("Status"), items: const [], onChanged: (val){}),
                ),
              ),
              // Add more filters if needed
            ],
          ),
          const SizedBox(height: 24),

          // Event List
          Expanded(
            child: Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              child: eventsAsync.when(
                data: (events) => ListView.separated(
                  itemCount: events.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _EventListItem(event: event);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final EventSummary event;

  const _EventListItem({required this.event});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'planning': return Colors.blue;
      case 'completed': return Colors.grey;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Date Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('MMM').format(DateTime.tryParse(event.date) ?? DateTime.now()).toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.gray600),
                ),
                Text(
                  DateFormat('dd').format(DateTime.tryParse(event.date) ?? DateTime.now()),
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                 Row(
                   children: [
                     const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                     const SizedBox(width: 4),
                     Text(event.location ?? 'No Location', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                   ],
                 ),
              ],
            ),
          ),
          // Manager
           Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AppTheme.gray400),
                const SizedBox(width: 4),
                Text(
                  event.manager ?? 'Unassigned',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.gray700),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(event.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                event.status,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _getStatusColor(event.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Actions
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.grey), onPressed: (){}),
        ],
      ),
    );
  }
}
