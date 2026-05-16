import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventifi_admin/features/auth/domain/auth_models.dart';
import 'package:eventifi_admin/features/auth/presentation/auth_controller.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final menus = authState.value?.menus ?? [];
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            height: 64,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                 // Placeholder Logo
                Container(
                  width: 32,
                  height: 32,
                  color: Colors.black,
                  alignment: Alignment.center,
                   child: const Text('E', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                 Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                      'EVE NATION',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                         color: Colors.amber[700]
                      ),
                    ),
                     Text(
                      'Every Celebration,',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                    ),
                     Text(
                      'Perfectly Planned',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                    ),
                   ],
                 )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _SidebarItem(
                  title: 'Dashboard',
                  icon: Icons.grid_view,
                  isSelected: currentPath == '/',
                  onTap: () => context.go('/'),
                ),
                // Dynamic Menus
                for (final menu in menus)
                  _SidebarItem(
                    title: menu.name,
                    icon: _getIconData(menu.icon),
                    isSelected: currentPath == (menu.route ?? '/unknown'),
                    onTap: () {
                      if (menu.route != null) {
                         context.go(menu.route!);
                      }
                    },
                  ),
              ],
            ),
          ),
           // User Profile (Bottom)
           const Divider(height: 1),
           ListTile(
             leading: const CircleAvatar(child: Icon(Icons.person)),
             title: Text(authState.value?.user.firstName ?? 'User'),
             subtitle: Text(authState.value?.user.roleCode ?? 'Role'),
             trailing: IconButton(
               icon: const Icon(Icons.logout),
               onPressed: () {
                 ref.read(authControllerProvider.notifier).logout();
               },
             ),
           )
        ],
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    // Simple mapping for now, can be expanded
    switch (iconName) {
      case 'dashboard':
        return Icons.grid_view;
      case 'organization':
        return Icons.business;
      case 'role': // "role" matches existing seed data usually
      case 'roles':
        return Icons.shield_outlined;
      case 'users':
        return Icons.people_outline;
      case 'events':
        return Icons.calendar_today;
      case 'vendors':
        return Icons.storefront;
      case 'bidding':
        return Icons.gavel;
      case 'orders':
        return Icons.shopping_cart_outlined;
      case 'reports':
        return Icons.description_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}

class _SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber[50] : Colors.transparent,
            border: isSelected
                ? Border(right: BorderSide(color: Colors.amber[700]!, width: 4))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.amber[700] : Colors.grey[600],
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.amber[900] : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
