import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system using Google Fonts Inter for body and Outfit for display.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.outfit(fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -1.5),
        displayMedium: GoogleFonts.outfit(fontSize: 45, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        displaySmall: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
        titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.25),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.5),
      );
}
