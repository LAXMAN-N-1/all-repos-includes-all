import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // ── Convenience Proxies ──────────────────────────────────────
  static const Color primaryBlue = AppColors.primary;
  static const Color accentOrange = AppColors.accent;
  static const Color accentGreen = AppColors.success;
  static const Color accentGold = AppColors.accentGold;
  static const Color surfaceDark = AppColors.dark;
  static const Color backgroundDark = AppColors.darkDeep;
  static const Color textMain = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textWhite = AppColors.textWhite;

  // ── Standardized Radii ───────────────────────────────────────
  static const double radiusXL = 28;   // Cards, containers
  static const double radiusLG = 20;   // Inputs, large buttons
  static const double radiusMD = 16;   // Buttons, small cards
  static const double radiusSM = 12;   // Badges, chips
  static const double radiusXS = 8;    // Tiny elements

  // ── Standardized Spacing ─────────────────────────────────────
  static const double spacingXS = 4;
  static const double spacingSM = 8;
  static const double spacingMD = 16;
  static const double spacingLG = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;

  // ── Content Padding ──────────────────────────────────────────
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);

  // ── Map Style ────────────────────────────────────────────────
  static const String mapStyleDark = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#0A1628"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#0A1628"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#111827"}]
  }
]
''';

  // ── Shadow System ────────────────────────────────────────────
  static List<BoxShadow> shadowLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowHeavy = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowBlue = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.15),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowAccent = [
    BoxShadow(
      color: AppColors.accent.withValues(alpha: 0.15),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Typography Helpers ───────────────────────────────────────
  static TextStyle displayLarge({Color? color}) => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: color,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: -0.3,
  );

  static TextStyle displaySmall({Color? color}) => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.outfit(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.5,
  );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.4,
  );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle labelLarge({Color? color}) => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.5,
  );

  // ── Light Theme ──────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,

      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32, fontWeight: FontWeight.w800,
          color: AppColors.textPrimary, letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 24, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 17, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, color: AppColors.textPrimary, height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: AppColors.textSecondary, height: 1.4,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, color: AppColors.textTertiary,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: AppColors.textTertiary, letterSpacing: 0.5,
        ),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 17, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXL)),
        color: Colors.white,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 15),
        labelStyle: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMD)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMD)),
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXL)),
        backgroundColor: AppColors.surface,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.dark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSM)),
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.border.withValues(alpha: 0.3),
        thickness: 0.5,
      ),
    );
  }

  // ── Dark Theme ───────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryDark,
        secondary: AppColors.accent,
        surface: AppColors.surfaceDark,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkDeep,

      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32, fontWeight: FontWeight.w800,
          color: Colors.white, letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 24, fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 17, fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, color: Colors.white, height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: Colors.white70, height: 1.4,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, color: Colors.white54,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: Colors.white54, letterSpacing: 0.5,
        ),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 22),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXL)),
        color: Colors.white.withValues(alpha: 0.1),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassDarkStrong,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 15),
        labelStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLG)),
          textStyle: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMD)),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXL)),
        backgroundColor: AppColors.surfaceDark,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSM)),
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      ),

      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 0.5,
      ),
    );
  }

  // ── Helper: Input Decoration ─────────────────────────────────
  static InputDecoration inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark
          ? AppColors.glassDarkStrong
          : Colors.white.withValues(alpha: 0.8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLG),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : AppColors.border.withValues(alpha: 0.6),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLG),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLG),
        borderSide: BorderSide(
          color: isDark ? AppColors.primaryDark : AppColors.primary,
          width: 1.5,
        ),
      ),
      hintStyle: GoogleFonts.inter(
        color: isDark ? Colors.white30 : AppColors.textHint,
        fontSize: 15,
      ),
    );
  }

  // ── Helper: Glass Decoration ─────────────────────────────────
  static BoxDecoration glassDecoration(bool isDark, {
    double radius = radiusXL,
    double borderWidth = 0.5,
  }) {
    return BoxDecoration(
      color: isDark ? AppColors.glassDarkStrong : AppColors.glassWhiteStrong,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ── Helper: Section Title Style ──────────────────────────────
  static TextStyle sectionTitle(bool isDark) => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: isDark ? Colors.white : AppColors.textPrimary,
  );

  // ── Helper: Section Subtitle Style ───────────────────────────  
  static TextStyle sectionSubtitle(bool isDark) => GoogleFonts.inter(
    fontSize: 14,
    color: isDark ? Colors.white54 : AppColors.textTertiary,
  );
}
