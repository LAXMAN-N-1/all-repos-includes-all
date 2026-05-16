import 'package:flutter/material.dart';

class CommonAspectRatio extends StatelessWidget {
  final double ratio;
  final Widget child;

  const CommonAspectRatio({super.key, required this.ratio, required this.child});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ratio,
      child: child,
    );
  }
}
