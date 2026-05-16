import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Purple Elegance Palette
  static const Color primary50 = Color(0xFFFAF5FF);
  static const Color primary100 = Color(0xFFF3E8FF);
  static const Color primary200 = Color(0xFFE9D5FF);
  static const Color primary300 = Color(0xFFD8B4FE);
  static const Color primary400 = Color(0xFFC084FC);
  static const Color primary500 = Color(0xFFA855F7); // Main Primary
  static const Color primary600 = Color(0xFF9333EA);
  static const Color primary700 = Color(0xFF7E22CE);
  static const Color primary800 = Color(0xFF6B21A8);
  static const Color primary900 = Color(0xFF581C87);

  static const Color accentYellow = Color(0xFFFDB913); // Your Brand Yellow
  static const Color accentYellowDark = Color(0xFFE5A711);
  static const Color primaryGold = accentYellow; // Legacy alias

  static const Color bgPrimary = Color(0xFFFAF5FF); // Light Purple Tint
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgCard = Color(0xFFFFFFFF); // Using pure white for contrast

  static const Color textPrimary = Color(0xFF1E1B4B); // Dark Navy/Purple
  static const Color textSecondary = Color(0xFF4C1D95);
  static const Color textLight = Color(0xFFA78BFA);
  
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF43F5E);
  static const Color info = Color(0xFF6366F1);

  static const Color sidebarDark = Color(0xFF1E1B4B);
  
  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFFA855F7).withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Legacy/Common Styles
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: bgCard,
    borderRadius: BorderRadius.circular(16),
    boxShadow: cardShadow,
    border: Border.all(color: primary200),
  );

  static TextStyle get heading => GoogleFonts.outfit(
    fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary
  );

  static TextStyle get subHeading => GoogleFonts.inter(
    fontSize: 14, color: textSecondary.withOpacity(0.8)
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary500,
      scaffoldBackgroundColor: bgPrimary,
      cardColor: bgCard,
      dividerColor: primary200, // Light purple divider
      
      colorScheme: const ColorScheme.light(
        primary: primary500,
        onPrimary: Colors.white,
        secondary: accentYellow,
        onSecondary: Colors.black,
        surface: bgCard,
        onSurface: textPrimary,
        error: error,
        onError: Colors.white,
        outline: primary200,
      ),

      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ).copyWith(
        titleLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE9D5FF), width: 1), // primary200
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: bgCard,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        shape: Border(bottom: BorderSide(color: primary100, width: 1)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textLight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary500, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 2,
          shadowColor: primary500.withOpacity(0.4),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary700,
          side: const BorderSide(color: primary200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: primary600,
        size: 22,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme; 
}
