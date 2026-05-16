import 'package:flutter/material.dart';

enum BadgeVariant { defaultVariant, secondary, destructive, outline }

class CommonBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;

  const CommonBadge({super.key, required this.text, this.variant = BadgeVariant.defaultVariant});

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color textColor;
    Border? border;

    switch (variant) {
      case BadgeVariant.secondary:
        bgColor = const Color(0xFFF3F4F6); // secondary
        textColor = const Color(0xFF1F2937); // secondary-foreground
        break;
      case BadgeVariant.destructive:
        bgColor = Colors.red;
        textColor = Colors.white;
        break;
      case BadgeVariant.outline:
        bgColor = Colors.transparent;
        textColor = Colors.black87;
        border = Border.all(color: Colors.black12);
        break;
      case BadgeVariant.defaultVariant:
      default:
        bgColor = Colors.black; // primary
        textColor = Colors.white; // primary-foreground
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4), // rounded-md (~4-6px)
        border: border,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
