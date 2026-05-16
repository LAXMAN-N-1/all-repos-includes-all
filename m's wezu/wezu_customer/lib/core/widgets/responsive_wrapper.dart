import 'package:flutter/material.dart';

/// A wrapper widget that constrains content to a maximum width and
/// centers it horizontally. Use this around form-heavy or content-focused
/// screens to prevent them from stretching across huge desktop/web viewports.
///
/// On mobile, content fills the full width (maxWidth defaults to infinity).
///
/// Example usage:
/// ```dart
/// ResponsiveWrapper(
///   maxWidth: 520,
///   child: MyFormContent(),
/// )
/// ```
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
