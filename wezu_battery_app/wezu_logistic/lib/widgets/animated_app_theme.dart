import 'package:flutter/material.dart';
import '../../config/app_animations.dart';

/// A wrapper that provides smooth theme transitions for its child.
/// It implicitly animates Theme.of(context) changes.
class AnimatedAppTheme extends StatelessWidget {
  const AnimatedAppTheme({
    super.key,
    required this.child,
    required this.data,
  });

  final Widget child;
  final ThemeData data;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: data,
      child: child,
    );
  }
}
