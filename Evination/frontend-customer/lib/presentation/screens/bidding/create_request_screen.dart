import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/bidding_provider.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventTypeController = TextEditingController();
  final _dateController = TextEditingController(); // Better with DatePicker
  final _cityController = TextEditingController();
  final _budgetController = TextEditingController();
  final _guestCountController = TextEditingController();
  final _requirementsController = TextEditingController();
  
  // New Fields
  String _selectedSubCategory = 'General';
  // Images picker could be added here

  @override
  void dispose() {
    _eventTypeController.dispose();
    _dateController.dispose();
    _cityController.dispose();
    _budgetController.dispose();
    _guestCountController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "event_type": _eventTypeController.text,
        "sub_category": _selectedSubCategory,
        "event_date": _dateController.text, // Format: YYYY-MM-DD
        "city": _cityController.text,
        "budget": double.tryParse(_budgetController.text) ?? 0,
        "guest_count": int.tryParse(_guestCountController.text) ?? 0,
        "requirements": _requirementsController.text
      };

      try {
        await ref.read(biddingControllerProvider.notifier).createRequest(data);
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Request Created Successfully!'))
           );
           context.pop(); // Go back
           // ref.refresh(myRequestsProvider); // Auto-refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(biddingControllerProvider);
    final isLoading = state is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Post Event Request')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedSubCategory,
                  items: ['General', 'Hindu Wedding', 'Corporate', 'Birthday']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSubCategory = val!),
                  decoration: const InputDecoration(labelText: "Sub Category"),
                ),
                TextFormField(
                  controller: _eventTypeController,
                  decoration: const InputDecoration(labelText: "Event Type (e.g. Marriage)"),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: "Date (YYYY-MM-DD)"),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: "City"),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _budgetController,
                  decoration: const InputDecoration(labelText: "Budget"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _guestCountController,
                  decoration: const InputDecoration(labelText: "Guest Count"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _requirementsController,
                  decoration: const InputDecoration(labelText: "Requirements / Notes"),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading ? const CircularProgressIndicator() : const Text("Post Request"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
