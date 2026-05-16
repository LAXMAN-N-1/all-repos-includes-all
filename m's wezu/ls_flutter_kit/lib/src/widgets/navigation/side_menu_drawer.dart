import 'package:flutter/material.dart';

/// An Apple/iOS style side menu drawer optimized for mobile.
///
/// Combines a profile header, glassmorphism overlay on active apps,
/// and smooth slide anims for full native app feel.
class SideMenuDrawer extends StatelessWidget {
  final Widget header;
  final List<Widget> menuItems;
  final Widget? footer;
  final Color? backgroundColor;

  const SideMenuDrawer({
    super.key,
    required this.header,
    required this.menuItems,
    this.footer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: header,
            ),
            const Divider(height: 1, indent: 24, endIndent: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                children: menuItems,
              ),
            ),
            if (footer != null) ...[
              const Divider(height: 1, indent: 24, endIndent: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper construct for Apple-style side menu items
class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? iconColor;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : (iconColor ?? theme.colorScheme.onSurfaceVariant),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? activeColor : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.chevron_right, size: 20, color: activeColor),
            ],
          ),
        ),
      ),
    );
  }
}
