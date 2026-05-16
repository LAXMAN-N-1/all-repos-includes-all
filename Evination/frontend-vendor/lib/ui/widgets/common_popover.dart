import 'package:flutter/material.dart';

class CommonPopover extends StatelessWidget {
  final Widget trigger;
  final Widget content;

  const CommonPopover({
    super.key,
    required this.trigger,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: trigger,
        );
      },
      menuChildren: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: content,
        ),
      ],
    );
  }
}
