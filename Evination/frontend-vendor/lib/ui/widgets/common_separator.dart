import 'package:flutter/material.dart';

class CommonSeparator extends StatelessWidget {
  final Axis orientation;
  final Color? color;

  const CommonSeparator({
    super.key,
    this.orientation = Axis.horizontal,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (orientation == Axis.horizontal) {
      return Divider(height: 1, color: color ?? Colors.grey[200]);
    } else {
      return VerticalDivider(width: 1, color: color ?? Colors.grey[200]);
    }
  }
}
