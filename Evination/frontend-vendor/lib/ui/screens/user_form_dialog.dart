import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/models/role_model.dart';
import '../../data/models/branch_model.dart';
import '../../logic/providers/role_provider.dart';
import '../../logic/providers/branch_provider.dart';
import '../../logic/providers/user_provider.dart';
import '../../theme/app_theme.dart';

class UserFormDialog extends ConsumerStatefulWidget {
  final User? user;
  const UserFormDialog({super.key, this.user});

  @override
  ConsumerState<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Dropdown States
  int? _selectedRoleId;
  int? _selectedBranchId;
  String _status = 'Active';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.fullName; // Roughly splitting name might be needed if separate fields
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.phone ?? '';
      _usernameController.text = widget.user!.username;
      
      _selectedRoleId = widget.user!.roleId;
      _selectedBranchId = widget.user!.branchId;
      _status = widget.user!.isActive ? 'Active' : 'Inactive';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);
    final branchesAsync = ref.watch(branchesProvider);
    
    // For "Name" field, we'll just put it in First Name for simplicity or split it.
    // The backend expects first_name, last_name.
    // We'll use "Full Name" input and split it.
    
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(widget.user == null ? 'Add User' : 'Edit User', style: AppTheme.heading),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Grid Inputs
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 3.5,
                        children: [
                          _buildTextField('Full Name', _nameController, required: true),
                          _buildTextField('Email', _emailController, required: true, isEmail: true),
                          _buildTextField('Phone', _phoneController, required: true),
                          _buildTextField('Username', _usernameController, required: true),
                          if (widget.user == null) 
                            _buildTextField('Password', _passwordController, required: true, isPassword: true),
                          
                          // Role Dropdown
                          _buildDropdown<int>(
                            label: 'Role',
                            value: _selectedRoleId,
                            items: rolesAsync.asData?.value.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList() ?? [],
                            onChanged: (v) => setState(() => _selectedRoleId = v),
                            isLoading: rolesAsync.isLoading,
                          ),
                          
                          // Branch Dropdown
                          _buildDropdown<int>(
                            label: 'Branch',
                            value: _selectedBranchId,
                            items: branchesAsync.asData?.value.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList() ?? [],
                            onChanged: (v) => setState(() => _selectedBranchId = v),
                            isLoading: branchesAsync.isLoading,
                          ),
                          
                          // Status Dropdown
                          _buildDropdown<String>(
                            label: 'Status',
                            value: _status,
                            items: ['Active', 'Inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => _status = v!),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Permission Table Information (Visual Only for now as per Backend constrains)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50], 
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                               const Icon(Icons.security, size: 16, color: Color(0xFFFDB913)),
                               const SizedBox(width: 8),
                               const Text('Access Level & Category Assignments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ]),
                            const SizedBox(height: 12),
                            const Text(
                              'Permissions are currently managed via Roles. Selecting a Role automatically assigns the corresponding permissions.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   TextButton(
                     onPressed: () => Navigator.pop(context), 
                     child: Text('Cancel', style: TextStyle(color: Colors.grey[600]))
                   ),
                   const SizedBox(width: 16),
                   ElevatedButton(
                     onPressed: _isLoading ? null : _save,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFFFDB913),
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                     ),
                     child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save User'),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false, bool isEmail = false, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ${required ? "*" : ""}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 6),
        Expanded(
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            validator: (v) {
              if (required && (v == null || v.isEmpty)) return 'Required';
              return null;
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDropdown<T>({
    required String label, 
    required T? value, 
    required List<DropdownMenuItem<T>> items, 
    required ValueChanged<T?> onChanged,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 6),
        Expanded(
          child: isLoading 
            ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            : DropdownButtonFormField<T>(
                value: value,
                items: items,
                onChanged: onChanged,
                decoration: InputDecoration(
                   contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                ),
                validator: (v) => v == null ? 'Required' : null,
              ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    // Split Name
    final nameParts = _nameController.text.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    try {
      if (widget.user == null) {
        // Create
        await ref.read(usersProvider.notifier).createUser({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'first_name': firstName,
          'last_name': lastName,
          'phone': _phoneController.text.trim(),
          'role_id': _selectedRoleId,
          'branch_id': _selectedBranchId,
          // 'status': _status, // Backend handles status via inactive flag usually or explicit field if supported
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User created successfully')));
      } else {
        // Update
        await ref.read(usersProvider.notifier).updateUser(widget.user!.id, {
          'first_name': firstName,
          'last_name': lastName,
          'phone': _phoneController.text.trim(),
          'role_id': _selectedRoleId,
          'branch_id': _selectedBranchId,
          // 'status': _status, 
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User updated successfully')));
      }
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
