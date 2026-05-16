import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/bid_model.dart';
import '../../logic/providers/bid_provider.dart';
import '../../theme/app_theme.dart';

class AdminBidActionDialog extends ConsumerStatefulWidget {
  final Bid bid;
  final String actionType; // 'accept' or 'reject'

  const AdminBidActionDialog({super.key, required this.bid, required this.actionType});

  @override
  ConsumerState<AdminBidActionDialog> createState() => _AdminBidActionDialogState();
}

class _AdminBidActionDialogState extends ConsumerState<AdminBidActionDialog> {
  final _notesController = TextEditingController();
  bool _isLoading = false;

  bool get isAccept => widget.actionType == 'accept';

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    try {
      if (isAccept) {
        await ref.read(bidsProvider.notifier).approveBid(widget.bid.id, _notesController.text);
        if (mounted) {
          Navigator.pop(context); // Close dialog
          context.go('/admin/bidding/assigned/${widget.bid.id}');
        }
      } else {
        await ref.read(bidsProvider.notifier).rejectBid(widget.bid.id, _notesController.text);
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = isAccept ? Colors.green : Colors.red;
    final title = isAccept ? 'Accept Bid' : 'Reject Bid';
    final infoText = isAccept 
        ? 'The vendor will be notified of the acceptance and can proceed with the event preparation.'
        : 'The vendor will be notified of the rejection with the reason provided.';

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(title, style: AppTheme.heading.copyWith(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              '${widget.bid.vendorName ?? 'Unknown'} - \$${widget.bid.amount}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Notes Input
            Text(
              isAccept ? 'Acceptance Notes (Optional)' : 'Rejection Reason',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: isAccept ? 'Add any notes for the vendor...' : 'Please provide a reason for rejection...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                border: Border.all(color: color.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(infoText, style: TextStyle(color: color.shade700, fontSize: 13)),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Confirm ${isAccept ? "Accept" : "Reject"}', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
