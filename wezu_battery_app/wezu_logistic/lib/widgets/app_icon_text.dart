import 'package:flutter/material.dart';
import '../config/app_spacing.dart';

class AppIconText extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final TextStyle? style;

  const AppIconText({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurfaceVariant;
    final effectiveStyle = style ?? theme.textTheme.bodySmall?.copyWith(
      color: effectiveColor,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: effectiveColor),
        AppSpacing.gapW4,
        Flexible(
          child: Text(
            label, 
            style: effectiveStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
