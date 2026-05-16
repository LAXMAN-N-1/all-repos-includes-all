import 'package:flutter/material.dart';

class CommonMenubar extends StatelessWidget {
  final List<MenubarItem> items;

  const CommonMenubar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return MenuAnchor(
            builder: (context, controller, child) {
              return InkWell(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(item.label, style: const TextStyle(fontSize: 14)),
                ),
              );
            },
            menuChildren: item.children.map((child) {
              return MenuItemButton(
                onPressed: child.onTap,
                child: Text(child.label),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class MenubarItem {
  final String label;
  final List<MenubarChild> children;

  MenubarItem({required this.label, required this.children});
}

class MenubarChild {
  final String label;
  final VoidCallback onTap;

  MenubarChild({required this.label, required this.onTap});
}
