import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/bidding_provider.dart';

class RequestListScreen extends ConsumerWidget {
  const RequestListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-request'),
        child: const Icon(Icons.add),
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
             return const Center(child: Text('No requests found. Create one!'));
          }
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return Card(
                child: ListTile(
                  title: Text(req.eventName),
                  subtitle: Text("${req.eventDate} | ${req.status}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.push('/request-details/${req.id}', extra: req),
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
