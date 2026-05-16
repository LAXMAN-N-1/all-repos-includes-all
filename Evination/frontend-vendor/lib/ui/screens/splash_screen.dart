import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/widgets/animated_3d_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Animation logic is now self-contained in Animated3DLogo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black, // Pure Black Void (Core Concept: "The Void Awakens")
        child: Center(
          child: Animated3DLogo(
            size: 200, 
            animateStory: true,
            onAnimationComplete: () {
              // Navigate to Login after complete animation sequence (5s + buffer)
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) context.go('/login');
              });
            },
          ),
        ),
      ),
    );
  }
}
