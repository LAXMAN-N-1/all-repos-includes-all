import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/bid_provider.dart';
import '../../data/models/bid_model.dart';
import '../../theme/app_theme.dart';

class QuoteDetailsScreen extends ConsumerWidget {
  final int bidId;
  const QuoteDetailsScreen({super.key, required this.bidId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We reuse eventBidsProvider but we need a single bid. 
    // Ideally we should have a 'getBid(id)' provider. 
    // For now, let's assume we can fetch it or find it if we have the list kept.
    // Given the architecture, I'll create a future provider for a single bid or just filter.
    // Since we don't have a single-bid endpoint in `BidService` yet visible, I'll assume we might need to add it or use the list.
    // However, looking at `BidService` (inferred), `getBids` gets all. 
    // I'll implement a specific fetch in `BidService` later if needed, but for now let's hack it by fetching event bids if we knew eventId, but we don't.
    // Actually, `VendorBid` by ID is a standard GET. Let's assume `bidDetailProvider` exists or I'll add it logic here.
    
    // TEMPORARY: Since I didn't add `getBidById` to service, I will use a hypothetical provider `bidDetailProvider`.
    // Wait, I should implement `bidDetailProvider`.
    
    final bidAsync = ref.watch(bidDetailProvider(bidId));

    return Scaffold(
      body: bidAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading quote: $err')),
        data: (quote) => _buildContent(context, quote),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Bid quote) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final subtotal = (quote.lineItems?.fold<double>(0, (sum, item) => sum + (item['total'] as num).toDouble()) ?? quote.amount); 
    // Fallback to amount if lines missing. If lines exist, sum them.
    // Actually logic: Amount usually is Total.
    
    final tax = quote.tax ?? 0;
    final discount = quote.discount ?? 0;
    final total = quote.amount; // Should match subtotal + tax - discount

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Link
          TextButton.icon(
            onPressed: () => context.go('/orders'), // Or back to comparison if from there
            icon: const Icon(Icons.arrow_back, size: 20),
            label: const Text('Back to Orders'), // User context
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Title & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                 Text('Quote #${quote.id}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 4),
                 Text('For Event: ${quote.eventName ?? 'Unknown'}', style: TextStyle(color: Colors.grey[600])),
              ]),
              Row(children: [
                OutlinedButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.download, size: 16), 
                  label: const Text('Download PDF'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12)),
                  child: Text(quote.status, style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 24),

          // Quote Card (Gradient)
          Container(
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(16),
               boxShadow: AppTheme.cardDecoration.boxShadow,
               color: Colors.white,
             ),
             clipBehavior: Clip.antiAlias,
             child: Column(
               children: [
                 // Gradient Header
                 Container(
                   padding: const EdgeInsets.all(32),
                   decoration: const BoxDecoration(
                     gradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF2563EB)]),
                   ),
                   child: Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Quote Information', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _WhiteInfo('Quote ID', '${quote.id}'),
                          _WhiteInfo('Valid Until', quote.validUntil != null ? DateFormat('MMM dd, yyyy').format(quote.validUntil!) : '-'),
                          _WhiteInfo('Status', quote.status),
                       ])),
                       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Vendor Details', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Text(quote.vendorName ?? '-', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Contact: ${quote.vendorContact ?? "-"}', style: const TextStyle(color: Colors.white70)),
                          Text(quote.vendorEmail ?? '-', style: const TextStyle(color: Colors.white70)),
                          Text(quote.vendorPhone ?? '-', style: const TextStyle(color: Colors.white70)),
                       ])),
                     ],
                   ),
                 ),
                 
                 // Event Details
                 Padding(
                   padding: const EdgeInsets.all(32),
                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Event Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Row(
                         children: [
                           _IconInfo(Icons.inventory_2_outlined, 'Event', quote.eventName ?? '-'),
                           const SizedBox(width: 48),
                           _IconInfo(Icons.calendar_today_outlined, 'Date', quote.eventDate != null ? DateFormat('MMM dd, yyyy').format(quote.eventDate!) : '-'),
                           const SizedBox(width: 48),
                           _IconInfo(Icons.location_on_outlined, 'Location', quote.eventLocation ?? '-'),
                         ],
                      ),
                   ]),
                 ),
                 const Divider(height: 1),

                 // Line Items
                 Padding(
                   padding: const EdgeInsets.all(32),
                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Quote Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Table(
                        columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
                        children: [
                          TableRow(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))), children: [
                             const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('Description', style: TextStyle(color: Colors.grey))),
                             const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('Qty', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey))),
                             const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('Unit Price', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey))),
                             const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('Total', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey))),
                          ]),
                          if (quote.lineItems != null)
                             ...quote.lineItems!.map((item) => TableRow(children: [
                                Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(item['description'] ?? '')),
                                Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('${item['quantity']}', textAlign: TextAlign.right)),
                                Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(currency.format(item['unit_price'] ?? item['unitPrice']), textAlign: TextAlign.right)),
                                Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(currency.format(item['total']), textAlign: TextAlign.right)),
                             ])),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 300,
                          child: Column(children: [
                            _SummaryRow('Subtotal', currency.format(subtotal)),
                            _SummaryRow('Tax', currency.format(tax)),
                            _SummaryRow('Discount', '-${currency.format(discount)}', color: Colors.green),
                            const Divider(height: 24),
                            _SummaryRow('Total', currency.format(total), isBold: true, fontSize: 18),
                          ]),
                        ),
                      ),
                   ]),
                 ),
                 const Divider(height: 1),
                 
                 // Terms
                 if (quote.terms != null && quote.terms!.isNotEmpty)
                 Padding(
                   padding: const EdgeInsets.all(32),
                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Terms & Conditions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...quote.terms!.map((t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                         const Icon(Icons.check, size: 16, color: Colors.green),
                         const SizedBox(width: 8),
                         Expanded(child: Text(t, style: TextStyle(color: Colors.grey[600]))),
                      ]))),
                   ]),
                 ),

                 // Notes
                 Container(
                   width: double.infinity,
                   padding: const EdgeInsets.all(32),
                   color: Colors.grey[50], 
                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Additional Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(quote.vendorNotes ?? 'No notes provided.', style: TextStyle(color: Colors.grey[600])),
                   ]),
                 )
               ],
             ),
          ),
          
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
               ElevatedButton.icon(
                 onPressed: () {}, 
                 icon: const Icon(Icons.check), 
                 label: const Text('Approve Quote'),
                 style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFDB913), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
               ),
               const SizedBox(width: 16),
               OutlinedButton(
                 onPressed: () {}, 
                 child: const Text('Request Changes'),
                 style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
               ),
               const SizedBox(width: 16),
               OutlinedButton.icon(
                 onPressed: () {}, 
                 icon: const Icon(Icons.close),
                 label: const Text('Reject Quote'),
                 style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
               ),
               const Spacer(),
               if (quote.eventId != null)
               OutlinedButton(
                 onPressed: () => context.push('/orders/comparison/${quote.eventId}'),
                 child: const Text('Compare Quotes'),
                 style: OutlinedButton.styleFrom(foregroundColor: Colors.amber, side: const BorderSide(color: Colors.amber), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
               ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _WhiteInfo extends StatelessWidget {
  final String label;
  final String value;
  const _WhiteInfo(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$label: $value', style: const TextStyle(color: Colors.white70)),
    );
  }
}

class _IconInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _IconInfo(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
       Icon(icon, color: Colors.grey[400]),
       const SizedBox(width: 12),
       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
       ]),
    ]);
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;
  final Color? color;
  const _SummaryRow(this.label, this.value, {this.isBold = false, this.fontSize = 14, this.color});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
         Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.grey[600])),
         Text(value, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
      ]),
    );
  }
}
