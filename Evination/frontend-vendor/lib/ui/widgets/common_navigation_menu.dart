import 'package:flutter/material.dart';

// Simplified Navigation Menu for Flutter Context
class CommonNavigationMenu extends StatelessWidget {
  final List<NavigationMenuItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CommonNavigationMenu({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50], 
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = selectedIndex == index;
          return InkWell(
            onTap: () => onItemSelected(index),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
              ),
              child: Text(
                item.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class NavigationMenuItem {
  final String label;
  NavigationMenuItem({required this.label});
}
