import 'package:flutter/material.dart';

class CommonHoverCard extends StatelessWidget {
  final Widget child;
  final Widget hoverContent;
  final double width;

  const CommonHoverCard({
    super.key,
    required this.child,
    required this.hoverContent,
    this.width = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      richMessage: WidgetSpan(
        child: Container(
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: hoverContent,
        ),
      ),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: child,
    );
  }
}
