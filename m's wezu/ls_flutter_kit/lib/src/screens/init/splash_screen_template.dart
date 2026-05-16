import 'package:flutter/material.dart';

/// Reusable Future-based splash screen.
/// Runs an initialization future (e.g. auth check, data preload) and then
/// automatically navigates to the next route based on the result.
class SplashScreenTemplate<T> extends StatefulWidget {
  final Future<T> Function() initializeFuture;
  final void Function(BuildContext context, T result) onInitializationComplete;
  final Widget centerWidget;
  final Color? backgroundColor;
  final Widget? loaderWidget;

  const SplashScreenTemplate({
    super.key,
    required this.initializeFuture,
    required this.onInitializationComplete,
    required this.centerWidget,
    this.backgroundColor,
    this.loaderWidget,
  });

  @override
  State<SplashScreenTemplate> createState() => _SplashScreenTemplateState();
}

class _SplashScreenTemplateState<T> extends State<SplashScreenTemplate<T>> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
    _startInit();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startInit() async {
    // Ensure splash is visible for at least the animation duration
    final results = await Future.wait([
      widget.initializeFuture(),
      Future.delayed(const Duration(milliseconds: 1500)),
    ]);
    if (mounted) {
      widget.onInitializationComplete(context, results[0] as T);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.centerWidget,
                const SizedBox(height: 48),
                widget.loaderWidget ?? const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
