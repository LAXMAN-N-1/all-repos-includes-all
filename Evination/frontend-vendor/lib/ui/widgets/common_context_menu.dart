import 'package:flutter/material.dart';

class CommonContextMenu extends StatelessWidget {
  final Widget child;
  final List<PopupMenuItem> items;
  final Function(dynamic) onSelected;

  const CommonContextMenu({
    super.key,
    required this.child,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (details) {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          items: items,
          elevation: 8,
        ).then((value) {
          if (value != null) {
            onSelected(value);
          }
        });
      },
      child: child,
    );
  }
}
