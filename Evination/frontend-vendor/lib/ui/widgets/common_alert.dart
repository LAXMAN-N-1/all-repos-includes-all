import 'package:flutter/material.dart';

enum AlertVariant { defaultVariant, destructive, success, warning }

class CommonAlert extends StatelessWidget {
  final String? title;
  final String description;
  final AlertVariant variant;
  final IconData? icon;

  const CommonAlert({
    super.key,
    this.title,
    required this.description,
    this.variant = AlertVariant.defaultVariant,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color iconColor;
    Color borderColor;

    switch (variant) {
      case AlertVariant.destructive:
        bgColor = Colors.red[50]!;
        textColor = Colors.red[900]!;
        iconColor = Colors.red[600]!;
        borderColor = Colors.red[200]!;
        break;
      case AlertVariant.success:
        bgColor = Colors.green[50]!;
        textColor = Colors.green[900]!;
        iconColor = Colors.green[600]!;
        borderColor = Colors.green[200]!;
        break;
      case AlertVariant.warning:
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[900]!;
        iconColor = Colors.orange[600]!;
        borderColor = Colors.orange[200]!;
        break;
      case AlertVariant.defaultVariant:
      default:
        bgColor = Colors.white;
        textColor = Colors.black87;
        iconColor = Colors.black87;
        borderColor = Colors.grey[200]!;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: textColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
