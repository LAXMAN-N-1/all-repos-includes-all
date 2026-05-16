import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/bidding_provider.dart';
import '../../../data/models/booking/booking_model.dart';
import '../../../data/models/bid/bid_model.dart';

class RequestDetailScreen extends ConsumerWidget {
  final int requestId;
  final BookingModel? requestObj; // Passed as extra

  const RequestDetailScreen({super.key, required this.requestId, this.requestObj});

  void _showBidDetails(BuildContext context, WidgetRef ref, BidModel bid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Bid from Vendor ${bid.vendorId}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Proposal: ${bid.proposal}"),
            const SizedBox(height: 10),
            Text("Amount: \$${bid.finalPrice ?? bid.amount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (bid.finalPrice != null)
               Text("Includes Fees/Taxes", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
               Navigator.pop(context);
               await ref.read(biddingControllerProvider.notifier).selectBid(bid.id);
               // Refresh?
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bid Selected!')));
            },
            child: const Text("Select This Vendor"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If requestObj is null (deep link), we could fetch it. using just ID for bids now.
    
    final bidsAsync = ref.watch(requestBidsProvider(requestId));

    return Scaffold(
      appBar: AppBar(title: Text(requestObj?.eventName ?? "Request Details")),
      body: Column(
        children: [
          if (requestObj != null) 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${requestObj!.status}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Budget: ${requestObj!.budget}"),
                       Text("City: ${requestObj!.city}"),
                    ],
                  ),
                ),
              ),
            ),
          
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Received Bids", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          
          Expanded(
            child: bidsAsync.when(
              data: (bids) {
                if (bids.isEmpty) return const Center(child: Text("No bids received/shortlisted yet."));
                return ListView.builder(
                  itemCount: bids.length,
                  itemBuilder: (context, index) {
                    final bid = bids[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.store)),
                      title: Text("Vendor Quote: ${bid.finalPrice ?? bid.amount}"),
                      subtitle: Text(bid.proposal),
                      trailing: ElevatedButton(
                        onPressed: () => _showBidDetails(context, ref, bid),
                        child: const Text("View"),
                      ),
                    );
                  },
                );
              },
              error: (e, s) => Center(child: Text("Error: $e")),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          )
        ],
      ),
    );
  }
}
