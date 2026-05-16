import 'package:flutter/material.dart';

/// Section header with title and optional "View All" action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final TextStyle? titleStyle;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction, this.titleStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: titleStyle ?? Theme.of(context).textTheme.titleMedium),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!, style: TextStyle(color: Theme.of(context).colorScheme.primary))),
        ],
      ),
    );
  }
}

/// Responsive grid that auto-adjusts columns by screen width.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int cols;
        if (width >= 1024) {
          cols = desktopColumns;
        } else if (width >= 600) {
          cols = tabletColumns;
        } else {
          cols = mobileColumns;
        }

        return Padding(
          padding: padding,
          child: Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children.map((child) {
              final itemWidth = (width - (cols - 1) * spacing - (padding is EdgeInsets ? ((padding as EdgeInsets).horizontal) : 0)) / cols;
              return SizedBox(width: itemWidth, child: child);
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Page header with breadcrumb, title, and action buttons.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String>? breadcrumbs;
  final List<Widget>? actions;

  const PageHeader({super.key, required this.title, this.subtitle, this.breadcrumbs, this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (breadcrumbs != null && breadcrumbs!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: breadcrumbs!.asMap().entries.map((e) {
                  final isLast = e.key == breadcrumbs!.length - 1;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.value, style: theme.textTheme.bodySmall?.copyWith(
                        color: isLast ? theme.colorScheme.primary : theme.colorScheme.outline,
                        fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                      )),
                      if (!isLast) Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.chevron_right, size: 14, color: theme.colorScheme.outline)),
                    ],
                  );
                }).toList(),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                    if (subtitle != null)
                      Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline))),
                  ],
                ),
              ),
              if (actions != null) ...actions!.map((a) => Padding(padding: const EdgeInsets.only(left: 8), child: a)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Yes/No confirmation dialog.
class ConfirmationModal extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final IconData? icon;

  const ConfirmationModal({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor,
    this.icon,
  });

  static Future<bool> show(BuildContext context, {required String title, required String message, String? confirmLabel, Color? confirmColor, IconData? icon}) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => ConfirmationModal(title: title, message: message, confirmLabel: confirmLabel ?? 'Confirm', confirmColor: confirmColor, icon: icon),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 48, color: confirmColor ?? theme.colorScheme.error), const SizedBox(height: 16)],
          Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(cancelLabel)),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: confirmColor ?? theme.colorScheme.error),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

/// Admin dashboard shell with sidebar navigation.
class AdminShell extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdminDestination> destinations;
  final Widget? header;
  final Widget? footer;
  final double sidebarWidth;

  const AdminShell({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.header,
    this.footer,
    this.sidebarWidth = 260,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    if (!isDesktop) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations.take(5).map((d) => NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon ?? d.icon), label: d.label)).toList(),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: sidebarWidth,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(right: BorderSide(color: theme.dividerColor)),
            ),
            child: Column(
              children: [
                if (header != null) header!,
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    children: destinations.asMap().entries.map((e) {
                      final isSelected = e.key == selectedIndex;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          leading: Icon(isSelected ? (e.value.selectedIcon ?? e.value.icon) : e.value.icon,
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline),
                          title: Text(e.value.label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)),
                          selected: isSelected,
                          selectedTileColor: theme.colorScheme.primary.withOpacity(0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          onTap: () => onDestinationSelected(e.key),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (footer != null) footer!,
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class AdminDestination {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  const AdminDestination({required this.label, required this.icon, this.selectedIcon});
}
