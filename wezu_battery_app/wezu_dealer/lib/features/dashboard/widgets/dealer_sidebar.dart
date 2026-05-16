import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';

class DealerSidebar extends StatelessWidget {
  final String currentRoute;
  
  const DealerSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(right: BorderSide(color: AppColors.borderDark)),
      ),
      child: Column(
        children: [
          // Logo & Branding
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF059669)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: const Icon(LucideIcons.batteryCharging, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WEZU', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    const Text('Dealer Portal', style: TextStyle(fontSize: 10, color: AppColors.textTertiary, letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(color: AppColors.borderDark, height: 1),
          const SizedBox(height: 8),

          // — Section: Main —
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 12, bottom: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('MAIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2)),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _NavItem(
                  icon: LucideIcons.layoutDashboard,
                  label: 'Overview',
                  isSelected: currentRoute == '/dashboard',
                  onTap: () => context.go('/dashboard'),
                ),
                _NavItem(
                  icon: LucideIcons.mapPin,
                  label: 'Stations',
                  isSelected: currentRoute.startsWith('/stations'),
                  onTap: () => context.go('/stations'),
                ),
                _NavItem(
                  icon: LucideIcons.packageCheck,
                  label: 'Inventory',
                  isSelected: currentRoute.startsWith('/inventory'),
                  onTap: () => context.go('/inventory'),
                ),
                _NavItem(
                  icon: LucideIcons.indianRupee,
                  label: 'Sales & Revenue',
                  isSelected: currentRoute.startsWith('/sales'),
                  onTap: () => context.go('/sales'),
                ),
                _NavItem(
                  icon: LucideIcons.users,
                  label: 'Customers',
                  isSelected: currentRoute.startsWith('/customers'),
                  onTap: () => context.go('/customers'),
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8, bottom: 6),
                  child: Text('ENGAGEMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2)),
                ),

                _NavItem(
                  icon: LucideIcons.megaphone,
                  label: 'Campaigns',
                  isSelected: currentRoute.startsWith('/campaigns'),
                  onTap: () => context.go('/campaigns'),
                  accentColor: AppColors.purple,
                ),
                _NavItem(
                  icon: LucideIcons.barChart3,
                  label: 'Analytics',
                  isSelected: currentRoute.startsWith('/analytics'),
                  onTap: () => context.go('/analytics'),
                  accentColor: AppColors.cyan,
                ),
                _NavItem(
                  icon: LucideIcons.ticket,
                  label: 'Support Tickets',
                  isSelected: currentRoute.startsWith('/tickets'),
                  onTap: () => context.go('/tickets'),
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8, bottom: 6),
                  child: Text('MANAGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2)),
                ),

                _NavItem(
                  icon: LucideIcons.fileText,
                  label: 'Documents',
                  isSelected: currentRoute.startsWith('/documents'),
                  onTap: () => context.go('/documents'),
                ),
                _NavItem(
                  icon: LucideIcons.bell,
                  label: 'Notifications',
                  isSelected: currentRoute.startsWith('/notifications'),
                  onTap: () => context.go('/notifications'),
                  accentColor: AppColors.amber,
                ),
                _NavItem(
                  icon: LucideIcons.shield,
                  label: 'Roles & Access',
                  isSelected: currentRoute.startsWith('/roles'),
                  onTap: () => context.go('/roles'),
                ),
              ],
            ),
          ),
          
          // Bottom Actions
          const Divider(color: AppColors.borderDark, height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _NavItem(
                  icon: LucideIcons.settings,
                  label: 'Settings',
                  isSelected: currentRoute.startsWith('/settings'),
                  onTap: () => context.go('/settings'),
                ),
                _NavItem(
                  icon: LucideIcons.logOut,
                  label: 'Sign Out',
                  isSelected: false,
                  onTap: () => context.go('/login'),
                  accentColor: AppColors.red,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor ?? AppColors.primary;
    final isActive = widget.isSelected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? color.withValues(alpha: 0.1)
                  : _hovered
                      ? AppColors.pageBg.withValues(alpha: 0.5)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isActive ? Border.all(color: color.withValues(alpha: 0.15)) : null,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 18,
                  color: isActive ? color : (_hovered ? AppColors.textSecondary : AppColors.textTertiary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive ? AppColors.textPrimary : (_hovered ? AppColors.textSecondary : AppColors.textTertiary),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4, height: 4,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color,
                      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4)]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
