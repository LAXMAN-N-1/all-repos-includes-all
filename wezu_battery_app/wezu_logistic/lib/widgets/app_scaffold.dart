import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A consistent scaffold wrapper that handles safe areas,
/// status bar styling, and optional FAB slot.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.useSafeArea = true,
    this.resizeToAvoidBottomInset = true,
    this.statusBarBrightness,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final bool useSafeArea;
  final bool resizeToAvoidBottomInset;
  final Brightness? statusBarBrightness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overlayFromTheme = theme.appBarTheme.systemOverlayStyle;

    final wantsLightIcons = statusBarBrightness == Brightness.light
        ? true
        : statusBarBrightness == Brightness.dark
        ? false
        : overlayFromTheme?.statusBarIconBrightness == Brightness.light
        ? true
        : overlayFromTheme?.statusBarIconBrightness == Brightness.dark
        ? false
        : theme.brightness == Brightness.dark;

    final overlayStyle = (overlayFromTheme ?? const SystemUiOverlayStyle())
        .copyWith(
          statusBarColor: Colors.transparent,
          // Android clock/icons color
          statusBarIconBrightness: wantsLightIcons
              ? Brightness.light
              : Brightness.dark,
          // iOS clock/icons color (inverse semantics)
          statusBarBrightness: wantsLightIcons
              ? Brightness.dark
              : Brightness.light,
        );

    // Keep system UI in sync on OEM variants where AnnotatedRegion alone is flaky.
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        child: Scaffold(
          appBar: appBar,
          backgroundColor: Colors
              .transparent, // Allow AnimatedContainer color to show through
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          body: _buildBodyWithGradients(context),
        ),
      ),
    );
  }

  Widget _buildBodyWithGradients(BuildContext context) {
    final bgColor =
        backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
    final content = useSafeArea ? SafeArea(child: body) : body;

    return Stack(
      children: [
        // Main content
        content,

        // Top gradient: fades from header background → transparent
        // Always show this to ensure consistent header fade for SliverAppBars too
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 24,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bgColor, bgColor.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
