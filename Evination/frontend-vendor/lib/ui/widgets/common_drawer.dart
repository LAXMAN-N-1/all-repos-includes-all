import 'package:flutter/material.dart';

class CommonDrawer extends StatelessWidget {
  final Widget child;
  final Widget? header;
  final Widget? footer;

  const CommonDrawer({super.key, required this.child, this.header, this.footer});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: header!,
            ),
          const Divider(height: 1),
          Expanded(child: child),
          if (footer != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}
