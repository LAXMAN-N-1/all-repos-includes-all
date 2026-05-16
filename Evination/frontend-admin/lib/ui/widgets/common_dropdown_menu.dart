import 'package:flutter/material.dart';

class CommonDropdownMenu<T> extends StatelessWidget {
  final Widget trigger;
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T> onSelected;

  const CommonDropdownMenu({
    super.key,
    required this.trigger,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (context) => items,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: trigger,
    );
  }
}
