import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';

class AuraLogo extends StatelessWidget {
  final double size;
  final bool animate;

  const AuraLogo({Key? key, this.size = 100, this.animate = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AuraColors.primary, AuraColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AuraColors.primary.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.local_pharmacy_rounded,
            size: size * 0.6,
            color: Colors.white,
          ),
        ).animate(target: animate ? 1 : 0)
         .scale(duration: 600.ms, curve: Curves.easeOutBack)
         .shimmer(delay: 400.ms, color: Colors.white.withOpacity(0.5)),

        SizedBox(height: 16),

        // Text
        Flexible(
          child: Text(
            "AuraMed",
            style: GoogleFonts.outfit(
              fontSize: size * 0.35, // Slightly reduced font size
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ).animate(target: animate ? 1 : 0)
         .fadeIn(delay: 200.ms, duration: 600.ms)
         .moveY(begin: 10, end: 0),
      ],
    );
  }
}
