import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const CommonBreadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      children.add(
        InkWell(
          onTap: isLast ? null : item.onTap,
          child: Text(
            item.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isLast ? Colors.black87 : Colors.grey[500],
              fontWeight: isLast ? FontWeight.normal : FontWeight.w400,
            ),
          ),
        ),
      );

      if (!isLast) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  BreadcrumbItem({required this.label, this.onTap});
}
