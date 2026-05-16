import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuraColors {
  // Premium Teal/Emerald Palette
  static const Color primary = Color(0xFF00C9A7); // Vibrant Teal
  static const Color secondary = Color(0xFF845EC2); // Deep Purple
  static const Color background = Color(0xFF0F172A); // Dark Navy
  static const Color surface = Color(0xFF1E293B); // Slate
  
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  
  static const Color success = Color(0xFF00C9A7);
  static const Color warning = Color(0xFFFFC75F);
  static const Color error = Color(0xFFFF9671);
  
  // Glassmorphism
  static Color glassWhite = Colors.white.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.1);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AuraColors.background,
      primaryColor: AuraColors.primary,
      
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: AuraColors.textPrimary,
        displayColor: AuraColors.textPrimary,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AuraColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AuraColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AuraColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AuraColors.primary, width: 2),
        ),
        labelStyle: TextStyle(color: AuraColors.textSecondary),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AuraColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ), colorScheme: ColorScheme.dark(
        primary: AuraColors.primary,
        secondary: AuraColors.secondary,
        surface: AuraColors.surface,
        background: AuraColors.background,
      ),
    );
  }
}
