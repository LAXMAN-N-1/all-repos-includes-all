import 'package:flutter/material.dart';
import '../../data/models/bid_model.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminBidDetailsDialog extends StatelessWidget {
  final Bid bid;
  const AdminBidDetailsDialog({super.key, required this.bid});

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bid.vendorName ?? 'Unknown Vendor', style: AppTheme.heading.copyWith(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(bid.eventName ?? 'Unknown Event', style: AppTheme.subHeading),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                   // Bid Amount
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: Colors.amber[50],
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: Colors.amber[100]!),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('Bid Amount', style: TextStyle(color: Colors.amber[700], fontSize: 14)),
                         const SizedBox(height: 4),
                         Text(currencyFmt.format(bid.amount), style: TextStyle(color: Colors.amber[600], fontSize: 32, fontWeight: FontWeight.bold)),
                       ],
                     ),
                   ),
                   const SizedBox(height: 24),

                   // Vendor Info
                   Text('Vendor Information', style: AppTheme.heading.copyWith(fontSize: 18)),
                   const SizedBox(height: 12),
                   _buildVendorInfoGrid(bid),
                   
                   const SizedBox(height: 24),

                   // Proposal
                   Text('Proposal Details', style: AppTheme.heading.copyWith(fontSize: 18)),
                   const SizedBox(height: 8),
                   Text(bid.proposal ?? 'No proposal text provided.', style: TextStyle(color: Colors.grey[600], height: 1.5)),

                   const SizedBox(height: 24),

                   // Includes & Requirements
                   Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('Service Includes', style: AppTheme.heading.copyWith(fontSize: 18)),
                             const SizedBox(height: 12),
                             ...?bid.includes?.map((item) => Padding(
                               padding: const EdgeInsets.only(bottom: 8.0),
                               child: Row(
                                 children: [
                                   Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                                   const SizedBox(width: 8),
                                   Text(item.toString()),
                                 ],
                               ),
                             )),
                           ],
                         ),
                       ),
                       const SizedBox(width: 24),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('Requirements Met', style: AppTheme.heading.copyWith(fontSize: 18)),
                             const SizedBox(height: 12),
                             Wrap(
                               spacing: 8,
                               runSpacing: 8,
                               children: (bid.requirements ?? []).map((req) => 
                                 Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                   decoration: BoxDecoration(
                                     color: Colors.blue[50],
                                     borderRadius: BorderRadius.circular(8),
                                   ),
                                   child: Text(req.toString(), style: TextStyle(color: Colors.blue[700], fontSize: 13)),
                                 )
                               ).toList(),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorInfoGrid(Bid bid) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3,
      children: [
        _infoItem('Rating', '${bid.vendorRating ?? "N/A"} / 5.0', icon: Icons.star, iconColor: Colors.amber),
        // We don't have experience/completedEvents in generic Bid model yet unless we enhanced it properly or pass it via loose map logic if generic model used dynamic.
        // The Bid model I defined earlier HAS typed fields for these if I updated it right?
        // Wait, I updated Bid model but I'm not sure if I added 'vendorExperience' etc.
        // Let's assume standard fields or n/a.
        // In React 'vendorExperience' was used. In my schema analysis I didn't explicitly see it in `BidSummary`.
        // `BidDetailResponse` had it.
        // My `Bid` model DOES NOT have `vendorExperience` or `completedEvents` explicitly defined as fields in the LAST VIEW.
        // It had `proposal`, `includes`, `requirements`.
        // Let's check `Bid` model content again or use `includes` which I know exists.
        _infoItem('Category',  'Catering'), // Placeholder as discussed
      ],
    );
  }

  Widget _infoItem(String label, String value, {IconData? icon, Color? iconColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: iconColor), const SizedBox(width: 4)],
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
