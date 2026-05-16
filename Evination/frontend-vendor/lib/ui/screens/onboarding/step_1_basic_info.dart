import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_app/data/models/onboarding/onboarding_models.dart';
import 'package:vendor_app/logic/providers/onboarding_provider.dart';

class Step1BasicInfo extends ConsumerStatefulWidget {
  const Step1BasicInfo({Key? key}) : super(key: key);

  @override
  ConsumerState<Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends ConsumerState<Step1BasicInfo> {
  final _formKey = GlobalKey<FormState>();
  final _contactPersonCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); // Optional if already logged in

  String _vendorType = 'company';

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
            Text(
              "Let's get started",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            
            // Vendor Type Selection
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Company'),
                    value: 'company',
                    groupValue: _vendorType,
                    onChanged: (val) {
                      setState(() => _vendorType = val!);
                      ref.read(onboardingProvider.notifier).setVendorType(val!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Individual'),
                    value: 'individual',
                    groupValue: _vendorType,
                    onChanged: (val) {
                      setState(() => _vendorType = val!);
                      ref.read(onboardingProvider.notifier).setVendorType(val!);
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyNameCtrl,
              decoration: InputDecoration(
                labelText: _vendorType == 'company' ? 'Company Name' : 'Business/Professional Name',
                border: const OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactPersonCtrl,
              decoration: const InputDecoration(
                labelText: 'Contact Person Name',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Next'),
              ),
            ),
            
             if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(state.error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final req = InitiateRequest(
        vendor_type: _vendorType,
        company_name: _vendorType == 'company' ? _companyNameCtrl.text : null,
        business_name: _vendorType == 'individual' ? _companyNameCtrl.text : null,
        contact_person: _contactPersonCtrl.text,
        phone: _phoneCtrl.text,
      );
      ref.read(onboardingProvider.notifier).submitBasicInfo(req);
    }
  }
}
