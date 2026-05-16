import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventifi_admin/features/vendors/domain/vendor_models.dart';
import 'package:eventifi_admin/features/vendors/presentation/vendor_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorFormDialog extends ConsumerStatefulWidget {
  final Vendor? vendor;

  const VendorFormDialog({super.key, this.vendor});

  @override
  ConsumerState<VendorFormDialog> createState() => _VendorFormDialogState();
}

class _VendorFormDialogState extends ConsumerState<VendorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fnameController;
  late TextEditingController _lnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;

  @override
  void initState() {
    super.initState();
    _fnameController = TextEditingController(text: widget.vendor?.firstName ?? '');
    _lnameController = TextEditingController(text: widget.vendor?.lastName ?? '');
    _emailController = TextEditingController(text: widget.vendor?.email ?? '');
    _phoneController = TextEditingController(text: widget.vendor?.phone ?? '');
    _companyController = TextEditingController(text: widget.vendor?.companyName ?? '');
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vendor != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Vendor' : 'Add Vendor', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Row(
                 children: [
                   Expanded(child: TextFormField(controller: _fnameController, decoration: const InputDecoration(labelText: 'First Name'), validator: (v) => v!.isEmpty ? 'Req' : null)),
                   const SizedBox(width: 16),
                   Expanded(child: TextFormField(controller: _lnameController, decoration: const InputDecoration(labelText: 'Last Name'), validator: (v) => v!.isEmpty ? 'Req' : null)),
                 ],
               ),
              const SizedBox(height: 16),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.contains('@') ? null : 'Invalid'),
              const SizedBox(height: 16),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              const SizedBox(height: 16),
              TextFormField(controller: _companyController, decoration: const InputDecoration(labelText: 'Company Name')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600], foregroundColor: Colors.white),
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final request = CreateVendorRequest(
        firstName: _fnameController.text,
        lastName: _lnameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        companyName: _companyController.text,
      );

      if (widget.vendor != null) {
        await ref.read(vendorControllerProvider.notifier).updateVendor(widget.vendor!.id, request);
      } else {
        await ref.read(vendorControllerProvider.notifier).createVendor(request);
      }
      
      if (mounted) Navigator.pop(context);
    }
  }
}
