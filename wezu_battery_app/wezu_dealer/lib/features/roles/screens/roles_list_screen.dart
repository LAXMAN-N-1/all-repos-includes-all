import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/roles_provider.dart';
import '../../../core/models/dealer_role.dart';
import '../../../core/utils/icon_utils.dart';
import '../widgets/create_role_drawer.dart';
import '../../../core/services/roles_service.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/widgets/confirmation_modal.dart';


class RolesListScreen extends ConsumerStatefulWidget {
  const RolesListScreen({super.key});
  @override
  ConsumerState<RolesListScreen> createState() => _RolesListScreenState();
}

class _RolesListScreenState extends ConsumerState<RolesListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _stagger(int i, {required Widget child}) {
    final begin = (i * 0.1).clamp(0.0, 1.0);
    final end = (begin + 0.3).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _c,
      builder: (c, _) {
        final t = Curves.easeOut.transform(
          ((_c.value - begin) / (end - begin)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  void _openCreateRoleDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, anim1, anim2) => const Align(
        alignment: Alignment.centerRight,
        child: CreateRoleDrawer(),
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Roles & Permissions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Dashboard / Roles',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 13,
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
                    _PillTab(title: 'Roles', isActive: true, onTap: () {}),
                    _PillTab(
                      title: 'Users',
                      isActive: false,
                      onTap: () => context.go('/roles/users'),
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search roles...',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    prefixIcon: Icon(
                      LucideIcons.search,
                      size: 16,
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
              // Create Button
              ElevatedButton.icon(
                onPressed: _openCreateRoleDrawer,
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Create Role'),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Stats Bar
          rolesAsync.when(
            loading: () => const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  'Error: $err',
                  style: TextStyle(color: AppColors.red),
                ),
              ),
            ),
            data: (roles) {
              final int totalUsers =
                  roles.fold<int>(0, (sum, r) => sum + (r.usersCount));
              final lastUpdated = roles.isEmpty
                  ? DateTime.now()
                  : roles
                      .expand((r) => [r.updatedAt])
                      .reduce((a, b) => a.isAfter(b) ? a : b);
              final timeAgo = DateTime.now().difference(lastUpdated);
              String timeStr = timeAgo.inHours > 24
                  ? '${timeAgo.inDays} days ago'
                  : (timeAgo.inHours > 0
                      ? '${timeAgo.inHours} hrs ago'
                      : '${timeAgo.inMinutes} mins ago');

              return Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      title: 'Total Roles',
                      value: '${roles.length}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatTile(
                      title: 'Total Users',
                      value: '$totalUsers',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatTile(title: 'Last Changed', value: timeStr),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: _StatTile(
                      title: 'Pending Requests',
                      value: '0',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Roles List
          rolesAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (roles) {
              final filteredRoles = roles
                  .where((r) => r.name.toLowerCase().contains(_searchQuery))
                  .toList();

              if (filteredRoles.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.shieldOff,
                          size: 64,
                          color: AppColors.textTertiary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No roles match your search',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _searchCtrl.clear(),
                          child: const Text(
                            'Clear search',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: List.generate(filteredRoles.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _stagger(
                      i,
                      child: _EnhancedRoleCard(role: filteredRoles[i]),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
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

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final bool highlight;

  const _StatTile({
    required this.title,
    required this.value,
    bool? highlight,
  }) : highlight = highlight ?? false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent line
          Container(
            height: 3,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: highlight ? AppColors.amber : AppColors.primary,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppColors.amber : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedRoleCard extends ConsumerStatefulWidget {
  final DealerRole role;
  const _EnhancedRoleCard({required this.role});

  @override
  ConsumerState<_EnhancedRoleCard> createState() => _EnhancedRoleCardState();
}

class _EnhancedRoleCardState extends ConsumerState<_EnhancedRoleCard> {
  bool _hovered = false;

  int _countPerms(String type) {
    int count = 0;
    widget.role.permissions.forEach((_, perms) {
      if (perms.contains(type)) count++;
    });
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuperAdmin =
        widget.role.name.toLowerCase().contains('super admin') ||
            widget.role.isSystem;
    final Color accentColor = isSuperAdmin ? AppColors.red : AppColors.primary;

    // Zone 3 logic
    final List<Map<String, String>> modules = [
      {'id': 'DS', 'name': 'Dashboard'},
      {'id': 'ST', 'name': 'Stations'},
      {'id': 'INV', 'name': 'Inventory'},
      {'id': 'REV', 'name': 'Revenue'},
      {'id': 'CUS', 'name': 'Customers'},
      {'id': 'TKT', 'name': 'Tickets'},
      {'id': 'DOC', 'name': 'Documents'},
      {'id': 'CAM', 'name': 'Campaigns'},
    ];

    Color getModuleDotColor(String name) {
      if (isSuperAdmin) return AppColors.primary;
      final perms = widget.role.permissions[name] ?? [];
      if (perms.contains('View') && perms.contains('Edit'))
        return AppColors.primary;
      if (perms.contains('View')) return AppColors.amber;
      return AppColors.textTertiary.withValues(alpha: 0.3);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/roles/edit/${widget.role.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.cardBgHover : AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered
                  ? accentColor.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Hover sliding glow bar
              if (_hovered)
                Positioned(
                  left: -24,
                  top: -24,
                  bottom: -24,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Zone 1: Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: IconUtils.gradientFromHex(
                        widget.role.colorHex,
                        isSuperAdmin: isSuperAdmin,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        IconUtils.fromString(widget.role.iconName),
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Zone 2: Identity
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.role.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.role.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _MiniChip(
                              label: '${_countPerms('View')} View',
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            _MiniChip(
                              label: '${_countPerms('Create')} Create',
                              color: AppColors.cyan,
                            ),
                            const SizedBox(width: 6),
                            _MiniChip(
                              label: '${_countPerms('Edit')} Edit',
                              color: AppColors.amber,
                            ),
                            const SizedBox(width: 6),
                            _MiniChip(
                              label: '${_countPerms('Delete')} Delete',
                              color: AppColors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Zone 3: Matrix Preview Strip
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: modules.map((m) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                m['id']!,
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: getModuleDotColor(m['name']!),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Zone 4: User count
                  Container(
                    width: 140,
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.role.usersCount} users',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (widget.role.usersCount > 0)
                          SizedBox(
                            width: 60,
                            height: 24,
                            child: Stack(
                              children: List.generate(
                                widget.role.usersCount > 3
                                    ? 3
                                    : widget.role.usersCount,
                                (i) {
                                  return Positioned(
                                    right: i * 14.0,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.cardBg,
                                          width: 2,
                                        ),
                                        color: accentColor.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                      child: const Icon(
                                        LucideIcons.user,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Zone 5: Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          isSuperAdmin ? LucideIcons.lock : LucideIcons.edit2,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: isSuperAdmin
                            ? null
                            : () => context.go('/roles/edit/${widget.role.id}'),
                        tooltip: isSuperAdmin ? 'System Role' : 'Edit',
                      ),
                      IconButton(
                        icon: Icon(
                          isSuperAdmin ? LucideIcons.lock : LucideIcons.trash2,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: isSuperAdmin
                            ? null
                            : () {
                                ConfirmationModal.show(
                                  context,
                                  title: 'Delete Role',
                                  description:
                                      'Are you sure you want to delete ${widget.role.name}?',
                                  confirmText: 'Delete',
                                  isDanger: true,
                                  onConfirm: () async {
                                    try {
                                      final success = await ref
                                          .read(rolesServiceProvider)
                                          .deleteRole(
                                            int.parse(widget.role.id),
                                          );
                                      if (success) {
                                        if (!mounted) return;
                                        ref.invalidate(rolesProvider);
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
                        tooltip: isSuperAdmin ? 'System Role' : 'Delete',
                      ),
                      const SizedBox(width: 8),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _hovered ? 1.0 : 0.4,
                        child: const Icon(
                          LucideIcons.chevronRight,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
