import 'package:flutter/material.dart';

class AdminSidebarItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final List<AdminSidebarItem>? subItems;

  const AdminSidebarItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.subItems,
  });
}

/// A highly customizable, collapsible admin sidebar.
///
/// Features:
/// - User profile header section
/// - Nested sub-items via ExpansionTile
/// - Footer section (e.g. for settings / logout)
/// - Selected state styling
class AdminSidebar extends StatefulWidget {
  final Widget? header;
  final List<AdminSidebarItem> items;
  final Widget? footer;
  final double width;
  final Color? backgroundColor;
  final bool isCollapsed;

  const AdminSidebar({
    super.key,
    this.header,
    required this.items,
    this.footer,
    this.width = 280,
    this.backgroundColor,
    this.isCollapsed = false,
  });

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surface;
    final w = widget.isCollapsed ? 80.0 : widget.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: w,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          if (widget.header != null) widget.header!,
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              children: widget.items.map((item) => _buildItem(item, theme)).toList(),
            ),
          ),
          if (widget.footer != null) widget.footer!,
        ],
      ),
    );
  }

  Widget _buildItem(AdminSidebarItem item, ThemeData theme) {
    if (widget.isCollapsed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: item.isSelected
                  ? theme.colorScheme.primary.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (item.subItems != null && item.subItems!.isNotEmpty) {
      return ExpansionTile(
        key: PageStorageKey(item.title),
        leading: Icon(item.icon, color: theme.colorScheme.onSurfaceVariant),
        title: Text(item.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        shape: const Border(),
        childrenPadding: const EdgeInsets.only(left: 24),
        children: item.subItems!.map((sub) => _buildItem(sub, theme)).toList(),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: ListTile(
        onTap: item.onTap,
        leading: Icon(
          item.icon,
          color: item.isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          item.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.w500,
            color: item.isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
        selected: item.isSelected,
        selectedTileColor: theme.colorScheme.primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        dense: true,
        horizontalTitleGap: 8,
      ),
    );
  }
}
