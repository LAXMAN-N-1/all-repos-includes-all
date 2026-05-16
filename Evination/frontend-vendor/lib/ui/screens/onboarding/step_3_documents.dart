import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_app/data/models/onboarding/onboarding_models.dart';
import 'package:vendor_app/logic/providers/onboarding_provider.dart';

class Step3Documents extends ConsumerStatefulWidget {
  const Step3Documents({Key? key}) : super(key: key);

  @override
  ConsumerState<Step3Documents> createState() => _Step3DocumentsState();
}

class _Step3DocumentsState extends ConsumerState<Step3Documents> {
  final _panCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();

  // Mock upload implementation (URLs)
  String? _panUrl;
  String? _gstUrl;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("KYC Documents", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          
          _buildDocSection("PAN Card", _panCtrl, _panUrl, (url) => setState(() => _panUrl = url)),
          const SizedBox(height: 20),
          _buildDocSection("GST (Optional)", _gstCtrl, _gstUrl, (url) => setState(() => _gstUrl = url)),
          
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
                  child: state.isLoading ? const CircularProgressIndicator() : const Text("Submit Application"),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDocSection(String label, TextEditingController ctrl, String? currentUrl, Function(String) onUpload) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: '$label Number',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Mock upload
                    onUpload("http://mock.url/doc.pdf"); 
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mock Upload Success!")));
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload File"),
                ),
                if (currentUrl != null)
                   const Padding(
                     padding: EdgeInsets.only(left: 10),
                     child: Icon(Icons.check_circle, color: Colors.green),
                   )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _submit() async {
    // Basic validation
    if (_panCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PAN Number is required")));
      return;
    }

    final docs = <DocItem>[];
    if (_panUrl != null) docs.add(DocItem(type: 'pan', url: _panUrl!, number: _panCtrl.text));
    if (_gstUrl != null) docs.add(DocItem(type: 'gst', url: _gstUrl!, number: _gstCtrl.text));

    // 1. Submit Docs
    final success = await ref.read(onboardingProvider.notifier).submitDocuments(docs);
    if (success) {
      // 2. Final Submit
       final submitted = await ref.read(onboardingProvider.notifier).finalSubmit();
       if (submitted) {
         // Navigate to Success
         // context.go('/onboarding/success'); // Needs GoRouter setup
       }
    }
  }
}
