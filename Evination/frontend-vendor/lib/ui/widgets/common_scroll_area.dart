import 'package:flutter/material.dart';

class CommonScrollArea extends StatelessWidget {
  final Widget child;
  final Axis scrollDirection;

  const CommonScrollArea({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: scrollDirection,
        child: child,
      ),
    );
  }
}
