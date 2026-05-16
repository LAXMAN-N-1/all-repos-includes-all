import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_panel/logic/providers/admin_bidding_provider.dart';
import 'package:admin_panel/data/models/bidding/admin_bid_model.dart';
import 'package:admin_panel/theme/app_theme.dart';

class BidCurationScreen extends ConsumerStatefulWidget {
  final int requestId;

  const BidCurationScreen({super.key, required this.requestId});

  @override
  ConsumerState<BidCurationScreen> createState() => _BidCurationScreenState();
}

class _BidCurationScreenState extends ConsumerState<BidCurationScreen> {
  final List<int> _selectedBidIds = [];

  void _onAction(BuildContext context, int bidId, String action) async {
    await ref.read(curationProvider.notifier).curate(bidId, action);
    final state = ref.read(curationProvider);
    
    if (state.hasError) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${state.error}")));
    } else {
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bid $action success!")));
         ref.invalidate(requestBidsProvider(widget.requestId));
      }
    }
  }

  void _pushToCustomer() async {
    if (_selectedBidIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select at least one bid to push.")));
      return;
    }

    await ref.read(curationProvider.notifier).pushToCustomer(widget.requestId, _selectedBidIds);
    final state = ref.read(curationProvider);
    
    if (state.hasError) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${state.error}")));
    } else {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bids pushed to customer successfully!")));
         ref.invalidate(requestBidsProvider(widget.requestId));
         setState(() => _selectedBidIds.clear());
      }
    }
  }

  Widget _buildBreakdownRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bidsAsync = ref.watch(requestBidsProvider(widget.requestId));

    return Scaffold(
      appBar: AppBar(title: Text('Curate Bids (Req #${widget.requestId})')),
      body: bidsAsync.when(
        data: (bids) {
          if (bids.isEmpty) return const Center(child: Text('No bids received yet.'));
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: bids.length,
                  itemBuilder: (context, index) {
                    final bid = bids[index];
                    final bool isShortlisted = bid.status == 'accepted' || bid.status == 'shortlisted';
                    final bool isPushed = bid.isPushed == 1;
                    
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      color: isPushed ? Colors.blue[50] : null,
                      child: CheckboxListTile(
                        value: _selectedBidIds.contains(bid.id),
                        onChanged: isPushed ? null : (val) {
                          setState(() {
                            if (val == true) _selectedBidIds.add(bid.id);
                            else _selectedBidIds.remove(bid.id);
                          });
                        },
                        title: Row(
                          children: [
                            Expanded(child: Text("Vendor: ${bid.vendorName ?? 'ID: ${bid.vendorId}'}", style: const TextStyle(fontWeight: FontWeight.bold))),
                            if (!isPushed)
                              TextButton.icon(
                                onPressed: () => _editPricing(context, bid),
                                icon: const Icon(Icons.edit, size: 14),
                                label: const Text("Edit Price", style: TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Proposal: ${bid.proposal}"),
                            const SizedBox(height: 8),
                            if (bid.finalPrice != null && bid.finalPrice! > 0) ...[
                              Row(
                                children: [
                                  Text("Base: ₹${bid.amount}", style: TextStyle(color: Colors.grey[600], fontSize: 13, decoration: TextDecoration.lineThrough)),
                                  const SizedBox(width: 8),
                                  Text("Final: ₹${bid.finalPrice}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                                ],
                              ),
                              Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  title: const Text("View Breakdown", style: TextStyle(fontSize: 12, color: Colors.blue)),
                                  tilePadding: EdgeInsets.zero,
                                  childrenPadding: EdgeInsets.zero,
                                  dense: true,
                                  children: [
                                    _buildBreakdownRow("Platform Commission", "₹${bid.platformCommission?.toStringAsFixed(2)}"),
                                    _buildBreakdownRow("GST on Comm", "₹${bid.gstOnCommission?.toStringAsFixed(2)}"),
                                    _buildBreakdownRow("Gateway Fee", "₹${bid.gatewayFee?.toStringAsFixed(2)}"),
                                    const Divider(),
                                    _buildBreakdownRow("Total Customer Price", "₹${bid.finalPrice?.toStringAsFixed(2)}", isBold: true),
                                  ],
                                ),
                              ),
                            ] else 
                              Text("Amount: ₹${bid.amount}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              
                            if (isPushed) const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Chip(label: Text("PUSHED TO CUSTOMER"), backgroundColor: Colors.blue, labelStyle: TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ],
                        ),
                        secondary: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (bid.status == 'pending' || bid.status == 'submitted') ...[
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                onPressed: () => _onAction(context, bid.id, 'accept'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                onPressed: () => _onAction(context, bid.id, 'reject'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_selectedBidIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _pushToCustomer,
                    icon: const Icon(Icons.send),
                    label: Text("Push ${_selectedBidIds.length} Bids to Customer"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
            ],
          );
        },
        error: (e, s) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _editPricing(BuildContext context, AdminBidModel bid) {
      final priceCtrl = TextEditingController(text: (bid.finalPrice ?? bid.amount).toString());
      final commCtrl = TextEditingController(text: (bid.platformCommission ?? 0).toString());
      final notesCtrl = TextEditingController(text: "");

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Edit Bid Pricing"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               TextField(
                 controller: priceCtrl,
                 decoration: const InputDecoration(labelText: "Final Price (Customer View)"),
                 keyboardType: TextInputType.number,
               ),
               const SizedBox(height: 8),
               TextField(
                 controller: commCtrl,
                 decoration: const InputDecoration(labelText: "Platform Commission (Optional override)"),
                 keyboardType: TextInputType.number,
               ),
               const SizedBox(height: 8),
               TextField(
                 controller: notesCtrl,
                 decoration: const InputDecoration(labelText: "Notes (Internal)"),
               ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                  final price = double.tryParse(priceCtrl.text);
                  if (price == null) return;
                  final comm = double.tryParse(commCtrl.text);
                  
                  Navigator.pop(context);
                  await ref.read(curationProvider.notifier).updateBidPricing(
                      bid.id, 
                      price, 
                      commission: comm, // If 0 or null logic in backend handles auto-calc if omitted, but here we pass specific
                      notes: notesCtrl.text
                  );
                  ref.invalidate(requestBidsProvider(widget.requestId));
              },
              child: const Text("Save"),
            ),
          ],
        ),
      );
  }
}
