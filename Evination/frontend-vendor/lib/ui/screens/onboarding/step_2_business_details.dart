import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_app/data/models/onboarding/onboarding_models.dart';
import 'package:vendor_app/logic/providers/onboarding_provider.dart';

class Step2BusinessDetails extends ConsumerStatefulWidget {
  const Step2BusinessDetails({Key? key}) : super(key: key);

  @override
  ConsumerState<Step2BusinessDetails> createState() => _Step2BusinessDetailsState();
}

class _Step2BusinessDetailsState extends ConsumerState<Step2BusinessDetails> {
  final _formKey = GlobalKey<FormState>();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  // Mock Categories
  final List<Map<String, dynamic>> _allCategories = [
    {'id': 1, 'name': 'Weddings'},
    {'id': 2, 'name': 'Corporate Events'},
    {'id': 3, 'name': 'Parties'},
  ];
  final Set<int> _selectedCategories = {};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Business Details", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityCtrl,
                    decoration: const InputDecoration(labelText: 'City *', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateCtrl,
                    decoration: const InputDecoration(labelText: 'State *', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
             const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description/Bio', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            
            const SizedBox(height: 20),
            Text("Select Categories *", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: _allCategories.map((cat) {
                final isSelected = _selectedCategories.contains(cat['id']);
                return FilterChip(
                  label: Text(cat['name']),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) _selectedCategories.add(cat['id']);
                      else _selectedCategories.remove(cat['id']);
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedCategories.isEmpty)
              const Text("Please select at least one", style: TextStyle(color: Colors.red, fontSize: 12)),

            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: () => ref.read(onboardingProvider.notifier).prevStep(),
                  child: const Text("Back"),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading ? const CircularProgressIndicator() : const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedCategories.isNotEmpty) {
      final req = BusinessDetailsRequest(
        address: _addressCtrl.text,
        city: _cityCtrl.text,
        state: _stateCtrl.text,
        description: _descCtrl.text,
        categories: _selectedCategories.map((id) => CategorySelection(category_id: id)).toList(),
      );
      ref.read(onboardingProvider.notifier).submitBusinessDetails(req);
    }
  }
}
