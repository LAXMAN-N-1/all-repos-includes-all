import 'package:flutter/material.dart';

/// WEZU "Electric Grid" Color System
/// Three-layer depth model with electric green primary accent
class AppColors {
  // ── Background Layers (3-layer depth) ─────────────────
  static const Color pageBg        = Color(0xFF0A0E17);  // Deepest — page background
  static const Color shellBg       = Color(0xFF0F1218);  // Sidebar, topbar
  static const Color cardBg        = Color(0xFF1A1F2E);  // Cards, panels, raised surfaces
  static const Color cardBgHover   = Color(0xFF1E2438);  // Card hover state
  static const Color inputBg       = Color(0xFF1A1F2E);  // Input fields

  // ── Borders ───────────────────────────────────────────
  static const Color border        = Color(0xFF2A3040);  // Standard border
  static const Color borderLight   = Color(0xFF1E2535);  // Subtle border (topbar)
  static const Color borderFocus   = Color(0xFF10B981);  // Focus ring

  // ── Primary Accent — Electric Green ───────────────────
  static const Color primary       = Color(0xFF10B981);
  static const Color primaryHover  = Color(0xFF34D399);
  static const Color primaryMuted  = Color(0xFF064E3B);  // Dark green for badges
  static const Color primaryGlow   = Color(0x1F10B981);  // 12% opacity glow

  // ── Secondary Accents ─────────────────────────────────
  static const Color cyan          = Color(0xFF06B6D4);  // Rentals, secondary data
  static const Color cyanMuted     = Color(0xFF0C1A3A);  // Info badge bg
  static const Color amber         = Color(0xFFF59E0B);  // Revenue, financial
  static const Color amberMuted    = Color(0xFF451A03);  // Warning badge bg
  static const Color red           = Color(0xFFEF4444);  // Critical, errors
  static const Color redMuted      = Color(0xFF450A0A);  // Error badge bg
  static const Color purple        = Color(0xFF8B5CF6);  // Campaigns, promotions
  static const Color purpleMuted   = Color(0xFF1E1145);  // Purple badge bg

  // ── Text Hierarchy ────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF1F5F9);  // Headings, values
  static const Color textSecondary = Color(0xFF94A3B8);  // Body, description
  static const Color textTertiary  = Color(0xFF64748B);  // Labels, timestamps
  static const Color textMuted     = Color(0xFF475569);  // Disabled, placeholders

  // ── Status Colors (for badges) ────────────────────────
  static const Color successText   = Color(0xFF6EE7B7);
  static const Color warningText   = Color(0xFFFCD34D);
  static const Color errorText     = Color(0xFFFCA5A5);
  static const Color infoText      = Color(0xFF93C5FD);

  // ── Legacy Aliases (backward compatibility) ───────────
  static const Color backgroundDark         = pageBg;
  static const Color backgroundLight        = Color(0xFFF5F5F7);
  static const Color surfaceDark            = cardBg;
  static const Color surfaceLight           = Color(0xFFFFFFFF);
  static const Color borderDark             = border;
  static const Color borderLight2           = Color(0xFFE4E4E7);
  static const Color textHighEmphasisDark   = textPrimary;
  static const Color textMediumEmphasisDark = textSecondary;
  static const Color textLowEmphasisDark    = textTertiary;
  static const Color textHighEmphasisLight  = Color(0xFF0F0F12);
  static const Color textMediumEmphasisLight  = Color(0xFF52525B);
  static const Color textLowEmphasisLight   = Color(0xFFA1A1AA);
  static const Color accent                 = cyan;
  static const Color primaryDark            = Color(0xFF059669);
  static const Color success                = primary;
  static const Color warning                = amber;
  static const Color error                  = red;
  static const Color info                   = cyan;
}
