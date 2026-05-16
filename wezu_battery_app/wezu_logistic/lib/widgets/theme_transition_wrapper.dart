import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_animations.dart';
import '../core/theme_provider.dart';

/// A wrapper that enables a circular reveal animation when switching themes.
/// 
/// It works by:
/// 1. Taking a screenshot of the current UI (Old Theme).
/// 2. Switching the theme instantly.
/// 3. Overlaying the Old Theme screenshot.
/// 4. Animating a circular clip (revealing the New Theme) from the touch point.
class ThemeTransitionWrapper extends ConsumerStatefulWidget {
  const ThemeTransitionWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  static ThemeTransitionWrapperState of(BuildContext context) {
    return context.findAncestorStateOfType<ThemeTransitionWrapperState>()!;
  }

  @override
  ConsumerState<ThemeTransitionWrapper> createState() => ThemeTransitionWrapperState();
}

class ThemeTransitionWrapperState extends ConsumerState<ThemeTransitionWrapper> with SingleTickerProviderStateMixin {
  final GlobalKey _repaintKey = GlobalKey();
  
  late AnimationController _controller;
  late Animation<double> _animation;
  
  ui.Image? _oldThemeImage;
  Offset _center = Offset.zero;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100), // Slower, 1100ms
      vsync: this,
    );
    // Use a standard easeInOut curve for smoother continuous transition
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
          _oldThemeImage = null; // Clear memory
        });
      }
    });

    // We no longer call setState on every frame, as CustomPainter handles repainting via the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Triggers the theme change with a circular reveal animation.
  /// [center] is the screen position of the button that triggered the change.
  Future<void> changeTheme(ThemeMode newMode, Offset center) async {
    if (_isAnimating) return;

    // Small delay before capturing to let button ripple start.
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        ref.read(themeModeProvider.notifier).setTheme(newMode);
        return;
      }

      final pixelRatio = MediaQuery.of(context).devicePixelRatio;

      ui.Image? image;
      int retries = 3;
      
      // Attempt to capture the image. If it's animating/needs paint, it might throw, so we retry briefly.
      while (image == null && retries > 0) {
        try {
          image = await boundary.toImage(pixelRatio: pixelRatio);
        } catch (_) {
          await Future.delayed(const Duration(milliseconds: 20));
          retries--;
        }
      }

      if (!mounted) return;

      if (image == null) {
        // Fallback — switch without animation if capture repeatedly fails (e.g., active camera platform view)
        ref.read(themeModeProvider.notifier).setTheme(newMode);
        return;
      }

      setState(() {
        _oldThemeImage = image;
        _center = center;
        _isAnimating = true;
      });

      // Switch Theme (Instant logic, but hidden by old theme overlay)
      ref.read(themeModeProvider.notifier).setTheme(newMode);

      // Start Animation
      _controller.forward(from: 0.0);
    } catch (e) {
      ref.read(themeModeProvider.notifier).setTheme(newMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The actual App (New Theme)
        // We wrap the child in RepaintBoundary to allow screenshotting.
        RepaintBoundary(
          key: _repaintKey,
          child: widget.child,
        ),

        // 2. The Overlay (Old Theme) - Only visible during animation
        if (_isAnimating && _oldThemeImage != null)
          Positioned.fill(
            child: IgnorePointer(
              // Allow interaction with new theme? No, block during transition to clear visual
              child: CustomPaint(
                painter: _ThemeRevealPainter(
                  image: _oldThemeImage!,
                  center: _center,
                  animation: _animation,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ThemeRevealPainter extends CustomPainter {
  final ui.Image image;
  final Offset center;
  final Animation<double> animation;

  _ThemeRevealPainter({
    required this.image,
    required this.center,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    
    // Determine max radius (distance from center to furthest corner)
    final double maxRadius = _distanceToFurthestCorner(center, size);
    final double currentRadius = maxRadius * animation.value;

    // We use evenOdd fill type to create a "hole" (the circle) within the full screen rect.
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: currentRadius))
      ..fillType = PathFillType.evenOdd;

    canvas.save();
    canvas.clipPath(path);
    
    // Draw the image to fit the screen
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, Paint());
    
    canvas.restore();
  }

  double _distanceToFurthestCorner(Offset point, Size size) {
    double distance(double x1, double y1, double x2, double y2) {
      return (Offset(x1, y1) - Offset(x2, y2)).distance;
    }
    final d1 = distance(point.dx, point.dy, 0, 0);
    final d2 = distance(point.dx, point.dy, size.width, 0);
    final d3 = distance(point.dx, point.dy, 0, size.height);
    final d4 = distance(point.dx, point.dy, size.width, size.height);
    
    return [d1, d2, d3, d4].reduce((a, b) => a > b ? a : b);
  }

  @override
  bool shouldRepaint(_ThemeRevealPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.image != image || oldDelegate.center != center;
  }
}
