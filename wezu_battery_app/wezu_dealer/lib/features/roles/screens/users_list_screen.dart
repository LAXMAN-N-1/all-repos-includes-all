import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/users_provider.dart';
import '../../../core/providers/roles_provider.dart';
import '../../../core/models/dealer_user.dart';
import '../../../core/models/dealer_role.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/widgets/confirmation_modal.dart';
import '../../../core/services/roles_service.dart';

class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});
  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedRoleFilter;

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

  void _openInviteModal() {
    context.go('/roles/users/invite');
  }

  Future<void> _changeRole(DealerUser user, DealerRole newRole) async {
    if (user.role == newRole.name) return;

    ConfirmationModal.show(
      context,
      title: 'Change User Role',
      description:
          'Are you sure you want to change ${user.name}\\\'s role to ${newRole.name}? This will immediately update their access.',
      confirmText: 'Change Role',
      isDanger: false,
      onConfirm: () async {
        try {
          final success = await ref.read(rolesServiceProvider).changeUserRole(
                int.parse(user.id),
                int.parse(newRole.id),
              );

          if (success) {
            if (!mounted) return;
            ref.invalidate(usersProvider); // Refresh users
            ref.invalidate(userStatsProvider);
            ToastService.show(
              context,
              'Role updated for ${user.name}',
              type: ToastType.success,
            );
          }
        } catch (e) {
          if (!mounted) return;
          ToastService.show(
            context,
            'Error updating role: $e',
            type: ToastType.error,
          );
        }
      },
    );
  }

  void _removeUser(DealerUser user, {required List<DealerRole> roles}) {
    // Need to find the role ID to call the delete endpoint
    final currentRole =
        roles.firstWhere((r) => r.name == user.role, orElse: () => roles.first);

    ConfirmationModal.show(
      context,
      title: 'Revoke Access',
      description:
          'Are you sure you want to revoke access for ${user.email}? They will no longer be able to log in.',
      confirmText: 'Revoke',
      isDanger: true,
      requireMatch: user.email,
      onConfirm: () async {
        try {
          final success =
              await ref.read(rolesServiceProvider).removeUserFromRole(
                    int.parse(currentRole.id),
                    int.parse(user.id),
                  );

          if (success) {
            if (!mounted) return;
            ref.invalidate(usersProvider);
            ref.invalidate(userStatsProvider);
            ToastService.show(
              context,
              'User access revoked',
              type: ToastType.success,
            );
          }
        } catch (e) {
          if (!mounted) return;
          ToastService.show(
            context,
            'Error revoking access: $e',
            type: ToastType.error,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final rolesAsync = ref.watch(rolesProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 8),
                  const Text(
                    'Team Members',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _PillTab(
                      title: 'Roles',
                      isActive: false,
                      onTap: () => context.go('/roles'),
                    ),
                    _PillTab(
                      title: 'Users',
                      isActive: true,
                      onTap: () {},
                    ),
                    _PillTab(
                      title: 'Matrix',
                      isActive: false,
                      onTap: () => context.go('/roles/permissions'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Search
              Container(
                width: 240,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Search user...',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    prefixIcon: Icon(
                      LucideIcons.search,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Invite User Button
              ElevatedButton.icon(
                onPressed: _openInviteModal,
                icon: const Icon(LucideIcons.mailPlus, size: 16),
                label: const Text('Invite User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Chips
          statsAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (stats) => Row(
              children: [
                _statChip('Total', stats['total'] ?? 0, AppColors.primary),
                const SizedBox(width: 12),
                _statChip('Active', stats['active'] ?? 0, AppColors.cyan),
                const SizedBox(width: 12),
                _statChip('Pending', stats['pending'] ?? 0, AppColors.amber),
                const SizedBox(width: 12),
                _statChip(
                    'Inactive', stats['inactive'] ?? 0, AppColors.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Users Table
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: usersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(80),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(80),
                child: Center(
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(color: AppColors.red),
                  ),
                ),
              ),
              data: (users) {
                final roles = rolesAsync.valueOrNull ?? [];

                final filtered = users.where((u) {
                  bool matchesQuery =
                      u.name.toLowerCase().contains(_searchQuery) ||
                          u.email.toLowerCase().contains(_searchQuery);
                  bool matchesRole = _selectedRoleFilter == null ||
                      u.role == _selectedRoleFilter;
                  return matchesQuery && matchesRole;
                }).toList();

                if (filtered.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(80),
                    child: Center(
                      child: Text(
                        'No users found matching your criteria.',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Col Headers
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'USER',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: _RoleFilterDropdown(
                              roles: roles,
                              selected: _selectedRoleFilter,
                              onChanged: (v) =>
                                  setState(() => _selectedRoleFilter = v),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'STATIONS',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'STATUS',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 80), // Actions
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),

                    // User Rows
                    ...List.generate(filtered.length, (i) {
                      final u = filtered[i];
                      final isLast = i == filtered.length - 1;
                      final roleObj = roles.firstWhere(
                        (r) => r.name == u.role,
                        orElse: () => DealerRole(
                          id: '0',
                          name: u.role,
                          description: '',
                          isSystem: false,
                        ),
                      );
                      final bool isSuperAdmin =
                          roleObj.name.toLowerCase().contains('super admin') ||
                              roleObj.isSystem;
                      final Color roleColor =
                          isSuperAdmin ? AppColors.red : AppColors.primary;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : const Border(
                                  bottom: BorderSide(color: AppColors.border),
                                ),
                          color: i.isEven
                              ? Colors.transparent
                              : Colors.white.withValues(alpha: 0.02),
                        ),
                        child: Row(
                          children: [
                            // Identity
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.2),
                                    child: Text(
                                      u.name.isNotEmpty
                                          ? u.name[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        u.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        u.email,
                                        style: const TextStyle(
                                          color: AppColors.textTertiary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Role
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: roleColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: roleColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        IconUtils.fromString(roleObj.iconName),
                                        size: 12,
                                        color: roleColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        u.role,
                                        style: TextStyle(
                                          color: roleColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Stations
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'All Stations',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            // Status
                            Expanded(
                              flex: 1,
                              child: _statusBadge(u.status),
                            ),

                            // Actions
                            SizedBox(
                              width: 80,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  PopupMenuButton<DealerRole>(
                                    icon: const Icon(
                                      LucideIcons.userCog,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    tooltip: 'Change Role',
                                    color: AppColors.cardBgHover,
                                    onSelected: (r) => _changeRole(u, r),
                                    itemBuilder: (context) => roles.map((r) {
                                      return PopupMenuItem(
                                        value: r,
                                        child: Text(
                                          r.name,
                                          style: TextStyle(
                                            color: r.name == u.role
                                                ? AppColors.primary
                                                : Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      LucideIcons.userX,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    tooltip: 'Revoke Access',
                                    onPressed: () =>
                                        _removeUser(u, roles: roles),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count',
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(label,
              style:
                  TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'active':
        color = AppColors.primary;
        label = 'Active';
        break;
      case 'pending':
        color = AppColors.amber;
        label = 'Pending';
        break;
      case 'inactive':
        color = AppColors.textTertiary;
        label = 'Inactive';
        break;
      case 'suspended':
        color = AppColors.red;
        label = 'Suspended';
        break;
      default:
        color = AppColors.textTertiary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _RoleFilterDropdown extends StatelessWidget {
  final List<DealerRole> roles;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _RoleFilterDropdown({
    required this.roles,
    this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      tooltip: 'Filter by Role',
      color: AppColors.cardBgHover,
      onSelected: onChanged,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selected ?? 'ALL ROLES',
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            LucideIcons.chevronDown,
            size: 12,
            color: AppColors.textTertiary,
          ),
        ],
      ),
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: null,
          child: Text('All Roles', style: TextStyle(color: Colors.white)),
        ),
        ...roles.map(
          (r) => PopupMenuItem(
            value: r.name,
            child: Text(r.name, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class _PillTab extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  const _PillTab({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
