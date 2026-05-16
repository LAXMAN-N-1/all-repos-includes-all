import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors (White + Yellow Palette)
  static const Color primaryDark = Color(0xFFFFFFFF); // Changed to white for light theme
  static const Color warmWhite = Color(0xFFFAFAFA);
  static const Color sunflowerYellow = Color(0xFFFDB913); // Brighter, richer yellow
  static const Color goldenAmber = Color(0xFFE8960C);
  static const Color darkCharcoal = Color(0xFF2D2D2D); // Keep for text only
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyLight = Color(0xFFF8F9FA); // Softer light grey
  static const Color greyMedium = Color(0xFF9CA3AF);
  static const Color greyDark = Color(0xFF4B5563);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  // Functional Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color emerald = Color(0xFF10B981);

  // Brand Gradients
  static const LinearGradient luxuryGradient = LinearGradient(
    colors: [sunflowerYellow, goldenAmber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFFFDF7), Color(0xFFFFF8E7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x0D000000),
      Color(0x05000000),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy aliases for backward compatibility
  static const Color primaryBlack = primaryDark;
  static const Color deepBordeaux = warmWhite;
  static const Color crimsonSilk = sunflowerYellow;
  static const Color rubyRed = goldenAmber;
  static const Color softBlush = darkCharcoal;
  static const Color surfaceDark = surfaceLight;

  static const LinearGradient bordeauxGradient = heroGradient;
}
