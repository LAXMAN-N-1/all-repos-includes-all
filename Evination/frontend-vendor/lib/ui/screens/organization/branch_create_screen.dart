import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/services/branch_service.dart';
import '../../../theme/app_theme.dart';

class BranchCreateScreen extends ConsumerStatefulWidget {
  const BranchCreateScreen({super.key});

  @override
  ConsumerState<BranchCreateScreen> createState() => _BranchCreateScreenState();
}

class _BranchCreateScreenState extends ConsumerState<BranchCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Fields
  String name = '';
  String address = '';
  String city = '';
  String state = '';
  String zipCode = '';
  String country = '';
  String manager = '';
  String phone = '';
  String email = '';
  bool isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true);
      
      try {
        await ref.read(branchServiceProvider).createBranch({
          'name': name,
          'organization_id': 1, // Defaulting to org 1 for now or fetch from user context
          'code': 'BR-${DateTime.now().millisecondsSinceEpoch}', // Auto-gen code
          'address': address,
          'city': city,
          'state': state,
          'pincode': zipCode,
          'country': country,
          'phone': phone,
          'email': email,
          // Manager ID logic handled by backend or separate selection
          // 'manager_name': manager 
        });
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Branch created successfully')));
           context.go('/admin/organization/branches');
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                TextButton.icon(
                  onPressed: () => context.go('/admin/organization/branches'),
                  icon: const Icon(Icons.arrow_back, size: 20),
                  label: const Text('Back to Branches'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Text('Create New Branch', style: AppTheme.heading.copyWith(fontSize: 28)),
                const SizedBox(height: 8),
                Text('Add a new branch location to your organization', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 24),

                // Form
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: AppTheme.cardDecoration.boxShadow
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         // Branch Info
                         _SectionHeader(icon: Icons.business, title: 'Branch Information'),
                         const SizedBox(height: 24),
                         _TextField(
                           label: 'Branch Name *', 
                           hint: 'e.g., EventUnity West Coast', 
                           onSaved: (v) => name = v!,
                           validator: (v) => v!.isEmpty ? 'Required' : null
                         ),
                         const SizedBox(height: 32),

                         // Location Details
                         _SectionHeader(icon: Icons.location_on, title: 'Location Details'),
                         const SizedBox(height: 24),
                         _TextField(
                           label: 'Street Address *', 
                           hint: '123 Main Street', 
                           onSaved: (v) => address = v!
                         ),
                         const SizedBox(height: 24),
                         Row(children: [
                           Expanded(child: _TextField(label: 'City *', hint: 'New York', onSaved: (v) => city = v!)),
                           const SizedBox(width: 24),
                           Expanded(child: _TextField(label: 'State/Province *', hint: 'NY', onSaved: (v) => state = v!)),
                         ]),
                         const SizedBox(height: 24),
                         Row(children: [
                           Expanded(child: _TextField(label: 'ZIP/Postal Code *', hint: '10001', onSaved: (v) => zipCode = v!, validator: (v) => v!.isEmpty ? 'Required' : null)),
                           const SizedBox(width: 24),
                           Expanded(child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Text('Country *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                               const SizedBox(height: 8),
                               DropdownButtonFormField<String>(
                                 decoration: InputDecoration(
                                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                                   enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                 ),
                                 items: ['United States', 'Canada', 'UK', 'India'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                 onChanged: (v) => country = v!,
                                 onSaved: (v) => country = v ?? '',
                                 validator: (v) => v == null ? 'Required' : null,
                                 hint: const Text('Select Country'),
                               ),
                             ],
                           )),
                         ]),
                         const SizedBox(height: 32),

                         // Contact Info
                         _SectionHeader(icon: Icons.person, title: 'Contact Information'),
                         const SizedBox(height: 24),
                         Row(children: [
                           Expanded(child: _TextField(label: 'Branch Manager *', hint: 'John Smith', onSaved: (v) => manager = v!)),
                           const SizedBox(width: 24),
                           Expanded(child: _TextField(label: 'Phone Number *', hint: '+1 (555) 123-4567', onSaved: (v) => phone = v!)),
                         ]),
                         const SizedBox(height: 24),
                         _TextField(label: 'Email Address *', hint: 'branch@eventunity.com', onSaved: (v) => email = v!),
                         
                         const SizedBox(height: 48),
                         const Divider(),
                         const SizedBox(height: 24),
                         
                         // Actions
                         Row(children: [
                            ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFDB913), // Assuming primary color logic
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Branch'),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: () => context.go('/admin/organization/branches'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Cancel'),
                            ),
                         ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 20, color: Colors.black87),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ]);
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;

  const _TextField({required this.label, required this.hint, this.onSaved, this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
             hintText: hint,
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.amber)),
             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onSaved: onSaved,
          validator: validator ?? (v) => v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
