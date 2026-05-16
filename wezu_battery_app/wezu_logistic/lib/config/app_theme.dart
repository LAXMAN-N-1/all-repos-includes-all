import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Application theme configuration.
/// Defines a cohesive, consistent visual system for every Material widget.
/// Supports both Light and Dark modes.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
  static ThemeData get amoledTheme =>
      _buildTheme(Brightness.dark, amoled: true);

  static ThemeData _buildTheme(Brightness brightness, {bool amoled = false}) {
    final isDark = brightness == Brightness.dark;

    // 1. Generate M3 ColorScheme from seed
    final seedScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );

    // 2. Override for AMOLED if needed
    final colorScheme = amoled
        ? seedScheme.copyWith(
            surface: Colors.black,
            onSurface: Colors.white,
            surfaceContainerLow: const Color(0xFF121212), // Dark grey for cards
            surfaceContainer: const Color(0xFF1E1E1E),
            surfaceContainerHigh: const Color(0xFF2C2C2C),
            surfaceContainerHighest: const Color(0xFF333333),
            scrim: Colors.grey[900], // Lighter scrim for contrast
          )
        : seedScheme;

    final textTheme = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    Color? stateLayer(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.transparent;
      }
      if (states.contains(WidgetState.pressed)) {
        return colorScheme.primary.withValues(alpha: isDark ? 0.16 : 0.12);
      }
      if (states.contains(WidgetState.hovered)) {
        return colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.08);
      }
      if (states.contains(WidgetState.focused)) {
        return colorScheme.primary.withValues(alpha: isDark ? 0.14 : 0.1);
      }
      return Colors.transparent;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: amoled ? Colors.black : colorScheme.surface,
      colorScheme: colorScheme,

      // ─── Typography ────────────────────────────────────────────────
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),

      // ─── App Bar ────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
        backgroundColor: amoled ? Colors.black : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: amoled ? Colors.transparent : colorScheme.surfaceTint,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // ─── Cards ──────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: amoled
            ? const Color(0xFF121212)
            : colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          side: isDark && !amoled
              ? BorderSide(color: colorScheme.outlineVariant)
              : BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),

      // ─── Buttons ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusLg, // 16px for M3
              ),
              textStyle: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              minimumSize: const Size(double.infinity, 52),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith(stateLayer),
              splashFactory: NoSplash.splashFactory,
            ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.outline),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusLg,
              ),
              textStyle: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              minimumSize: const Size(double.infinity, 52),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith(stateLayer),
              splashFactory: NoSplash.splashFactory,
            ),
      ),

      textButtonTheme: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              textStyle: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith(stateLayer),
              splashFactory: NoSplash.splashFactory,
            ),
      ),

      // ─── Input Decoration ──────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            colorScheme.surfaceContainerHighest, // M3 Standard for inputs
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide:
              BorderSide.none, // M3 Filled inputs don't have borders usually
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),

      // ─── Bottom Navigation Bar ─────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ─── Floating Action Button ────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3, // M3 Standard
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg, // 16px
        ),
      ),

      // ─── Chip ──────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.onSurface,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
        overlayColor: WidgetStateProperty.resolveWith(stateLayer),
        splashFactory: NoSplash.splashFactory,
      ),

      // ─── Divider ───────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ─── Snackbar ─────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
      ),

      // ─── Dialog ───────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ─── Loading / Progress ───────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.secondaryContainer,
      ),

      // ─── Interaction ──────────────────────────────────────────────
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      // ─── Page Transitions (Predictive Back) ───────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
