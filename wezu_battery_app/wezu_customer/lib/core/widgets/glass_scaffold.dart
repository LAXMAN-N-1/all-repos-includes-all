import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Wrapper scaffold providing the consistent Apple-style mesh gradient 
/// background with decorative ambient orbs across all screens.
class GlassScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.extendBodyBehindAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkBgGradient : AppColors.lightBgGradient,
        ),
        child: Stack(
          children: [
            // Ambient mesh orbs
            Positioned(
              top: -screenHeight * 0.08,
              right: -screenWidth * 0.15,
              child: _MeshOrb(
                size: screenWidth * 0.55,
                color: (isDark ? AppColors.meshBlue : AppColors.meshBlue)
                    .withValues(alpha: isDark ? 0.08 : 0.06),
              ),
            ),
            Positioned(
              top: screenHeight * 0.35,
              left: -screenWidth * 0.2,
              child: _MeshOrb(
                size: screenWidth * 0.6,
                color: (isDark ? AppColors.meshPurple : AppColors.meshPurple)
                    .withValues(alpha: isDark ? 0.06 : 0.04),
              ),
            ),
            Positioned(
              bottom: -screenHeight * 0.05,
              right: -screenWidth * 0.1,
              child: _MeshOrb(
                size: screenWidth * 0.5,
                color: (isDark ? AppColors.meshTeal : AppColors.meshPink)
                    .withValues(alpha: isDark ? 0.05 : 0.03),
              ),
            ),
            // Actual body
            body,
          ],
        ),
      ),
    );
  }
}

/// Decorative ambient gradient orb for mesh background.
class _MeshOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _MeshOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 120,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }
}
