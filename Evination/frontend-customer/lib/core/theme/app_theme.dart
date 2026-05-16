import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.sunflowerYellow,
      scaffoldBackgroundColor: AppColors.white,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.outfit().fontFamily,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.sunflowerYellow,
        secondary: AppColors.goldenAmber,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkCharcoal,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: AppColors.darkCharcoal,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkCharcoal,
        ),
        displaySmall: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.darkCharcoal,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkCharcoal,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: AppColors.greyDark,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: AppColors.greyMedium,
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkCharcoal),
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.darkCharcoal,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sunflowerYellow,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.greyLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sunflowerYellow, width: 2),
        ),
        hintStyle: GoogleFonts.outfit(color: AppColors.greyMedium),
      ),
    );
  }

  // Keep backward compatibility
  static ThemeData get darkTheme => lightTheme;
}
