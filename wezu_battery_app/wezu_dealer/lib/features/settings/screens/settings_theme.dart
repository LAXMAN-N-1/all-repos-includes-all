import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsTheme {
  static const Color backgroundDark = Color(0xFF0A0E17);
  static const Color shellDark = Color(0xFF0F1218);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color primaryCyan = Color(0xFF06B6D4);
  static const Color secondaryAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color surfaceDark = Color(0xFF1A1F2E);
  static const Color borderSubtle = Color(0xFF2A3040);
  static const Color mutedGray = Color(0xFF94A3B8);
  static const Color textHigh = Color(0xFFF1F5F9);

  // Glow Helpers (Derived from original brand colors)
  static Color glow(Color base) => base.withValues(alpha: 0.15);
  static Color softGlow(Color base) => base.withValues(alpha: 0.08);

  static final TextStyle h1 = GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: textHigh, letterSpacing: -0.5);

  static final TextStyle h2 = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textHigh);
  static final TextStyle h3 = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textHigh);
  static final TextStyle body = GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textHigh, height: 1.5);
  static final TextStyle label = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: mutedGray, letterSpacing: 0.5);
  static final TextStyle subline = GoogleFonts.inter(fontSize: 11, color: mutedGray);
  static final TextStyle mono = GoogleFonts.jetBrainsMono(fontSize: 12, color: primaryCyan);

  static InputDecoration inputDecoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: subline.copyWith(fontSize: 13),
    prefixIcon: Icon(icon, size: 18, color: primaryGreen.withValues(alpha: 0.7)),
    filled: true,
    fillColor: shellDark,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderSubtle)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderSubtle)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen, width: 2)),
  );
}
