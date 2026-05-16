import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common_input.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_textarea.dart';
import '../../../logic/providers/vendor_provider.dart';
import '../../../data/models/vendor/vendor_registration_model.dart';
import '../../../theme/app_theme.dart';

class AddVendorScreen extends ConsumerStatefulWidget {
  const AddVendorScreen({super.key});

  @override
  ConsumerState<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends ConsumerState<AddVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _companyController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pricingController = TextEditingController();
  final _servicesController = TextEditingController();
  final _areasController = TextEditingController();

  // Optional Bank/Docs
  final _bankNameController = TextEditingController();
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _licenseController = TextEditingController();
  final _insuranceController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = VendorRegistrationModel(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      companyName: _companyController.text.trim(),
      businessType: _businessTypeController.text.trim(),
      contactPerson: _contactPersonController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      servicesDescription: _servicesController.text.trim(),
      pricingRange: _pricingController.text.trim(),
      serviceAreas: _areasController.text.trim(),
      
      // Optional/Placeholders
      businessLicenseUrl: _licenseController.text.trim().isEmpty ? null : _licenseController.text.trim(),
      insuranceCertUrl: _insuranceController.text.trim().isEmpty ? null : _insuranceController.text.trim(),
      bankName: _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
      accountNumber: _accountController.text.trim().isEmpty ? null : _accountController.text.trim(),
      ifscCode: _ifscController.text.trim().isEmpty ? null : _ifscController.text.trim(),
    );

    final success = await ref.read(vendorProvider.notifier).createVendor(data);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vendor added successfully')));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add vendor')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Vendor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Account Information'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: CommonInput(controller: _emailController, label: 'Email (Username)', validator: (v) => v!.isEmpty ? 'Required' : null)),
                  const SizedBox(width: 16),
                  Expanded(child: CommonInput(controller: _passwordController, label: 'Password', obscureText: true, validator: (v) => v!.length < 6 ? 'Min 6 chars' : null)),
                ],
              ),
              const SizedBox(height: 24),

              _sectionTitle('Business Details'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: CommonInput(controller: _companyController, label: 'Company Name', validator: (v) => v!.isEmpty ? 'Required' : null)),
                  const SizedBox(width: 16),
                  Expanded(child: CommonInput(controller: _businessTypeController, label: 'Business Type')),
                ],
              ),
              const SizedBox(height: 16),
              CommonInput(controller: _contactPersonController, label: 'Contact Person', validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: CommonInput(controller: _phoneController, label: 'Phone', validator: (v) => v!.isEmpty ? 'Required' : null)),
                  const SizedBox(width: 16),
                  Expanded(child: CommonInput(controller: _cityController, label: 'City', validator: (v) => v!.isEmpty ? 'Required' : null)),
                ],
              ),
              const SizedBox(height: 16),
              CommonInput(controller: _addressController, label: 'Full Address', validator: (v) => v!.isEmpty ? 'Required' : null),
              
              const SizedBox(height: 24),
              _sectionTitle('Services'),
              const SizedBox(height: 16),
              CommonTextarea(controller: _servicesController, label: 'Services Description', minLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: CommonInput(controller: _pricingController, label: 'Pricing Range')),
                  const SizedBox(width: 16),
                  Expanded(child: CommonInput(controller: _areasController, label: 'Service Areas')),
                ],
              ),

              const SizedBox(height: 32),
              CommonButton(
                text: _isLoading ? 'Creating...' : 'Create Vendor',
                onPressed: _isLoading ? null : _submit,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary800));
  }
}
