import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vendor_app/data/models/bidding_event_model.dart';
import 'package:vendor_app/logic/providers/bid_provider.dart';
import '../../../theme/app_theme.dart';

class VendorBidSubmissionScreen extends ConsumerStatefulWidget {
  final int eventId;
  final List<BiddingServiceRequest> services;

  const VendorBidSubmissionScreen({super.key, required this.eventId, required this.services});

  @override
  ConsumerState<VendorBidSubmissionScreen> createState() => _VendorBidSubmissionScreenState();
}

class _VendorBidSubmissionScreenState extends ConsumerState<VendorBidSubmissionScreen> {
  int _currentStep = 0;
  List<Map<String, dynamic>> _bidData = [];
  bool _isSubmitting = false;

  // Controllers for current step
  final _amountController = TextEditingController();
  final _timelineController = TextEditingController();
  final _notesController = TextEditingController();
  final _includesController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _advantagesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize empty data for each service
    _bidData = List.generate(widget.services.length, (index) => {});
  }

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



  void _loadStepData(int step) {
    if (step >= _bidData.length) return;
    final data = _bidData[step];
    _amountController.text = data['amount']?.toString() ?? '';
    _timelineController.text = data['timeline_days']?.toString() ?? '';
    _notesController.text = data['notes'] ?? '';
    _includesController.text = data['includes'] ?? '';
    _requirementsController.text = data['requirements'] ?? '';
    _advantagesController.text = data['advantages'] ?? '';
  }

  void _saveCurrentStepData() {
    _bidData[_currentStep] = {
      'amount': double.tryParse(_amountController.text),
      'timeline_days': int.tryParse(_timelineController.text),
      'notes': _notesController.text,
      'includes': _includesController.text,
      'requirements': _requirementsController.text,
      'advantages': _advantagesController.text,
    };
  }

  Future<void> _submitAll() async {
    _saveCurrentStepData();

    // Validate
    for (int i = 0; i < widget.services.length; i++) {
      if (_bidData[i]['amount'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter amount for ${widget.services[i].category}')));
        setState(() => _currentStep = i);
        _loadStepData(i);
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      // Loop and submit each bid
      // In a real app complexity, we might want a batch API, but reusing existing provider method for now.
      for (int i = 0; i < widget.services.length; i++) {
        final service = widget.services[i];
        final data = _bidData[i];
        
        final submission = {
          'event_id': service.id,
          'amount': data['amount'],
          'timeline_days': data['timeline_days'],
          'includes': data['includes']?.toString().isNotEmpty == true 
              ? data['includes'].toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() 
              : null,
          'requirements': data['requirements']?.toString().isNotEmpty == true 
              ? data['requirements'].toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() 
              : null,
          'advantages': data['advantages']?.toString().isNotEmpty == true 
              ? data['advantages'].toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() 
              : null,
          'notes': data['notes']?.toString().isNotEmpty == true ? data['notes'] : null,
        };

        await ref.read(bidsProvider.notifier).submitBid(submission);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All bids submitted successfully!'), backgroundColor: AppTheme.success));
        context.go('/vendor/bidding/dashboard'); // Or back to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting bids: $e'), backgroundColor: AppTheme.error));
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _nextStep() {
    // Validate current
    if (double.tryParse(_amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    _saveCurrentStepData();

    if (_currentStep < widget.services.length - 1) {
      setState(() {
        _currentStep++;
      });
      _loadStepData(_currentStep);
    } else {
      _submitAll();
    }
  }

  void _prevStep() {
    _saveCurrentStepData();
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _loadStepData(_currentStep);
    } else {
       context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using a custom Stepper view or standard Stepper?
    // Standard Stepper is strictly vertical or horizontal and sometimes rigid.
    // Let's use a custom UI builder that looks like a stepper but gives us full control over the content area.
    final currentService = widget.services[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text('Bid Submission (${_currentStep + 1}/${widget.services.length})'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Custom Stepper Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: AppTheme.bgCard,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(widget.services.length, (index) {
                  final isCompleted = index < _currentStep;
                  final isCurrent = index == _currentStep;
                  
                  return Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent ? AppTheme.emeraldGreen : AppTheme.gray200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted 
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : Text('${index + 1}', style: TextStyle(color: isCurrent ? Colors.white : AppTheme.gray600, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(widget.services[index].category, style: TextStyle(color: isCurrent ? Colors.black : AppTheme.gray500, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                      if (index < widget.services.length - 1)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          width: 40,
                          height: 2,
                          color: AppTheme.gray200,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bid for ${currentService.category}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (currentService.description != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.info.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.info, size: 16, color: AppTheme.info),
                          const SizedBox(width: 8),
                          Expanded(child: Text(currentService.description!, style: const TextStyle(color: AppTheme.info))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // Form
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Your Bid Amount *',
                      prefixText: '₹ ',
                      hintText: 'Enter your competitive price',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _timelineController,
                    decoration: InputDecoration(
                      labelText: 'Completion Timeline (Days)',
                      hintText: 'e.g., 7',
                      suffixText: 'days',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                   TextField(
                    controller: _includesController,
                    decoration: InputDecoration(
                      labelText: 'What\'s Included in This Price?',
                      hintText: 'e.g., 3-course meal, setup, cleanup',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true, fillColor: Colors.white,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                   TextField(
                    controller: _requirementsController,
                    decoration: InputDecoration(
                      labelText: 'Any Requirements from Client?',
                      hintText: 'e.g., Venue access 2 hours before',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true, fillColor: Colors.white,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                   TextField(
                    controller: _advantagesController,
                    decoration: InputDecoration(
                      labelText: 'Why Choose You? (USP)',
                      hintText: 'e.g., Award-winning service',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true, fillColor: Colors.white,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                   TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Additional Notes / Proposal',
                      hintText: 'Any other details',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true, fillColor: Colors.white,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : _prevStep,
                    child: const Text('Back'),
                  )
                else
                  const SizedBox(), // Spacer
                  
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_currentStep == widget.services.length - 1 ? 'Submit All Bids' : 'Next Service'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
