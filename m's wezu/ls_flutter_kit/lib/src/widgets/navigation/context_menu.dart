import 'package:flutter/material.dart';

/// Context menu item model.
class ContextMenuItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? color;

  const ContextMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });
}

/// Generic pop-up context menu button (Three-dot menu).
class ContextMenu<T> extends StatelessWidget {
  final List<ContextMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final IconData triggerIcon;
  final String? tooltip;

  const ContextMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.triggerIcon = Icons.more_vert,
    this.tooltip = 'Options',
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      icon: Icon(triggerIcon, color: Theme.of(context).colorScheme.outline),
      tooltip: tooltip,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return items.map((ContextMenuItem<T> item) {
          return PopupMenuItem<T>(
            value: item.value,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 20, color: item.color ?? Theme.of(context).colorScheme.onSurface),
                  const SizedBox(width: 12),
                ],
                Text(
                  item.label,
                  style: TextStyle(
                    color: item.color ?? Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
