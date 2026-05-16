import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vendor_app/data/models/bidding_event_model.dart';
import 'package:vendor_app/logic/providers/bid_provider.dart';
import '../../../theme/app_theme.dart';

class ServiceBidScreen extends ConsumerStatefulWidget {
  final int eventId;
  final BiddingServiceRequest service;

  const ServiceBidScreen({super.key, required this.eventId, required this.service});

  @override
  ConsumerState<ServiceBidScreen> createState() => _ServiceBidScreenState();
}

class _ServiceBidScreenState extends ConsumerState<ServiceBidScreen> {
  final _amountController = TextEditingController();
  final _timelineController = TextEditingController();
  final _notesController = TextEditingController();
  final _includesController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _advantagesController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _timelineController.dispose();
    _notesController.dispose();
    _includesController.dispose();
    _requirementsController.dispose();
    _advantagesController.dispose();
    super.dispose();
  }

  Future<void> _submitBid() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final submission = {
        'event_id': widget.service.id, // Using service ID as the target for the bid
        'amount': amount,
        'timeline_days': int.tryParse(_timelineController.text),
        'includes': _includesController.text.isNotEmpty 
            ? _includesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() 
            : null,
        'requirements': _requirementsController.text.isNotEmpty 
            ? _requirementsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() 
            : null,
        'advantages': _advantagesController.text.isNotEmpty 
            ? _advantagesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() 
            : null,
        'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      };

      await ref.read(bidsProvider.notifier).submitBid(submission);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Bid submitted successfully!'),
              ],
            ),
            backgroundColor: AppTheme.success,
          ),
        );
        context.pop(); // Return to Event Details
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting bid: $e'), backgroundColor: AppTheme.error),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bid: ${widget.service.category}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.tag, size: 18, color: AppTheme.emeraldGreen),
                      const SizedBox(width: 8),
                      Text(widget.service.category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
                    ],
                  ),
                  if (widget.service.description != null) ...[
                    const SizedBox(height: 12),
                    Text(widget.service.description!, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Budget: ₹${widget.service.lowestBid} - ₹${widget.service.highestBid}', 
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.gray700)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        child: Text('${widget.service.bidsCount} Bids', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Your Proposal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Form Fields
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Bid Amount (₹) *',
                prefixText: '₹ ',
                hintText: 'Enter your price',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timelineController,
              decoration: InputDecoration(
                labelText: 'Timeline (Days)',
                suffixText: 'days',
                hintText: 'e.g. 5',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _includesController,
              decoration: InputDecoration(
                labelText: 'What\'s Included?',
                hintText: 'Briefly list deliverables',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.white,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _requirementsController,
              decoration: InputDecoration(
                labelText: 'Requirements',
                hintText: 'What you need from client',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.white,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _advantagesController,
              decoration: InputDecoration(
                labelText: 'Why You?',
                hintText: 'Your USP',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.white,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes',
                hintText: 'Additional details',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: _isSubmitting 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Bid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
