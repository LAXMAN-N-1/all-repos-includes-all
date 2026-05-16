import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';

// Sidebar collapse state
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

class DealerShell extends ConsumerStatefulWidget {
  final Widget child;
  const DealerShell({super.key, required this.child});

  @override
  ConsumerState<DealerShell> createState() => _DealerShellState();
}

class _DealerShellState extends ConsumerState<DealerShell> {
  bool _searchFocused = false;

  @override
  Widget build(BuildContext context) {
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final isMobile = MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      drawer: isMobile
          ? Drawer(
              width: 260,
              backgroundColor: AppColors.shellBg,
              child: const _Sidebar(collapsed: false, isDrawer: true),
            )
          : null,
      body: Row(
        children: [
          // Desktop Sidebar
          if (!isMobile) _Sidebar(collapsed: collapsed),

          // Main Content Area
          Expanded(
            child: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  _Topbar(
                    searchFocused: _searchFocused,
                    onSearchFocusChanged: (f) => setState(() => _searchFocused = f),
                    isMobile: isMobile,
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SIDEBAR
// ═══════════════════════════════════════════════════════════════

class _Sidebar extends ConsumerWidget {
  final bool collapsed;
  final bool isDrawer;
  const _Sidebar({required this.collapsed, this.isDrawer = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isDrawer ? 260 : (collapsed ? 64 : 240),
      decoration: BoxDecoration(
        color: AppColors.shellBg,
        border: isDrawer
            ? null
            : Border(right: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
      ),
      child: Column(
        children: [
          // Brand Header
          _BrandHeader(collapsed: collapsed),

          const SizedBox(height: 8),

          // Nav items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('MAIN', collapsed),
                  _NavItem(icon: LucideIcons.layoutDashboard, label: 'Overview', path: '/dashboard', currentPath: currentPath, collapsed: collapsed, isDrawer: isDrawer),
                  _NavItem(icon: LucideIcons.mapPin, label: 'Stations', path: '/stations', currentPath: currentPath, collapsed: collapsed, isDrawer: isDrawer),

                  const SizedBox(height: 12),
                  _sectionLabel('OPERATIONS', collapsed),
                  _NavItem(icon: LucideIcons.package, label: 'Inventory', path: '/inventory', currentPath: currentPath, collapsed: collapsed, isDrawer: isDrawer),
                  _NavItem(icon: LucideIcons.indianRupee, label: 'Revenue', path: '/sales', currentPath: currentPath, collapsed: collapsed, badgeColor: AppColors.amber, isDrawer: isDrawer),

                  const SizedBox(height: 12),
                  _sectionLabel('CUSTOMERS', collapsed),
                  _NavItem(icon: LucideIcons.users, label: 'Customers', path: '/customers', currentPath: currentPath, collapsed: collapsed, isDrawer: isDrawer),
                  _NavItem(icon: LucideIcons.headphones, label: 'Tickets', path: '/tickets', currentPath: currentPath, collapsed: collapsed, badge: '3', isDrawer: isDrawer),

                  const SizedBox(height: 12),
                  _sectionLabel('MARKETING', collapsed),
                  _NavItem(icon: LucideIcons.megaphone, label: 'Campaigns', path: '/campaigns', currentPath: currentPath, collapsed: collapsed, isDrawer: isDrawer),

                  const SizedBox(height: 12),
                  _sectionLabel('BUSINESS', collapsed),
                  _NavItem(icon: LucideIcons.barChart3, label: 'Analytics', path: '/analytics', currentPath: currentPath, collapsed: collapsed, isDrawer: isDrawer),
                  _NavItem(icon: LucideIcons.fileText, label: 'Documents', path: '/documents', currentPath: currentPath, collapsed: collapsed, isDrawer: isDrawer),
                  _NavItem(icon: LucideIcons.bell, label: 'Notifications', path: '/notifications', currentPath: currentPath, collapsed: collapsed, isDrawer: isDrawer),

                  const SizedBox(height: 12),
                  _sectionLabel('SYSTEM', collapsed),
                  _NavItem(icon: LucideIcons.users, label: 'Team Members', path: '/roles/users', currentPath: currentPath, collapsed: collapsed, isDrawer: isDrawer),
                  _NavItem(icon: LucideIcons.shield, label: 'Roles', path: '/roles', currentPath: currentPath, collapsed: collapsed, isDrawer: isDrawer),
                  _NavItem(icon: LucideIcons.settings, label: 'Settings', path: '/settings', currentPath: currentPath, collapsed: collapsed, isDrawer: isDrawer),
                ],
              ),
            ),
          ),

          // User Profile
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
            ),
            child: _UserProfile(collapsed: collapsed, isDrawer: isDrawer),
          ),

          // Collapse button (Desktop only)
          if (!isDrawer)
            InkWell(
              onTap: () => ref.read(sidebarCollapsedProvider.notifier).state = !collapsed,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.3))),
                ),
                child: Center(
                  child: AnimatedRotation(
                    turns: collapsed ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(LucideIcons.chevronsLeft, size: 14, color: AppColors.textTertiary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, bool collapsed) {
    if (collapsed) return const SizedBox(height: 16);
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 8, bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Brand Header ────────────────────────────────────────────
class _BrandHeader extends StatelessWidget {
  final bool collapsed;
  const _BrandHeader({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryGlow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(LucideIcons.batteryCharging, size: 16, color: AppColors.primary),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('WEZU', style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 13,
                  fontWeight: FontWeight.w800, letterSpacing: 0.5,
                )),
                Text('Dealer Portal', style: TextStyle(
                  color: AppColors.primary, fontSize: 9,
                  fontWeight: FontWeight.w600, letterSpacing: 1.5,
                )),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Nav Item ────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String path;
  final String currentPath;
  final bool collapsed;
  final String? badge;
  final Color? badgeColor;
  final bool isDrawer;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.currentPath,
    required this.collapsed,
    this.badge,
    this.badgeColor,
    this.isDrawer = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  bool get _isActive => widget.currentPath.startsWith(widget.path);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Tooltip(
          message: widget.collapsed ? widget.label : '',
          waitDuration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: () {
              context.go(widget.path);
              if (widget.isDrawer) {
                Navigator.of(context).pop();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: widget.collapsed ? 12 : 10),
              decoration: BoxDecoration(
                color: _isActive
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : (_hovered ? AppColors.cardBg : Colors.transparent),
                borderRadius: BorderRadius.circular(8),
                border: _isActive
                    ? Border(left: BorderSide(color: AppColors.primary, width: 2))
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    widget.icon, size: 16,
                    color: _isActive ? AppColors.primary : (_hovered ? AppColors.textSecondary : AppColors.textTertiary),
                  ),
                  if (!widget.collapsed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _isActive ? FontWeight.w600 : FontWeight.w400,
                          color: _isActive ? AppColors.primary : (_hovered ? AppColors.textPrimary : AppColors.textSecondary),
                        ),
                        child: Text(widget.label),
                      ),
                    ),
                    if (widget.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (widget.badgeColor ?? AppColors.primary).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.badge!,
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: widget.badgeColor ?? AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── User Profile ────────────────────────────────────────────
class _UserProfile extends ConsumerWidget {
  final bool collapsed;
  final bool isDrawer;
  const _UserProfile({required this.collapsed, this.isDrawer = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final name = user?.fullName ?? 'Dealer';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';

    return Padding(
      padding: const EdgeInsets.all(8),
      child: PopupMenuButton<String>(
        color: AppColors.cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        offset: const Offset(0, -120),
        onSelected: (value) {
          if (isDrawer) Navigator.of(context).pop();
          if (value == 'logout') {
            ref.read(authProvider.notifier).logout();
            context.go('/login');
          } else if (value == 'account') {
            context.go('/my-account');
          } else if (value == 'settings') {
            context.go('/settings');
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'account',
            child: Row(
              children: [
                const Icon(LucideIcons.user, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Text('My Account', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                const Icon(LucideIcons.settings, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Text('Settings', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                const Icon(LucideIcons.logOut, size: 14, color: AppColors.red),
                const SizedBox(width: 8),
                const Text('Log Out', style: TextStyle(fontSize: 13, color: AppColors.red)),
              ],
            ),
          ),
        ],
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 6 : 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.pageBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(initial, style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12,
                  )),
                ),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(name, style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600,
                      ), overflow: TextOverflow.ellipsis),
                      Text(user?.userType ?? 'Dealer Admin', style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 10,
                      )),
                    ],
                  ),
                ),
                const Icon(LucideIcons.moreVertical, size: 14, color: AppColors.textTertiary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TOPBAR
// ═══════════════════════════════════════════════════════════════

class _Topbar extends StatelessWidget {
  final bool searchFocused;
  final ValueChanged<bool> onSearchFocusChanged;
  final bool isMobile;

  const _Topbar({required this.searchFocused, required this.onSearchFocusChanged, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    final pageTitle = _getPageTitle(uri);
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dateStr = '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.shellBg,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      child: Row(
        children: [
          if (isMobile) ...[
            IconButton(
              icon: const Icon(LucideIcons.menu, size: 20, color: AppColors.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(maxWidth: 40, minWidth: 40),
            ),
            const SizedBox(width: 4),
          ],
          
          // Page title - Expanded to prevent pushing icons off-screen
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pageTitle, 
                  style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (!isMobile)
                  Text(dateStr, style: const TextStyle(
                    fontSize: 11, color: AppColors.textTertiary,
                  )),
              ],
            ),
          ),
          
          const SizedBox(width: 8),

          // Search
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isMobile ? (searchFocused ? 120 : 36) : (searchFocused ? 320 : 200),
            height: 36,
            child: TextField(
              onTap: () => onSearchFocusChanged(true),
              onTapOutside: (_) => onSearchFocusChanged(false),
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: isMobile && !searchFocused ? null : 'Search...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(LucideIcons.search, size: 15, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.pageBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),

          // Notification bell
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.bell, size: 18, color: AppColors.textSecondary),
                  onPressed: () => context.go('/notifications'),
                  padding: EdgeInsets.zero,
                ),
                Positioned(
                  right: 10, top: 10,
                  child: Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 4),

          // User Avatar
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Text('D', style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12,
              )),
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(String uri) {
    if (uri.startsWith('/dashboard')) return 'Overview';
    if (uri.startsWith('/stations')) return 'Station Management';
    if (uri.startsWith('/inventory')) return 'Inventory';
    if (uri.startsWith('/sales')) return 'Sales & Revenue';
    if (uri.startsWith('/customers')) return 'Customers';
    if (uri.startsWith('/tickets')) return 'Support Tickets';
    if (uri.startsWith('/documents')) return 'Documents';
    if (uri.startsWith('/campaigns')) return 'Campaigns';
    if (uri.startsWith('/analytics')) return 'Analytics & Reports';
    if (uri.startsWith('/notifications')) return 'Notifications';
    if (uri.startsWith('/roles')) return 'Roles & Permissions';
    if (uri.startsWith('/settings')) return 'Settings';
    if (uri.startsWith('/my-account')) return 'My Account';
    return 'Overview';
  }
}
