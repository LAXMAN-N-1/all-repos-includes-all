import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class IconUtils {
  static IconData fromString(String name) {
    switch (name.toLowerCase()) {
      case 'crown':
        return LucideIcons.crown;
      case 'person':
        return LucideIcons.user;
      case 'usercog':
        return LucideIcons.userCog;
      case 'shield':
        return LucideIcons.shield;
      case 'location':
        return LucideIcons.mapPin;
      case 'headset':
        return LucideIcons.headphones;
      case 'eye':
        return LucideIcons.eye;
      case 'wrench':
        return LucideIcons.wrench;
      case 'chart':
        return LucideIcons.barChart2;
      case 'document':
        return LucideIcons.fileText;
      case 'lock':
        return LucideIcons.lock;
      case 'star':
        return LucideIcons.star;
      case 'key':
        return LucideIcons.key;
      default:
        return LucideIcons.circleDashed;
    }
  }

  static LinearGradient gradientFromHex(
    String hex, {
    bool isSuperAdmin = false,
  }) {
    if (isSuperAdmin) {
      return const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFFF9800)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    Color baseColor = _hexToColor(hex);
    return LinearGradient(
      colors: [baseColor, baseColor.withValues(alpha: 0.6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Color _hexToColor(String code) {
    String formattedCode = code.replaceAll('#', '');
    if (formattedCode.length == 6) {
      formattedCode = 'FF$formattedCode';
    }
    try {
      return Color(int.parse(formattedCode, radix: 16));
    } catch (e) {
      return const Color(0xFF8B8D97);
    }
  }
}
