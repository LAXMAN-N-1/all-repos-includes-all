import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Configuration for a slidable action item.
class SlidableActionData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const SlidableActionData({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// A standardized wrapper over flutter_slidable for swipe-to-delete or edit actions.
class SlidableListItem extends StatelessWidget {
  final Widget child;
  final String itemKey;
  final List<SlidableActionData>? startActions;
  final List<SlidableActionData>? endActions;
  final double actionExtentRatio;

  const SlidableListItem({
    super.key,
    required this.child,
    required this.itemKey,
    this.startActions,
    this.endActions,
    this.actionExtentRatio = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    if ((startActions == null || startActions!.isEmpty) &&
        (endActions == null || endActions!.isEmpty)) {
      return child; // Degrade gracefully if no actions provided
    }

    return Slidable(
      key: ValueKey(itemKey),
      startActionPane: startActions != null && startActions!.isNotEmpty
          ? ActionPane(
              motion: const ScrollMotion(),
              extentRatio: actionExtentRatio * startActions!.length,
              children: startActions!.map((action) => _buildSlidableAction(action)).toList(),
            )
          : null,
      endActionPane: endActions != null && endActions!.isNotEmpty
          ? ActionPane(
              motion: const ScrollMotion(),
              extentRatio: actionExtentRatio * endActions!.length,
              children: endActions!.map((action) => _buildSlidableAction(action)).toList(),
            )
          : null,
      child: child,
    );
  }

  Widget _buildSlidableAction(SlidableActionData action) {
    return CustomSlidableAction(
      onPressed: (_) => action.onTap(),
      backgroundColor: action.color,
      foregroundColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(action.icon),
          const SizedBox(height: 4),
          Text(action.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
