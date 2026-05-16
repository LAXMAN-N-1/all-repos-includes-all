import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New Nature's Premium Palette
  static const Color mintWhisper = Color(0xFFD1F2EB);   // Light Background / Cards
  static const Color emeraldGreen = Color(0xFF50C878);  // Primary Action / Success
  static const Color royalAmethyst = Color(0xFF0B6E4F); // Secondary / Deep Accent (Dark Cyan/Green)
  static const Color darkEvergreen = Color(0xFF013220); // Dark Surface / Readings / Sidebar
  
  // Mapped Semantic Colors
  static const Color primaryColor = emeraldGreen;
  static const Color secondaryColor = royalAmethyst;
  static const Color accentColor = mintWhisper;
  
  static const Color success = emeraldGreen;
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Legacy Golden Theme Aliases (for backward compatibility)
  static const Color primaryGold = emeraldGreen;
  static const Color darkGold = darkEvergreen;
  static const Color lightGold = mintWhisper;
  static const Color bgCard = Colors.white;
  static const Color backgroundTint = mintWhisper;
  static const Color textPrimary = darkEvergreen;
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray500 = Color(0xFF6B7280);
  
  // Legacy Primary Swatches
  static const Color primary200 = mintWhisper;
  static const Color primary500 = emeraldGreen;
  static const Color primary600 = royalAmethyst;
  static const Color primary700 = darkEvergreen;

  // Neutral Colors (adapted for dark green theme contrast)
  static const Color gray900 = darkEvergreen; // Text Headings
  static const Color gray700 = Color(0xFF1F4D36); // Body Text (Darker Green-Gray)
  static const Color gray600 = Color(0xFF4B7763);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray100 = mintWhisper; // Lightest Mint for backgrounds
  
  // UI Specific
  static const Color sidebarColor = darkEvergreen;
  static const Color cardColor = Colors.white;
  static const Color scaffoldBg = Color(0xFFF0FDF9); // Very light mint/white mix for main bg, softer than pure mint

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: darkEvergreen.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(20), // More rounded for modern look
    boxShadow: cardShadow,
    border: Border.all(color: mintWhisper), // Mint border
  );

  static TextStyle get heading => GoogleFonts.outfit(
    fontSize: 24, fontWeight: FontWeight.bold, color: darkEvergreen
  );

  static TextStyle get subHeading => GoogleFonts.inter(
    fontSize: 14, color: gray600
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: emeraldGreen,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: cardColor,
      dividerColor: mintWhisper,
      
      colorScheme: const ColorScheme.light(
        primary: emeraldGreen,
        secondary: royalAmethyst,
        surface: cardColor,
        onSurface: darkEvergreen,
        error: error,
        outline: mintWhisper,
        background: scaffoldBg,
      ),

      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: gray700,
        displayColor: darkEvergreen,
      ).copyWith(
        titleLarge: GoogleFonts.outfit(
          color: darkEvergreen,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: darkEvergreen,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: mintWhisper, width: 1.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: darkEvergreen),
        titleTextStyle: TextStyle(color: darkEvergreen, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        shape: Border(bottom: BorderSide(color: mintWhisper, width: 1)),
        centerTitle: false,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hoverColor: mintWhisper.withOpacity(0.2),
        labelStyle: const TextStyle(color: gray600),
        hintStyle: TextStyle(color: gray400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: mintWhisper),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: mintWhisper), // Subtle mint border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: emeraldGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          elevation: 4,
          shadowColor: emeraldGreen.withOpacity(0.4),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkEvergreen,
          side: const BorderSide(color: emeraldGreen, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: royalAmethyst,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: royalAmethyst,
        size: 24,
      ),

      dividerTheme: const DividerThemeData(
        color: mintWhisper,
        thickness: 1.5,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: mintWhisper,
        labelStyle: TextStyle(color: darkEvergreen, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme; 
}
