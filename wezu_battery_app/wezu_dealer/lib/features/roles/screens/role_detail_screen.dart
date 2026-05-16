import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/roles_provider.dart';
import '../../../core/models/dealer_role.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/widgets/confirmation_modal.dart';
import '../../../core/services/roles_service.dart';

class RoleDetailScreen extends ConsumerStatefulWidget {
  final String roleId;
  const RoleDetailScreen({super.key, required this.roleId});

  @override
  ConsumerState<RoleDetailScreen> createState() => _RoleDetailScreenState();
}

class _RoleDetailScreenState extends ConsumerState<RoleDetailScreen>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0;
  bool _isEditing = false;
  int _pendingChanges = 0;

  // Edit states
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;

  // Clone of permissions map to allow local edits
  late Map<String, Set<String>> _editPermissions;

  final List<String> _tabs = [
    'Permissions',
    'Assigned Users',
    'Activity Log',
    'Settings',
  ];
  final List<Map<String, String>> _modules = [
    {'id': 'DS', 'name': 'Dashboard', 'desc': 'High-level metrics and KPIs'},
    {'id': 'ST', 'name': 'Stations', 'desc': 'Manage swapping stations'},
    {'id': 'INV', 'name': 'Inventory', 'desc': 'Batteries and parts tracking'},
    {'id': 'REV', 'name': 'Revenue', 'desc': 'Financials and sales data'},
    {'id': 'CUS', 'name': 'Customers', 'desc': 'Client profiles and activity'},
    {'id': 'TKT', 'name': 'Tickets', 'desc': 'Support operations'},
    {'id': 'DOC', 'name': 'Documents', 'desc': 'Contracts and agreements'},
    {'id': 'CAM', 'name': 'Campaigns', 'desc': 'Promotions and marketing'},
  ];

  late final AnimationController _animCtrl;
  late final Animation<Offset> _floatBarSlide;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _editPermissions = {};
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _floatBarSlide = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _enterEditMode(DealerRole role) {
    if (role.isSystem) return;
    _nameCtrl.text = role.name;
    _descCtrl.text = role.description;

    _editPermissions.clear();
    for (var m in _modules) {
      _editPermissions[m['name']!] = Set.from(
        role.permissions[m['name']!] ?? [],
      );
    }

    setState(() {
      _isEditing = true;
      _activeTab = 0; // Force permissions tab
      _pendingChanges = 0;
    });
    _animCtrl.forward();
  }

  void _discardChanges() {
    ConfirmationModal.show(
      context,
      title: 'Discard Changes',
      description: 'Are you sure? This will undo $_pendingChanges changes.',
      confirmText: 'Discard',
      isDanger: false,
      onConfirm: () {
        _animCtrl.reverse().then((_) {
          setState(() => _isEditing = false);
        });
      },
    );
  }

  Future<void> _saveChanges() async {
    final List<String> slugs = [];
    _editPermissions.forEach((module, actions) {
      for (var action in actions) {
        slugs.add('${module.toLowerCase()}:${action.toLowerCase()}');
      }
    });

    try {
      final success = await ref.read(rolesServiceProvider).updateRole(
            int.parse(widget.roleId),
            {
              'name': _nameCtrl.text,
              'description': _descCtrl.text,
              'permissions': slugs,
            },
          );

      if (success) {
        if (!mounted) return;
        ref.invalidate(rolesProvider);
        _animCtrl.reverse().then((_) {
          setState(() => _isEditing = false);
          ToastService.show(
            context,
            'Role updated successfully',
            type: ToastType.success,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.show(
        context,
        'Failed to update role: $e',
        type: ToastType.error,
      );
    }
  }

  void _recordChange() {
    setState(() => _pendingChanges++);
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);
    return rolesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: AppColors.red)),
      ),
      data: (roles) {
        final role = roles.firstWhere(
          (r) => r.id.toString() == widget.roleId,
          orElse: () => DealerRole(
            id: '0',
            name: 'Unknown',
            description: '',
            isSystem: false,
          ),
        );

        final bool isSuperAdmin =
            role.name.toLowerCase().contains('super admin') || role.isSystem;
        final Color accentColor = isSuperAdmin
            ? AppColors.red
            : AppColors.primary;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb
                  Row(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => context.go('/roles'),
                          child: const Text(
                            'Roles & Permissions',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.chevronRight,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        role.name,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: IconUtils.gradientFromHex(
                                  role.colorHex,
                                  isSuperAdmin: isSuperAdmin,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  IconUtils.fromString(role.iconName),
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_isEditing)
                                    TextField(
                                      controller: _nameCtrl,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (_) => _recordChange(),
                                    )
                                  else
                                    Text(
                                      role.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  if (_isEditing)
                                    TextField(
                                      controller: _descCtrl,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (_) => _recordChange(),
                                    )
                                  else
                                    Text(
                                      role.description,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Created on ${role.updatedAt.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!_isEditing)
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: isSuperAdmin
                                        ? null
                                        : () => _enterEditMode(role),
                                    icon: Icon(
                                      isSuperAdmin
                                          ? LucideIcons.lock
                                          : LucideIcons.edit2,
                                      size: 14,
                                    ),
                                    label: const Text('Edit Role'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: AppColors.primary
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      LucideIcons.copy,
                                      size: 14,
                                    ),
                                    label: const Text('Duplicate'),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      LucideIcons.moreVertical,
                                      size: 20,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 24),

                        // Header Stats
                        Row(
                          children: [
                            _buildHeaderStat(
                              'Total Perms',
                              '${role.permissions.values.fold(0, (s, l) => s + l.length)} granted',
                            ),
                            _buildHeaderStat(
                              'Full Access',
                              '${role.permissions.values.where((l) => l.length == 4).length} modules',
                            ),
                            _buildHeaderStat(
                              'Partial Access',
                              '${role.permissions.values.where((l) => l.length > 0 && l.length < 4).length} modules',
                            ),
                            _buildHeaderStat(
                              'Assigned to',
                              '${role.usersCount} users',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tab Navigation
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: List.generate(_tabs.length, (i) {
                        bool isActive = _activeTab == i;
                        return GestureDetector(
                          onTap: _isEditing
                              ? null
                              : () => setState(() => _activeTab = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isActive
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              _tabs[i],
                              style: TextStyle(
                                color: isActive
                                    ? AppColors.primary
                                    : (_isEditing
                                          ? AppColors.textTertiary
                                          : AppColors.textSecondary),
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tab Content
                  _buildTabContent(role),
                ],
              ),
            ),

            // Floating Save Bar
            if (_isEditing)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: SlideTransition(
                    position: _floatBarSlide,
                    child: Container(
                      width: 500,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBgHover,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$_pendingChanges pending',
                              style: const TextStyle(
                                color: AppColors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _discardChanges,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                            ),
                            child: const Text(
                              'Discard',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _pendingChanges > 0
                                ? _saveChanges
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Expanded _buildHeaderStat(String title, String val) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(DealerRole role) {
    switch (_activeTab) {
      case 0:
        return _buildPermissionsTab(role);
      case 1:
        return _buildUsersTab();
      case 2:
        return _buildActivityLogTab();
      case 3:
        return _buildSettingsTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPermissionsTab(DealerRole role) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
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
                _buildColHeader('VIEW', LucideIcons.eye, AppColors.primary),
                _buildColHeader(
                  'CREATE',
                  LucideIcons.plusCircle,
                  AppColors.cyan,
                ),
                _buildColHeader('EDIT', LucideIcons.edit2, AppColors.amber),
                _buildColHeader('DELETE', LucideIcons.trash2, AppColors.red),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Rows
          ..._modules.asMap().entries.map((entry) {
            final m = entry.value;
            final isLast = entry.key == _modules.length - 1;

            final Set<String> perms = _isEditing
                ? _editPermissions[m['name']!]!
                : Set.from(role.permissions[m['name']!] ?? []);

            Widget buildCell(String type) {
              bool val = perms.contains(type);

              if (_isEditing) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (val)
                        perms.remove(type);
                      else {
                        perms.add(type);
                        if (type != 'View')
                          perms.add('View'); // Dependency trick
                      }
                      _recordChange();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: val ? AppColors.amber : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 36,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: val ? AppColors.primary : AppColors.pageBg,
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 180),
                        alignment: val
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
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
                  ),
                );
              }

              // Read only mode
              if (val)
                return const Icon(
                  LucideIcons.checkCircle2,
                  color: AppColors.primary,
                  size: 20,
                );
              return const Icon(
                LucideIcons.xCircle,
                color: AppColors.textTertiary,
                size: 20,
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(bottom: BorderSide(color: AppColors.border)),
                color: entry.key.isEven
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.02),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m['name']!,
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
                  Expanded(child: Center(child: buildCell('View'))),
                  Expanded(child: Center(child: buildCell('Create'))),
                  Expanded(child: Center(child: buildCell('Edit'))),
                  Expanded(child: Center(child: buildCell('Delete'))),
                ],
              ),
            );
          }),

          // Permissions Summary Bar Chart (Read-only bottom section)
          if (!_isEditing) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Permission Depths',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._modules.map((m) {
                    final l = (role.permissions[m['name']!] ?? []).length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              m['name']!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: l / 4.0,
                                minHeight: 8,
                                backgroundColor: AppColors.pageBg,
                                valueColor: AlwaysStoppedAnimation(
                                  l == 4
                                      ? AppColors.primary
                                      : (l > 0
                                            ? AppColors.amber
                                            : AppColors.textTertiary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 40,
                            child: Text(
                              '$l / 4',
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Expanded _buildColHeader(String text, IconData icon, Color c) {
    return Expanded(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: c,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(60),
        child: Text(
          'Assigned Users Tab Content to be implemented.',
          style: TextStyle(color: AppColors.textTertiary),
        ),
      ),
    );
  }

  Widget _buildActivityLogTab() {
    final auditLogsAsync = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      return ref.read(rolesServiceProvider).getAuditLog(int.parse(widget.roleId));
    });

    return Consumer(
      builder: (context, ref, child) {
        final logs = ref.watch(auditLogsAsync);
        return logs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (data) {
            if (data.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: Text(
                    'No activities recorded for this role.',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (ctx, i) {
                final log = data[i];
                return _buildActivityItem(
                  log['action'] ?? 'changed',
                  log['description'] ?? 'No detail available',
                  DateTime.parse(log['created_at'] ?? DateTime.now().toIso8601String()),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActivityItem(String title, String desc, DateTime time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.border, width: 2)),
      ),
      margin: const EdgeInsets.only(left: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(left: -19, top: 4),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danger Zone',
          style: TextStyle(
            color: AppColors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delete this role',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'This action cannot be undone. Users assigned to this role will lose access.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ConfirmationModal.show(
                    context,
                    title: 'Delete Role',
                    description: 'Are you sure you want to delete this role?',
                    confirmText: 'Delete',
                    isDanger: true,
                    onConfirm: () async {
                      try {
                        final success = await ref.read(rolesServiceProvider).deleteRole(
                          int.parse(widget.roleId),
                        );
                        if (success) {
                          if (!mounted) return;
                          ref.invalidate(rolesProvider);
                          context.go('/roles');
                          ToastService.show(
                            context,
                            'Role deleted',
                            type: ToastType.success,
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ToastService.show(
                          context,
                          'Failed to delete: $e',
                          type: ToastType.error,
                        );
                      }
                    },
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                child: const Text('Delete Role'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
