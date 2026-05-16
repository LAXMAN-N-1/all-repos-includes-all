import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventifi_admin/features/roles/domain/role_models.dart';
import 'package:eventifi_admin/features/roles/presentation/role_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleFormDialog extends ConsumerStatefulWidget {
  final Role? role;

  const RoleFormDialog({super.key, this.role});

  @override
  ConsumerState<RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends ConsumerState<RoleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');
    _codeController = TextEditingController(text: widget.role?.code ?? '');
    _descController = TextEditingController(text: widget.role?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.role != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Role' : 'Create Role', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Role Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Role Code (unique)'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                readOnly: isEditing, // Prevent changing code on edit if backend relies on it
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600], foregroundColor: Colors.white),
          child: Text(isEditing ? 'Save Changes' : 'Create Role'),
        ),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final request = CreateRoleRequest(
        name: _nameController.text,
        code: _codeController.text,
        description: _descController.text,
        rights: widget.role?.rights ?? [], // Preserve rights if editing, or empty
      );

      if (widget.role != null) {
        await ref.read(roleControllerProvider.notifier).updateRole(widget.role!.id, request);
      } else {
        await ref.read(roleControllerProvider.notifier).createRole(request);
      }
      
      if (mounted) Navigator.pop(context);
    }
  }
}
