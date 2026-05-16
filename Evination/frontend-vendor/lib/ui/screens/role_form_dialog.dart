import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/role_model.dart';
import '../../data/models/role_right_model.dart';
import '../../data/services/role_right_service.dart';
import '../../data/services/role_service.dart';
import '../../logic/providers/role_provider.dart';
import '../../logic/providers/menu_provider.dart';
import '../../theme/app_theme.dart';

class RoleFormDialog extends ConsumerStatefulWidget {
  final Role? role;
  const RoleFormDialog({super.key, this.role});

  @override
  ConsumerState<RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends ConsumerState<RoleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedColor = 'gray';
  
  // Matrix State: MenuID -> Rights
  Map<int, RoleRightBulkItem> _permissionsState = {};
  bool _isLoading = false;

  final List<String> _colors = ['gray', 'red', 'blue', 'green', 'purple', 'orange'];

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      _nameController.text = widget.role!.name;
      _descController.text = widget.role!.description ?? '';
      _selectedColor = widget.role!.color;
      _loadExistingRights();
    }
  }

  Future<void> _loadExistingRights() async {
    if (widget.role == null) return;
    try {
      final rights = await ref.read(roleRightServiceProvider).getRoleRights(widget.role!.id);
      setState(() {
        for (var r in rights) {
          _permissionsState[r.menuId] = RoleRightBulkItem(
            menuId: r.menuId,
            canView: r.canView,
            canCreate: r.canCreate,
            canEdit: r.canEdit,
            canDelete: r.canDelete,
          );
        }
      });
    } catch (e) {
      debugPrint('Failed to load rights: $e');
    }
  }

  void _updatePermission(int menuId, String type, bool value) {
    setState(() {
      final existing = _permissionsState[menuId] ?? RoleRightBulkItem(menuId: menuId);
      
      _permissionsState[menuId] = RoleRightBulkItem(
        menuId: menuId,
        canView: type == 'view' ? value : existing.canView,
        canCreate: type == 'create' ? value : existing.canCreate,
        canEdit: type == 'edit' ? value : existing.canEdit,
        canDelete: type == 'delete' ? value : existing.canDelete,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text,
        'code': _nameController.text.toUpperCase().replaceAll(' ', '_'), // Simple code generation
        'description': _descController.text,
        'color': _selectedColor,
      };

      int roleId;
      if (widget.role != null) {
        await ref.read(rolesProvider.notifier).editRole(widget.role!.id, data);
        roleId = widget.role!.id;
      } else {
        // Create Role NOT implemented to return ID in provider yet. 
        // Provider calls 'createRole' which returns void.
        // I need to change provider/service to return the created role or ID.
        // For now, I'll assume I can just fetch the role by code or refactor service.
        // Let's refactor service to return Role first? Or just use service directly here.
        // Create Logic
        final roleService = ref.read(roleServiceProvider);
        final newRole = await roleService.createRole(data);
        roleId = newRole.id;
        ref.invalidate(rolesProvider);
      }

      // Save Permissions
      if (_permissionsState.isNotEmpty) {
        await ref.read(roleRightServiceProvider).syncRoleRightsBulk(
          roleId, 
          _permissionsState.values.toList()
        );
      }
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      String msg = 'An error occurred';
      if (e.toString().contains('400')) {
        msg = 'Role with this name/code already exists.';
      } else {
        msg = e.toString();
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menusAsync = ref.watch(menusProvider);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 900,
        height: 800,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.role == null ? 'Add New Role' : 'Edit Role', style: AppTheme.heading),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            
            Expanded(
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Fix overflow by filling height
                  children: [
                    // Left: Role Details
                    SizedBox(
                      width: 300,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Role Details', style: AppTheme.subHeading),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Role Name', border: OutlineInputBorder()),
                              validator: (v) => v?.isEmpty == true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descController,
                              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            Text('Color Tag', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _colors.map((c) => InkWell(
                                onTap: () => setState(() => _selectedColor = c),
                                child: Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: _getColor(c),
                                    shape: BoxShape.circle,
                                    border: _selectedColor == c ? Border.all(color: Colors.black, width: 2) : null,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 48),
                    
                    // Right: Permissions Matrix
                    Expanded(
                      child: menusAsync.when(
                        data: (menus) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Permissions Matrix', style: AppTheme.subHeading),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Table(
                                  border: TableBorder(horizontalInside: BorderSide(color: Colors.grey[200]!)),
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(1), 2: FlexColumnWidth(1),
                                    3: FlexColumnWidth(1), 4: FlexColumnWidth(1),
                                  },
                                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(color: Colors.grey[50]),
                                      children: const [
                                        Padding(padding: EdgeInsets.all(8.0), child: Text('Menu', style: TextStyle(fontWeight: FontWeight.bold))),
                                        Center(child: Text('View', style: TextStyle(fontSize: 12))),
                                        Center(child: Text('Create', style: TextStyle(fontSize: 12))),
                                        Center(child: Text('Edit', style: TextStyle(fontSize: 12))),
                                        Center(child: Text('Delete', style: TextStyle(fontSize: 12))),
                                      ],
                                    ),
                                    ...menus.map((menu) {
                                      final rights = _permissionsState[menu.id] ?? RoleRightBulkItem(menuId: menu.id);
                                      return TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                            child: Text(menu.name), // TODO: Indent submenus if needed
                                          ),
                                          Center(child: Checkbox(value: rights.canView, onChanged: (v) => _updatePermission(menu.id, 'view', v!))),
                                          Center(child: Checkbox(value: rights.canCreate, onChanged: (v) => _updatePermission(menu.id, 'create', v!))),
                                          Center(child: Checkbox(value: rights.canEdit, onChanged: (v) => _updatePermission(menu.id, 'edit', v!))),
                                          Center(child: Checkbox(value: rights.canDelete, onChanged: (v) => _updatePermission(menu.id, 'delete', v!))),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => Center(child: Text('Error: $e')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Role', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.red;
      case 'purple': return Colors.amber;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
