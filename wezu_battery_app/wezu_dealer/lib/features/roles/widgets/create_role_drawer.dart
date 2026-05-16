import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/roles_service.dart';
import '../../../core/providers/roles_provider.dart';

class CreateRoleDrawer extends ConsumerStatefulWidget {
  const CreateRoleDrawer({super.key});

  @override
  ConsumerState<CreateRoleDrawer> createState() => _CreateRoleDrawerState();
}

class _CreateRoleDrawerState extends ConsumerState<CreateRoleDrawer> {
  int _currentStep = 1;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _selectedIcon = 'shield';
  String _selectedColor = '#10B981'; // AppColors.primary

  final List<String> _icons = [
    'crown',
    'person',
    'shield',
    'location',
    'headset',
    'eye',
    'wrench',
    'chart',
    'document',
    'lock',
    'star',
    'key',
  ];
  final List<String> _colors = [
    '#10B981',
    '#06B6D4',
    '#F59E0B',
    '#EF4444',
    '#8B5CF6',
    '#EC4899',
    '#3B82F6',
    '#8B8D97',
  ];

  // Modules for permissions grid
  final List<Map<String, String>> _modules = [
    {'id': 'DS', 'name': 'Dashboard', 'desc': 'High-level metrics and KPIs'},
    {'id': 'ST', 'name': 'Stations', 'desc': 'Manage swapping stations'},
    {'id': 'INV', 'name': 'Inventory', 'desc': 'Batteries and parts tracking'},
    {'id': 'REV', 'name': 'Revenue', 'desc': 'Financials and sales data'},
    {'id': 'CUS', 'name': 'Customers', 'desc': 'Client profiles and activity'},
  ];

  // Map of module -> Set of permissions (View, Create, Edit, Delete)
  final Map<String, Set<String>> _permissions = {};

  @override
  void initState() {
    super.initState();
    for (var m in _modules) {
      _permissions[m['name']!] = {};
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _saveRole();
    }
  }

  Future<void> _saveRole() async {
    final List<String> slugs = [];
    _permissions.forEach((module, actions) {
      for (var action in actions) {
        // slug format: module:action (lowercase)
        slugs.add('${module.toLowerCase()}:${action.toLowerCase()}');
      }
    });

    try {
      final success = await ref.read(rolesServiceProvider).createRole({
        'name': _nameCtrl.text,
        'description': _descCtrl.text,
        'icon': _selectedIcon,
        'color': _selectedColor,
        'permissions': slugs,
      });

      if (success) {
        if (!mounted) return;
        ref.invalidate(rolesProvider); // Refresh roles list
        ToastService.show(
          context,
          'Role created successfully',
          type: ToastType.success,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.show(
        context,
        'Failed to create role: $e',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 560,
        decoration: BoxDecoration(
          color: AppColors.pageBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
            ),
          ],
          border: const Border(left: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Role',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Define access permissions for this role',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.x,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Step Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: AppColors.cardBg,
              child: Row(
                children: [
                  _buildStep(1, 'Role Identity'),
                  _buildStepDash(),
                  _buildStep(2, 'Set Permissions'),
                  _buildStepDash(),
                  _buildStep(3, 'Assign Users'),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildCurrentStep(),
              ),
            ),

            // Footer
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  if (_currentStep > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Back'),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: (_currentStep == 1 && _nameCtrl.text.isEmpty)
                        ? null
                        : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.3,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      _currentStep == 3 ? 'Create Role' : 'Next Step',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step, String title) {
    bool isCompleted = _currentStep > step;
    bool isActive = _currentStep == step;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.primary
                : (isActive
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.cardBg),
            border: Border.all(
              color: isCompleted || isActive
                  ? AppColors.primary
                  : AppColors.border,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(LucideIcons.check, size: 12, color: Colors.white)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDash() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Identity();
      case 2:
        return _buildStep2Permissions();
      case 3:
        return _buildStep3AssignUsers();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1Identity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        const Text(
          'Role Name',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          onChanged: (v) => setState(() {}),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g. Finance Manager',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Description
        const Text(
          'Role Description',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descCtrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Short description of this role...',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Icon Picker
        const Text(
          'Role Icon',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _icons.map((ic) {
              bool sel = _selectedIcon == ic;
              IconData iconData = LucideIcons.circle;
              switch (ic) {
                case 'crown':
                  iconData = LucideIcons.crown;
                  break;
                case 'person':
                  iconData = LucideIcons.user;
                  break;
                case 'shield':
                  iconData = LucideIcons.shield;
                  break;
                case 'location':
                  iconData = LucideIcons.mapPin;
                  break;
                case 'headset':
                  iconData = LucideIcons.headphones;
                  break;
                case 'eye':
                  iconData = LucideIcons.eye;
                  break;
                case 'chart':
                  iconData = LucideIcons.barChart2;
                  break;
                case 'document':
                  iconData = LucideIcons.fileText;
                  break;
                case 'lock':
                  iconData = LucideIcons.lock;
                  break;
                case 'star':
                  iconData = LucideIcons.star;
                  break;
                case 'key':
                  iconData = LucideIcons.key;
                  break;
                case 'wrench':
                  iconData = LucideIcons.wrench;
                  break;
              }
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = ic),
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    color: sel ? AppColors.primary : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),

        // Color Picker
        const Text(
          'Accent Color',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _colors.map((c) {
            bool sel = _selectedColor == c;
            Color colorParsed = Color(
              int.parse(c.replaceAll('#', 'FF'), radix: 16),
            );
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = c),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorParsed,
                  border: Border.all(
                    color: sel ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: colorParsed.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2Permissions() {
    return Column(
      children: [
        // Quick Apply Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Text(
                'Quick Apply:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  /* toggle view only logic */
                },
                child: const Text(
                  'Read Only',
                  style: TextStyle(color: AppColors.cyan),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  /* toggle full access logic */
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Full Access',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Header Row
        const Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'MODULE',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'VIEW',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'CREATE',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'EDIT',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'DELETE',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.border),

        // Grid
        ..._modules.map((m) {
          final ModuleName = m['name']!;
          final perms = _permissions[ModuleName]!;

          Widget moduleToggle(String type) {
            bool val = perms.contains(type);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (val) {
                    perms.remove(type);
                  } else {
                    perms.add(type);
                    // Dependency logic
                    if (type != 'View') perms.add('View');
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 36,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: val ? AppColors.primary : AppColors.cardBgHover,
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 180),
                  alignment: val ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ModuleName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        m['desc']!,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Center(child: moduleToggle('View'))),
                Expanded(child: Center(child: moduleToggle('Create'))),
                Expanded(child: Center(child: moduleToggle('Edit'))),
                Expanded(child: Center(child: moduleToggle('Delete'))),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep3AssignUsers() {
    return Column(
      children: [
        const Icon(LucideIcons.users, size: 48, color: AppColors.textTertiary),
        const SizedBox(height: 16),
        const Text(
          'Assign Users (Optional)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'You can add users to this role now or do it later.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Text(
              'User Search and Selection List to be implemented.',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }
}
