import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eventifi_admin/features/events/presentation/event_controller.dart';
import 'package:eventifi_admin/features/events/presentation/widgets/event_form_dialog.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                    'Event Management',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                   Text(
                    'Manage events, schedules, and locations',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                    ),
                  ),
                 ],
               ),
              ElevatedButton.icon(
                onPressed: () {
                    showDialog(context: context, builder: (_) => const EventFormDialog());
                }, 
                icon: const Icon(Icons.add),
                label: const Text('Create Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
           Expanded(
             child: eventsAsync.when(
               loading: () => const Center(child: CircularProgressIndicator()),
               error: (err, stack) => Center(child: Text('Error: $err')),
               data: (events) {
                 if (events.isEmpty) {
                   return const Center(child: Text('No events found.'));
                 }
                 return ListView.separated(
                   separatorBuilder: (_, __) => const SizedBox(height: 16),
                   itemCount: events.length,
                   itemBuilder: (context, index) {
                     final event = events[index];
                     return Card(
                       elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                       child: ListTile(
                         contentPadding: const EdgeInsets.all(16),
                         leading: Container(
                           width: 60,
                           height: 60,
                           decoration: BoxDecoration(
                             color: Colors.amber[50],
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Text(DateFormat('MMM').format(event.date).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                               Text(DateFormat('dd').format(event.date), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber[800])),
                             ],
                           ),
                         ),
                         title: Text(event.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                         subtitle: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const SizedBox(height: 4),
                             Row(
                               children: [
                                 Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                                 const SizedBox(width: 4),
                                 Text(event.location, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                               ],
                             ),
                             if (event.description != null)
                             Padding(
                               padding: const EdgeInsets.only(top: 4.0),
                               child: Text(event.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                             )
                           ],
                         ),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             IconButton(
                               icon: const Icon(Icons.edit, size: 20),
                               onPressed: () {
                                 showDialog(context: context, builder: (_) => EventFormDialog(event: event));
                               },
                             ),
                             IconButton(
                               icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                               onPressed: () {
                                 ref.read(eventControllerProvider.notifier).deleteEvent(event.id);
                               },
                             ),
                           ],
                         ),
                       ),
                     );
                   },
                 );
               },
             )
           )
        ],
      ),
    );
  }
}
