import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vendor_app/theme/app_theme.dart';
import 'package:vendor_app/logic/providers/vendor_bidding_provider.dart';

class LeadsListScreen extends ConsumerWidget {
  const LeadsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Leads'),
        backgroundColor: AppTheme.emeraldGreen,
        foregroundColor: Colors.white,
      ),
      body: leadsAsync.when(
        data: (leads) {
          if (leads.isEmpty) return const Center(child: Text('No new leads found.'));
          return ListView.builder(
            itemCount: leads.length,
            itemBuilder: (context, index) {
              final lead = leads[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lead.eventName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                       Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(lead.eventDate),
                          const SizedBox(width: 16),
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(lead.city ?? "Unknown"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Budget: ${lead.budget}"),
                      if (lead.subCategory != null)
                         Text("Type: ${lead.subCategory}", style: TextStyle(color: Colors.blue[700])),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/leads/bid/${lead.id}', extra: lead),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.emeraldGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Submit Quote'),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (e, s) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
