import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vendor_app/logic/providers/vendor_bidding_provider.dart';
import 'package:vendor_app/data/models/bidding/lead_model.dart';
import 'package:vendor_app/theme/app_theme.dart';

class BidSubmissionScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final LeadModel? lead;

  const BidSubmissionScreen({super.key, required this.bookingId, this.lead});

  @override
  ConsumerState<BidSubmissionScreen> createState() => _BidSubmissionScreenState();
}

class _BidSubmissionScreenState extends ConsumerState<BidSubmissionScreen> {
  final _amountController = TextEditingController();
  final _proposalController = TextEditingController();
  final _timelineController = TextEditingController(text: '7');
  final _advantagesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    _proposalController.dispose();
    _timelineController.dispose();
    _advantagesController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final proposal = _proposalController.text;

      // In a real app, we'd pass all fields to the backend. 
      // For now, focusing on amount and proposal as primary.
      await ref.read(bidSubmissionProvider.notifier).submitBid(widget.bookingId, amount, proposal);
      
      final state = ref.read(bidSubmissionProvider);
      if (state.hasError) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${state.error}")));
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bid Submitted Successfully!")));
           context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bidSubmissionProvider);
    final isLoading = state is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lead?.eventName ?? "Submit Bid"),
        backgroundColor: AppTheme.emeraldGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.lead != null) ...[
                 Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: AppTheme.mintWhisper,
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Row(
                     children: [
                       Icon(Icons.info_outline, color: AppTheme.emeraldGreen),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text("Customer Budget", style: TextStyle(color: AppTheme.darkEvergreen, fontSize: 12)),
                             Text("${widget.lead!.budget}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.emeraldGreen)),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
                 const SizedBox(height: 24),
              ],
              
              const Text("Your Quotation Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: "Your Quote Amount (₹)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixText: "₹ ",
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _timelineController,
                decoration: InputDecoration(
                  labelText: "Estimated Timeline (Days)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixText: " days",
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _proposalController,
                decoration: InputDecoration(
                  labelText: "Proposal / Pitch",
                  hintText: "Explain why the customer should choose you...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _advantagesController,
                decoration: InputDecoration(
                  labelText: "Key Advantages (Comma separated)",
                  hintText: "e.g. Premium equipment, 24/7 support",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkEvergreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading ? null : _submit,
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("SUBMIT QUOTATION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                ),
              ),
              
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "Platform will add service fees before customer sees final price",
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
