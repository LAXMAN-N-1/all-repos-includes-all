import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/roles_provider.dart';
import '../../../core/models/dealer_role.dart';
import '../../../core/services/toast_service.dart';

class PermissionsMatrixScreen extends ConsumerStatefulWidget {
  const PermissionsMatrixScreen({super.key});
  @override
  ConsumerState<PermissionsMatrixScreen> createState() =>
      _PermissionsMatrixScreenState();
}

class _PermissionsMatrixScreenState
    extends ConsumerState<PermissionsMatrixScreen> {
  bool _hideSystemRoles = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  final List<Map<String, String>> _categories = [
    {
      'cat': 'Core Platform',
      'mod': 'Dashboard',
      'desc': 'Overview and metrics',
    },
    {
      'cat': 'Core Platform',
      'mod': 'Settings',
      'desc': 'Global platform config',
    },
    {'cat': 'Operations', 'mod': 'Stations', 'desc': 'Hardware swapping units'},
    {'cat': 'Operations', 'mod': 'Inventory', 'desc': 'Stock and spare parts'},
    {'cat': 'Business', 'mod': 'Revenue', 'desc': 'Financial reporting'},
    {'cat': 'Business', 'mod': 'Customers', 'desc': 'End-user management'},
    {'cat': 'Support', 'mod': 'Tickets', 'desc': 'Issue resolution'},
    {'cat': 'Support', 'mod': 'Documents', 'desc': 'Legal and compliance'},
    {
      'cat': 'Growth',
      'mod': 'Campaigns',
      'desc': 'Marketing and promos',
    }, // Corrected description
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
      () => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showEditPopover(
    BuildContext context,
    DealerRole role,
    String moduleName,
  ) {
    if (role.isSystem) return;
    showDialog(
      context: context,
      builder: (c) => _InlineCellEditor(role: role, moduleName: moduleName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
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
              const Text(
                'Permissions Matrix',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              // Toggles and Search
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Hide System Roles',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _hideSystemRoles,
                    onChanged: (v) => setState(() => _hideSystemRoles = v),
                    activeThumbColor: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 240,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Search modules...',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        prefixIcon: Icon(
                          LucideIcons.search,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Matrix Grid
        Expanded(
          child: rolesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Error: $e',
                style: const TextStyle(color: AppColors.red),
              ),
            ),
            data: (allRoles) {
              final roles = allRoles
                  .where((r) => !_hideSystemRoles || !r.isSystem)
                  .toList();
              final modulesFiltered = _categories
                  .where((c) => c['mod']!.toLowerCase().contains(_searchQuery))
                  .toList();

              if (roles.isEmpty)
                return const Center(
                  child: Text(
                    'No roles available.',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                );

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Col Headers
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(
                              width: 240,
                            ), // Left padding for rows column
                            ...roles.map((r) => _buildRoleColHeader(r)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Matrix Rows
                        ..._buildRows(modulesFiltered, roles),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoleColHeader(DealerRole role) {
    final bool isSuperAdmin =
        role.name.toLowerCase().contains('super admin') || role.isSystem;
    final Color accentColor = isSuperAdmin ? AppColors.red : AppColors.primary;

    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isSuperAdmin ? 'SYSTEM' : 'CUSTOM',
              style: TextStyle(
                color: accentColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            role.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            '${role.usersCount} users',
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRows(
    List<Map<String, String>> modules,
    List<DealerRole> roles,
  ) {
    List<Widget> rows = [];
    String lastCat = '';

    for (var m in modules) {
      if (m['cat'] != lastCat) {
        lastCat = m['cat']!;
        rows.add(
          Padding(
            padding: const EdgeInsets.only(top: 32, bottom: 16),
            child: Text(
              lastCat.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        );
      }

      rows.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Row Header
              Container(
                width: 240,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m['mod']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      m['desc']!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Cells
              ...roles.map((r) {
                final Set<String> perms = Set.from(
                  r.permissions[m['mod']!] ?? [],
                );

                return GestureDetector(
                  onTap: () => _showEditPopover(context, r, m['mod']!),
                  child: Container(
                    width: 160,
                    height: 64,
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: AppColors.border)),
                    ),
                    child: Center(
                      child: perms.isEmpty
                          ? const Text(
                              '—',
                              style: TextStyle(color: AppColors.border),
                            )
                          : _MiniMatrixCellDot(
                              perms: perms,
                              isSystem: r.isSystem,
                            ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }
    return rows;
  }
}

class _MiniMatrixCellDot extends StatelessWidget {
  final Set<String> perms;
  final bool isSystem;
  const _MiniMatrixCellDot({required this.perms, required this.isSystem});

  @override
  Widget build(BuildContext context) {
    bool p(String t) => perms.contains(t);
    Color c(String t) {
      if (!p(t)) return AppColors.pageBg;
      if (isSystem) return AppColors.red;
      return t == 'Delete'
          ? AppColors.red
          : (t == 'Edit'
              ? AppColors.amber
              : (t == 'Create' ? AppColors.cyan : AppColors.primary));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _d('V', c('View')),
        const SizedBox(width: 4),
        _d('C', c('Create')),
        const SizedBox(width: 4),
        _d('E', c('Edit')),
        const SizedBox(width: 4),
        _d('D', c('Delete')),
      ],
    );
  }

  Widget _d(String l, Color c) {
    bool has = c != AppColors.pageBg;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: has ? c : AppColors.border,
      ),
    );
  }
}

class _InlineCellEditor extends StatefulWidget {
  final DealerRole role;
  final String moduleName;
  const _InlineCellEditor({required this.role, required this.moduleName});

  @override
  State<_InlineCellEditor> createState() => _InlineCellEditorState();
}

class _InlineCellEditorState extends State<_InlineCellEditor> {
  late Set<String> _perms;

  @override
  void initState() {
    super.initState();
    _perms = Set.from(widget.role.permissions[widget.moduleName] ?? []);
  }

  Widget _toggle(String type) {
    bool val = _perms.contains(type);
    Color activeC = type == 'Delete'
        ? AppColors.red
        : (type == 'Edit'
            ? AppColors.amber
            : (type == 'Create' ? AppColors.cyan : AppColors.primary));

    return CheckboxListTile(
      value: val,
      title: Text(
        type,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      activeColor: activeC,
      checkColor: Colors.white,
      side: const BorderSide(color: AppColors.textTertiary),
      onChanged: (v) {
        setState(() {
          if (v == true) {
            _perms.add(type);
            if (type != 'View') _perms.add('View');
          } else {
            _perms.remove(type);
            if (type == 'View') _perms.clear();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.role.name} / ${widget.moduleName}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Edit Permissions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),
            _toggle('View'),
            _toggle('Create'),
            _toggle('Edit'),
            _toggle('Delete'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Update role locally. real app persists to backend
                    widget.role.permissions[widget.moduleName] =
                        _perms.toList();
                    ToastService.show(
                      context,
                      'Permissions updated',
                      type: ToastType.success,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
