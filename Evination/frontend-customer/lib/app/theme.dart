import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.crimsonSilk,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.crimsonSilk,
        primary: AppColors.crimsonSilk,
        secondary: AppColors.rubyRed,
        surface: AppColors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: AppSizes.fontSize4XL,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlack,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: AppSizes.fontSize2XL,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlack,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: AppSizes.fontSizeMD,
          color: AppColors.primaryBlack,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimsonSilk,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeightMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: AppSizes.fontSizeMD,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.greyLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.crimsonSilk, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppSizes.spacing16),
      ),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepBordeaux,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.crimsonSilk,
        primary: AppColors.crimsonSilk,
        secondary: AppColors.rubyRed,
        surface: AppColors.surfaceDark,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: AppColors.softBlush,
        displayColor: AppColors.softBlush,
      ),
    );
  }
}
